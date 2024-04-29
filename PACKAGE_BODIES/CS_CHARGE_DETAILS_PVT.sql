--------------------------------------------------------
--  DDL for Package Body CS_CHARGE_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CHARGE_DETAILS_PVT" AS
/* $Header: csxvestb.pls 120.61.12010000.13 2010/04/14 08:05:21 rgandhi ship $ */

--==========================================================
-- Global Variables Decalaration
--==========================================================

RECORD_LOCK_EXCEPTION EXCEPTION ;
PRAGMA EXCEPTION_INIT(RECORD_LOCK_EXCEPTION,-0054);


-- Structure Definitions
TYPE REC_UOM IS RECORD
 (
   Unit_of_Measure NUMBER
 );

TYPE TBL_UOM IS TABLE OF REC_UOM INDEX BY BINARY_INTEGER ;


--===========================================================
-- Declaration of  Procedures and functions
--===========================================================
PROCEDURE VALIDATE_CHARGE_DETAILS(
                 P_API_NAME                  IN            VARCHAR2,
                 P_CHARGES_DETAIL_REC        IN            CS_Charge_Details_PUB.Charges_Rec_Type,
                 P_VALIDATION_MODE           IN            VARCHAR2,
                 P_USER_ID                   IN            NUMBER,
                 P_LOGIN_ID                  IN            NUMBER,
                 X_CHARGES_DETAIL_REC        OUT NOCOPY    CS_Charge_Details_PUB.Charges_Rec_Type,
                 X_MSG_DATA                  OUT NOCOPY    VARCHAR2,
                 X_MSG_COUNT                 OUT NOCOPY    NUMBER,
                 X_RETURN_STATUS             OUT NOCOPY    VARCHAR2);


PROCEDURE ADD_INVALID_ARGUMENT_MSG(
                 P_TOKEN_AN	  VARCHAR2,
                 P_TOKEN_V	  VARCHAR2,
                 P_TOKEN_P	  VARCHAR2);

PROCEDURE ADD_NULL_PARAMETER_MSG(
                 P_TOKEN_AN   IN  VARCHAR2,
                 P_TOKEN_NP   IN  VARCHAR2);

PROCEDURE CANT_UPDATE_DETAIL_PARAM_MSG(
                 P_TOKEN_AN            IN      VARCHAR2,
                 P_TOKEN_CN            IN      VARCHAR2,
                 P_TOKEN_V             IN      VARCHAR2 );

PROCEDURE CANNOT_DELETE_LINE_MSG(
                 P_TOKEN_AN    IN      VARCHAR2);

PROCEDURE RECORD_IS_LOCKED_MSG(
                 P_TOKEN_AN     IN  VARCHAR2);


PROCEDURE GET_SITE_FOR_PARTY(
                 P_API_NAME          IN         VARCHAR2,
                 P_SITE_USE_ID       IN         NUMBER,
                 P_PARTY_ID          IN         NUMBER,
                 P_VAL_MODE          IN         VARCHAR2,
                 X_SITE_ID           OUT NOCOPY NUMBER,
                 X_RETURN_STATUS     OUT NOCOPY VARCHAR2);

PROCEDURE GET_SR_DEFAULTS(
                 P_API_NAME               IN          VARCHAR2,
                 P_INCIDENT_ID            IN          NUMBER,
                 X_BUSINESS_PROCESS_ID    OUT NOCOPY  NUMBER,
                 X_CUSTOMER_ID            OUT NOCOPY  NUMBER,
                 X_CUSTOMER_SITE_ID       OUT NOCOPY  NUMBER,
                 X_CUST_PO_NUMBER         OUT NOCOPY  VARCHAR2,
                 X_CUSTOMER_PRODUCT_ID    OUT NOCOPY  NUMBER,
                 X_SYSTEM_ID              OUT NOCOPY  NUMBER,
                 X_INVENTORY_ITEM_ID      OUT NOCOPY  NUMBER,
                 X_ACCOUNT_ID             OUT NOCOPY  NUMBER,
                 X_BILL_TO_PARTY_ID       OUT NOCOPY  NUMBER,
                 X_BILL_TO_ACCOUNT_ID     OUT NOCOPY  NUMBER,
                 X_BILL_TO_CONTACT_ID     OUT NOCOPY  NUMBER,
                 X_BILL_TO_SITE_ID        OUT NOCOPY  NUMBER,
                 X_SHIP_TO_PARTY_ID       OUT NOCOPY  NUMBER,
                 X_SHIP_TO_ACCOUNT_ID     OUT NOCOPY  NUMBER,
                 X_SHIP_TO_CONTACT_ID     OUT NOCOPY  NUMBER,
                 X_SHIP_TO_SITE_ID        OUT NOCOPY  NUMBER,
                 X_CONTRACT_ID            OUT NOCOPY  NUMBER,
                 X_CONTRACT_SERVICE_ID    OUT NOCOPY  NUMBER,
                 X_INCIDENT_DATE          OUT NOCOPY  DATE,
                 X_CREATION_DATE          OUT NOCOPY  DATE,
                 X_MSG_DATA               OUT NOCOPY  VARCHAR2,
                 X_MSG_COUNT              OUT NOCOPY  NUMBER,
                 X_RETURN_STATUS          OUT NOCOPY  VARCHAR2);

PROCEDURE VALIDATE_TXN_TYPE(
                 P_API_NAME                  IN         VARCHAR2,
                 P_BUSINESS_PROCESS_ID       IN         NUMBER,
                 P_TXN_TYPE_ID               IN         NUMBER,
                 P_SOURCE_CODE               IN         VARCHAR2,
                 X_LINE_ORDER_CATEGORY_CODE  OUT NOCOPY VARCHAR2,
                 X_NO_CHARGE_FLAG            OUT NOCOPY VARCHAR2,
                 X_INTERFACE_TO_OE_FLAG      OUT NOCOPY VARCHAR2, -- Added a new parameter for R11.5.10
                 X_UPDATE_IB_FLAG            OUT NOCOPY VARCHAR2,
                 X_SRC_REFERENCE_REQD_FLAG   OUT NOCOPY VARCHAR2,
                 X_SRC_RETURN_REQD_FLAG      OUT NOCOPY VARCHAR2,
                 X_NON_SRC_REFERENCE_REQD    OUT NOCOPY VARCHAR2,
                 X_NON_SRC_RETURN_REQD       OUT NOCOPY VARCHAR2,
                 X_MSG_DATA                  OUT NOCOPY  VARCHAR2,
                 X_MSG_COUNT                 OUT NOCOPY  NUMBER,
                 X_RETURN_STATUS             OUT NOCOPY VARCHAR2);

PROCEDURE VALIDATE_ITEM(
                 P_API_NAME             IN         VARCHAR2,
                 P_INV_ID               IN         NUMBER,
                 P_UPDATE_IB_FLAG       IN         VARCHAR2,
                 X_COMMS_TRACKABLE_FLAG OUT NOCOPY VARCHAR2,
                 X_SERIAL_CONTROL_FLAG  OUT NOCOPY VARCHAR2,
                 X_REV_CONTROL_FLAG     OUT NOCOPY VARCHAR2,
                 X_MSG_DATA             OUT NOCOPY  VARCHAR2,
                 X_MSG_COUNT            OUT NOCOPY  NUMBER,
                 X_RETURN_STATUS        OUT NOCOPY VARCHAR2);

PROCEDURE GET_BILLING_FLAG(
                 P_API_NAME            IN         VARCHAR2,
                 P_INV_ID              IN         NUMBER,
                 P_TXN_TYPE_ID         IN         NUMBER,
                 X_BILLING_FLAG        OUT NOCOPY VARCHAR2,
                 X_MSG_DATA            OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT           OUT NOCOPY NUMBER,
                 X_RETURN_STATUS       OUT NOCOPY VARCHAR2);

PROCEDURE GET_TXN_BILLING_TYPE(
                 P_API_NAME            IN         VARCHAR2,
                 P_INV_ID              IN         NUMBER,
                 P_TXN_TYPE_ID         IN         NUMBER,
                 X_TXN_BILLING_TYPE_ID OUT NOCOPY NUMBER,
                 X_MSG_DATA            OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT           OUT NOCOPY NUMBER,
                 X_RETURN_STATUS       OUT NOCOPY VARCHAR2);

PROCEDURE GET_UOM(
                 P_INV_ID            IN NUMBER,
                 X_TBL_UOM           OUT NOCOPY TBL_UOM,
                 X_MSG_DATA          OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT         OUT NOCOPY NUMBER,
                 X_RETURN_STATUS     OUT NOCOPY VARCHAR2);


PROCEDURE GET_PRIMARY_UOM(
                 P_INV_ID            IN NUMBER,
                 X_PRIMARY_UOM       OUT NOCOPY VARCHAR2,
                 X_MSG_DATA          OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT         OUT NOCOPY NUMBER,
                 X_RETURN_STATUS     OUT NOCOPY VARCHAR2) ;


PROCEDURE VALIDATE_SOURCE(
                 P_API_NAME          IN         VARCHAR2,
                 P_SOURCE_CODE       IN         VARCHAR2,
                 P_SOURCE_ID         IN         NUMBER,
                 P_ORG_ID            IN         NUMBER,
                 X_SOURCE_ID         OUT NOCOPY NUMBER,
                 X_MSG_DATA          OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT         OUT NOCOPY NUMBER,
                 X_RETURN_STATUS     OUT NOCOPY VARCHAR2) ;

PROCEDURE GET_CONTRACT_PRICE_LIST(
                 p_api_name               IN         VARCHAR2,
                 p_business_process_id    IN         NUMBER,
                 p_request_date           IN         DATE,
                 p_contract_line_id       IN         NUMBER,
                 --p_coverage_id            IN         NUMBER,
                 x_price_list_id          OUT NOCOPY NUMBER,
                 x_currency_code          OUT NOCOPY VARCHAR2,
                 X_MSG_DATA               OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT              OUT NOCOPY NUMBER,
                 x_return_status          OUT NOCOPY VARCHAR2);

PROCEDURE  GET_CURRENCY_CODE(
                 p_api_name        IN         VARCHAR2,
                 p_price_list_id   IN         NUMBER ,
                 x_currency_code   OUT NOCOPY VARCHAR2,
                 X_MSG_DATA        OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT       OUT NOCOPY NUMBER,
                 x_return_status   OUT NOCOPY VARCHAR2);

PROCEDURE DO_TXNS_EXIST(
                 P_API_NAME            IN          VARCHAR2,
                 P_ESTIMATE_DETAIL_ID  IN          NUMBER ,
                 x_ORDER_LINE_ID       OUT NOCOPY  NUMBER,
                 x_gen_bca_flag        OUT NOCOPY  VARCHAR2,
                 x_charge_line_type    OUT NOCOPY  VARCHAR2,
                 x_RETURN_STATUS       OUT NOCOPY  VARCHAR2);

PROCEDURE  GET_CONVERSION_RATE(
                 P_API_NAME       IN         VARCHAR2,
                 P_FROM_CURRENCY  IN         VARCHAR2,
                 P_TO_CURRENCY    IN         VARCHAR2,
                 X_DENOMINATOR    OUT NOCOPY NUMBER,
                 X_NUMERATOR      OUT NOCOPY NUMBER,
                 X_RATE           OUT NOCOPY NUMBER,
                 X_RETURN_STATUS  OUT NOCOPY VARCHAR);


PROCEDURE Validate_Who_Info(
                 P_API_NAME                  IN            VARCHAR2,
                 P_USER_ID                   IN            NUMBER,
                 P_LOGIN_ID                  IN            NUMBER,
                 X_RETURN_STATUS             OUT NOCOPY    VARCHAR2);


PROCEDURE GET_CHARGE_DETAIL_REC(
                 P_API_NAME           IN         VARCHAR2,
                 P_ESTIMATE_DETAIL_ID IN         NUMBER,
                 x_CHARGE_DETAIL_REC  OUT NOCOPY CS_ESTIMATE_DETAILS%ROWTYPE ,
                 x_MSG_DATA           OUT NOCOPY VARCHAR2,
                 x_MSG_COUNT          OUT NOCOPY NUMBER,
                 x_RETURN_STATUS      OUT NOCOPY VARCHAR2);

--Fixed Bug # 3325667 added p_org_id to procedure get_line_type
Procedure Get_Line_Type(
                 p_api_name              IN VARCHAR2,
                 p_txn_billing_type_id   IN  NUMBER,
                 p_org_id                IN  NUMBER,
                 x_line_type_id          OUT NOCOPY  NUMBER,
                 x_return_status         OUT NOCOPY VARCHAR2,
                 x_msg_count             OUT NOCOPY NUMBER,
                 x_msg_data              OUT NOCOPY VARCHAR2);

--Bug Fix for Bug # 3086455
PROCEDURE get_charge_flags_from_sr(
                 p_api_name                IN          VARCHAR2,
                 p_incident_id             IN          NUMBER,
                 x_disallow_new_charge     OUT NOCOPY  VARCHAR2,
                 x_disallow_charge_update  OUT NOCOPY  VARCHAR2,
                 x_msg_data                OUT NOCOPY  VARCHAR2,
                 x_msg_count               OUT NOCOPY  NUMBER,
                 x_return_status           OUT NOCOPY  NUMBER);

--Added by bkanimoz on 15-dec-2007 --Service Costing Enh

PROCEDURE get_charge_flag_from_sac
(
	  p_api_name                IN          VARCHAR2,
          p_txn_type_id             IN          NUMBER,
	  x_create_charge_flag      OUT NOCOPY  VARCHAR2,
	  x_msg_data                OUT NOCOPY  VARCHAR2,
	  x_msg_count               OUT NOCOPY  NUMBER,
          x_return_status           OUT NOCOPY  NUMBER
);


PROCEDURE Validate_Order(
                 p_api_name              IN VARCHAR2,
                 p_order_header_id       IN NUMBER,
                 p_org_id                IN NUMBER,
                 x_return_status         OUT NOCOPY VARCHAR2,
                 x_msg_count             OUT NOCOPY NUMBER,
                 x_msg_data              OUT NOCOPY VARCHAR2);

PROCEDURE VALIDATE_ORG_ID(
                 P_API_NAME       IN VARCHAR2,
                 P_ORG_ID         IN NUMBER,
                 X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT      OUT NOCOPY NUMBER,
                 X_MSG_DATA       OUT NOCOPY VARCHAR2);


FUNCTION IS_INCIDENT_ID_VALID (
                 p_incident_id   IN         NUMBER,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;


FUNCTION IS_RETURN_REASON_VALID(
                 P_RETURN_REASON_CODE IN         VARCHAR2,
                 X_MSG_DATA           OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT          OUT NOCOPY NUMBER,
                 X_RETURN_STATUS      OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION IS_CHARGE_LINE_TYPE_VALID(
                 p_charge_line_type IN         VARCHAR2,
                 x_msg_data         OUT NOCOPY VARCHAR2,
                 x_msg_count        OUT NOCOPY NUMBER,
                 x_return_status    OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION IS_BUSINESS_PROCESS_ID_VALID(
                 p_business_process_id IN         NUMBER,
                 x_msg_data            OUT NOCOPY VARCHAR2,
                 x_msg_count           OUT NOCOPY NUMBER,
                 x_return_status       OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION IS_PARTY_VALID(
                 p_party_id      IN         NUMBER,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION IS_ACCOUNT_VALID(
                 p_account_id    IN         NUMBER,
                 p_party_id      IN         NUMBER,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION IS_CONTACT_VALID(
                 p_contact_id    IN         NUMBER,
                 p_party_id      IN         NUMBER,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION IS_PARTY_SITE_VALID(
                 p_party_site_id IN         NUMBER,
                 p_party_id      IN         NUMBER,
                 p_val_mode      IN         VARCHAR2,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;


FUNCTION IS_CONTRACT_VALID(
                 p_contract_id           IN NUMBER,
                 x_msg_data              OUT NOCOPY VARCHAR2,
                 x_msg_count             OUT NOCOPY NUMBER,
                 x_return_status         OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

--Added for R12 implementation

FUNCTION IS_CONTRACT_LINE_VALID(
                 p_contract_line_id      IN NUMBER,
                 x_contract_id           OUT NOCOPY NUMBER,
                 x_msg_data              OUT NOCOPY VARCHAR2,
                 x_msg_count             OUT NOCOPY NUMBER,
                 x_return_status         OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION IS_PRICE_LIST_VALID(
                 p_price_list_id  IN         NUMBER,
                 x_msg_data       OUT NOCOPY VARCHAR2,
                 x_msg_count      OUT NOCOPY NUMBER,
                 x_return_status  OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION IS_UOM_VALID(
                 p_uom_code       IN         VARCHAR2,
                 p_inv_id         IN         NUMBER,
                 x_msg_data       OUT NOCOPY VARCHAR2,
                 x_msg_count      OUT NOCOPY NUMBER,
                 x_return_status  OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;


FUNCTION IS_INSTANCE_FOR_INVENTORY(
                 p_instance_id    IN         NUMBER,
                 p_inv_id         IN         NUMBER,
                 x_msg_data       OUT NOCOPY VARCHAR2,
                 x_msg_count      OUT NOCOPY NUMBER,
                 x_return_status  OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION IS_INSTANCE_VALID(
                 p_instance_id    IN         NUMBER,
                 p_party_id       IN         NUMBER,
                 x_msg_data       OUT NOCOPY VARCHAR2,
                 x_msg_count      OUT NOCOPY NUMBER,
                 x_return_status  OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION IS_INSTANCE_SERIAL_VALID  (
                                   p_instance_id   IN         NUMBER
                                  ,p_serial_number IN         VARCHAR
                                  ,x_msg_data      OUT NOCOPY VARCHAR2
                                  ,x_msg_count     OUT NOCOPY NUMBER
                                  ,x_return_status OUT NOCOPY VARCHAR2)

RETURN VARCHAR2;

FUNCTION IS_TXN_INV_ORG_VALID(
                 p_txn_inv_org    IN         NUMBER,
                 p_inv_id         IN         NUMBER,
                 x_msg_data       OUT NOCOPY VARCHAR2,
                 x_msg_count      OUT NOCOPY NUMBER,
                 x_return_status  OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION IS_ESTIMATE_DETAIL_ID_VALID(
                 p_estimate_detail_id IN         NUMBER,
                 x_msg_data           OUT NOCOPY VARCHAR2,
                 x_msg_count          OUT NOCOPY NUMBER,
                 x_return_status      OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;


FUNCTION GET_CONTRACT_LINE_ID(
                 p_coverage_id        IN         NUMBER,
                 x_msg_data           OUT NOCOPY VARCHAR2,
                 x_msg_count          OUT NOCOPY NUMBER,
                 x_return_status      OUT NOCOPY VARCHAR2)
RETURN NUMBER;

-- Added fix for the bug:5125858
FUNCTION IS_ITEM_REVISION_VALID(
                 p_inventory_item_id IN         NUMBER,
                 p_item_revision     IN         VARCHAR2,
                 x_msg_data           OUT NOCOPY VARCHAR2,
                 x_msg_count          OUT NOCOPY NUMBER,
                 x_return_status      OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

-- Added fix for the bug:
FUNCTION IS_LINE_NUMBER_VALID(
                 p_line_number       IN         NUMBER,
                 p_incident_id       IN         NUMBER,
                 x_msg_data           OUT NOCOPY VARCHAR2,
                 x_msg_count          OUT NOCOPY NUMBER,
                 x_return_status      OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

--=================================================
-- Function Implementations
--=================================================

--==================================================
-- IS_INCIDENT_ID_VALID - for Incident Id Validation
--==================================================
FUNCTION IS_INCIDENT_ID_VALID (p_incident_id   IN         NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2
                               )
RETURN VARCHAR2
IS

Cursor c_incident IS
  SELECT 'Y'
    FROM cs_incidents_all
   WHERE incident_id = p_incident_id;

lv_exists_flag VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_incident_id_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN c_incident;
FETCH c_incident INTO lv_exists_flag;
CLOSE c_incident;

RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;

END IS_INCIDENT_ID_VALID;

--========================================================
-- IS_RETURN_RESON_VALID - For Return Reson Code Validation
--=========================================================

FUNCTION IS_RETURN_REASON_VALID(P_RETURN_REASON_CODE IN         VARCHAR2,
                                X_MSG_DATA           OUT NOCOPY VARCHAR2,
                                X_MSG_COUNT          OUT NOCOPY NUMBER,
                                X_RETURN_STATUS      OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS

--Cursor to check return reason code

CURSOR c_return_reason_cur(p_return_reason_code varchar2) is
SELECT meaning from ar_lookups
WHERE  lookup_type = 'CREDIT_MEMO_REASON'
and lookup_code = p_return_reason_code;

lv_exists_flag VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_return_reason_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

 FOR v_return_reason_cur IN c_return_reason_cur(p_return_reason_code)
     LOOP
       lv_exists_flag := 'Y' ;
     END LOOP ;
   RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;

END IS_RETURN_REASON_VALID;

--========================================================
--IS_CHARGE_LINE_TYPE_VALID - for Charge Line Type
--Validation
--========================================================
FUNCTION IS_CHARGE_LINE_TYPE_VALID(p_charge_line_type IN VARCHAR2,
                                   x_msg_data         OUT NOCOPY VARCHAR2,
                                   x_msg_count        OUT NOCOPY NUMBER,
                                   x_return_status    OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS

--Cursor to check valid Incident Id

Cursor c_charge_line_type (p_charge_line_type IN VARCHAR2) IS
  SELECT lookup_code
    FROM fnd_lookup_values
   WHERE lookup_type = 'CS_CHG_LINE_TYPE' AND
         lookup_code = p_charge_line_type;

lv_exists_flag VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_charge_line_type_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR v_charge_line_type IN c_charge_line_type(p_charge_line_type)
     LOOP
       lv_exists_flag := 'Y';
     END LOOP ;
   RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;


END IS_CHARGE_LINE_TYPE_VALID;

--=========================================================
-- IS_BUSINESS_PROCESS_ID_VALID - for Business Process ID
-- Validation
--=========================================================
FUNCTION IS_BUSINESS_PROCESS_ID_VALID(p_business_process_id IN         NUMBER,
                                      x_msg_data            OUT NOCOPY VARCHAR2,
                                      x_msg_count           OUT NOCOPY NUMBER,
                                      x_return_status       OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS

--Cursor to check valid Incident Id

Cursor c_business_process_id (p_business_process_id IN NUMBER) IS

  SELECT business_process_id
    FROM cs_business_processes
   WHERE business_process_id = p_business_process_id;

lv_exists_flag VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_business_process_id_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR v_business_process_id IN c_business_process_id (p_business_process_id)
     LOOP
       lv_exists_flag := 'Y';
     END LOOP ;
   RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;

END IS_BUSINESS_PROCESS_ID_VALID;

--===============================================================
-- IS_PARTY_VALID - for Bill_To_Party and Ship_to_Party Validation
--===============================================================

FUNCTION IS_PARTY_VALID(p_party_id      IN         NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

lv_exists_flag VARCHAR2(1) := 'N';

CURSOR c_party IS
SELECT 'Y'
FROM hz_parties
WHERE party_id = p_party_id
AND   nvl(status, 'A')  = 'A';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_party_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN c_party;
FETCH c_party INTO lv_exists_flag;
CLOSE c_party;

RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;

END IS_PARTY_VALID;



--===============================================================
-- IS_ACCOUNT_VALID - for Bill_to_Accout and Ship_
--===============================================================
FUNCTION IS_ACCOUNT_VALID(p_account_id    IN         NUMBER,
                          p_party_id      IN         NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS

--Bug Fix for Bug # 2981195
--Added to the where
--Account_Activation_Date and Account_Termination_Date logic
--removed this from where clause Account_Activation_Date and Account_Termination_Date logic

--Cursor to check Account Id
CURSOR c_account(p_account_id in number,
                 p_party_id   in number) IS
SELECT cust_account_id
FROM   hz_cust_accounts
WHERE  cust_account_id = p_account_id
  AND  party_id = p_party_id
  AND  nvl(status, 'A') = 'A';


lv_exists_flag VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_account_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR v_account IN c_account(p_account_id,
                              p_party_id )
     LOOP
       lv_exists_flag := 'Y';
     END LOOP ;
   RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;

END IS_ACCOUNT_VALID;

--===============================================================
-- IS_CONTACT_VALID - for Bill_to_Contact and Ship_to_Contact
--===============================================================
FUNCTION IS_CONTACT_VALID(p_contact_id    IN         NUMBER,
                          p_party_id      IN         NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS

--Check the party_type for the given party

 CURSOR c_party_type(p_party_id in number) IS
  SELECT party_type
   FROM  hz_parties
  WHERE  party_id = p_party_id;

CURSOR  c_contact_org(p_party_id in number,
                      p_contact_id in number) IS
SELECT  rel.party_id
FROM    hz_relationships party_rel,
        hz_parties sub,
        hz_parties rel,
        ar_lookups ar,
        ar_lookups relm,
        hz_relationship_types typ,
        hz_code_assignments asg
WHERE   party_rel.object_id = p_party_id
        AND party_rel.party_id =  rel.party_id
        AND rel.party_id = p_contact_id
        AND party_rel.subject_id = sub.party_id
        AND sub.party_type = 'PERSON'
        AND sub.status = 'A'
        AND ar.lookup_type(+) = 'CONTACT_TITLE'
        AND sub.person_pre_name_adjunct = ar.lookup_code(+)
        AND relm.lookup_type(+) = 'PARTY_RELATIONS_TYPE'
        AND party_rel.relationship_code = relm.lookup_code(+)
        AND nvl(party_rel.start_date, sysdate-1) < sysdate
        AND nvl(party_rel.end_date  , sysdate+1) > sysdate
        AND party_rel.status = 'A'
        AND asg.owner_table_name = 'HZ_RELATIONSHIP_TYPES'
        AND asg.owner_table_id = typ.relationship_type_id
        AND asg.class_category = 'RELATIONSHIP_TYPE_GROUP'
        AND asg.class_code = 'PARTY_REL_GRP_CONTACTS'
        AND typ.relationship_type = party_rel.relationship_type
        AND party_rel.subject_type = 'PERSON'
        AND party_rel.subject_table_name = 'HZ_PARTIES'
        AND party_rel.object_type = 'ORGANIZATION'
        AND party_rel.object_table_name = 'HZ_PARTIES'
        AND party_rel.relationship_code = typ.forward_rel_code;

CURSOR  c_contact_person(p_party_id number,p_contact_id number) IS
SELECT  rel.party_id
FROM    hz_relationships party_rel,
        hz_parties sub,
        hz_parties rel,
        ar_lookups ar,
        ar_lookups relm,
        hz_relationship_types typ,
        hz_code_assignments asg
WHERE   party_rel.object_id = p_party_id
        AND party_rel.party_id = rel.party_id
        AND rel.party_id = p_contact_id
        AND party_rel.subject_id = sub.party_id
        AND sub.party_type = 'PERSON'
        AND ar.lookup_type(+) = 'CONTACT_TITLE'
        AND sub.person_pre_name_adjunct = ar.lookup_code(+)
        AND relm.lookup_type(+) = 'PARTY_RELATIONS_TYPE'
        AND party_rel.relationship_code = relm.lookup_code(+)
        AND nvl(party_rel.start_date, sysdate-1) < sysdate
        AND nvl(party_rel.end_date  , sysdate+1) > sysdate
        AND party_rel.status = 'A'
        AND asg.owner_table_name = 'HZ_RELATIONSHIP_TYPES'
        AND asg.owner_table_id = typ.relationship_type_id
        AND asg.class_category = 'RELATIONSHIP_TYPE_GROUP'
        AND asg.class_code = 'PARTY_REL_GRP_CONTACTS'
        AND typ.relationship_type = party_rel.relationship_type
        AND party_rel.subject_type = 'PERSON'
        AND party_rel.subject_table_name = 'HZ_PARTIES'
        AND party_rel.object_type = 'PERSON' -- added for bug # 4744186
        AND party_rel.object_table_name = 'HZ_PARTIES'
        AND party_rel.relationship_code = typ.forward_rel_code;

lv_exists_flag VARCHAR2(1) := 'N';
lv_party_type VARCHAR2(30);
lv_type_found VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_contact_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR v_party_type IN c_party_type(p_party_id)
     LOOP
       lv_type_found := 'Y';
       lv_party_type := v_party_type.party_type;
     END LOOP ;

     IF lv_type_found = 'Y' THEN
      IF lv_party_type = 'ORGANIZATION' THEN
        FOR v_contact_org IN c_contact_org(p_party_id , p_contact_id)LOOP
          lv_exists_flag := 'Y';
        END LOOP;
      ELSE
         IF lv_party_type = 'PERSON'
         THEN
            /* Start : 4744186 */
            IF p_party_id = p_contact_id
            THEN
            /*If Bill to/ship to Party id is same as Bill to/ship to contact id and Bill to/ship to
            party type is PERSON, there will not be any relationship*/
               lv_exists_flag := 'Y';
            ELSE
            /* End : 4744186 */
               FOR v_contact_person IN c_contact_person(p_party_id,  p_contact_id)
               LOOP
                  lv_exists_flag := 'Y';
               END LOOP;
            END IF;
         END IF;
      END IF;
   ELSE
      --lv_type_found = 'N'
      lv_exists_flag := 'N';
   END IF;

     RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;

END IS_CONTACT_VALID;


--===============================================================
-- IS_PARTY_SITE - for Bill_to_Accout and Ship_
--===============================================================
FUNCTION IS_PARTY_SITE_VALID(p_party_site_id IN         NUMBER,
                             p_party_id      IN         NUMBER,
                             p_val_mode      IN         VARCHAR2,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS

-- Cursor to check Bill To Party Site Id

Cursor c_bill_to_party_site(p_party_site_id IN NUMBER,
                            p_party_id      IN NUMBER) IS
SELECT site.party_site_id
 FROM  HZ_PARTY_SITES site,
       HZ_PARTY_SITE_USES site_use,
       HZ_PARTIES party
 WHERE site.party_site_id  = p_party_site_id
       AND site.party_id   =  p_party_id
       AND site.party_id   = party.party_id
       AND site.party_site_id = site_use.party_site_id
       AND nvl(site.status, 'A') = 'A'
       AND site_use.site_use_type = 'BILL_TO';

--Cursor to check Ship To Party Site Id

Cursor c_ship_to_party_site(p_party_site_id IN NUMBER,
                            p_party_id      IN NUMBER) IS
SELECT site.party_site_id
 FROM  HZ_PARTY_SITES site,
       HZ_PARTY_SITE_USES site_use,
       HZ_PARTIES party
 WHERE site.party_site_id  = p_party_site_id
       AND site.party_id   =  p_party_id
       AND site.party_id   = party.party_id
       AND site.party_site_id = site_use.party_site_id
       AND nvl(site.status, 'A') = 'A'
       AND site_use.site_use_type = 'SHIP_TO';

Cursor c_party_site(p_party_site_id IN NUMBER,
                    p_party_id      IN NUMBER) IS

SELECT site.party_site_id
 FROM  HZ_PARTY_SITES site,
       HZ_PARTIES party
 WHERE site.party_site_id  = p_party_site_id
       AND site.party_id   =  p_party_id
       AND site.party_id   = party.party_id
       AND nvl(site.status, 'A') = 'A';

lv_exists_flag VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_party_site_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_val_mode = 'BILL_TO' THEN
   FOR v_bill_to_party_site IN c_bill_to_party_site(p_party_site_id,
                    p_party_id)
     LOOP
       lv_exists_flag := 'Y';
     END LOOP ;
  ELSIF  p_val_mode =  'SHIP_TO' THEN
   FOR v_ship_to_party_site IN  c_ship_to_party_site(p_party_site_id,
                     p_party_id)
     LOOP
       lv_exists_flag := 'Y';
     END LOOP ;

  ELSE
    -- the p_val_mode = 'NONE'
    FOR v_party_site IN c_party_site(p_party_site_id,
                                     p_party_id)
      LOOP
        lv_exists_flag := 'Y';
      END LOOP;

  END IF;
  RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;

END IS_PARTY_SITE_VALID;

--======================================================
-- IS_CONTRACT_LINE VALID - for Contract Line Validation
--======================================================

FUNCTION IS_CONTRACT_LINE_VALID(
                 p_contract_line_id      IN NUMBER,
                 x_contract_id           OUT NOCOPY NUMBER,
                 x_msg_data              OUT NOCOPY VARCHAR2,
                 x_msg_count             OUT NOCOPY NUMBER,
                 x_return_status         OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS

Cursor c_check_contract_line IS
select id, chr_id
from okc_k_lines_b
where id = p_contract_line_id;

l_contract_line_id NUMBER;
l_exists_flag VARCHAR2(1);

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_contract_line_valid';


BEGIN
   OPEN c_check_contract_line;
   FETCH c_check_contract_line INTO l_contract_line_id, x_contract_id;
   CLOSE c_check_contract_line;

   IF l_contract_line_id IS NOT NULL THEN
     l_exists_flag := 'Y';
   ELSE
     l_exists_flag := 'N';
   END IF;

  RETURN l_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN l_exists_flag;


END;

--======================================================
-- IS_CONTRACT_VALID - for Contract Validation
--======================================================

-- Changed for R12 By mviswana
FUNCTION IS_CONTRACT_VALID(
                 p_contract_id           IN         NUMBER,
                 x_msg_data              OUT NOCOPY VARCHAR2,
                 x_msg_count             OUT NOCOPY NUMBER,
                 x_return_status         OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS

 --Commented this code AND PTY.OBJECT1_ID1 = p_customer_id
 --to resolve bug 3254006

 Cursor c_contract_check IS
  SELECT 'x'
  FROM OKC_K_HEADERS_ALL_B HDR
       --OKC_K_PARTY_ROLES_B PTY
  WHERE
  HDR.START_DATE IS NOT NULL AND
  HDR.END_DATE IS NOT NULL AND
  HDR.TEMPLATE_YN='N' AND
  -- HDR.ID=PTY.CHR_ID AND
  -- PTY.JTOT_OBJECT1_CODE='OKX_PARTY' AND
  HDR.ID = p_contract_id;

  -- Commented to Fix Bug # 3554509

  --AND
  --p_request_date between nvl(hdr.start_date,p_request_date) and
  --nvl(hdr.end_date,p_request_date);
  --AND PTY.OBJECT1_ID1 = p_customer_id  ;



lv_exists_flag VARCHAR2(1) := 'N';
lv_check_flag VARCHAR2(1) := 'N';


l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_contract_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;


  FOR v_contract_check in c_contract_check LOOP
    lv_check_flag := 'Y';
    ------DBMS_OUTPUT.PUT_LINE('Found contract');

  END LOOP;

  IF lv_check_flag = 'Y' THEN
    lv_exists_flag := 'Y';
  ELSE
    lv_exists_flag := 'N';
  END IF;


  RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;

END;

--==============================================================
-- FUNCTION GET_CONTRACT_LINE_ID
--==============================================================

FUNCTION GET_CONTRACT_LINE_ID(
                 p_coverage_id        IN         NUMBER,
                 x_msg_data           OUT NOCOPY VARCHAR2,
                 x_msg_count          OUT NOCOPY NUMBER,
                 x_return_status      OUT NOCOPY VARCHAR2) RETURN NUMBER IS

CURSOR c_k_line IS
SELECT cle_id
FROM   okc_k_lines_b
WHERE  id = p_coverage_id;

lv_temp NUMBER := 0;

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_contract_line_id';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN c_k_line;
FETCH c_k_line INTO lv_temp;
CLOSE c_k_line;

RETURN lv_temp;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_temp;

END GET_CONTRACT_LINE_ID;

--========================================================
-- IS_UOM_VALID - For Uom Validation
--========================================================
FUNCTION IS_UOM_VALID(p_uom_code       IN         VARCHAR2,
                      p_inv_id         IN         NUMBER,
                      x_msg_data       OUT NOCOPY VARCHAR2,
                      x_msg_count      OUT NOCOPY NUMBER,
                      x_return_status  OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS


Cursor c_uom_code(p_uom_code IN VARCHAR2,
                  p_inv_id IN NUMBER) IS
 SELECT   uom_code
   FROM   MTL_ITEM_UOMS_VIEW
   WHERE  uom_code = p_uom_code  AND
          inventory_item_id = P_INV_ID AND
          organization_id = cs_std.get_item_valdn_orgzn_id ;

lv_exists_flag VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_uom_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR v_uom_code IN c_uom_code(p_uom_code,
                               p_inv_id) LOOP
    lv_exists_flag := 'Y';
  END LOOP;
  RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;
END;

--=========================================================
-- IS_INSTANCE_FOR_INVENTORY
--=========================================================
FUNCTION IS_INSTANCE_FOR_INVENTORY(p_instance_id    IN         NUMBER,
                                   p_inv_id         IN         NUMBER,
                                   x_msg_data       OUT NOCOPY VARCHAR2,
                                   x_msg_count      OUT NOCOPY NUMBER,
                                   x_return_status  OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS

--Cursor to check valid instnace_id*

Cursor c_instance(p_instance_id IN NUMBER,
                  p_inv_id      IN NUMBER) IS
  SELECT instance_id
    FROM csi_item_instances
   WHERE instance_id = p_instance_id
     AND inventory_item_id = p_inv_id;
     --AND INV_MASTER_ORGANIZATION_ID = cs_std.get_item_valdn_orgzn_id;

lv_exists_flag VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_instance_for_inventory';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR v_instance IN c_instance(p_instance_id,
                               p_inv_id) LOOP
    lv_exists_flag := 'Y';

  END LOOP;

  RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;
END;

--=========================================================
-- IS_INSTANCE_VALID
-- SSHILPAM	Bug 8552188: Should be able to validate the
--	        instance against related parties also.
--=========================================================
FUNCTION IS_INSTANCE_VALID(p_instance_id    IN         NUMBER,
                           p_party_id       IN         NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_return_status  OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS

CURSOR c_instance IS
   SELECT 'Y'
    FROM  CSI_ITEM_INSTANCES cp,
          MTL_SYSTEM_ITEMS_KFV ITEMS
    WHERE cp.instance_id = p_instance_id AND
          CP.OWNER_PARTY_SOURCE_TABLE = 'HZ_PARTIES' AND
          -- cp.owner_party_id = p_party_id AND Commented for bug 8552188
          ITEMS.INVENTORY_ITEM_ID = CP.INVENTORY_ITEM_ID AND
          ITEMS.ORGANIZATION_ID = cs_std.get_item_valdn_orgzn_id AND
          exists (select 'x'
                    from csi_i_parties cip
                    where cip.party_id = p_party_id
                          and cip.instance_id = cp.instance_id
                          and cip.party_source_table = 'HZ_PARTIES')AND
                          (
                          (fnd_profile.value('CS_SR_RESTRICT_IB') = 'YES'
                           and CP.LOCATION_TYPE_CODE IN('HZ_PARTY_SITES','HZ_LOCATIONS'))
                           or (fnd_profile.value('CS_SR_RESTRICT_IB') <> 'YES'));

lv_exists_flag VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_instance_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN c_instance;
FETCH c_instance INTO lv_exists_flag;
CLOSE c_instance;

  RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;
END;

--==========================================================
--IS_INSTANCE_SERIAL_VALID
--==========================================================

FUNCTION IS_INSTANCE_SERIAL_VALID( p_instance_id   IN         NUMBER
                                  ,p_serial_number IN         VARCHAR
                                  ,x_msg_data      OUT NOCOPY VARCHAR2
                                  ,x_msg_count     OUT NOCOPY NUMBER
                                  ,x_return_status OUT NOCOPY VARCHAR2)

RETURN VARCHAR2
IS

Cursor c_instance_serial_number IS
  SELECT 'Y'
    FROM csi_item_instances
   WHERE instance_id = p_instance_id
     AND serial_number = p_serial_number;

lv_exists_flag VARCHAR2(1) := 'N';
l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_instance_serial_number_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

--DBMS_OUTPUT.PUT_LINE('In IS_INSTANCE_SERIAL_VALID ');

OPEN c_instance_serial_number;
FETCH c_instance_serial_number INTO lv_exists_flag;
CLOSE c_instance_serial_number;

--DBMS_OUTPUT.PUT_LINE('lv_exists_flag');

RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN
        --DBMS_OUTPUT.PUT_LINE('MAYA');

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;

END IS_INSTANCE_SERIAL_VALID ;

--==========================================================
--IS_PRICE_LIST_VALID
--=========================================================
FUNCTION IS_PRICE_LIST_VALID(p_price_list_id  IN         NUMBER,
                             x_msg_data       OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_return_status  OUT NOCOPY VARCHAR2
                           )
RETURN VARCHAR2
IS

Cursor c_price_list(p_price_list_id IN NUMBER) IS
SELECT list_header_id
FROM   QP_LIST_HEADERS_B
WHERE  list_type_code in ('PRL','AGR')
AND    list_header_id = p_price_list_id
AND    sysdate between nvl(start_date_active,sysdate) and
       nvl(end_date_active,sysdate);

lv_exists_flag VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_price_list_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR v_price_list in c_price_list(p_price_list_id) LOOP
    lv_exists_flag := 'Y';
  END LOOP;

  RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;
END;

--=========================================================
--IS_TXN_INV_ORG_VALID - for transaction inv org validation
--=========================================================

FUNCTION IS_TXN_INV_ORG_VALID(p_txn_inv_org    IN         NUMBER,
                              p_inv_id         IN         NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_return_status  OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS
--Bug Fix for 9371992
--Replaced cursor c_oper_unit_for_inv_org with c_inv_org_for_item

/*CURSOR c_oper_unit_for_inv_org (p_txn_inv_org number) IS
SELECT
TO_NUMBER(hoi2.org_information3) OPERATING_UNIT
FROM
hr_organization_units hou,
hr_organization_information hoi1,
hr_organization_information hoi2,
mtl_parameters mp
WHERE
mp.organization_id = p_txn_inv_org
AND mp.organization_id = hou.organization_id
AND hou.organization_id = hoi1.organization_id
AND hoi1.org_information1 = 'INV'
AND hoi1.org_information2 = 'Y'
AND hoi1.org_information_context = 'CLASS'
AND hou.organization_id = hoi2.organization_id
AND hoi2.org_information_context = 'Accounting Information' ;*/
CURSOR c_inv_org_for_item (p_inv_id number) IS
SELECT  hou.organization_id inv_org_id
FROM   hr_organization_units hou,
       hr_organization_information hoi1,
       mtl_parameters mp,
       mtl_system_items_b msi
WHERE
       hou.organization_id = msi.organization_id
   AND hou.organization_id = hoi1.organization_id
   AND hoi1.org_information1 = 'INV'
   AND hoi1.org_information2 = 'Y'
   AND msi.organization_id = mp.organization_id
   AND to_date(sysdate) between hou.date_from and nvl(hou.date_to,to_date(sysdate))
   AND msi.inventory_item_id = p_inv_id;

lv_exists_flag VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_txn_inv_org_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

 FOR v_inv_org_for_item IN c_inv_org_for_item (p_inv_id) LOOP

  IF v_inv_org_for_item.inv_org_id = p_txn_inv_org THEN
     lv_exists_flag := 'Y';
     EXIT;
  END IF;
 END LOOP;

 RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;

END;

--------------------------------------------------------------------------------
-- FUNCTION IS_ESTIMATE_DETAIL_ID_VALID
--------------------------------------------------------------------------------
FUNCTION IS_ESTIMATE_DETAIL_ID_VALID (p_estimate_detail_id IN         NUMBER,
                                      x_msg_data           OUT NOCOPY VARCHAR2,
                                      x_msg_count          OUT NOCOPY NUMBER,
                                      x_return_status      OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

Cursor c_estimate_detail_id IS
  SELECT 1
   FROM CS_ESTIMATE_DETAILS
  WHERE estimate_detail_id = p_estimate_detail_id;

  lv_exists_flag VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_estimate_detail_id_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR v_estimate_detail_id IN c_estimate_detail_id LOOP
    lv_exists_flag := 'Y';
  END LOOP;

RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;

END IS_ESTIMATE_DETAIL_ID_VALID;

--------------------------------------------------------------------------------
-- FUNCTION IS_ITEM_REVISION_VALID
--------------------------------------------------------------------------------
FUNCTION IS_ITEM_REVISION_VALID (p_inventory_item_id IN         NUMBER,
                                 p_item_revision     IN         VARCHAR2,
                                      x_msg_data           OUT NOCOPY VARCHAR2,
                                      x_msg_count          OUT NOCOPY NUMBER,
                                      x_return_status      OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

Cursor c_item_revision IS
  SELECT 1
  FROM MTL_ITEM_REVISIONS
  WHERE inventory_item_id = p_inventory_item_id and
        revision = p_item_revision and
        organization_id = cs_std.get_item_valdn_orgzn_id ;

  lv_exists_flag VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_item_revision_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR v_item_revision IN c_item_revision LOOP
    lv_exists_flag := 'Y';
  END LOOP;

RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;

END IS_ITEM_REVISION_VALID;

--------------------------------------------------------------------------------
-- FUNCTION IS_LINE_NUMBER_VALID
--------------------------------------------------------------------------------
FUNCTION IS_LINE_NUMBER_VALID(
                 p_line_number       IN         NUMBER,
                 p_incident_id       IN         NUMBER,
                 x_msg_data           OUT NOCOPY VARCHAR2,
                 x_msg_count          OUT NOCOPY NUMBER,
                 x_return_status      OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

Cursor c_line_number IS
  SELECT line_number
  FROM CS_ESTIMATE_DETAILS
  WHERE incident_id = p_incident_id and
        line_number = p_line_number;

lv_exists_flag VARCHAR2(1) := 'N';

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_line_number_valid';

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_line_number <= 0 THEN
     lv_exists_flag := 'Y';
  ELSE
     FOR v_line_number IN c_line_number LOOP
     lv_exists_flag := 'Y';
     END LOOP;
  END IF;

RETURN lv_exists_flag;

EXCEPTION

      WHEN OTHERS THEN

        FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
        FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
        FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN lv_exists_flag;

END IS_LINE_NUMBER_VALID;

--==========================================================
--==========================================================
--  API for upstream to Create Charge Details
--==========================================================
PROCEDURE Create_Charge_Details(
      p_api_version           IN  	  NUMBER,
      p_init_msg_list         IN 	  VARCHAR2 	:= FND_API.G_FALSE,
      p_commit                IN 	  VARCHAR2 	:= FND_API.G_FALSE,
      p_validation_level      IN  	  NUMBER 	:= FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_object_version_number OUT NOCOPY  NUMBER,
      x_estimate_detail_id    OUT NOCOPY  NUMBER,
      x_line_number           OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      p_resp_appl_id          IN          NUMBER := FND_GLOBAL.RESP_APPL_ID,
      p_resp_id               IN          NUMBER := FND_GLOBAL.RESP_ID,
      p_user_id               IN          NUMBER := FND_GLOBAL.USER_ID,
      p_login_id              IN  	  NUMBER := NULL,
      p_transaction_control   IN          VARCHAR2      := FND_API.G_TRUE,
      p_est_detail_rec        IN          CS_Charge_Details_PUB.Charges_Rec_Type
			) IS

l_api_version       NUMBER                   :=  1.0 ;
l_api_name          CONSTANT VARCHAR2(30)    := 'Create_Charge_Details' ;
l_api_name_full     CONSTANT VARCHAR2(61)    :=  G_PKG_NAME || '.' || l_api_name ;
l_log_module        CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';
l_return_status     VARCHAR2(1) ;
l_est_detail_rec    CS_Charge_Details_PUB.Charges_Rec_Type;
l_line_num          NUMBER               := 1 ;
l_ed_id             NUMBER ;
lx_org_id           NUMBER ;
lx_profile          VARCHAR2(1);
l_org_id            NUMBER ;

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'create_charge_details';


--DEBUG
l_errm VARCHAR2(100);

BEGIN

--DBMS_OUTPUT.PUT_LINE('BEGIN create_charge_details');
--DBMS_OUTPUT.PUT_LINE('submit_error_message is '||p_est_detail_rec.submit_error_message);

  -- Standard start of API savepoint
  IF FND_API.To_Boolean(p_transaction_control) THEN
    SAVEPOINT Create_Charge_Details_PVT;
  END IF ;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version,
     p_api_version,
     l_api_name,
     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_appl_id:' || p_resp_appl_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_id:' || p_resp_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_user_id:' || p_user_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_login_id:' || p_login_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_transaction_control:' || p_transaction_control
    );

 -- --------------------------------------------------------------------------
 -- This procedure Logs the charges record paramters.
 -- --------------------------------------------------------------------------
    CS_Charge_Details_PUB.Log_Charges_Rec_Parameters
    ( p_Charges_Rec             =>  p_est_detail_rec
    );

  END IF;

  -- Make the preprocessing call to the user hooks
  --
  -- Pre call to the customer type user hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_CHARGE_DETAILS_PVT',
                               'Create_Charge_Details',
			       'B','C') THEN

    CS_CHARGE_DETAILS_CUHK.Create_Charge_Details_Pre(
		p_api_version      	   => l_api_version,
		p_init_msg_list    	   => FND_API.G_FALSE,
		p_commit           	   => p_commit,
		p_validation_level 	   => p_validation_level,
		x_return_status    	   => l_return_status,
		x_msg_count       	   => x_msg_count,
		x_object_version_number    => x_object_version_number,
        	x_estimate_detail_id       => l_ed_id,
    	    	x_line_number              => l_line_num,
		x_msg_data         	   => x_msg_data,
		p_resp_appl_id    	   => p_resp_appl_id,
		p_resp_id          	   => p_resp_id,
    		p_user_id          	   => p_user_id,
		p_login_id         	   => p_login_id,
        	p_transaction_control      => p_transaction_control,
		p_est_detail_rec           => p_est_detail_rec);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_ERR_PRE_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  --
  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_CHARGE_DETAILS_PVT',
                               'Create_Charge_Details',
                               'B', 'V')  THEN

    CS_CHARGE_DETAILS_VUHK.Create_Charge_Details_Pre(
		p_api_version      	   => l_api_version,
		p_init_msg_list    	   => FND_API.G_FALSE,
		p_commit           	   => p_commit,
		p_validation_level 	   => p_validation_level,
		x_return_status    	   => l_return_status,
		x_msg_count       	   => x_msg_count,
		x_object_version_number    => x_object_version_number,
                x_estimate_detail_id       => l_ed_id,
                x_line_number              => l_line_num,
		x_msg_data         	   => x_msg_data,
		p_resp_appl_id    	   => p_resp_appl_id,
		p_resp_id          	   => p_resp_id,
    	        p_user_id          	   => p_user_id,
		p_login_id         	   => p_login_id,
                p_transaction_control      => p_transaction_control,
		p_est_detail_rec           => p_est_detail_rec);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_ERR_PRE_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  -- ======================================================================
  -- Apply business-rule validation to all required and passed parameters
  -- if validation level is set.
  -- ======================================================================

  IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN

    --DBMS_OUTPUT.PUT_LINE('Calling VALIDATE_WHO_INFO');
    --DBMS_OUTPUT.PUT_LINE('p_user_id '|| p_user_id);
    --DBMS_OUTPUT.PUT_LINE('p_login_id '||p_login_id);

    Validate_Who_Info (p_api_name             => l_api_name_full,
                       p_user_id              => p_user_id,
                       p_login_id             => p_login_id,
                       x_return_status        => l_return_status);

    --DBMS_OUTPUT.PUT_LINE('Back from VALIDATE_WHO_INFO '||l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- --DBMS_OUTPUT.PUT_LINE('Calling VALIDATE_CHARGE_DETAILS');

    --Validate the Charge Detail Record that is passed in by the Upstream Module
    VALIDATE_CHARGE_DETAILS(p_api_name           => l_api_name,
                            p_charges_detail_rec => p_est_detail_rec,
                            p_validation_mode    => 'I',
                            p_user_id            => p_user_id,
                            p_login_id           => p_login_id,
                            x_charges_detail_rec => l_est_detail_rec,
                            x_msg_data           => x_msg_data,
                            x_msg_count          => x_msg_count,
                            x_return_status      => l_return_status);



    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.Set_Name('CS', 'CS_CHG_VALIDATE_CHRG_DETAIL_ER');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  --Fixed Bug # 3795144
  ELSE
    --p_validation_level = FND_API.G_VALID_LEVEL_NONE
    IF (p_validation_level = FND_API.G_VALID_LEVEL_NONE) THEN
      --populate the l_est_detail_rec record
      l_est_detail_rec := p_est_detail_rec;
    END IF;
  END IF ;

  -----------------------------------------
  -- Prepare to INSERT record into database
  -----------------------------------------
  -- Added fix for the bug:5125385
  -- commented this out as billing_engine and copy_to_estimate are failing

  -- dbms_output.put_line('Value of charge line number ' || l_est_detail_rec.line_number);

  IF l_est_detail_rec.line_number IS NOT NULL AND
     l_est_detail_rec.line_number <> FND_API.G_MISS_NUM THEN

     l_line_num := l_est_detail_rec.line_number;

  ELSE

  SELECT max(line_number) + 1
  INTO   l_line_num
  FROM   CS_ESTIMATE_DETAILS
  WHERE  incident_id = p_est_detail_rec.incident_id;

  END IF;

  l_line_num := NVL(l_line_num,1);


  SELECT cs_estimate_details_s.nextval
  INTO   l_ed_id
  FROM   DUAL ;

  --DBMS_OUTPUT.PUT_LINE('Calling CS_ESTIMATE_DETAILS_PKG.INSERT_ROW');
  --DBMS_OUTPUT.PUT_LINE('l_org_id = '||l_est_detail_rec.org_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.incident_id = '||l_est_detail_rec.incident_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.original_source_id = '||l_est_detail_rec.original_source_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.original_source_code = '||l_est_detail_rec.original_source_code);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.source_id = '||l_est_detail_rec.source_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.source_code = '||l_est_detail_rec.source_code);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.contract_id = '||l_est_detail_rec.contract_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.coverage_id = '||l_est_detail_rec.coverage_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.coverage_txn_group_id = '||l_est_detail_rec.coverage_txn_group_id);
  --DBMS_OUTPUT.PUT_LINE('l_EST_DETAIL_rec.currency_code = '||l_EST_DETAIL_rec.currency_code);
  --DBMS_OUTPUT.PUT_LINE('l_EST_DETAIL_rec.conversion_rate = '||l_EST_DETAIL_rec.conversion_rate);
  --DBMS_OUTPUT.PUT_LINE('l_EST_DETAIL_rec.conversion_rate_date = '||l_EST_DETAIL_rec.conversion_rate_date);
  --DBMS_OUTPUT.PUT_LINE('l_EST_DETAIL_rec.conversion_type_code = '||l_EST_DETAIL_rec.conversion_type_code);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.invoice_to_org_id = '||l_est_detail_rec.invoice_to_org_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.ship_to_org_id = '||l_est_detail_rec.ship_to_org_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.purchase_order_num = '||l_est_detail_rec.purchase_order_num);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.order_line_id = '||l_est_detail_rec.order_line_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.line_type_id = '||l_est_detail_rec.line_type_id);
  --DBMS_OUTPUT.PUT_LINE('l_EST_DETAIL_rec.LINE_CATEGORY_CODE = '||l_EST_DETAIL_rec.LINE_CATEGORY_CODE);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.price_list_id = '||l_est_detail_rec.price_list_id);
  --DBMS_OUTPUT.PUT_LINE('l_line_num = '||l_line_num);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.inventory_item_id_in = '||l_est_detail_rec.inventory_item_id_in);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.item_revision = '||l_est_detail_rec.item_revision);
  --DBMS_OUTPUT.PUT_LINE('l_EST_DETAIL_rec.SERIAL_NUMBER = '||l_EST_DETAIL_rec.SERIAL_NUMBER);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.quantity_required = '||l_est_detail_rec.quantity_required);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.unit_of_measure_code = '||l_est_detail_rec.unit_of_measure_code);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.selling_price = '||l_est_detail_rec.selling_price);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.after_warranty_cost = '||l_est_detail_rec.after_warranty_cost);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.business_process_id = '||l_est_detail_rec.business_process_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.transaction_type_id = '||l_est_detail_rec.transaction_type_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.customer_product_id = '||l_est_detail_rec.customer_product_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.order_header_id = '||l_est_detail_rec.order_header_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.installed_cp_return_by_date = '||l_est_detail_rec.installed_cp_return_by_date);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.new_cp_return_by_date = '||l_est_detail_rec.new_cp_return_by_date);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.interface_to_oe_flag = '||l_est_detail_rec.interface_to_oe_flag);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.rollup_flag = '||l_est_detail_rec.rollup_flag);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.no_charge_flag = '||l_est_detail_rec.no_charge_flag);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.add_to_order_flag = '||l_est_detail_rec.add_to_order_flag);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.return_reason_code = '||l_est_detail_rec.return_reason_code);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.generated_by_bca_engine = '||l_est_detail_rec.generated_by_bca_engine);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.transaction_inventory_org = '||l_est_detail_rec.transaction_inventory_org);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.transaction_sub_inventory = '||l_est_detail_rec.transaction_sub_inventory);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.charge_line_type = '||l_est_detail_rec.charge_line_type);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.ship_to_account_id = '||l_est_detail_rec.ship_to_account_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.bill_to_account_id = '||l_est_detail_rec.bill_to_account_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.ship_to_contact_id = '||l_est_detail_rec.ship_to_contact_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.bill_to_contact_id = '||l_est_detail_rec.bill_to_contact_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.list_price = '||l_est_detail_rec.list_price);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.activity_start_time = '||TO_CHAR(l_est_detail_rec.activity_start_time, 'DD-MON-YYYY HH24:MI:SS'));
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.activity_end_time = '||TO_CHAR(l_est_detail_rec.activity_end_time, 'DD-MON-YYYY HH24:MI:SS'));
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.contract_discount_amount = '||l_est_detail_rec.contract_discount_amount);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.bill_to_party_id = '||l_est_detail_rec.bill_to_party_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.ship_to_party_id = '||l_est_detail_rec.ship_to_party_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.coverage_bill_rate_id = '||l_est_detail_rec.coverage_bill_rate_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.txn_billing_type_id = '||l_est_detail_rec.txn_billing_type_id);
  --DBMS_OUTPUT.PUT_LINE('p_login_id = '||p_login_id);
  --DBMS_OUTPUT.PUT_LINE('p_user_id = '||p_user_id);
  --DBMS_OUTPUT.PUT_LINE('p_user_id = '||p_user_id);
  --DBMS_OUTPUT.PUT_LINE('l_ed_id = '||l_ed_id);

  CS_ESTIMATE_DETAILS_PKG.Insert_Row(
    p_org_id                           => l_est_detail_rec.org_id,
    p_incident_id                      => l_est_detail_rec.incident_id,
    p_original_source_id               => l_est_detail_rec.original_source_id,
    p_original_source_code             => l_est_detail_rec.original_source_code,
    p_source_id                        => l_est_detail_rec.source_id,
    p_source_code                      => l_est_detail_rec.source_code,
    p_contract_line_id                 => l_est_detail_rec.contract_line_id,
    p_rate_type_code                   => l_est_detail_rec.rate_type_code,
    p_contract_id                      => l_est_detail_rec.contract_id,
    p_coverage_id                      => null,
    p_coverage_txn_group_id            => null,
    p_CURRENCY_CODE                    => l_EST_DETAIL_rec.currency_code,
    p_CONVERSION_RATE                  => l_EST_DETAIL_rec.conversion_rate,
    p_CONVERSION_TYPE_CODE             => l_EST_DETAIL_rec.conversion_type_code,
    p_CONVERSION_RATE_DATE             => l_EST_DETAIL_rec.conversion_rate_date,
    p_invoice_to_org_id                => l_est_detail_rec.invoice_to_org_id,
    p_ship_to_org_id                   => l_est_detail_rec.ship_to_org_id,
    p_purchase_order_num               => l_est_detail_rec.purchase_order_num,
    p_order_line_id                    => l_est_detail_rec.order_line_id,
    p_line_type_id                     => l_est_detail_rec.line_type_id,
    p_LINE_CATEGORY_CODE               => l_EST_DETAIL_rec.LINE_CATEGORY_CODE,
    p_price_list_header_id             => l_est_detail_rec.price_list_id,
    p_line_number                      => l_line_num,
    p_inventory_item_id                => l_est_detail_rec.inventory_item_id_in,
    p_item_revision	               => l_est_detail_rec.item_revision,
    p_SERIAL_NUMBER                    => l_EST_DETAIL_rec.SERIAL_NUMBER,
    p_quantity_required                => l_est_detail_rec.quantity_required,
    p_unit_of_measure_code             => l_est_detail_rec.unit_of_measure_code,
    p_selling_price                    => l_est_detail_rec.selling_price,
    p_after_warranty_cost              => l_est_detail_rec.after_warranty_cost,
    p_business_process_id              => l_est_detail_rec.business_process_id,
    p_transaction_type_id              => l_est_detail_rec.transaction_type_id,
    p_customer_product_id              => l_est_detail_rec.customer_product_id,
    p_order_header_id                  => l_est_detail_rec.order_header_id,
    p_installed_cp_return_by_date      => l_est_detail_rec.installed_cp_return_by_date,
    p_new_cp_return_by_date            => l_est_detail_rec.new_cp_return_by_date,
    p_interface_to_oe_flag             => nvl(l_est_detail_rec.interface_to_oe_flag, 'N'),
    p_rollup_flag                      => nvl(l_est_detail_rec.rollup_flag,'N'),
    p_no_charge_flag                   => nvl(l_est_detail_rec.no_charge_flag,'N'),
    p_add_to_order_flag                => nvl(l_est_detail_rec.add_to_order_flag,'N'),
    p_return_reason_code               => l_est_detail_rec.return_reason_code,
    p_generated_by_bca_engine_flag     => nvl(l_est_detail_rec.generated_by_bca_engine,'N'),
    p_transaction_inventory_org        => l_est_detail_rec.transaction_inventory_org,
    p_transaction_sub_inventory	       => l_est_detail_rec.transaction_sub_inventory,
    p_charge_line_type                 => l_est_detail_rec.charge_line_type,
    p_ship_to_account_id               => l_est_detail_rec.ship_to_account_id,
    p_invoice_to_account_id            => l_est_detail_rec.bill_to_account_id,
    p_ship_to_contact_id               => l_est_detail_rec.ship_to_contact_id,
    p_bill_to_contact_id               => l_est_detail_rec.bill_to_contact_id,
    p_list_price                       => l_est_detail_rec.list_price,
    p_activity_start_date_time         => l_est_detail_rec.activity_start_time,
    p_activity_end_date_time           => l_est_detail_rec.activity_end_time,
    p_contract_discount_amount         => l_est_detail_rec.contract_discount_amount,
    p_bill_to_party_id                 => l_est_detail_rec.bill_to_party_id,
    p_ship_to_party_id                 => l_est_detail_rec.ship_to_party_id,
    p_pricing_context                  => l_est_detail_rec.pricing_context,
    p_pricing_attribute1               => l_est_detail_rec.pricing_attribute1,
    p_pricing_attribute2               => l_est_detail_rec.pricing_attribute2,
    p_pricing_attribute3               => l_est_detail_rec.pricing_attribute3,
    p_pricing_attribute4               => l_est_detail_rec.pricing_attribute4,
    p_pricing_attribute5               => l_est_detail_rec.pricing_attribute5,
    p_pricing_attribute6               => l_est_detail_rec.pricing_attribute6,
    p_pricing_attribute7               => l_est_detail_rec.pricing_attribute7,
    p_pricing_attribute8               => l_est_detail_rec.pricing_attribute8,
    p_pricing_attribute9               => l_est_detail_rec.pricing_attribute9,
    p_pricing_attribute10              => l_est_detail_rec.pricing_attribute10,
    p_pricing_attribute11              => l_est_detail_rec.pricing_attribute11,
    p_pricing_attribute12              => l_est_detail_rec.pricing_attribute12,
    p_pricing_attribute13              => l_est_detail_rec.pricing_attribute13,
    p_pricing_attribute14              => l_est_detail_rec.pricing_attribute14,
    p_pricing_attribute15              => l_est_detail_rec.pricing_attribute15,
    p_pricing_attribute16              => l_est_detail_rec.pricing_attribute16,
    p_pricing_attribute17              => l_est_detail_rec.pricing_attribute17,
    p_pricing_attribute18              => l_est_detail_rec.pricing_attribute18,
    p_pricing_attribute19              => l_est_detail_rec.pricing_attribute19,
    p_pricing_attribute20              => l_est_detail_rec.pricing_attribute20,
    p_pricing_attribute21              => l_est_detail_rec.pricing_attribute21,
    p_pricing_attribute22              => l_est_detail_rec.pricing_attribute22,
    p_pricing_attribute23              => l_est_detail_rec.pricing_attribute23,
    p_pricing_attribute24              => l_est_detail_rec.pricing_attribute24,
    p_pricing_attribute25              => l_est_detail_rec.pricing_attribute25,
    p_pricing_attribute26              => l_est_detail_rec.pricing_attribute26,
    p_pricing_attribute27              => l_est_detail_rec.pricing_attribute27,
    p_pricing_attribute28              => l_est_detail_rec.pricing_attribute28,
    p_pricing_attribute29              => l_est_detail_rec.pricing_attribute29,
    p_pricing_attribute30              => l_est_detail_rec.pricing_attribute30,
    p_pricing_attribute31              => l_est_detail_rec.pricing_attribute31,
    p_pricing_attribute32              => l_est_detail_rec.pricing_attribute32,
    p_pricing_attribute33              => l_est_detail_rec.pricing_attribute33,
    p_pricing_attribute34              => l_est_detail_rec.pricing_attribute34,
    p_pricing_attribute35              => l_est_detail_rec.pricing_attribute35,
    p_pricing_attribute36              => l_est_detail_rec.pricing_attribute36,
    p_pricing_attribute37              => l_est_detail_rec.pricing_attribute37,
    p_pricing_attribute38              => l_est_detail_rec.pricing_attribute38,
    p_pricing_attribute39              => l_est_detail_rec.pricing_attribute39,
    p_pricing_attribute40              => l_est_detail_rec.pricing_attribute40,
    p_pricing_attribute41              => l_est_detail_rec.pricing_attribute41,
    p_pricing_attribute42              => l_est_detail_rec.pricing_attribute42,
    p_pricing_attribute43              => l_est_detail_rec.pricing_attribute43,
    p_pricing_attribute44              => l_est_detail_rec.pricing_attribute44,
    p_pricing_attribute45              => l_est_detail_rec.pricing_attribute45,
    p_pricing_attribute46              => l_est_detail_rec.pricing_attribute46,
    p_pricing_attribute47              => l_est_detail_rec.pricing_attribute47,
    p_pricing_attribute48              => l_est_detail_rec.pricing_attribute48,
    p_pricing_attribute49              => l_est_detail_rec.pricing_attribute49,
    p_pricing_attribute50              => l_est_detail_rec.pricing_attribute50,
    p_pricing_attribute51              => l_est_detail_rec.pricing_attribute51,
    p_pricing_attribute52              => l_est_detail_rec.pricing_attribute52,
    p_pricing_attribute53              => l_est_detail_rec.pricing_attribute53,
    p_pricing_attribute54              => l_est_detail_rec.pricing_attribute54,
    p_pricing_attribute55              => l_est_detail_rec.pricing_attribute55,
    p_pricing_attribute56              => l_est_detail_rec.pricing_attribute56,
    p_pricing_attribute57              => l_est_detail_rec.pricing_attribute57,
    p_pricing_attribute58              => l_est_detail_rec.pricing_attribute58,
    p_pricing_attribute59              => l_est_detail_rec.pricing_attribute59,
    p_pricing_attribute60              => l_est_detail_rec.pricing_attribute60,
    p_pricing_attribute61              => l_est_detail_rec.pricing_attribute61,
    p_pricing_attribute62              => l_est_detail_rec.pricing_attribute62,
    p_pricing_attribute63              => l_est_detail_rec.pricing_attribute63,
    p_pricing_attribute64              => l_est_detail_rec.pricing_attribute64,
    p_pricing_attribute65              => l_est_detail_rec.pricing_attribute65,
    p_pricing_attribute66              => l_est_detail_rec.pricing_attribute66,
    p_pricing_attribute67              => l_est_detail_rec.pricing_attribute67,
    p_pricing_attribute68              => l_est_detail_rec.pricing_attribute68,
    p_pricing_attribute69              => l_est_detail_rec.pricing_attribute69,
    p_pricing_attribute70              => l_est_detail_rec.pricing_attribute70,
    p_pricing_attribute71              => l_est_detail_rec.pricing_attribute71,
    p_pricing_attribute72              => l_est_detail_rec.pricing_attribute72,
    p_pricing_attribute73              => l_est_detail_rec.pricing_attribute73,
    p_pricing_attribute74              => l_est_detail_rec.pricing_attribute74,
    p_pricing_attribute75              => l_est_detail_rec.pricing_attribute75,
    p_pricing_attribute76              => l_est_detail_rec.pricing_attribute76,
    p_pricing_attribute77              => l_est_detail_rec.pricing_attribute77,
    p_pricing_attribute78              => l_est_detail_rec.pricing_attribute78,
    p_pricing_attribute79              => l_est_detail_rec.pricing_attribute79,
    p_pricing_attribute80              => l_est_detail_rec.pricing_attribute80,
    p_pricing_attribute81              => l_est_detail_rec.pricing_attribute81,
    p_pricing_attribute82              => l_est_detail_rec.pricing_attribute82,
    p_pricing_attribute83              => l_est_detail_rec.pricing_attribute83,
    p_pricing_attribute84              => l_est_detail_rec.pricing_attribute84,
    p_pricing_attribute85              => l_est_detail_rec.pricing_attribute85,
    p_pricing_attribute86              => l_est_detail_rec.pricing_attribute86,
    p_pricing_attribute87              => l_est_detail_rec.pricing_attribute87,
    p_pricing_attribute88              => l_est_detail_rec.pricing_attribute88,
    p_pricing_attribute89              => l_est_detail_rec.pricing_attribute89,
    p_pricing_attribute90              => l_est_detail_rec.pricing_attribute90,
    p_pricing_attribute91              => l_est_detail_rec.pricing_attribute91,
    p_pricing_attribute92              => l_est_detail_rec.pricing_attribute92,
    p_pricing_attribute93              => l_est_detail_rec.pricing_attribute93,
    p_pricing_attribute94              => l_est_detail_rec.pricing_attribute94,
    p_pricing_attribute95              => l_est_detail_rec.pricing_attribute95,
    p_pricing_attribute96              => l_est_detail_rec.pricing_attribute96,
    p_pricing_attribute97              => l_est_detail_rec.pricing_attribute97,
    p_pricing_attribute98              => l_est_detail_rec.pricing_attribute98,
    p_pricing_attribute99              => l_est_detail_rec.pricing_attribute99,
    p_pricing_attribute100             => l_est_detail_rec.pricing_attribute100,
    p_attribute1                       => l_est_detail_rec.attribute1,
    p_attribute2                       => l_est_detail_rec.attribute2,
    p_attribute3                       => l_est_detail_rec.attribute3,
    p_attribute4                       => l_est_detail_rec.attribute4,
    p_attribute5                       => l_est_detail_rec.attribute5,
    p_attribute6                       => l_est_detail_rec.attribute6,
    p_attribute7                       => l_est_detail_rec.attribute7,
    p_attribute8                       => l_est_detail_rec.attribute8,
    p_attribute9                       => l_est_detail_rec.attribute9,
    p_attribute10                      => l_est_detail_rec.attribute10,
    p_attribute11                      => l_est_detail_rec.attribute11,
    p_attribute12                      => l_est_detail_rec.attribute12,
    p_attribute13                      => l_est_detail_rec.attribute13,
    p_attribute14                      => l_est_detail_rec.attribute14,
    p_attribute15                      => l_est_detail_rec.attribute15,
    p_context                          => l_est_detail_rec.context,
    p_coverage_bill_rate_id            => l_est_detail_rec.coverage_bill_rate_id,
    p_coverage_billing_type_id         => null,
    p_txn_billing_type_id              => l_est_detail_rec.txn_billing_type_id,
    p_submit_restriction_message       => l_est_detail_rec.submit_restriction_message,
    p_submit_error_message             => l_est_detail_rec.submit_error_message,
    p_submit_from_system               => l_est_detail_rec.submit_from_system,
    p_line_submitted                   => nvl(l_est_detail_rec.line_submitted_flag, 'N'),
    p_last_update_date                 => sysdate,
    --p_last_update_login              => p_user_id,
    p_last_update_login                => p_login_id,
    p_last_updated_by                  => p_user_id,
    p_creation_date                    => sysdate,
    p_created_by                       => p_user_id,
    p_estimate_detail_id               => l_ed_id,
    /* Credit Card 9358401 */
    p_instrument_payment_use_id        => l_est_detail_rec.instrument_payment_use_id,
    x_object_version_number            => x_object_version_number );

  --DBMS_OUTPUT.PUT_LINE('Back from CS_ESTIMATE_DETAILS_PKG.INSERT_ROW. OVN '||x_object_version_number);

  -- hint: primary key should be returned.
  -- x_estimate_detail_id := x_estimate_detail_id;

  x_estimate_detail_id      := l_ed_id ;
  x_line_number             := nvl(l_line_num,1) ;


  -- Make the postprocessing call to the user hooks
  --
  -- Post call to the customer type user hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_CHARGE_DETAILS_PVT',
 			       'Create_Charge_Details',
			       'A','C') THEN

    CS_CHARGE_DETAILS_CUHK.Create_Charge_Details_Post(
		p_api_version      	   => l_api_version,
		p_init_msg_list    	   => FND_API.G_FALSE,
		p_commit           	   => p_commit,
		p_validation_level 	   => p_validation_level,
		x_return_status    	   => l_return_status,
		x_msg_count       	   => x_msg_count,
		x_object_version_number    => x_object_version_number,
                x_estimate_detail_id       => l_ed_id,
                x_line_number              => l_line_num,
		x_msg_data         	   => x_msg_data,
		p_resp_appl_id    	   => p_resp_appl_id,
		p_resp_id          	   => p_resp_id,
    	        p_user_id          	   => p_user_id,
		p_login_id         	   => p_login_id,
                p_transaction_control      => p_transaction_control,
		p_est_detail_rec           => p_est_detail_rec);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_ERR_PST_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;
  --
  --
  -- Post call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_CHARGE_DETAILS_PVT',
                               'Create_Charge_Details',
                               'A', 'V')  THEN

    CS_CHARGE_DETAILS_VUHK.Create_Charge_Details_Post(
		p_api_version      	   => l_api_version,
		p_init_msg_list    	   => FND_API.G_FALSE,
		p_commit           	   => p_commit,
		p_validation_level 	   => p_validation_level,
		x_return_status    	   => l_return_status,
		x_msg_count       	   => x_msg_count,
		x_object_version_number    => x_object_version_number,
       	        x_estimate_detail_id       => l_ed_id,
       	        x_line_number              => l_line_num,
		x_msg_data         	   => x_msg_data,
		p_resp_appl_id    	   => p_resp_appl_id,
		p_resp_id          	   => p_resp_id,
    		p_user_id          	   => p_user_id,
		p_login_id         	   => p_login_id,
       	        p_transaction_control      => p_transaction_control,
		p_est_detail_rec           => p_est_detail_rec);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_ERR_PST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;


  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => FND_API.G_FALSE) ;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      IF FND_API.To_Boolean(p_transaction_control) THEN
        ROLLBACK TO Create_Charge_Details_PVT;
      END IF ;


      FND_MSG_PUB.Count_And_Get(p_count    => x_msg_count,
                                p_data     => x_msg_data,
                                p_encoded  => FND_API.G_FALSE) ;


      x_return_status := FND_API.G_RET_STS_ERROR;



      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF FND_API.To_Boolean(p_transaction_control) THEN
        ROLLBACK TO Create_Charge_Details_PVT;
      END IF ;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE) ;
      WHEN OTHERS THEN
      --l_errm := SQLERRM;
      --DBMS_OUTPUT.PUT_LINE('OTHERS inside CREATE_CHARGE_DETAILS '||l_errm);

      IF FND_API.To_Boolean(p_transaction_control) THEN
        ROLLBACK TO Create_Charge_Details_PVT;
      END IF ;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                p_data    => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;

END Create_Charge_Details;


--=====================================================
--API to Update Charge Details into CS_ESTIMATE_DETAILS
--=====================================================

PROCEDURE Update_Charge_Details(
        p_api_version           IN         NUMBER,
        p_init_msg_list         IN         VARCHAR2          := FND_API.G_FALSE,
        p_commit                IN         VARCHAR2          := FND_API.G_FALSE,
        p_validation_level      IN         NUMBER            := FND_API.G_VALID_LEVEL_FULL,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_object_version_number OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
      --p_resp_appl_id          IN         NUMBER            := NULL,
      --p_resp_id               IN         NUMBER            := NULL,
      --p_user_id               IN         NUMBER            := NULL,
        p_resp_appl_id          IN         NUMBER            := FND_GLOBAL.RESP_APPL_ID,
        p_resp_id               IN         NUMBER            := FND_GLOBAL.RESP_ID,
        p_user_id               IN         NUMBER            := FND_GLOBAL.USER_ID,
        p_login_id              IN         NUMBER            := NULL,
        p_transaction_control   IN         VARCHAR2          := FND_API.G_TRUE,
        p_est_detail_rec        IN         CS_Charge_Details_PUB.Charges_Rec_Type
                ) IS

l_api_version                     NUMBER                 :=  1.0 ;
l_api_name                        VARCHAR2(30)           := 'Update_Charge_Details' ;
l_api_name_full                   VARCHAR2(61)           :=  G_PKG_NAME || '.' || l_api_name ;
l_log_module            CONSTANT  VARCHAR2(255)          := 'cs.plsql.' || l_api_name_full || '.';
l_return_status                   VARCHAR2(1) ;

l_line_num                        NUMBER                 :=  1 ;
l_ed_id                           NUMBER ;
l_org_id                          NUMBER ;
l_est_detail_rec                  CS_Charge_Details_PUB.Charges_Rec_Type;

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'update_charge_details';

BEGIN

  --DBMS_OUTPUT.PUT_LINE('Updating Charge Details');

  -- Standard start of API savepoint
  IF FND_API.To_Boolean(p_transaction_control) THEN
    SAVEPOINT Update_Charge_Details_PVT;
  END IF ;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_appl_id:' || p_resp_appl_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_id:' || p_resp_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_user_id:' || p_user_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_login_id:' || p_login_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_transaction_control:' || p_transaction_control
    );

 -- --------------------------------------------------------------------------
 -- This procedure Logs the charges record paramters.
 -- --------------------------------------------------------------------------
    CS_Charge_Details_PUB.Log_Charges_Rec_Parameters
    ( p_Charges_Rec             =>  p_est_detail_rec
    );

  END IF;

  -- Make the preprocessing call to the user hooks
  --
  -- Pre call to the customer type user hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_CHARGE_DETAILS_PVT',
                               'Update_Charge_Details',
                               'B','C') THEN

    CS_CHARGE_DETAILS_CUHK.Update_Charge_Details_Pre(
                  p_api_version              => l_api_version,
                  p_init_msg_list            => FND_API.G_FALSE,
                  p_commit                   => p_commit,
                  p_validation_level         => p_validation_level,
                  x_return_status            => l_return_status,
                  x_msg_count                => x_msg_count,
                  x_object_version_number    => x_object_version_number,
                  x_estimate_detail_id       => l_ed_id,
                  x_msg_data                 => x_msg_data,
                  p_resp_appl_id             => p_resp_appl_id,
                  p_resp_id                  => p_resp_id,
                  p_user_id                  => p_user_id,
                  p_login_id                 => p_login_id,
                  p_transaction_control      => p_transaction_control,
                  p_est_detail_rec           => p_est_detail_rec);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_ERR_PRE_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;
  --
  --
  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_CHARGE_DETAILS_PVT',
                               'Update_Charge_Details',
                               'B', 'V')  THEN

    CS_CHARGE_DETAILS_VUHK.Update_Charge_Details_Pre(
                p_api_version              => l_api_version,
                p_init_msg_list            => FND_API.G_FALSE,
                p_commit                   => p_commit,
                p_validation_level         => p_validation_level,
                x_return_status            => l_return_status,
                x_msg_count                => x_msg_count,
                x_object_version_number    => x_object_version_number,
                x_estimate_detail_id       => l_ed_id,
                x_msg_data                 => x_msg_data,
                p_resp_appl_id             => p_resp_appl_id,
                p_resp_id                  => p_resp_id,
                p_user_id                  => p_user_id,
                p_login_id                 => p_login_id,
                p_transaction_control      => p_transaction_control,
                p_est_detail_rec           => p_est_detail_rec);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_ERR_PRE_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  -- ----------------------------------------------------------------------
  -- Apply business-rule validation to all required and passed parameters
  -- if validation level is set.
  -- ----------------------------------------------------------------------
  IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN

    --  Validate the user and login ids

    Validate_Who_Info ( p_api_name             => l_api_name_full,
                        p_user_id              => NVL(p_user_id, -1),
                        p_login_id             => p_login_id,
                        x_return_status        => l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('validating charge details');

    -- Validate the Charge Detail Record that is passed in by the Upstream Module
    VALIDATE_CHARGE_DETAILS(p_api_name           => l_api_name,
                            p_charges_detail_rec => p_est_detail_rec,
                            p_validation_mode    => 'U',
                            p_user_id            => p_user_id,
                            p_login_id           => p_login_id,
                            x_charges_detail_rec => l_est_detail_rec,
                            x_msg_data           => x_msg_data,
                            x_msg_count          => x_msg_count,
                            x_return_status      => l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.Set_Name('CS', 'CS_CHG_VALIDATE_CHRG_DETAIL_ER');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   --Fixed Bug # 3795144
   ELSE
    --p_validation_level = FND_API.G_VALID_LEVEL_NONE
    IF (p_validation_level = FND_API.G_VALID_LEVEL_NONE) THEN
      --populate the l_est_detail_rec record
      l_est_detail_rec := p_est_detail_rec;
    END IF;
   END IF ;

  --DBMS_OUTPUT.PUT_LINE('Calling CS_ESTIMATE_DETAILS_PKG.UPDATE_ROW');
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.org_id = '||l_est_detail_rec.org_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.incident_id = '||l_est_detail_rec.incident_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.original_source_id = '||l_est_detail_rec.original_source_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.original_source_code = '||l_est_detail_rec.original_source_code);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.source_id = '||l_est_detail_rec.source_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.source_code = '||l_est_detail_rec.source_code);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.contract_id = '||l_est_detail_rec.contract_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.coverage_id = '||l_est_detail_rec.coverage_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.coverage_txn_group_id = '||l_est_detail_rec.coverage_txn_group_id);
  --DBMS_OUTPUT.PUT_LINE('l_EST_DETAIL_rec.currency_code = '||l_EST_DETAIL_rec.currency_code);
  --DBMS_OUTPUT.PUT_LINE('l_EST_DETAIL_rec.conversion_rate = '||l_EST_DETAIL_rec.conversion_rate);
  --DBMS_OUTPUT.PUT_LINE('l_EST_DETAIL_rec.conversion_rate_date = '||l_EST_DETAIL_rec.conversion_rate_date);
  --DBMS_OUTPUT.PUT_LINE('l_EST_DETAIL_rec.conversion_type_code = '||l_EST_DETAIL_rec.conversion_type_code);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.invoice_to_org_id = '||l_est_detail_rec.invoice_to_org_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.ship_to_org_id = '||l_est_detail_rec.ship_to_org_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.purchase_order_num = '||l_est_detail_rec.purchase_order_num);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.order_line_id = '||l_est_detail_rec.order_line_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.line_type_id = '||l_est_detail_rec.line_type_id);
  --DBMS_OUTPUT.PUT_LINE('l_EST_DETAIL_rec.LINE_CATEGORY_CODE = '||l_EST_DETAIL_rec.LINE_CATEGORY_CODE);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.price_list_id = '||l_est_detail_rec.price_list_id);
  --DBMS_OUTPUT.PUT_LINE('l_line_num = '||l_line_num);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.inventory_item_id_in = '||l_est_detail_rec.inventory_item_id_in);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.item_revision = '||l_est_detail_rec.item_revision);
  --DBMS_OUTPUT.PUT_LINE('l_EST_DETAIL_rec.SERIAL_NUMBER = '||l_EST_DETAIL_rec.SERIAL_NUMBER);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.quantity_required = '||l_est_detail_rec.quantity_required);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.unit_of_measure_code = '||l_est_detail_rec.unit_of_measure_code);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.selling_price = '||l_est_detail_rec.selling_price);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.after_warranty_cost = '||l_est_detail_rec.after_warranty_cost);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.business_process_id = '||l_est_detail_rec.business_process_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.transaction_type_id = '||l_est_detail_rec.transaction_type_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.customer_product_id = '||l_est_detail_rec.customer_product_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.order_header_id = '||l_est_detail_rec.order_header_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.installed_cp_return_by_date = '||l_est_detail_rec.installed_cp_return_by_date);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.new_cp_return_by_date = '||l_est_detail_rec.new_cp_return_by_date);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.interface_to_oe_flag = '||l_est_detail_rec.interface_to_oe_flag);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.rollup_flag = '||l_est_detail_rec.rollup_flag);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.no_charge_flag = '||l_est_detail_rec.no_charge_flag);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.add_to_order_flag = '||l_est_detail_rec.add_to_order_flag);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.return_reason_code = '||l_est_detail_rec.return_reason_code);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.generated_by_bca_engine = '||l_est_detail_rec.generated_by_bca_engine);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.transaction_inventory_org = '||l_est_detail_rec.transaction_inventory_org);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.transaction_sub_inventory = '||l_est_detail_rec.transaction_sub_inventory);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.charge_line_type = '||l_est_detail_rec.charge_line_type);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.ship_to_account_id = '||l_est_detail_rec.ship_to_account_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.bill_to_account_id = '||l_est_detail_rec.bill_to_account_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.ship_to_contact_id = '||l_est_detail_rec.ship_to_contact_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.bill_to_contact_id = '||l_est_detail_rec.bill_to_contact_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.list_price = '||l_est_detail_rec.list_price);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.activity_start_time = '||TO_CHAR(l_est_detail_rec.activity_start_time, 'DD-MON-YYYY HH24:MI:SS'));
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.activity_end_time = '||TO_CHAR(l_est_detail_rec.activity_end_time, 'DD-MON-YYYY HH24:MI:SS'));
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.contract_discount_amount = '||l_est_detail_rec.contract_discount_amount);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.bill_to_party_id = '||l_est_detail_rec.bill_to_party_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.ship_to_party_id = '||l_est_detail_rec.ship_to_party_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.coverage_bill_rate_id = '||l_est_detail_rec.coverage_bill_rate_id);
  --DBMS_OUTPUT.PUT_LINE('l_est_detail_rec.txn_billing_type_id = '||l_est_detail_rec.txn_billing_type_id);
  --DBMS_OUTPUT.PUT_LINE('p_login_id = '||p_login_id);
  --DBMS_OUTPUT.PUT_LINE('p_user_id = '||p_user_id);
  --DBMS_OUTPUT.PUT_LINE('p_user_id = '||p_user_id);
  --DBMS_OUTPUT.PUT_LINE('l_ed_id = '||l_ed_id);
  --DBMS_OUTPUT.PUT_LINE('Before  Update '||l_est_detail_rec.CONTRACT_ID);

  CS_ESTIMATE_DETAILS_PKG.Update_Row(
          x_object_version_number        => x_object_version_number,
          p_ESTIMATE_DETAIL_ID           => l_est_detail_rec.ESTIMATE_DETAIL_ID,
          p_ORG_ID                       => l_est_detail_rec.org_id,
          p_INCIDENT_ID                  => l_est_detail_rec.INCIDENT_ID,
          p_ORIGINAL_SOURCE_ID           => l_est_detail_rec.ORIGINAL_SOURCE_ID,
          p_ORIGINAL_SOURCE_CODE         => l_est_detail_rec.ORIGINAL_SOURCE_CODE,
          p_SOURCE_ID                    => l_est_detail_rec.SOURCE_ID,
          p_SOURCE_CODE                  => l_est_detail_rec.SOURCE_CODE,
          p_contract_line_id             => l_est_detail_rec.contract_line_id,
          p_rate_type_code               => l_est_detail_rec.rate_type_code,
          p_contract_id                  => l_est_detail_rec.CONTRACT_ID,
          p_coverage_id                  => null,
          p_coverage_txn_group_id        => null,
          --p_EXCEPTION_COVERAGE_USED    => l_est_detail_rec.EXCEPTION_COVERAGE_USED,
          p_CURRENCY_CODE                => l_est_detail_rec.currency_code,
          p_CONVERSION_RATE              => NULL,
          p_CONVERSION_TYPE_CODE         => NULL,
          p_CONVERSION_RATE_DATE         => NULL,
          p_INVOICE_TO_ORG_ID            => l_est_detail_rec.INVOICE_TO_ORG_ID,
          p_SHIP_TO_ORG_ID               => l_est_detail_rec.SHIP_TO_ORG_ID,
          p_PURCHASE_ORDER_NUM           => l_est_detail_rec.PURCHASE_ORDER_NUM,
          p_ORDER_LINE_ID                => l_est_detail_rec.ORDER_LINE_ID,
          p_LINE_TYPE_ID                 => l_est_detail_rec.LINE_TYPE_ID,
          p_LINE_CATEGORY_CODE           => l_est_detail_rec.LINE_CATEGORY_CODE,
          p_PRICE_LIST_HEADER_ID         => l_est_detail_rec.PRICE_LIST_ID,
          p_LINE_NUMBER                  => l_est_detail_rec.line_number,
          p_INVENTORY_ITEM_ID            => l_est_detail_rec.INVENTORY_ITEM_ID_in,
          p_ITEM_REVISION                => l_est_detail_rec.ITEM_REVISION,
          p_SERIAL_NUMBER                => l_est_detail_rec.SERIAL_NUMBER,
          p_QUANTITY_REQUIRED            => l_est_detail_rec.QUANTITY_REQUIRED,
          p_UNIT_OF_MEASURE_CODE         => l_est_detail_rec.UNIT_OF_MEASURE_CODE,
          p_SELLING_PRICE                => l_est_detail_rec.SELLING_PRICE,
          p_AFTER_WARRANTY_COST          => l_est_detail_rec.AFTER_WARRANTY_COST,
          --p_FUNC_CURR_AFT_WARR_COST    => l_est_detail_rec.FUNC_CURR_AFT_WARR_COST,
          p_BUSINESS_PROCESS_ID          => l_est_detail_rec.BUSINESS_PROCESS_ID,
          p_TRANSACTION_TYPE_ID          => l_est_detail_rec.TRANSACTION_TYPE_ID,
          p_CUSTOMER_PRODUCT_ID          => l_est_detail_rec.CUSTOMER_PRODUCT_ID,
          p_ORDER_HEADER_ID              => l_est_detail_rec.ORDER_HEADER_ID,
          p_INSTALLED_CP_RETURN_BY_DATE  => l_est_detail_rec.INSTALLED_CP_RETURN_BY_DATE,
          p_NEW_CP_RETURN_BY_DATE        => l_est_detail_rec.NEW_CP_RETURN_BY_DATE,
          p_INTERFACE_TO_OE_FLAG         => nvl(l_est_detail_rec.INTERFACE_TO_OE_FLAG, 'N'),
          p_ROLLUP_FLAG                  => nvl(l_est_detail_rec.ROLLUP_FLAG, 'N'),
          p_no_charge_flag               => nvl(l_est_detail_rec.NO_CHARGE_FLAG, 'N'),
          p_ADD_TO_ORDER_FLAG            => nvl(l_est_detail_rec.ADD_TO_ORDER_FLAG, 'N'),
          p_RETURN_REASON_CODE           => l_est_detail_rec.RETURN_REASON_CODE,
          p_GENERATED_BY_BCA_ENGINE_FLAG => nvl(l_est_detail_rec.GENERATED_BY_BCA_ENGINE, 'N'),
          p_TRANSACTION_INVENTORY_ORG    => l_est_detail_rec.TRANSACTION_INVENTORY_ORG,
          p_TRANSACTION_SUB_INVENTORY    => l_est_detail_rec.TRANSACTION_SUB_INVENTORY,
          p_CHARGE_LINE_TYPE             => l_est_detail_rec.CHARGE_LINE_TYPE,
          p_SHIP_TO_ACCOUNT_ID           => l_est_detail_rec.SHIP_TO_ACCOUNT_ID,
          p_INVOICE_TO_ACCOUNT_ID        => l_est_detail_rec.BILL_TO_ACCOUNT_ID,
          p_SHIP_TO_CONTACT_ID           => l_est_detail_rec.SHIP_TO_CONTACT_ID,
          p_BILL_TO_CONTACT_ID           => l_est_detail_rec.BILL_TO_CONTACT_ID,
          p_LIST_PRICE                   => l_est_detail_rec.LIST_PRICE,--mviswana
          p_ACTIVITY_START_DATE_TIME     => l_est_detail_rec.ACTIVITY_START_TIME,
          p_ACTIVITY_END_DATE_TIME       => l_est_detail_rec.ACTIVITY_END_TIME,
          p_CONTRACT_DISCOUNT_AMOUNT     => l_est_detail_rec.CONTRACT_DISCOUNT_AMOUNT,
          p_BILL_TO_PARTY_ID             => l_est_detail_rec.BILL_TO_PARTY_ID,
          p_SHIP_TO_PARTY_ID             => l_est_detail_rec.SHIP_TO_PARTY_ID,
          --p_tax_code                   => l_est_detail_rec.tax_code,
          --p_est_tax_amount             => l_est_detail_rec.est_tax_amount,
          p_PRICING_CONTEXT              => l_est_detail_rec.PRICING_CONTEXT,
          p_PRICING_ATTRIBUTE1           => l_est_detail_rec.PRICING_ATTRIBUTE1,
          p_PRICING_ATTRIBUTE2           => l_est_detail_rec.PRICING_ATTRIBUTE2,
          p_PRICING_ATTRIBUTE3           => l_est_detail_rec.PRICING_ATTRIBUTE3,
          p_PRICING_ATTRIBUTE4           => l_est_detail_rec.PRICING_ATTRIBUTE4,
          p_PRICING_ATTRIBUTE5           => l_est_detail_rec.PRICING_ATTRIBUTE5,
          p_PRICING_ATTRIBUTE6           => l_est_detail_rec.PRICING_ATTRIBUTE6,
          p_PRICING_ATTRIBUTE7           => l_est_detail_rec.PRICING_ATTRIBUTE7,
          p_PRICING_ATTRIBUTE8           => l_est_detail_rec.PRICING_ATTRIBUTE8,
          p_PRICING_ATTRIBUTE9           => l_est_detail_rec.PRICING_ATTRIBUTE9,
          p_PRICING_ATTRIBUTE10          => l_est_detail_rec.PRICING_ATTRIBUTE10,
          p_PRICING_ATTRIBUTE11          => l_est_detail_rec.PRICING_ATTRIBUTE11,
          p_PRICING_ATTRIBUTE12          => l_est_detail_rec.PRICING_ATTRIBUTE12,
          p_PRICING_ATTRIBUTE13          => l_est_detail_rec.PRICING_ATTRIBUTE13,
          p_PRICING_ATTRIBUTE14          => l_est_detail_rec.PRICING_ATTRIBUTE14,
          p_PRICING_ATTRIBUTE15          => l_est_detail_rec.PRICING_ATTRIBUTE15,
          p_PRICING_ATTRIBUTE16          => l_est_detail_rec.PRICING_ATTRIBUTE16,
          p_PRICING_ATTRIBUTE17          => l_est_detail_rec.PRICING_ATTRIBUTE17,
          p_PRICING_ATTRIBUTE18          => l_est_detail_rec.PRICING_ATTRIBUTE18,
          p_PRICING_ATTRIBUTE19          => l_est_detail_rec.PRICING_ATTRIBUTE19,
          p_PRICING_ATTRIBUTE20          => l_est_detail_rec.PRICING_ATTRIBUTE20,
          p_PRICING_ATTRIBUTE21          => l_est_detail_rec.PRICING_ATTRIBUTE21,
          p_PRICING_ATTRIBUTE22          => l_est_detail_rec.PRICING_ATTRIBUTE22,
          p_PRICING_ATTRIBUTE23          => l_est_detail_rec.PRICING_ATTRIBUTE23,
          p_PRICING_ATTRIBUTE24          => l_est_detail_rec.PRICING_ATTRIBUTE24,
          p_pricing_attribute25          => l_est_detail_rec.pricing_attribute25,
          p_pricing_attribute26          => l_est_detail_rec.pricing_attribute26,
          p_pricing_attribute27          => l_est_detail_rec.pricing_attribute27,
          p_pricing_attribute28          => l_est_detail_rec.pricing_attribute28,
          p_pricing_attribute29          => l_est_detail_rec.pricing_attribute29,
          p_pricing_attribute30          => l_est_detail_rec.pricing_attribute30,
          p_pricing_attribute31          => l_est_detail_rec.pricing_attribute31,
          p_pricing_attribute32          => l_est_detail_rec.pricing_attribute32,
          p_pricing_attribute33          => l_est_detail_rec.pricing_attribute33,
          p_pricing_attribute34          => l_est_detail_rec.pricing_attribute34,
          p_pricing_attribute35          => l_est_detail_rec.pricing_attribute35,
          p_pricing_attribute36          => l_est_detail_rec.pricing_attribute36,
          p_pricing_attribute37          => l_est_detail_rec.pricing_attribute37,
          p_pricing_attribute38          => l_est_detail_rec.pricing_attribute38,
          p_pricing_attribute39          => l_est_detail_rec.pricing_attribute39,
          p_pricing_attribute40          => l_est_detail_rec.pricing_attribute40,
          p_pricing_attribute41          => l_est_detail_rec.pricing_attribute41,
          p_pricing_attribute42          => l_est_detail_rec.pricing_attribute42,
          p_pricing_attribute43          => l_est_detail_rec.pricing_attribute43,
          p_pricing_attribute44          => l_est_detail_rec.pricing_attribute44,
          p_pricing_attribute45          => l_est_detail_rec.pricing_attribute45,
          p_pricing_attribute46          => l_est_detail_rec.pricing_attribute46,
          p_pricing_attribute47          => l_est_detail_rec.pricing_attribute47,
          p_pricing_attribute48          => l_est_detail_rec.pricing_attribute48,
          p_pricing_attribute49          => l_est_detail_rec.pricing_attribute49,
          p_pricing_attribute50          => l_est_detail_rec.pricing_attribute50,
          p_pricing_attribute51          => l_est_detail_rec.pricing_attribute51,
          p_pricing_attribute52          => l_est_detail_rec.pricing_attribute52,
          p_pricing_attribute53          => l_est_detail_rec.pricing_attribute53,
          p_pricing_attribute54          => l_est_detail_rec.pricing_attribute54,
          p_pricing_attribute55          => l_est_detail_rec.pricing_attribute55,
          p_pricing_attribute56          => l_est_detail_rec.pricing_attribute56,
          p_pricing_attribute57          => l_est_detail_rec.pricing_attribute57,
          p_pricing_attribute58          => l_est_detail_rec.pricing_attribute58,
          p_pricing_attribute59          => l_est_detail_rec.pricing_attribute59,
          p_pricing_attribute60          => l_est_detail_rec.pricing_attribute60,
          p_pricing_attribute61          => l_est_detail_rec.pricing_attribute61,
          p_pricing_attribute62          => l_est_detail_rec.pricing_attribute62,
          p_pricing_attribute63          => l_est_detail_rec.pricing_attribute63,
          p_pricing_attribute64          => l_est_detail_rec.pricing_attribute64,
          p_pricing_attribute65          => l_est_detail_rec.pricing_attribute65,
          p_pricing_attribute66          => l_est_detail_rec.pricing_attribute66,
          p_pricing_attribute67          => l_est_detail_rec.pricing_attribute67,
          p_pricing_attribute68          => l_est_detail_rec.pricing_attribute68,
          p_pricing_attribute69          => l_est_detail_rec.pricing_attribute69,
          p_pricing_attribute70          => l_est_detail_rec.pricing_attribute70,
          p_pricing_attribute71          => l_est_detail_rec.pricing_attribute71,
          p_pricing_attribute72          => l_est_detail_rec.pricing_attribute72,
          p_pricing_attribute73          => l_est_detail_rec.pricing_attribute73,
          p_pricing_attribute74          => l_est_detail_rec.pricing_attribute74,
          p_pricing_attribute75          => l_est_detail_rec.pricing_attribute75,
          p_pricing_attribute76          => l_est_detail_rec.pricing_attribute76,
          p_pricing_attribute77          => l_est_detail_rec.pricing_attribute77,
          p_pricing_attribute78          => l_est_detail_rec.pricing_attribute78,
          p_pricing_attribute79          => l_est_detail_rec.pricing_attribute79,
          p_pricing_attribute80          => l_est_detail_rec.pricing_attribute80,
          p_pricing_attribute81          => l_est_detail_rec.pricing_attribute81,
          p_pricing_attribute82          => l_est_detail_rec.pricing_attribute82,
          p_pricing_attribute83          => l_est_detail_rec.pricing_attribute83,
          p_pricing_attribute84          => l_est_detail_rec.pricing_attribute84,
          p_pricing_attribute85          => l_est_detail_rec.pricing_attribute85,
          p_pricing_attribute86          => l_est_detail_rec.pricing_attribute86,
          p_pricing_attribute87          => l_est_detail_rec.pricing_attribute87,
          p_pricing_attribute88          => l_est_detail_rec.pricing_attribute88,
          p_pricing_attribute89          => l_est_detail_rec.pricing_attribute89,
          p_pricing_attribute90          => l_est_detail_rec.pricing_attribute90,
          p_pricing_attribute91          => l_est_detail_rec.pricing_attribute91,
          p_pricing_attribute92          => l_est_detail_rec.pricing_attribute92,
          p_pricing_attribute93          => l_est_detail_rec.pricing_attribute93,
          p_pricing_attribute94          => l_est_detail_rec.pricing_attribute94,
          p_pricing_attribute95          => l_est_detail_rec.pricing_attribute95,
          p_pricing_attribute96          => l_est_detail_rec.pricing_attribute96,
          p_pricing_attribute97          => l_est_detail_rec.pricing_attribute97,
          p_pricing_attribute98          => l_est_detail_rec.pricing_attribute98,
          p_pricing_attribute99          => l_est_detail_rec.pricing_attribute99,
          p_pricing_attribute100         => l_est_detail_rec.pricing_attribute100,
          p_attribute1                   => l_est_detail_rec.attribute1,
          p_attribute2                   => l_est_detail_rec.attribute2,
          p_attribute3                   => l_est_detail_rec.attribute3,
          p_attribute4                   => l_est_detail_rec.attribute4,
          p_attribute5                   => l_est_detail_rec.attribute5,
          p_attribute6                   => l_est_detail_rec.attribute6,
          p_attribute7                   => l_est_detail_rec.attribute7,
          p_attribute8                   => l_est_detail_rec.attribute8,
          p_attribute9                   => l_est_detail_rec.attribute9,
          p_attribute10                  => l_est_detail_rec.attribute10,
          p_attribute11                  => l_est_detail_rec.attribute11,
          p_attribute12                  => l_est_detail_rec.attribute12,
          p_attribute13                  => l_est_detail_rec.attribute13,
          p_attribute14                  => l_est_detail_rec.attribute14,
          p_attribute15                  => l_est_detail_rec.attribute15,
          p_context                      => l_est_detail_rec.context,
          --p_organization_id            => l_est_detail_rec.organization_id,
          p_coverage_bill_rate_id        => l_est_detail_rec.coverage_bill_rate_id,
          p_coverage_billing_type_id     => null,
          p_txn_billing_type_id          => l_est_detail_rec.txn_billing_type_id,
          p_submit_restriction_message   => l_est_detail_rec.submit_restriction_message,
          p_submit_error_message         => l_est_detail_rec.submit_error_message,
          p_submit_from_system           => l_est_detail_rec.submit_from_system,
          p_line_submitted               => nvl(l_est_detail_rec.line_submitted_flag, 'N'),
          p_last_update_date             => sysdate,
          p_last_update_login            => p_login_id,
          p_last_updated_by              => p_user_id,
          p_creation_date                => sysdate,
          p_created_by                   => p_user_id,
          /* Credit Card 9358401 */
          p_instrument_payment_use_id    => l_est_detail_rec.instrument_payment_use_id
          );

        -- Make the postprocessing call to the user hooks
        --
        -- Post call to the customer type user hook
        --
        IF jtf_usr_hks.Ok_To_Execute('CS_CHARGE_DETAILS_PVT',
                                     'Update_Charge_Details',
                                     'A','C') THEN

        CS_CHARGE_DETAILS_CUHK.Update_Charge_Details_Post(
                p_api_version               => l_api_version,
                p_init_msg_list             => FND_API.G_FALSE,
                p_commit                    => p_commit,
                p_validation_level          => p_validation_level,
                x_return_status             => l_return_status,
                x_msg_count                 => x_msg_count,
                x_object_version_number     => x_object_version_number,
                x_estimate_detail_id        => l_ed_id,
                x_msg_data                  => x_msg_data,
                p_resp_appl_id              => p_resp_appl_id,
                p_resp_id                   => p_resp_id,
                p_user_id                   => p_user_id,
                p_login_id                  => p_login_id,
                p_transaction_control       => p_transaction_control,
                p_est_detail_rec            => p_est_detail_rec);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
          FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_ERR_PST_CUST_USR_HK');
          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

  END IF;
  --
  --
  -- Post call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_CHARGE_DETAILS_PVT',
                               'Update_Charge_Details',
                               'A', 'V')  THEN

    CS_CHARGE_DETAILS_VUHK.Update_Charge_Details_Post(
                p_api_version               => l_api_version,
                p_init_msg_list             => FND_API.G_FALSE,
                p_commit                    => p_commit,
                p_validation_level          => p_validation_level,
                x_return_status             => l_return_status,
                x_msg_count                 => x_msg_count,
                x_object_version_number     => x_object_version_number,
                x_estimate_detail_id        => l_ed_id,
                x_msg_data                  => x_msg_data,
                p_resp_appl_id              => p_resp_appl_id,
                p_resp_id                   => p_resp_id,
                p_user_id                   => p_user_id,
                p_login_id                  => p_login_id,
                p_transaction_control       => p_transaction_control,
                p_est_detail_rec            => p_est_detail_rec);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_ERR_PST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;
  --
  --

  --Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
  (p_count => x_msg_count,
   p_data  => x_msg_data,
   p_encoded => FND_API.G_FALSE) ;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    );


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean(p_transaction_control) THEN
        ROLLBACK TO Update_Charge_Details_PVT;
      END IF ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count    => x_msg_count,
        p_data     => x_msg_data,
        p_encoded  => FND_API.G_FALSE) ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF FND_API.To_Boolean(p_transaction_control) THEN
        ROLLBACK TO Update_Charge_Details_PVT;
      END IF ;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_transaction_control) THEN
        ROLLBACK TO Update_Charge_Details_PVT;

      END IF ;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;

END Update_Charge_Details;

--==========================================================
-- API Delete Charge Details
-- Purpose: Delete a given a charge detail line
--          from CS_ESTIMATE_DETAILS based on the unique id
--          estimate_detail_id
--==========================================================

Procedure  Delete_Charge_Details(
             p_api_version          IN         NUMBER,
             p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
             p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
             p_validation_level     IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
             x_return_status        OUT NOCOPY VARCHAR2,
             x_msg_count            OUT NOCOPY NUMBER,
             x_msg_data             OUT NOCOPY VARCHAR2,
             p_transaction_control  IN         VARCHAR2 := FND_API.G_TRUE,
             p_estimate_detail_id   IN         NUMBER   := NULL)  AS

l_api_name       CONSTANT  VARCHAR2(30) := 'Delete_Charge_Details' ;
l_api_name_full  CONSTANT  VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
l_log_module     CONSTANT VARCHAR2(255) := 'cs.plsql.' || l_api_name_full || '.';
l_api_version    CONSTANT  NUMBER       := 1.0 ;

l_resp_appl_id          NUMBER  ;
l_resp_id               NUMBER  ;
l_user_id               NUMBER  ;
l_login_id              NUMBER  ;
l_org_id                NUMBER          := NULL ;
l_order_line_id         NUMBER ;
l_gen_bca_flag          VARCHAR2(1);
l_charge_line_type      VARCHAR2(30);
l_return_status         VARCHAR2(1) ;

l_estimate_detail_id    NUMBER := p_estimate_detail_id ;
l_charge_det_rec        CS_Charge_Details_PUB.Charges_Rec_Type;


l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'delete_charge_details';


BEGIN

  --Standard Start of API Savepoint
  IF FND_API.To_Boolean( p_transaction_control ) THEN
    SAVEPOINT   Delete_Charge_Details_PUB ;
  END IF ;

  --Standard Call to check API compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version,
     p_api_version,
     l_api_name,
     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;

  --Initialize the message list  if p_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list)   THEN
    FND_MSG_PUB.initialize ;
  END IF ;

  --Initialize the API Return Success to True
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_transaction_control:' || p_transaction_control
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_estimate_detail_id:' || p_estimate_detail_id
    );

  END IF;

  --Check for mandatory params estimate detail id
  --If  not passed or are null then raise error

  IF (p_estimate_detail_id IS NULL) THEN
    Add_Null_Parameter_Msg(l_api_name_full,
                           'p_estimate_detail_id') ;

    Add_Invalid_Argument_Msg(l_api_name_full,
                             to_char(p_estimate_detail_id),
                             'p_estimate_detail_id');
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  -- Check to see if Transactions exits in Order Management

  Do_Txns_Exist(l_api_name_full,
                p_estimate_detail_id,
                l_order_line_id,
                l_gen_bca_flag,
                l_charge_line_type,
                l_return_status) ;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  IF l_order_line_id IS NOT NULL THEN
    Cannot_Delete_Line_Msg(l_api_name_full) ;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  --Bug Fix for Bug # 3136630

  --IF l_gen_bca_flag IS NOT NULL THEN
  --  IF l_gen_bca_flag = 'Y' AND
  IF l_charge_line_type = 'IN PROGRESS' THEN
    Cannot_Delete_Line_Msg(l_api_name_full) ;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;
 -- END IF;

  DELETE FROM
  CS_ESTIMATE_DETAILS
  WHERE ESTIMATE_DETAIL_ID = p_estimate_detail_id ;

  --End of API Body
  --Standard Check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK ;
  END IF ;

  --Standard call to get  message count and if count is 1 , get message info
  FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                            p_data => x_msg_data) ;

  --Begin Exception Handling

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Delete_Charge_Details_PUB;
    END IF ;
  x_return_status :=  FND_API.G_RET_STS_ERROR ;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;



  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Delete_Charge_Details_PUB;
    END IF ;
  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;

  WHEN OTHERS THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Delete_Charge_Details_PUB;
    END IF ;
  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END IF ;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;

END  Delete_Charge_Details;   -- End of Procedure Delete Charge Details



--==================================
--Copy Estimates
--==================================
-- New API added for 11.5.10
-- mviswana
Procedure  Copy_Estimate(
        p_api_version         IN         NUMBER,
        p_init_msg_list       IN         VARCHAR2 := FND_API.G_FALSE,
        p_commit              IN         VARCHAR2 := FND_API.G_FALSE,
        p_transaction_control IN         VARCHAR2 := FND_API.G_TRUE,
        p_estimate_detail_id  IN         NUMBER   := NULL,
        x_estimate_detail_id  OUT NOCOPY NUMBER,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2 ) IS

l_api_version       NUMBER               :=  1.0 ;
l_api_name          VARCHAR2(30)         := 'Copy_Estimate' ;
l_api_name_full     VARCHAR2(61)         :=  G_PKG_NAME || '.' || l_api_name ;
l_log_module     CONSTANT VARCHAR2(255)  := 'cs.plsql.' || l_api_name_full || '.';
l_return_status     VARCHAR2(1) ;
l_est_detail_id     NUMBER;
l_line_number       NUMBER;
l_obj_ver_num       NUMBER;
l_est_detail_rec    CS_Charge_Details_PUB.Charges_Rec_Type;

cursor c_charges_rec(p_estimate_detail_id NUMBER) IS
select *
from cs_estimate_details
where estimate_detail_id = p_estimate_detail_id;

v_charges_rec c_charges_rec%ROWTYPE;
x_cost_id number;

l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

BEGIN

  --DBMS_OUTPUT.PUT_LINE('BEGIN copy_estimates');

  -- Standard start of API savepoint
  IF FND_API.To_Boolean(p_transaction_control) THEN
    SAVEPOINT Copy_Estimate_PVT;
  END IF ;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_transaction_control:' || p_transaction_control
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_estimate_detail_id:' || p_estimate_detail_id
    );

  END IF;

  -- ======================================================================
  -- Actual start of the program body.
  -- ======================================================================

  -- =========================================
  -- Validate the incoming estimate_detail_id
  -- =========================================

  IF p_estimate_detail_id IS NULL THEN
    FND_MESSAGE.SET_NAME('CS', 'CS_CHG_NOT_A_VALID_CHARGE_LINE');
    FND_MESSAGE.SET_TOKEN('ESTIMATE_DETAIL_ID', p_estimate_detail_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --DBMS_OUTPUT.PUT_LINE('passed 1st val');

  OPEN c_charges_rec(p_estimate_detail_id);
  FETCH c_charges_rec INTO v_charges_rec;
  IF c_charges_rec%NOTFOUND THEN
    CLOSE c_charges_rec;
    FND_MESSAGE.SET_NAME('CS', 'CS_CHG_NOT_A_VALID_CHARGE_LINE');
    FND_MESSAGE.SET_TOKEN('ESTIMATE_DETAIL_ID', p_estimate_detail_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_charges_rec;

  --DBMS_OUTPUT.PUT_LINE('passed 2ndst val');

  IF v_charges_rec.charge_line_type <> 'ESTIMATE' THEN
    FND_MESSAGE.SET_NAME('CS', 'CS_CHG_NOT_AN_ESTIMATE');
    FND_MESSAGE.SET_TOKEN('ESTIMATE_DETAIL_ID', p_estimate_detail_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --DBMS_OUTPUT.PUT_LINE('passed 3rd val');

  --populate the charges rec with values from v_charges_rec

  l_est_detail_rec.incident_id                  :=   v_charges_rec.incident_id;
  l_est_detail_rec.charge_line_type             :=   'ACTUAL';
  -- fix for bug:5125385
  -- l_est_detail_rec.line_number               :=   1;
  l_est_detail_rec.line_number                  :=   NULL;
  l_est_detail_rec.business_process_id          :=   v_charges_rec.business_process_id;
  l_est_detail_rec.transaction_type_id          :=   v_charges_rec.transaction_type_id;
  l_est_detail_rec.inventory_item_id_in         :=   v_charges_rec.inventory_item_id;
  l_est_detail_rec.item_revision                :=   v_charges_rec.item_revision;
  l_est_detail_rec.billing_flag                 :=   NULL;
  l_est_detail_rec.txn_billing_type_id          :=   v_charges_rec.txn_billing_type_id;
  l_est_detail_rec.unit_of_measure_code         :=   v_charges_rec.unit_of_measure_code;
  l_est_detail_rec.quantity_required            :=   v_charges_rec.quantity_required;
  l_est_detail_rec.return_reason_code           :=   v_charges_rec.return_reason_code;
  l_est_detail_rec.customer_product_id          :=   v_charges_rec.customer_product_id;
  l_est_detail_rec.serial_number                :=   v_charges_rec.serial_number;
  l_est_detail_rec.installed_cp_return_by_date  :=   v_charges_rec.installed_cp_return_by_date;
  l_est_detail_rec.new_cp_return_by_date        :=   v_charges_rec.new_cp_return_by_date;
  l_est_detail_rec.bill_to_party_id             :=   v_charges_rec.bill_to_party_id;
  l_est_detail_rec.bill_to_account_id           :=   v_charges_rec.INVOICE_TO_ACCOUNT_ID;
  l_est_detail_rec.bill_to_contact_id           :=   v_charges_rec.bill_to_contact_id;
  l_est_detail_rec.invoice_to_org_id            :=   v_charges_rec.invoice_to_org_id;
  l_est_detail_rec.ship_to_party_id             :=   v_charges_rec.ship_to_party_id;
  l_est_detail_rec.ship_to_account_id           :=   v_charges_rec.ship_to_account_id;
  l_est_detail_rec.ship_to_contact_id           :=   v_charges_rec.ship_to_contact_id;
  l_est_detail_rec.ship_to_org_id               :=   v_charges_rec.ship_to_org_id;
  l_est_detail_rec.contract_id                  :=   v_charges_rec.contract_id;
  l_est_detail_rec.contract_line_id             :=   v_charges_rec.contract_line_id;
  l_est_detail_rec.coverage_id                  :=   v_charges_rec.coverage_id;
  l_est_detail_rec.coverage_txn_group_id        :=   v_charges_rec.coverage_txn_group_id;
  l_est_detail_rec.coverage_bill_rate_id        :=   v_charges_rec.coverage_bill_rate_id;
  l_est_detail_rec.coverage_billing_type_id     :=   v_charges_rec.coverage_billing_type_id;
  l_est_detail_rec.price_list_id                :=   v_charges_rec.PRICE_LIST_HEADER_ID;
  l_est_detail_rec.currency_code                :=   v_charges_rec.currency_code;
  l_est_detail_rec.purchase_order_num           :=   v_charges_rec.purchase_order_num;
  l_est_detail_rec.list_price                   :=   v_charges_rec.list_price;



  --how do we know this we do not trap this value
  l_est_detail_rec.con_pct_over_list_price      :=   null;
  l_est_detail_rec.selling_price                :=   v_charges_rec.selling_price;
  l_est_detail_rec.contract_discount_amount     :=   v_charges_rec.contract_discount_amount;

  --how do we know when to apply contract discount if we do not trap this value
  l_est_detail_rec.apply_contract_discount      :=   'N' ;


  l_est_detail_rec.after_warranty_cost          :=   v_charges_rec.after_warranty_cost;
  l_est_detail_rec.transaction_inventory_org    :=   v_charges_rec.transaction_inventory_org;
  l_est_detail_rec.transaction_sub_inventory    :=   v_charges_rec.transaction_sub_inventory;
  l_est_detail_rec.rollup_flag                  :=   v_charges_rec.rollup_flag;
  l_est_detail_rec.add_to_order_flag            :=   v_charges_rec.add_to_order_flag;
  l_est_detail_rec.order_header_id              :=   v_charges_rec.order_header_id;
  l_est_detail_rec.interface_to_oe_flag         :=   v_charges_rec.interface_to_oe_flag;
  l_est_detail_rec.no_charge_flag               :=   v_charges_rec.no_charge_flag;
  l_est_detail_rec.line_category_code           :=   v_charges_rec.line_category_code;
  l_est_detail_rec.line_type_id                 :=   v_charges_rec.line_type_id;
  l_est_detail_rec.order_line_id                :=   v_charges_rec.order_line_id;
  l_est_detail_rec.conversion_rate              :=   v_charges_rec.conversion_rate;
  l_est_detail_rec.conversion_type_code         :=   v_charges_rec.conversion_type_code;
  l_est_detail_rec.conversion_rate_date         :=   v_charges_rec.conversion_rate_date;
  l_est_detail_rec.original_source_id           :=   v_charges_rec.original_source_id;
  l_est_detail_rec.original_source_code         :=   v_charges_rec.original_source_code;
  l_est_detail_rec.source_id                    :=   v_charges_rec.source_id;
  l_est_detail_rec.source_code                  :=   v_charges_rec.source_code;
  l_est_detail_rec.org_id                       :=   v_charges_rec.org_id;



  --Error Handling
  l_est_detail_rec.submit_restriction_message   :=   v_charges_rec.submit_restriction_message;
  l_est_detail_rec.submit_error_message         :=   v_charges_rec.submit_error_message;

  --DBMS_OUTPUT.PUT_LINE('submit_restriction_message is '||l_est_detail_rec.submit_restriction_message);
  --DBMS_OUTPUT.PUT_LINE('submit_error_message is '||l_est_detail_rec.submit_error_message);


  --Auto Submission Process
  l_est_detail_rec.submit_from_system           :=   v_charges_rec.submit_from_system;

  --Billing Engine
  --Fixed Bug # 3362046
  l_est_detail_rec.activity_start_time          :=   v_charges_rec.activity_start_date_time;
  l_est_detail_rec.activity_end_time            :=   v_charges_rec.activity_end_date_time;
  l_est_detail_rec.generated_by_bca_engine      :=   v_charges_rec.generated_by_bca_engine_flag;

  l_est_detail_rec.attribute1                   :=   v_charges_rec.attribute1;
  l_est_detail_rec.attribute2                   :=   v_charges_rec.attribute2;
  l_est_detail_rec.attribute3                   :=   v_charges_rec.attribute3;
  l_est_detail_rec.attribute4                   :=   v_charges_rec.attribute4;
  l_est_detail_rec.attribute5                   :=   v_charges_rec.attribute5;
  l_est_detail_rec.attribute6                   :=   v_charges_rec.attribute6;
  l_est_detail_rec.attribute7                   :=   v_charges_rec.attribute7;
  l_est_detail_rec.attribute8                   :=   v_charges_rec.attribute8;
  l_est_detail_rec.attribute9                   :=   v_charges_rec.attribute9;
  l_est_detail_rec.attribute10                  :=   v_charges_rec.attribute10;
  l_est_detail_rec.attribute11                  :=   v_charges_rec.attribute11;
  l_est_detail_rec.attribute12                  :=   v_charges_rec.attribute12;
  l_est_detail_rec.attribute13                  :=   v_charges_rec.attribute13;
  l_est_detail_rec.attribute14                  :=   v_charges_rec.attribute14;
  l_est_detail_rec.attribute15                  :=   v_charges_rec.attribute15;
  l_est_detail_rec.context                      :=   v_charges_rec.context;
  l_est_detail_rec.pricing_context              :=   v_charges_rec.pricing_context;
  l_est_detail_rec.pricing_attribute1           :=   v_charges_rec.pricing_attribute1;
  l_est_detail_rec.pricing_attribute2           :=   v_charges_rec.pricing_attribute2 ;
  l_est_detail_rec.pricing_attribute3           :=   v_charges_rec.pricing_attribute3 ;
  l_est_detail_rec.pricing_attribute4           :=   v_charges_rec.pricing_attribute4 ;
  l_est_detail_rec.pricing_attribute5           :=   v_charges_rec.pricing_attribute5 ;
  l_est_detail_rec.pricing_attribute6           :=   v_charges_rec.pricing_attribute6 ;
  l_est_detail_rec.pricing_attribute7           :=   v_charges_rec.pricing_attribute7 ;
  l_est_detail_rec.pricing_attribute8           :=   v_charges_rec.pricing_attribute8 ;
  l_est_detail_rec.pricing_attribute9           :=   v_charges_rec.pricing_attribute9 ;
  l_est_detail_rec.pricing_attribute10          :=   v_charges_rec.pricing_attribute10;
  l_est_detail_rec.pricing_attribute11          :=   v_charges_rec.pricing_attribute11;
  l_est_detail_rec.pricing_attribute12          :=   v_charges_rec.pricing_attribute12;
  l_est_detail_rec.pricing_attribute13          :=   v_charges_rec.pricing_attribute13;
  l_est_detail_rec.pricing_attribute14          :=   v_charges_rec.pricing_attribute14;
  l_est_detail_rec.pricing_attribute15          :=   v_charges_rec.pricing_attribute15;
  l_est_detail_rec.pricing_attribute16          :=   v_charges_rec.pricing_attribute16;
  l_est_detail_rec.pricing_attribute17          :=   v_charges_rec.pricing_attribute17;
  l_est_detail_rec.pricing_attribute18          :=   v_charges_rec.pricing_attribute18;
  l_est_detail_rec.pricing_attribute19          :=   v_charges_rec.pricing_attribute19;
  l_est_detail_rec.pricing_attribute20          :=   v_charges_rec.pricing_attribute20;
  l_est_detail_rec.pricing_attribute21          :=   v_charges_rec.pricing_attribute21;
  l_est_detail_rec.pricing_attribute22          :=   v_charges_rec.pricing_attribute22;
  l_est_detail_rec.pricing_attribute23          :=   v_charges_rec.pricing_attribute23;
  l_est_detail_rec.pricing_attribute24          :=   v_charges_rec.pricing_attribute24;
  l_est_detail_rec.pricing_attribute25          :=   v_charges_rec.pricing_attribute25;
  l_est_detail_rec.pricing_attribute26          :=   v_charges_rec.pricing_attribute26;
  l_est_detail_rec.pricing_attribute27          :=   v_charges_rec.pricing_attribute27;
  l_est_detail_rec.pricing_attribute28          :=   v_charges_rec.pricing_attribute28;
  l_est_detail_rec.pricing_attribute29          :=   v_charges_rec.pricing_attribute29;
  l_est_detail_rec.pricing_attribute30          :=   v_charges_rec.pricing_attribute30;
  l_est_detail_rec.pricing_attribute31          :=   v_charges_rec.pricing_attribute31;
  l_est_detail_rec.pricing_attribute32          :=   v_charges_rec.pricing_attribute32;
  l_est_detail_rec.pricing_attribute33          :=   v_charges_rec.pricing_attribute33;
  l_est_detail_rec.pricing_attribute34          :=   v_charges_rec.pricing_attribute34;
  l_est_detail_rec.pricing_attribute35          :=   v_charges_rec.pricing_attribute35;
  l_est_detail_rec.pricing_attribute36          :=   v_charges_rec.pricing_attribute36;
  l_est_detail_rec.pricing_attribute37          :=   v_charges_rec.pricing_attribute37;
  l_est_detail_rec.pricing_attribute38          :=   v_charges_rec.pricing_attribute38;
  l_est_detail_rec.pricing_attribute39          :=   v_charges_rec.pricing_attribute39;
  l_est_detail_rec.pricing_attribute40          :=   v_charges_rec.pricing_attribute40;
  l_est_detail_rec.pricing_attribute41          :=   v_charges_rec.pricing_attribute41;
  l_est_detail_rec.pricing_attribute42          :=   v_charges_rec.pricing_attribute42;
  l_est_detail_rec.pricing_attribute43          :=   v_charges_rec.pricing_attribute43;
  l_est_detail_rec.pricing_attribute44          :=   v_charges_rec.pricing_attribute44;
  l_est_detail_rec.pricing_attribute45          :=   v_charges_rec.pricing_attribute45;
  l_est_detail_rec.pricing_attribute46          :=   v_charges_rec.pricing_attribute46;
  l_est_detail_rec.pricing_attribute47          :=   v_charges_rec.pricing_attribute47;
  l_est_detail_rec.pricing_attribute48          :=   v_charges_rec.pricing_attribute48;
  l_est_detail_rec.pricing_attribute49          :=   v_charges_rec.pricing_attribute49;
  l_est_detail_rec.pricing_attribute50          :=   v_charges_rec.pricing_attribute50;
  l_est_detail_rec.pricing_attribute51          :=   v_charges_rec.pricing_attribute51;
  l_est_detail_rec.pricing_attribute52          :=   v_charges_rec.pricing_attribute52;
  l_est_detail_rec.pricing_attribute53          :=   v_charges_rec.pricing_attribute53;
  l_est_detail_rec.pricing_attribute54          :=   v_charges_rec.pricing_attribute54;
  l_est_detail_rec.pricing_attribute55          :=   v_charges_rec.pricing_attribute56;
  l_est_detail_rec.pricing_attribute56          :=   v_charges_rec.pricing_attribute56;
  l_est_detail_rec.pricing_attribute57          :=   v_charges_rec.pricing_attribute57;
  l_est_detail_rec.pricing_attribute58          :=   v_charges_rec.pricing_attribute58;
  l_est_detail_rec.pricing_attribute59          :=   v_charges_rec.pricing_attribute59;
  l_est_detail_rec.pricing_attribute60          :=   v_charges_rec.pricing_attribute60;
  l_est_detail_rec.pricing_attribute61          :=   v_charges_rec.pricing_attribute61;
  l_est_detail_rec.pricing_attribute62          :=   v_charges_rec.pricing_attribute62;
  l_est_detail_rec.pricing_attribute63          :=   v_charges_rec.pricing_attribute63;
  l_est_detail_rec.pricing_attribute64          :=   v_charges_rec.pricing_attribute64;
  l_est_detail_rec.pricing_attribute65          :=   v_charges_rec.pricing_attribute65;
  l_est_detail_rec.pricing_attribute66          :=   v_charges_rec.pricing_attribute66;
  l_est_detail_rec.pricing_attribute67          :=   v_charges_rec.pricing_attribute67;
  l_est_detail_rec.pricing_attribute68          :=   v_charges_rec.pricing_attribute68;
  l_est_detail_rec.pricing_attribute69          :=   v_charges_rec.pricing_attribute69;
  l_est_detail_rec.pricing_attribute70          :=   v_charges_rec.pricing_attribute70;
  l_est_detail_rec.pricing_attribute71          :=   v_charges_rec.pricing_attribute71;
  l_est_detail_rec.pricing_attribute72          :=   v_charges_rec.pricing_attribute72;
  l_est_detail_rec.pricing_attribute73          :=   v_charges_rec.pricing_attribute73;
  l_est_detail_rec.pricing_attribute74          :=   v_charges_rec.pricing_attribute74;
  l_est_detail_rec.pricing_attribute75          :=   v_charges_rec.pricing_attribute75;
  l_est_detail_rec.pricing_attribute76          :=   v_charges_rec.pricing_attribute76;
  l_est_detail_rec.pricing_attribute77          :=   v_charges_rec.pricing_attribute77;
  l_est_detail_rec.pricing_attribute78          :=   v_charges_rec.pricing_attribute78;
  l_est_detail_rec.pricing_attribute79          :=   v_charges_rec.pricing_attribute79;
  l_est_detail_rec.pricing_attribute80          :=   v_charges_rec.pricing_attribute80;
  l_est_detail_rec.pricing_attribute81          :=   v_charges_rec.pricing_attribute81;
  l_est_detail_rec.pricing_attribute82          :=   v_charges_rec.pricing_attribute82;
  l_est_detail_rec.pricing_attribute83          :=   v_charges_rec.pricing_attribute83;
  l_est_detail_rec.pricing_attribute84          :=   v_charges_rec.pricing_attribute84;
  l_est_detail_rec.pricing_attribute85          :=   v_charges_rec.pricing_attribute85;
  l_est_detail_rec.pricing_attribute86          :=   v_charges_rec.pricing_attribute86;
  l_est_detail_rec.pricing_attribute87          :=   v_charges_rec.pricing_attribute87;
  l_est_detail_rec.pricing_attribute88          :=   v_charges_rec.pricing_attribute88;
  l_est_detail_rec.pricing_attribute89          :=   v_charges_rec.pricing_attribute89;
  l_est_detail_rec.pricing_attribute90          :=   v_charges_rec.pricing_attribute90;
  l_est_detail_rec.pricing_attribute91          :=   v_charges_rec.pricing_attribute91;
  l_est_detail_rec.pricing_attribute92          :=   v_charges_rec.pricing_attribute92;
  l_est_detail_rec.pricing_attribute93          :=   v_charges_rec.pricing_attribute93;
  l_est_detail_rec.pricing_attribute94          :=   v_charges_rec.pricing_attribute94;
  l_est_detail_rec.pricing_attribute95          :=   v_charges_rec.pricing_attribute95;
  l_est_detail_rec.pricing_attribute96          :=   v_charges_rec.pricing_attribute96;
  l_est_detail_rec.pricing_attribute97          :=   v_charges_rec.pricing_attribute97;
  l_est_detail_rec.pricing_attribute98          :=   v_charges_rec.pricing_attribute98;
  l_est_detail_rec.pricing_attribute99          :=   v_charges_rec.pricing_attribute99;
  l_est_detail_rec.pricing_attribute100         :=   v_charges_rec.pricing_attribute100;
/*Credit Card 9358401*/
  l_est_detail_rec.instrument_payment_use_id    :=   v_charges_rec.instrument_payment_use_id;


  -- Call Create Charge Details to create line

  --DBMS_OUTPUT.PUT_LINE('Calling CS_Charge_Details_PUB.Create_Charge_Details');


  CS_Charge_Details_PUB.Create_Charge_Details(
    p_api_version    => l_api_version,
    p_commit         => fnd_api.g_false,
    p_init_msg_list  => fnd_api.g_false,
    x_msg_count      => x_msg_count,
    x_msg_data       => x_msg_data,
    x_return_status  => l_return_status,
    p_Charges_Rec    => l_est_detail_rec,
    p_create_cost_detail => 'Y' ,       --Added for  Service Costing
    x_cost_id             => x_cost_id, --Added for Service Costing
    x_estimate_detail_id  =>  x_estimate_detail_id,
    x_line_number        =>  l_line_number,
    x_object_version_number => l_obj_ver_num
    ) ;




 --DBMS_OUTPUT.PUT_LINE('Estimate detail Id is'||l_est_detail_id);

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --End of API Body
  --Standard Check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK ;
  END IF ;

  --Standard call to get  message count and if count is 1 , get message info
  FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                            p_data => x_msg_data) ;



  --Begin Exception Handling

  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Copy_Estimates_PVT;
    END IF ;

  x_return_status :=  FND_API.G_RET_STS_ERROR ;

  FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                            p_data    => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Copy_Estimates_PVT;
    END IF ;

  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;
  WHEN OTHERS THEN
    IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Copy_Estimates_PVT;
    END IF ;

  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level
    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END IF ;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;

END Copy_Estimate;


--==================================
-- Validate_Chrg_Dtls
--==================================
PROCEDURE VALIDATE_CHARGE_DETAILS(
                 P_API_NAME                  IN            VARCHAR2,
                 P_CHARGES_DETAIL_REC        IN            CS_Charge_Details_PUB.Charges_Rec_Type,
                 P_VALIDATION_MODE           IN            VARCHAR2,
                 P_USER_ID                   IN            NUMBER,
                 P_LOGIN_ID                  IN            NUMBER,
                 X_CHARGES_DETAIL_REC        OUT NOCOPY    CS_Charge_Details_PUB.Charges_Rec_Type,
                 X_MSG_DATA                  OUT NOCOPY    VARCHAR2,
                 X_MSG_COUNT                 OUT NOCOPY    NUMBER,
                 X_RETURN_STATUS             OUT NOCOPY    VARCHAR2)
IS

l_api_name                  CONSTANT   VARCHAR2(30) := 'Validate_Charge_Details' ;
l_api_name_full             CONSTANT   VARCHAR2(61) :=  G_PKG_NAME || '.' || l_api_name ;
l_log_module                CONSTANT VARCHAR2(255)  := 'cs.plsql.' || l_api_name_full || '.';
l_business_process_id                  NUMBER;
l_line_order_category_code             VARCHAR2(30);
l_no_charge_flag                       VARCHAR2(1);
l_create_charge_flag		       VARCHAR2(1); --costing enhancement
l_interface_to_oe_flag                 VARCHAR2(1);
l_update_ib_flag                       VARCHAR2(1);
l_src_reference_reqd_flag              VARCHAR2(1);
l_src_return_reqd_flag                 VARCHAR2(1);
l_non_src_reference_reqd_flag          VARCHAR2(1);
l_non_src_return_reqd                  VARCHAR2(1);
l_non_src_return_reqd_flag             VARCHAR2(1);
l_serial_control_flag                  VARCHAR2(1);
l_rev_control_flag                     VARCHAR2(1);
l_billing_flag                         VARCHAR2(30);
l_tbl_uom                              TBL_UOM;
l_primary_uom                          VARCHAR2(3);
l_txn_billing_type_id                  NUMBER;
l_line_type_id                         NUMBER;
l_order_header_id                      NUMBER;
l_def_bp_from_sr                       VARCHAR2(1) := 'N';
l_org_id                               NUMBER;

l_msg_data                             VARCHAR2(2000);
l_msg_count                            NUMBER;
l_profile                              VARCHAR2(200);
l_source_id                            NUMBER;
l_return_status                        VARCHAR2(1);
l_customer_id                          NUMBER;
l_customer_site_id                     NUMBER;
--Changed this to fix bug # 3667210
--Changed to VARCHAR2(50) as per table specification
l_cust_po_number                       VARCHAR2(50);
l_cust_product_id                      NUMBER;
l_system_id                            NUMBER;
l_inventory_item_id                    NUMBER;
l_account_id                           NUMBER;
l_bill_to_party_id                     NUMBER;
l_bill_to_account_id                   NUMBER;
l_bill_to_contact_id                   NUMBER;
l_bill_to_site_id                      NUMBER;
l_ship_to_party_id                     NUMBER;
l_ship_to_account_id                   NUMBER;
l_ship_to_contact_id                   NUMBER;
l_ship_to_site_id                      NUMBER;
l_contract_id                          NUMBER;
l_contract_service_id                  NUMBER;
l_po_number                            VARCHAR2(50);
l_price_list_exists                    VARCHAR2(1);
l_price_list_id                        NUMBER;
-- Changed length of the currency code to 15 for bug # 4120556
l_currency_code                        VARCHAR2(15);
l_conversion_needed_flag               VARCHAR2(1);
l_convert_currency                     VARCHAR2(10);
l_rate NUMBER;
l_numerator                            NUMBER;
l_denominator                          NUMBER;
l_list_price                           NUMBER;
l_contract_discount                    NUMBER;
l_db_rec                               CS_ESTIMATE_DETAILS%ROWTYPE;

l_transaction_type_changed             VARCHAR2(1);
l_item_changed                         VARCHAR2(1);

l_incident_date                        DATE;
l_creation_date                        DATE;
l_request_date                         DATE;
l_contract_line_id                     NUMBER;

--RF
l_db_det_rec                           CS_ESTIMATE_DETAILS%ROWTYPE;
l_calc_sp                              VARCHAR2(1);

--Fix for Bug # 3362130
l_comms_trackable_flag                 VARCHAR2(1);

l_in_oe_flag                           VARCHAR2(1) := 'N';
l_in_ib_flag                           VARCHAR2(1) := 'N';
l_rollup_flag                          VARCHAR2(1) := 'N';
l_bp_changed                           VARCHAR2(1) := 'N';
l_update_org                           VARCHAR2(10);

l_valid_check                          VARCHAR2(1);


l_disallow_new_charge                  VARCHAR2(1);
l_disallow_charge_update               VARCHAR2(1);

-- Added to fix Bug # 3819167
-- Fixed Bug # 3913707
-- l_absolute_quantity_required           NUMBER;

-- Added for bug # 4395867
l_original_source VARCHAR2(30);
l_source VARCHAR2(30);
l_pricing_date Date; -- Bug 	7117553
l_profile_value Varchar2(100); -- Bug 	7117553

-- Added for bug#5125934
l_serial_number                         VARCHAR2(30);


--taklam
l_internal_party_id                    NUMBER;
l_src_change_owner                     VARCHAR2(1);

-- Depot Loaner fix - Bug# 4586140
l_action_code   varchar2(30);

l_credit_status  boolean := TRUE;--Credit Card 9358401

Cursor C_SRC_CHANGE_OWNER(p_txn_billing_type_id NUMBER) IS
SELECT src_change_owner
FROM CSI_IB_TXN_TYPES
WHERE cs_transaction_type_id = p_txn_billing_type_id;

-- Depot Loaner fix - Bug# 4586140
-- Cursor to get depot details
/* Fix bug:5198520 */
Cursor c_get_depot_txns_details (p_estimate_detail_id in number) is
SELECT action_code
FROM   csd_product_transactions
WHERE  estimate_detail_id = p_estimate_detail_id;

/* Select action_code
from csd_product_txns_v
where estimate_detail_id = p_estimate_detail_id; */

-- Added for bug#5125934
Cursor c_serial_number(p_instance_id NUMBER) IS
SELECT serial_number
FROM   csi_item_instances
WHERE  instance_id = p_instance_id;

BEGIN

  --Standard Start of API Savepoint
  SAVEPOINT Validate_Charge_Details_PUB;

  --Initialize the API Return Success to True
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --DBMS_OUTPUT.PUT_LINE('BEGIN VALIDATE_CHARGE_DETAILS');
  --DBMS_OUTPUT.PUT_LINE('Cust_product_id is '||P_CHARGES_DETAIL_REC.customer_product_id);
  --DBMS_OUTPUT.PUT_LINE('Apply contract_discount '||P_CHARGES_DETAIL_REC.apply_contract_discount);

  --=============================
  --Estimate Detail ID Validation
  --==============================
  --DBMS_OUTPUT.PUT_LINE('Estimate Detail ID Validation ...');

  --DBMS_OUTPUT.PUT_LINE('Estimate Detail Id : '||p_charges_detail_rec.estimate_detail_id);

  --Check to see that estimate_detail_id is passed
  --If not passed the give error
  --If passed then validate and then
  --get the charges record from the database

  IF p_validation_mode = 'U' THEN
    IF p_charges_detail_rec.estimate_detail_id IS NULL OR
       p_charges_detail_rec.estimate_detail_id = FND_API.G_MISS_NUM THEN

      Add_Null_Parameter_Msg(l_api_name,
                             'estimate_detail_id') ;

      Add_Invalid_Argument_Msg(l_api_name,
                               TO_CHAR(p_charges_detail_rec.estimate_detail_id),
                               'estimate_detail_id');
      RAISE FND_API.G_EXC_ERROR;

    ELSE

      IF IS_ESTIMATE_DETAIL_ID_VALID(p_estimate_detail_id => p_charges_detail_rec.estimate_detail_id,
                                     x_msg_data           => l_msg_data,
                                     x_msg_count          => l_msg_count,
                                     x_return_status      => l_return_status) = 'U' THEN

        --raise unexpected error
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF IS_ESTIMATE_DETAIL_ID_VALID(p_estimate_detail_id => p_charges_detail_rec.estimate_detail_id,
                                     x_msg_data           => l_msg_data,
                                     x_msg_count          => l_msg_count,
                                     x_return_status      => l_return_status) = 'N' THEN

        Add_Invalid_Argument_Msg(l_api_name,
                               TO_CHAR(p_charges_detail_rec.estimate_detail_id),
                               'estimate_detail_id');
        RAISE FND_API.G_EXC_ERROR;

      ELSE
        --estimate detail id is valid
        --assign to out record
        x_charges_detail_rec.estimate_detail_id := p_charges_detail_rec.estimate_detail_id;

        -- Get existing Charges record for this estimate detail_id
        Get_Charge_Detail_Rec(p_api_name             => l_api_name_full,
                              p_estimate_detail_id   => p_charges_detail_rec.estimate_detail_id,
                              x_charge_detail_rec    => l_db_det_rec,
                              x_msg_data             => l_msg_data,
                              x_msg_count            => l_msg_count,
                              x_return_status        => l_return_status);

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END IF;
    END IF;
  END IF;


  --========================
  --Incident ID Validation
  --========================
  --DBMS_OUTPUT.PUT_LINE('Incident ID Validation ...');

  IF p_validation_mode = 'I' THEN

    --If incident_id is not passed the
    --raise error
    --else validate the incident_id and assign to out record
    --and get the SR defaults

    IF p_charges_detail_rec.incident_id IS NULL THEN

      Add_Null_Parameter_Msg(l_api_name,
                             'p_incident_id') ;

      Add_Invalid_Argument_Msg(l_api_name,
                               to_char(p_charges_detail_rec.incident_id),
                               'incident_id');
      RAISE FND_API.G_EXC_ERROR;

    ELSE
      -- The incident_id IS NOT NULL
      l_valid_check := IS_INCIDENT_ID_VALID( p_incident_id   => p_charges_detail_rec.incident_id,
                               x_msg_data      => l_msg_data,
                               x_msg_count     => l_msg_count,
                               x_return_status => l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_valid_check <> 'Y' THEN

        Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.incident_id),
                                 'incident_id');

        RAISE FND_API.G_EXC_ERROR;

      ELSE
        -- assign it to the out record
        x_charges_detail_rec.incident_id := p_charges_detail_rec.incident_id;

        -- get the defaults from Service Request for the incident id
        get_sr_defaults(p_api_name              => p_api_name,
                        p_incident_id           => x_charges_detail_rec.incident_id,
                        x_business_process_id   => l_business_process_id,
                        x_customer_id           => l_customer_id,
                        x_customer_site_id      => l_customer_site_id,
                        x_cust_po_number        => l_cust_po_number,
                        x_customer_product_id   => l_cust_product_id,
                        x_system_id             => l_system_id,       -- Fix bug
                        x_inventory_item_id     => l_inventory_item_id, -- Fix bug
                        x_account_id            => l_account_id,
                        x_bill_to_party_id      => l_bill_to_party_id,
                        x_bill_to_account_id    => l_bill_to_account_id,
                        x_bill_to_contact_id    => l_bill_to_contact_id,
                        x_bill_to_site_id       => l_bill_to_site_id,
                        x_ship_to_party_id      => l_ship_to_party_id,
                        x_ship_to_account_id    => l_ship_to_account_id,
                        x_ship_to_contact_id    => l_ship_to_contact_id,
                        x_ship_to_site_id       => l_ship_to_site_id,
                        x_contract_id           => l_contract_id,
                        x_contract_service_id   => l_contract_service_id,
                        x_incident_date         => l_incident_date,
                        x_creation_date         => l_creation_date,
                        x_msg_data              => l_msg_data,
                        x_msg_count             => l_msg_count,
                        x_return_status         => l_return_status);

        --DBMS_OUTPUT.PUT_LINE('Back from GET_SR_DEFAULTS l_bill_to_party_id '||l_bill_to_party_id);
        --DBMS_OUTPUT.PUT_LINE('Back from GET_SR_DEFAULTS l_ship_to_party_id '||l_ship_to_party_id);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;

        --DBMS_OUTPUT.PUT_LINE('l_incident_date '||l_incident_date);
        --DBMS_OUTPUT.PUT_LINE('l_creation_date '||l_creation_date);

      END IF;
    END IF;
  END IF;

  -- This needs to be merged with the above validation

  IF p_validation_mode = 'U' THEN

     --DBMS_OUTPUT.PUT_LINE('Incident_id '||l_db_det_rec.incident_id);
     -- Incident Id cannot be changed, assign from the database

      x_charges_detail_rec.incident_id := l_db_det_rec.incident_id;

      -- get the defaults from Service Request for the incident id
      get_sr_defaults(p_api_name              => p_api_name,
                      p_incident_id           => x_charges_detail_rec.incident_id,
                      x_business_process_id   => l_business_process_id,
                      x_customer_id           => l_customer_id,
                      x_customer_site_id      => l_customer_site_id,
                      x_cust_po_number        => l_cust_po_number,
                      x_customer_product_id   => l_cust_product_id,
                      x_system_id             => l_system_id,         -- Fix bug
                      x_inventory_item_id     => l_inventory_item_id, -- Fix bug
                      x_account_id            => l_account_id,
                      x_bill_to_party_id      => l_bill_to_party_id,
                      x_bill_to_account_id    => l_bill_to_account_id,
                      x_bill_to_contact_id    => l_bill_to_contact_id,
                      x_bill_to_site_id       => l_bill_to_site_id,
                      x_ship_to_party_id      => l_ship_to_party_id,
                      x_ship_to_account_id    => l_ship_to_account_id,
                      x_ship_to_contact_id    => l_ship_to_contact_id,
                      x_ship_to_site_id       => l_ship_to_site_id,
                      x_contract_id           => l_contract_id,
                      x_contract_service_id   => l_contract_service_id,
                      x_incident_date         => l_incident_date,
                      x_creation_date         => l_creation_date,
                      x_msg_data              => l_msg_data,
                      x_msg_count             => l_msg_count,
                      x_return_status         => l_return_status
                      );

      --DBMS_OUTPUT.PUT_LINE('business_process_id'||l_business_process_id);
      --DBMS_OUTPUT.PUT_LINE('customer_id'||l_customer_id);
      --DBMS_OUTPUT.PUT_LINE('customer_site_id'||l_customer_site_id);
      --DBMS_OUTPUT.PUT_LINE('cust_po_number'||l_cust_po_number);
      --DBMS_OUTPUT.PUT_LINE('customer_product_id'||l_cust_product_id);
      --DBMS_OUTPUT.PUT_LINE('account_id'||l_account_id);
      --DBMS_OUTPUT.PUT_LINE('bill_to_party_id'|| l_bill_to_party_id);
      --DBMS_OUTPUT.PUT_LINE('bill_to_account_id'||l_bill_to_account_id);
      --DBMS_OUTPUT.PUT_LINE('bill_to_contact_id'||l_bill_to_contact_id);
      --DBMS_OUTPUT.PUT_LINE('bill_to_site_id'||l_bill_to_site_id);
      --DBMS_OUTPUT.PUT_LINE('ship_to_party_id'||l_ship_to_account_id);
      --DBMS_OUTPUT.PUT_LINE('ship_to_account_id'||l_ship_to_account_id);
      --DBMS_OUTPUT.PUT_LINE('ship_to_contact_id'||l_ship_to_contact_id);
      --DBMS_OUTPUT.PUT_LINE('ship_to_site_id'||l_ship_to_site_id);
      --DBMS_OUTPUT.PUT_LINE('contract_id'||l_contract_id);
      --DBMS_OUTPUT.PUT_LINE('contract_service_id'||l_contract_service_id);
      --DBMS_OUTPUT.PUT_LINE('msg_data'||l_msg_data);
      --DBMS_OUTPUT.PUT_LINE('msg_count'|| l_msg_count);
      --DBMS_OUTPUT.PUT_LINE('return_status'||l_return_status);


      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

  ELSE

    null;

  END IF;

 --===================================================
 -- Get the disallow_new_charge_flag and
 -- disallow_charge_update_flag for the incident_id
 --===================================================

 --DBMS_OUTPUT.PUT_LINE('getting status form SR');
 --Bug Fix for Bug # 3086455
 get_charge_flags_from_sr(p_api_name               => p_api_name,
                          p_incident_id            => x_charges_detail_rec.incident_id,
                          x_disallow_new_charge    => l_disallow_new_charge,
                          x_disallow_charge_update => l_disallow_charge_update,
                          x_msg_data               => l_msg_data,
                          x_msg_count              => l_msg_count,
                          x_return_status          => l_return_status
                          );

 --DBMS_OUTPUT.PUT_LINE('l_disallow_new_charge is '||l_disallow_new_charge);
 --DBMS_OUTPUT.PUT_LINE('l_disallow_charge_update is '||l_disallow_charge_update);

 IF p_validation_mode = 'I' THEN
   IF l_disallow_new_charge  = 'Y' THEN
     --DBMS_OUTPUT.PUT_LINE('l_disallow_new_charge is '||l_disallow_new_charge);
     --raise error
     FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CANNOT_INSERT');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
 ELSIF p_validation_mode = 'U' THEN
   IF l_disallow_charge_update = 'Y' THEN
     --raise error
     FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CANNOT_UPDATE');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
 END IF;


 --===================================================
 --Assign values to columns that don't need validation
 --mviswana need to verify and change this
 --===================================================

  --DBMS_OUTPUT.PUT_LINE('Assign values to columns that do not need validation ...');

  IF p_validation_mode = 'I' THEN

    --IF p_charges_detail_rec.interface_to_oe_flag IS NOT NULL THEN
    --  x_charges_detail_rec.interface_to_oe_flag := p_charges_detail_rec.interface_to_oe_flag;
    --ELSE
    --  x_charges_detail_rec.interface_to_oe_flag := 'Y';
    --END IF;

    -- Added for Bug # 5135284
    IF p_charges_detail_rec.rollup_flag IS NOT NULL AND
       p_charges_detail_rec.rollup_flag IN ('Y', 'N') THEN
      x_charges_detail_rec.rollup_flag := p_charges_detail_rec.rollup_flag;
    ELSE
      x_charges_detail_rec.rollup_flag := 'N';
    END IF;

    -- Added for Bug # 5135284
    -- commenting for now
    IF p_charges_detail_rec.add_to_order_flag IS NOT NULL AND
       p_charges_detail_rec.add_to_order_flag IN ('Y', 'N', 'F') THEN
      x_charges_detail_rec.add_to_order_flag := p_charges_detail_rec.add_to_order_flag;
    ELSE
      x_charges_detail_rec.add_to_order_flag := 'N';
    END IF;

    IF p_charges_detail_rec.apply_contract_discount IS NULL THEN
      x_charges_detail_rec.apply_contract_discount := 'N';
    ELSE
      x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;
    END IF;

    x_charges_detail_rec.estimate_detail_id          := NULL;
    x_charges_detail_rec.order_line_id               := NULL;
    x_charges_detail_rec.coverage_bill_rate_id       := p_charges_detail_rec.coverage_bill_rate_id;
    x_charges_detail_rec.transaction_sub_inventory   := p_charges_detail_rec.transaction_sub_inventory;
    x_charges_detail_rec.submit_restriction_message  := p_charges_detail_rec.submit_restriction_message;
    x_charges_detail_rec.submit_error_message        := p_charges_detail_rec.submit_error_message;
    x_charges_detail_rec.submit_from_system          := p_charges_detail_rec.submit_from_system;


    --DBMS_OUTPUT.PUT_LINE('ORDER_LINE_ID IS '||x_charges_detail_rec.order_line_id);

  ELSIF p_validation_mode = 'U' THEN

    --Resolve Bug # 3078244
    --Resolve Bug # 3084879

    --DBMS_OUTPUT.PUT_LINE(' In Update Validation');
    --DBMS_OUTPUT.PUT_LINE(' p_charges_detail_rec.add_to_order_flag '||p_charges_detail_rec.add_to_order_flag );
    --DBMS_OUTPUT.PUT_LINE(' p_charges_detail_rec.coverage_bill_rate_id '||p_charges_detail_rec.coverage_bill_rate_id);
    --DBMS_OUTPUT.PUT_LINE(' p_charges_detail_rec.transaction_sub_inventory '||p_charges_detail_rec.transaction_sub_inventory);

    -- Check to see if add_to_order_flag is passed
    -- If not passed then assign from database
    -- If passed as null then assign 'N'
    -- If passed then assign to the out parameter

    IF p_charges_detail_rec.add_to_order_flag = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.add_to_order_flag :=  l_db_det_rec.add_to_order_flag;
    ELSIF p_charges_detail_rec.add_to_order_flag IS NULL THEN
      x_charges_detail_rec.add_to_order_flag :=  'N';
    ELSE
      -- Added for Bug # 5135284
      IF p_charges_detail_rec.add_to_order_flag IN ('Y', 'N', 'F') THEN
        x_charges_detail_rec.add_to_order_flag :=  p_charges_detail_rec.add_to_order_flag;
      ELSE
        x_charges_detail_rec.add_to_order_flag :=  'N';
      END IF;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.add_to_order_flag'||x_charges_detail_rec.add_to_order_flag);

    -- Check to see if coverage_bill_rate_id is passed
    -- If not passed then assign from database
    -- If passed as null then assign NULL
    -- If passed then assign to the out parameter

    IF p_charges_detail_rec.coverage_bill_rate_id = FND_API.G_MISS_NUM THEN
      x_charges_detail_rec.coverage_bill_rate_id :=  l_db_det_rec.coverage_bill_rate_id;
    ELSIF p_charges_detail_rec.coverage_bill_rate_id IS NULL THEN
      x_charges_detail_rec.coverage_bill_rate_id :=  null;
    ELSE
      x_charges_detail_rec.coverage_bill_rate_id :=  p_charges_detail_rec.coverage_bill_rate_id;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.coverage_bill_rate_id'||x_charges_detail_rec.coverage_bill_rate_id);

    -- Check to see if transaction_sub_inventory is passed
    -- If not passed then assign from database
    -- If passed as null then assign NULL
    -- If passed then assign to the out parameter

    IF p_charges_detail_rec.transaction_sub_inventory = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.transaction_sub_inventory :=  l_db_det_rec.transaction_sub_inventory;
    ELSIF p_charges_detail_rec.transaction_sub_inventory IS NULL THEN
      x_charges_detail_rec.transaction_sub_inventory :=  null;
    ELSE
      x_charges_detail_rec.transaction_sub_inventory :=  p_charges_detail_rec.transaction_sub_inventory;
    END IF;


    --DBMS_OUTPUT.PUT_LINE(' x_charges_detail_rec.transaction_sub_inventory '|| x_charges_detail_rec.transaction_sub_inventory);

    -- Check to see if interface_to_oe_flag is passed
    -- If not passed then assign from database
    -- If passed as null then assign NULL
    -- If passed then assign to the out parameter

    --IF p_charges_detail_rec.interface_to_oe_flag = FND_API.G_MISS_CHAR THEN
    --  x_charges_detail_rec.interface_to_oe_flag :=  l_db_det_rec.interface_to_oe_flag;
    --ELSIF p_charges_detail_rec.interface_to_oe_flag IS NULL THEN
    --  x_charges_detail_rec.interface_to_oe_flag :=  'N';
    --ELSE
    --  x_charges_detail_rec.interface_to_oe_flag :=  p_charges_detail_rec.interface_to_oe_flag;
    --END IF;

    --DBMS_OUTPUT.PUT_LINE(' x_charges_detail_rec.interface_to_oe_flag '||x_charges_detail_rec.interface_to_oe_flag);

    -- Check to see if apply_contract_discount is passed
    -- If not passed then assign from database
    -- If passed as null then assign NULL
    -- If passed then assign to the out parameter

    IF p_charges_detail_rec.apply_contract_discount = FND_API.G_MISS_CHAR OR
       p_charges_detail_rec.apply_contract_discount IS NULL THEN
       x_charges_detail_rec.apply_contract_discount := 'N';
    ELSE
      x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.apply_contract_discount'||x_charges_detail_rec.apply_contract_discount);

    -- Check to see if con_pct_over_list_price is passed
    -- If not passed then OR
    -- If passed as null then assign NULL
    -- If passed then assign to the out parameter

    IF p_charges_detail_rec.con_pct_over_list_price = FND_API.G_MISS_NUM OR
       p_charges_detail_rec.con_pct_over_list_price IS NULL THEN
       x_charges_detail_rec.con_pct_over_list_price := NULL;
    ELSE
      x_charges_detail_rec.con_pct_over_list_price  := p_charges_detail_rec.con_pct_over_list_price;
    END IF;

    x_charges_detail_rec.order_line_id := l_db_det_rec.order_line_id;

    -- Check to see if submit_restriction_message is passed
    -- If not passed then assign the value in the database
    -- If passed as NULL then assign NULL
    -- If passed then assign to out parameter

    IF p_charges_detail_rec.submit_restriction_message = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.submit_restriction_message :=  l_db_det_rec.submit_restriction_message;
    ELSIF p_charges_detail_rec.submit_restriction_message IS NULL THEN
      x_charges_detail_rec.submit_restriction_message :=  NULL;
    ELSE
      x_charges_detail_rec.submit_restriction_message :=  p_charges_detail_rec.submit_restriction_message;
    END IF;

    -- Check to see if submit_error_message is passed
    -- If not passed then assign the value in the database
    -- If passed as NULL then assign NULL
    -- If passed then assign to out parameter

    IF p_charges_detail_rec.submit_error_message = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.submit_error_message :=  l_db_det_rec.submit_error_message;
    ELSIF p_charges_detail_rec.submit_error_message IS NULL THEN
      x_charges_detail_rec.submit_error_message :=  NULL;
    ELSE
      x_charges_detail_rec.submit_error_message :=  p_charges_detail_rec.submit_error_message;
    END IF;

    -- Check to see if submit_from_system  is passed
    -- If not passed then assign the value in the database
    -- If passed as NULL then assign NULL
    -- If passed then assign to out parameter

    IF p_charges_detail_rec.submit_from_system = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.submit_from_system :=  l_db_det_rec.submit_from_system;
    ELSIF p_charges_detail_rec.submit_from_system IS NULL THEN
      x_charges_detail_rec.submit_from_system :=  NULL;
    ELSE
      x_charges_detail_rec.submit_from_system :=  p_charges_detail_rec.submit_from_system;
    END IF;

  END IF;

--=====================================
-- Validate the Org_id Passed
--====================================

  -- Get Org ID from Source for Incident ID
  --   CS_Multiorg_PVT.Get_OrgId(
  --                P_API_VERSION    => 1.2,
  --                P_INIT_MSG_LIST  => FND_API.G_FALSE,
  --                X_RETURN_STATUS  => l_return_status,
  --                X_MSG_COUNT      => l_msg_count,
  --                X_MSG_DATA       => l_msg_data,
  --                P_INCIDENT_ID    => p_charges_detail_rec.incident_id,
  --                X_ORG_ID         => l_org_id,
  --                X_PROFILE        => l_profile);

  -- -- --DBMS_OUTPUT.PUT_LINE('Back from CS_Multiorg_PVT.Get_OrgId '||l_return_status);
  -- -- --DBMS_OUTPUT.PUT_LINE('X Profile '||l_profile);
  -- -- --DBMS_OUTPUT.PUT_LINE('l_org_id '||l_org_id);


  -- Get Org ID from Source for Incident ID
  -- Call CS_MultiOrg_PUB.Get_OrgID
  -- This uses the new multi org public API
  --
  CS_Multiorg_PUB.Get_OrgId(
                P_API_VERSION       => 1.0,
                P_INIT_MSG_LIST     => FND_API.G_FALSE,
                -- Fix bug 3236597 P_COMMIT            => 'T',
                P_COMMIT            => 'F',  -- Fix bug 3236597
                P_VALIDATION_LEVEL  => FND_API.G_VALID_LEVEL_FULL,
                X_RETURN_STATUS     => l_return_status,
                X_MSG_COUNT         => l_msg_count,
                X_MSG_DATA          => l_msg_data,
                P_INCIDENT_ID       => p_charges_detail_rec.incident_id,
                X_ORG_ID            => l_org_id,
                X_PROFILE           => l_profile);

  --DBMS_OUTPUT.PUT_LINE('Back from CS_Multiorg_PVT.Get_OrgId '||l_return_status);
  --DBMS_OUTPUT.PUT_LINE('X Profile '||l_profile);
  --DBMS_OUTPUT.PUT_LINE('l_org_id '||l_org_id);


  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  IF p_validation_mode = 'I' THEN
    IF l_profile = 'Y' THEN
      IF p_charges_detail_rec.org_id IS NOT NULL THEN
        VALIDATE_ORG_ID(
                  P_API_NAME       => l_api_name,
                  P_ORG_ID         => p_charges_detail_rec.org_id,
                  X_RETURN_STATUS  => l_return_status,
                  X_MSG_COUNT      => l_msg_count,
                  X_MSG_DATA       => l_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        x_charges_detail_rec.org_id := p_charges_detail_rec.org_id;
      ELSE
        --use the default
        x_charges_detail_rec.org_id := l_org_id;
      END IF;
    ELSE
      -- l_profile = 'N'
      IF p_charges_detail_rec.org_id IS NOT NULL THEN
        IF p_charges_detail_rec.org_id <> l_org_id THEN
          --raise error
          --Need to define error here
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CANNOT_CHANGE_OU');
          FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          x_charges_detail_rec.org_id := p_charges_detail_rec.org_id;
        END IF;
      ELSE
        --p_charges_detail_rec.org_id IS NULL
        --assign default
        x_charges_detail_rec.org_id := l_org_id;
      END IF;
    END IF;

  ELSIF p_validation_mode = 'U' THEN
    -- Get Org ID from Source for Incident ID
    -- Resolve Bug # 3078244

    IF l_profile = 'Y' THEN

      -- If l_profile = 'Y' THEN if org_id is not passed
      -- or org_id is null then assign the value from the database
      -- else if passed then validate the org_id and if valid then
      -- assign the value to the out parameter

      IF p_charges_detail_rec.org_id = FND_API.G_MISS_NUM OR
         p_charges_detail_rec.org_id IS NULL THEN
         --use the value from the database
         x_charges_detail_rec.org_id := l_db_det_rec.org_id;

      ELSE
        VALIDATE_ORG_ID(
                  P_API_NAME       => l_api_name,
                  P_ORG_ID         => p_charges_detail_rec.org_id,
                  X_RETURN_STATUS  => l_return_status,
                  X_MSG_COUNT      => l_msg_count,
                  X_MSG_DATA       => l_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        x_charges_detail_rec.org_id := p_charges_detail_rec.org_id;

      END IF;

    ELSE
      -- l_profile = 'N'
      -- If l_profile = 'N' THEN if org_id is not passed
      -- or org_id is null then assign the value from the database
      -- else if passed then validate the org_id and if valid then
      -- assign the value to the out parameter

      IF p_charges_detail_rec.org_id = FND_API.G_MISS_NUM OR
         p_charges_detail_rec.org_id IS NULL THEN
        --use the value from the database
        x_charges_detail_rec.org_id := l_db_det_rec.org_id;

      ELSE
        IF p_charges_detail_rec.org_id <> l_db_det_rec.org_id THEN
          --raise error
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CANNOT_CHANGE_OU');
          FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          x_charges_detail_rec.org_id := p_charges_detail_rec.org_id;
        END IF;
      END IF;
    END IF;
  END IF;

  --DBMS_OUTPUT.PUT_LINE('org_id '||x_charges_detail_rec.org_id);

--=====================================
--Validate Original Source
--=====================================
  --DBMS_OUTPUT.PUT_LINE('Validate Original Source ...');
  IF p_validation_mode = 'I' THEN
    IF (p_charges_detail_rec.original_source_code IS NULL) OR (p_charges_detail_rec.original_source_id IS NULL) THEN

      FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_ORIGINAL_SOURCE');
      FND_MESSAGE.SET_TOKEN('ORIG_SOURCE_ID', p_charges_detail_rec.original_source_id);
      FND_MESSAGE.SET_TOKEN('ORIG_SOURCE_CODE', p_charges_detail_rec.original_source_code);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

    ELSE
      VALIDATE_SOURCE(
                P_API_NAME         => p_api_name,
                P_SOURCE_CODE      => p_charges_detail_rec.original_source_code,
                P_SOURCE_ID        => p_charges_detail_rec.original_source_id,
                P_ORG_ID           => x_charges_detail_rec.org_id,
                X_SOURCE_ID        => l_source_id,
                X_MSG_DATA         => l_msg_data,
                X_MSG_COUNT        => l_msg_count,
                X_RETURN_STATUS    => l_return_status) ;

      --DBMS_OUTPUT.PUT_LINE('Back from VALIDATE_SOURCE for ORIG SOURCE '||l_return_status);

      --IF l_return_status <> 'S' THEN
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        --raise error
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_ORIGINAL_SOURCE');
        FND_MESSAGE.SET_TOKEN('ORIG_SOURCE_ID', p_charges_detail_rec.original_source_id);
        FND_MESSAGE.SET_TOKEN('ORIG_SOURCE_CODE', p_charges_detail_rec.original_source_code);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign to out record
      x_charges_detail_rec.original_source_code := p_charges_detail_rec.original_source_code;
      x_charges_detail_rec.original_source_id := p_charges_detail_rec.original_source_id;

    END IF;


    IF (p_charges_detail_rec.source_code IS NOT NULL) AND (p_charges_detail_rec.source_id IS NOT NULL) THEN
      -- Call the Validate Source Procedure

      --DBMS_OUTPUT.PUT_LINE('source '||p_charges_detail_rec.source_code);
      --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.source_id'||p_charges_detail_rec.source_id);

      VALIDATE_SOURCE(
           P_API_NAME         => p_api_name,
           P_SOURCE_CODE      => p_charges_detail_rec.source_code,
           P_SOURCE_ID        => p_charges_detail_rec.source_id,
           --P_ORG_ID         => l_org_id,
           P_ORG_ID           => x_charges_detail_rec.org_id,
           X_SOURCE_ID        => l_source_id,
           X_MSG_DATA         => l_msg_data,
           X_MSG_COUNT        => l_msg_count,
           X_RETURN_STATUS    => l_return_status) ;

      --DBMS_OUTPUT.PUT_LINE('Back from VALIDATE_SOURCE for SOURCE '||l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

      --assign the values source_code, source_id to out record
      x_charges_detail_rec.source_code := p_charges_detail_rec.source_code;
      x_charges_detail_rec.source_id   := p_charges_detail_rec.source_id;

    ELSE
      --Default using original source code and original source id
      --assign the values source_code, source_id to out record
      x_charges_detail_rec.source_code := p_charges_detail_rec.original_source_code;
      x_charges_detail_rec.source_id   := p_charges_detail_rec.original_source_id;

    END IF;

  ELSIF p_validation_mode = 'U' THEN

    -- assign attributes from db record for original source id and
    -- original source code as both cannot be changed
    x_charges_detail_rec.original_source_id := l_db_det_rec.original_source_id;
    x_charges_detail_rec.original_source_code := l_db_det_rec.original_source_code;



    IF p_charges_detail_rec.source_code  = FND_API.G_MISS_CHAR OR
       p_charges_detail_rec.source_code IS NULL AND
       p_charges_detail_rec.source_id = FND_API.G_MISS_NUM OR
       p_charges_detail_rec.source_id IS NULL THEN

       --Default attributes using db record
       x_charges_detail_rec.source_code := l_db_det_rec.source_code;
       x_charges_detail_rec.source_id   := l_db_det_rec.source_id;

    ELSE

        VALIDATE_SOURCE(
           P_API_NAME         => p_api_name,
           P_SOURCE_CODE      => p_charges_detail_rec.source_code,
           P_SOURCE_ID        => p_charges_detail_rec.source_id,
           --P_ORG_ID         => l_org_id,
           P_ORG_ID           => x_charges_detail_rec.org_id,
           X_SOURCE_ID        => l_source_id,
           X_MSG_DATA         => l_msg_data,
           X_MSG_COUNT        => l_msg_count,
           X_RETURN_STATUS    => l_return_status) ;

        --DBMS_OUTPUT.PUT_LINE('Back from VALIDATE_SOURCE for SOURCE '||l_return_status);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;

        --assign the values source_code, source_id to out record
        x_charges_detail_rec.source_code := p_charges_detail_rec.source_code;
        x_charges_detail_rec.source_id   := p_charges_detail_rec.source_id;

    END IF;

  END IF;

  --DBMS_OUTPUT.PUT_LINE('Completed Source ID and Source Code Validation');

--================================================================
-- For Update Only
-- Estimate Detail Record cannot be updated based
-- on certain restrictions
-- If order lines exist for the record then we cannot update line
-- If the line is generated by billing engine then we cannot
-- update anything other than the after_warranty_cost
--================================================================
  IF p_validation_mode = 'U' THEN

    --Bug Fix for Bug # 2878503

    IF l_db_det_rec.order_line_id IS NOT NULL THEN
      l_in_oe_flag  := 'Y' ;
    ELSE
      l_in_oe_flag := 'N' ;
    END IF ;

    --DBMS_OUTPUT.PUT_LINE('l_in_oe_flag '||l_in_oe_flag);

    IF l_in_oe_flag = 'Y' THEN

      --DBMS_OUTPUT.PUT_LINE(' l_db_det_rec.original_source_code '||l_db_det_rec.original_source_code);
      --DBMS_OUTPUT.PUT_LINE(' p_charges_detail_rec.source_code '||p_charges_detail_rec.source_code);

      -- If the Charge Line is Interfaced to OM the upstream can only change the
      -- source code from SR to DR and vice versa
      -- everything else is not updateable

      IF  l_db_det_rec.original_source_code IN ('SR', 'DR') AND
          p_charges_detail_rec.source_code <> FND_API.G_MISS_CHAR AND
          p_charges_detail_rec.source_code IS NOT NULL AND
          p_charges_detail_rec.source_code IN ('DR', 'SR') THEN

          --DBMS_OUTPUT.PUT_LINE(' Calling validate_source');

            VALIDATE_SOURCE(
                P_API_NAME         => p_api_name,
                P_SOURCE_CODE      => p_charges_detail_rec.original_source_code,
                P_SOURCE_ID        => p_charges_detail_rec.original_source_id,
                P_ORG_ID           => x_charges_detail_rec.org_id,
                X_SOURCE_ID        => l_source_id,
                X_MSG_DATA         => l_msg_data,
                X_MSG_COUNT        => l_msg_count,
                X_RETURN_STATUS    => l_return_status) ;

            IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            --DBMS_OUTPUT.PUT_LINE(' l_source_id '||l_source_id);

            x_charges_detail_rec.source_id := l_source_id ;
            x_charges_detail_rec.source_code := p_charges_detail_rec.source_code ;

      ELSE
        --DBMS_OUTPUT.PUT_LINE('Coming to the else');
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_CANNOT_UPDATE_CHRG_LINE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (p_charges_detail_rec.charge_line_type                <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.line_number                     <> FND_API.G_MISS_NUM OR
          p_charges_detail_rec.business_process_id             <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.transaction_type_id             <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.inventory_item_id_in            <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.item_revision                   <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.billing_flag                    <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.txn_billing_type_id             <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.unit_of_measure_code            <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.quantity_required               <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.return_reason_code              <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.customer_product_id             <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.serial_number                   <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.installed_cp_return_by_date     <> FND_API.G_MISS_DATE OR
          p_charges_detail_rec.new_cp_return_by_date           <> FND_API.G_MISS_DATE OR
          p_charges_detail_rec.sold_to_party_id                <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.bill_to_party_id                <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.bill_to_account_id              <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.bill_to_contact_id              <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.invoice_to_org_id               <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.ship_to_party_id                <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.ship_to_account_id              <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.ship_to_contact_id              <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.ship_to_org_id                  <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.contract_id                     <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.contract_line_id                <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.coverage_id                     <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.coverage_txn_group_id           <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.coverage_bill_rate_id           <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.coverage_billing_type_id        <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.price_list_id                   <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.currency_code                   <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.purchase_order_num              <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.list_price                      <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.con_pct_over_list_price         <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.selling_price                   <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.contract_discount_amount        <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.apply_contract_discount         <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.after_warranty_cost             <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.transaction_inventory_org       <> FND_API.G_MISS_NUM OR
          p_charges_detail_rec.transaction_sub_inventory       <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.rollup_flag                     <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.add_to_order_flag               <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.order_header_id                 <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.interface_to_oe_flag            <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.no_charge_flag                  <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.line_category_code              <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.line_type_id                    <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.order_line_id                   <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.conversion_rate                 <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.conversion_type_code            <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.conversion_rate_date            <> FND_API.G_MISS_DATE OR
          p_charges_detail_rec.org_id                          <> FND_API.G_MISS_NUM  OR
          p_charges_detail_rec.activity_start_time             <> FND_API.G_MISS_DATE OR
          p_charges_detail_rec.activity_end_time               <> FND_API.G_MISS_DATE OR
          p_charges_detail_rec.generated_by_bca_engine         <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.submit_restriction_message      <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.submit_error_message            <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.submit_from_system              <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute1                      <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute2                      <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute3                      <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute4                      <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute5                      <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute6                      <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute7                      <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute8                      <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute9                      <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute10                     <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute11                     <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute12                     <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute13                     <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute14                     <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.attribute15                     <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.context                         <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_context                 <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute1              <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute2              <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute3              <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute4              <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute5              <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute6              <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute7              <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute8              <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute9              <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute10             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute11             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute12             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute13             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute14             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute15             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute16             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute17             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute18             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute19             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute20             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute21             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute22             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute23             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute24             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute25             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute26             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute27             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute28             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute29             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute30             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute31             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute32             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute33             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute34             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute35             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute36             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute37             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute38             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute39             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute40             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute41             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute42             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute43             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute44             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute45             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute46             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute47             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute48             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute49             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute50             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute51             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute52             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute53             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute54             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute55             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute56             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute57             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute58             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute59             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute60             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute61             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute62             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute63             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute64             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute65             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute66             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute67             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute68             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute69             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute70             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute71             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute72             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute73             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute74             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute75             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute76             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute77             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute78             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute79             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute80             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute81             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute82             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute83             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute84             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute85             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute86             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute87             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute88             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute89             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute90             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute91             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute92             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute93             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute94             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute95             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute96             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute97             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute98             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute99             <> FND_API.G_MISS_CHAR OR
          p_charges_detail_rec.pricing_attribute100            <> FND_API.G_MISS_CHAR ) THEN

          FND_MESSAGE.Set_Name('CS', 'CS_CHG_CANNOT_UPDATE_CHRG_LINE');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSE
     --l_in_oe_flag = 'N'
     --DBMS_OUTPUT.PUT_LINE('l_in_oe_flag is N ');
     null;
   END IF;



   -- Fixed Bug # 4395867
   -- If the original source is 'SR' and source is 'SD' then restrict the line from getting updated
   -- from Service Debrief
   --

   -- get the current_source for the update transaction

   IF p_charges_detail_rec.source_code IS NOT NULL AND
      p_charges_detail_rec.source_code <> FND_API.G_MISS_CHAR THEN
      l_source := p_charges_detail_rec.source_code;
   ELSE
      l_source := l_db_det_rec.source_code;
   END IF;

   -- get the original_source for the update transaction
      l_original_source := l_db_det_rec.original_source_code;

--Bug fix for bug 7445810
   IF l_db_det_rec.generated_by_bca_engine_flag = 'Y' AND
      l_original_source = 'SR' AND
      l_source = 'SD'  THEN
    IF (
	--cannot be updated
	    p_charges_detail_rec.charge_line_type                <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.line_number                     <> FND_API.G_MISS_NUM OR
            p_charges_detail_rec.business_process_id             <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.transaction_type_id             <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.inventory_item_id_in            <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.item_revision                   <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.billing_flag                    <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.txn_billing_type_id             <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.unit_of_measure_code            <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.quantity_required               <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.return_reason_code              <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.customer_product_id             <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.serial_number                   <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.installed_cp_return_by_date     <> FND_API.G_MISS_DATE OR
            p_charges_detail_rec.new_cp_return_by_date           <> FND_API.G_MISS_DATE OR

            p_charges_detail_rec.list_price                      <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.con_pct_over_list_price         <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.contract_discount_amount        <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.apply_contract_discount         <> FND_API.G_MISS_CHAR OR

	    p_charges_detail_rec.transaction_inventory_org       <> FND_API.G_MISS_NUM OR
            p_charges_detail_rec.transaction_sub_inventory       <> FND_API.G_MISS_CHAR OR


          --  p_charges_detail_rec.order_header_id                 <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.line_category_code              <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.line_type_id                    <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.order_line_id                   <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.conversion_rate                 <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.conversion_type_code            <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.conversion_rate_date            <> FND_API.G_MISS_DATE OR
            p_charges_detail_rec.original_source_id              <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.original_source_code            <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.org_id                          <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.activity_start_time             <> FND_API.G_MISS_DATE OR
            p_charges_detail_rec.activity_end_time               <> FND_API.G_MISS_DATE OR
            p_charges_detail_rec.generated_by_bca_engine         <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.submit_restriction_message      <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.submit_error_message            <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.submit_from_system              <> FND_API.G_MISS_CHAR OR
	    p_charges_detail_rec.sold_to_party_id                <> FND_API.G_MISS_NUM
            )

	--can be updated

	  /*  p_charges_detail_rec.sold_to_party_id                <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.bill_to_party_id                <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.bill_to_account_id              <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.bill_to_contact_id              <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.invoice_to_org_id               <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.ship_to_party_id                <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.ship_to_account_id              <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.ship_to_contact_id              <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.ship_to_org_id                  <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.contract_id                     <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.coverage_id                     <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.coverage_txn_group_id           <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.coverage_bill_rate_id           <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.coverage_billing_type_id        <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.price_list_id                   <> FND_API.G_MISS_NUM  OR
	    p_charges_detail_rec.currency_code                   <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.purchase_order_num              <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.selling_price                   <> FND_API.G_MISS_NUM  OR
            p_charges_detail_rec.rollup_flag                     <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.add_to_order_flag               <> FND_API.G_MISS_CHAR OR
	    p_charges_detail_rec.interface_to_oe_flag            <> FND_API.G_MISS_CHAR OR
	    p_charges_detail_rec.no_charge_flag                  <> FND_API.G_MISS_CHAR OR

            p_charges_detail_rec.attribute1                      <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.attribute2                      <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.attribute3                      <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.attribute4                      <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.attribute5                      <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.attribute6                      <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.attribute7                      <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.attribute8                      <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.attribute9                      <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.attribute10                     <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.attribute11                     <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.attribute12                     <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.attribute13                     <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.attribute14                     <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.attribute15                     <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.context                         <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_context                 <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute1              <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute2              <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute3              <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute4              <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute5              <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute6              <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute7              <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute8              <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute9              <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute10             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute11             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute12             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute13             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute14             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute15             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute16             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute17             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute18             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute19             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute20             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute21             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute22             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute23             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute24             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute25             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute26             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute27             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute28             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute29             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute30             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute31             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute32             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute33             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute34             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute35             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute36             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute37             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute38             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute39             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute40             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute41             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute42             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute43             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute44             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute45             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute46             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute47             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute48             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute49             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute50             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute51             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute52             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute53             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute54             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute55             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute56             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute57             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute58             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute59             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute60             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute61             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute62             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute63             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute64             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute65             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute66             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute67             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute68             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute69             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute70             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute71             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute72             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute73             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute74             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute75             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute76             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute77             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute78             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute79             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute80             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute81             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute82             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute83             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute84             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute85             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute86             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute87             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute88             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute89             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute90             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute91             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute92             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute93             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute94             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute95             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute96             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute97             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute98             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute99             <> FND_API.G_MISS_CHAR OR
            p_charges_detail_rec.pricing_attribute100            <> FND_API.G_MISS_CHAR )
            */

     THEN
         --RAISE FND_API.G_EXC_ERROR;
         --null;

--	 FND_MESSAGE.Set_Name('CS', 'CS_CHG_CANNOT_UPDATE_CHRG_LINE');
	 FND_MESSAGE.Set_Name('CS', 'CS_CHG_CANNOT_UPDATE_LINE'); --Bug 7445810	 created an appropriate message
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- If generated by BCA Engine then cannot update anything except the final amount
     -- need to find out from Iwen the exact requirements

   END IF;
  END IF;

     --DBMS_OUTPUT.PUT_LINE('Passed the Update Validation for BCA and Order Line');
--======================================
-- For Update Only
-- Check for Item Instance and Rollup Flag
-- from values in Database
--======================================
IF p_validation_mode = 'U' THEN
  IF l_db_det_rec.rollup_flag = 'Y' THEN
    l_rollup_flag := 'Y';
  END IF;
END IF;

--===========================
--Charge Line Type Validation
--===========================
--DBMS_OUTPUT.PUT_LINE('Charge Line Type Validation ...');

  IF p_validation_mode = 'I' THEN

    IF p_charges_detail_rec.charge_line_type IS NOT NULL THEN

      l_valid_check := IS_CHARGE_LINE_TYPE_VALID(p_charge_line_type => p_charges_detail_rec.charge_line_type,
                                   x_msg_data         => l_msg_data,
                                   x_msg_count        => l_msg_count,
                                   x_return_status    => l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_valid_check <> 'Y' THEN

        Add_Invalid_Argument_Msg(l_api_name,
                                 p_charges_detail_rec.charge_line_type,
                                 'charge_line_type');

        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_charges_detail_rec.charge_line_type :=  p_charges_detail_rec.charge_line_type;
      END IF;


    ELSE
      x_charges_detail_rec.charge_line_type := 'ACTUAL';
    END IF;

  ELSIF p_validation_mode = 'U' THEN

    --Resolve Bug # 3078244

    IF p_charges_detail_rec.charge_line_type  <> FND_API.G_MISS_CHAR AND
       p_charges_detail_rec.charge_line_type IS NOT NULL THEN

      IF l_db_det_rec.charge_line_type <> 'IN PROGRESS' THEN

        l_valid_check := IS_CHARGE_LINE_TYPE_VALID(p_charge_line_type => p_charges_detail_rec.charge_line_type,
                                     x_msg_data         => l_msg_data,
                                     x_msg_count        => l_msg_count,
                                     x_return_status    => l_return_status);

        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_valid_check <> 'Y' THEN

          Add_Invalid_Argument_Msg(l_api_name,
                                   p_charges_detail_rec.charge_line_type,
                                   'charge_line_type');

          RAISE FND_API.G_EXC_ERROR;
        ELSE
          x_charges_detail_rec.charge_line_type :=  p_charges_detail_rec.charge_line_type;
        END IF;

      ELSE
       -- give an error message
       FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CANNOT_UPDATE_INPROG');
       FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSE
    --get it from the db record
    x_charges_detail_rec.charge_line_type := l_db_det_rec.charge_line_type;

    IF x_charges_detail_rec.charge_line_type = 'IN PROGRESS' THEN
      FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CANNOT_UPDATE_INPROG');
      FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
   END IF;

   --DBMS_OUTPUT.PUT_LINE('passed charge_line_type validation in update');
  END IF;

 --=============================
 --Line submitted validate
 --=============================

 IF p_validation_mode = 'I' THEN

   IF  x_charges_detail_rec.charge_line_type IN ('ESTIMATE', 'IN_PROGRESS') THEN
     x_charges_detail_rec.line_submitted_flag := NULL;
   ELSE
     IF x_charges_detail_rec.charge_line_type = 'ACTUAL' THEN
      x_charges_detail_rec.line_submitted_flag := 'N';
     END IF;
   END IF;
 ELSIF p_validation_mode = 'U' THEN
   --Fixed Bug # 3353497
   IF x_charges_detail_rec.order_line_id IS NULL AND
      x_charges_detail_rec.charge_line_type = 'ACTUAL' THEN
      x_charges_detail_rec.line_submitted_flag := 'N';
   ELSE
      --in all other situations  l_line_submitted_flag := NULL;
      x_charges_detail_rec.line_submitted_flag := NULL;
   END IF;
 END IF;



 --==============================
 --Business Process ID Validation
 --==============================
  --DBMS_OUTPUT.PUT_LINE('Business Process ID Validation ...');

  IF p_validation_mode = 'I' THEN

    IF p_charges_detail_rec.business_process_id IS NOT NULL THEN

      l_valid_check := IS_BUSINESS_PROCESS_ID_VALID(
                                      p_business_process_id => p_charges_detail_rec.business_process_id,
                                      x_msg_data            => l_msg_data,
                                      x_msg_count           => l_msg_count,
                                      x_return_status       => l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_valid_check <> 'Y' THEN

        Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.business_process_id),
                                 'business_process_id');
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_charges_detail_rec.business_process_id := p_charges_detail_rec.business_process_id;
      END IF;

    ELSE
      -- Business Process Id is null
      -- Get the Business Process Id from Service Request
      -- Check if the profile to get Business Process From SR = 'Y'
      l_def_bp_from_sr := fnd_profile.value('CS_CHG_DEFAULT_BP_FROM_SR');

      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
      THEN
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE || ''
	, 'The Value of profile CS_CHG_DEFAULT_BP_FROM_SR :' || l_def_bp_from_sr
	);
      END IF;

      IF l_def_bp_from_sr = 'Y' THEN
        -- assign the business process id returned from GET_SR_DEFAULTS
        -- assign to out record
        IF l_business_process_id IS NOT NULL THEN
          x_charges_detail_rec.business_process_id := l_business_process_id;
        ELSE
          -- Raise Error
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_BUSS_PROCESS_ID');
          FND_MESSAGE.SET_TOKEN('BUSINESS_PROCESS_ID', l_business_process_id);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        -- Profile to get Business Process From SR = 'N'
        -- Raise error the Business Process ID IS Null and needed
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_BUSS_PROCESS_ID');
        FND_MESSAGE.SET_TOKEN('BUSINESS_PROCESS_ID', p_charges_detail_rec.business_process_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  ELSIF p_validation_mode = 'U' THEN

    -- In this API the Business Process can be updated
    -- If the Business process is passed and valid it will be updated
    -- else the value from db will be used
    --Resolve Bug # 3078244

    --Check to see if the upstream is passed a new business_process_id
    --If passed then validate the new business_process_id
    --If valid then assign to out parameters
    --Check too see if business_process_id is changed
    --If business_process_id is not passed assign the one in the database

    IF p_charges_detail_rec.business_process_id <> FND_API.G_MISS_NUM AND
       p_charges_detail_rec.business_process_id IS NOT NULL THEN

       l_valid_check := IS_BUSINESS_PROCESS_ID_VALID(
                                      p_business_process_id => p_charges_detail_rec.business_process_id,
                                      x_msg_data            => l_msg_data,
                                      x_msg_count           => l_msg_count,
                                      x_return_status       => l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_valid_check <> 'Y' THEN

        Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.business_process_id),
                                 'business_process_id');
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_charges_detail_rec.business_process_id := p_charges_detail_rec.business_process_id;

        IF p_charges_detail_rec.business_process_id <> l_db_det_rec.business_process_id THEN
          l_bp_changed := 'Y';
        END IF;

      END IF;
   ELSE
     -- p_charges_detail_rec.business_process_id is not passed
     -- use the business_process_id from the db
     x_charges_detail_rec.business_process_id := l_db_det_rec.business_process_id;
   END IF;

   --DBMS_OUTPUT.PUT_LINE('passed business process validation in update');

 END IF;

 --==============================
 --Transaction Type ID Validation
 --=============================
  --DBMS_OUTPUT.PUT_LINE('Transaction Type ID Validation ...');
  --DBMS_OUTPUT.PUT_LINE('p_validation_mode'|| p_validation_mode);

  IF p_validation_mode = 'I' THEN

    IF p_charges_detail_rec.transaction_type_id IS NULL THEN

      Add_Null_Parameter_Msg(l_api_name, 'transaction_type_id');
      Add_Invalid_Argument_Msg(l_api_name, to_char(p_charges_detail_rec.inventory_item_id_in), 'transaction_type_id');
      RAISE FND_API.G_EXC_ERROR;

    ELSE -- transaction_type_id is not null;

--Added by bkanimoz on 15-dec-2007
 --start

--check if the 'create_charge_flag' is 'Y' for the transaction type

    get_charge_flag_from_sac(p_api_name               => p_api_name,
                             p_txn_type_id            => p_charges_detail_rec.transaction_type_id,
			     x_create_charge_flag     => l_create_charge_flag,
			     x_msg_data               => l_msg_data,
		             x_msg_count              => l_msg_count,
                             x_return_status          => l_return_status
			    );

   IF l_create_charge_flag   = 'N' THEN
     --DBMS_OUTPUT.PUT_LINE('l_disallow_new_charge is '||l_disallow_new_charge);
     --raise error
     FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_CHARGE_FLAG');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

-- end


      --DBMS_OUTPUT.PUT_LINE('Calling VALIDATE_TXN_TYPE');
      -- Call Validate Transaction Type Procedure
      VALIDATE_TXN_TYPE(P_API_NAME                  => p_api_name,
                        P_BUSINESS_PROCESS_ID       => p_charges_detail_rec.business_process_id,
                        P_TXN_TYPE_ID               => p_charges_detail_rec.transaction_type_id,
                        P_SOURCE_CODE               => x_charges_detail_rec.source_code,
                        X_LINE_ORDER_CATEGORY_CODE  => l_line_order_category_code,
                        X_NO_CHARGE_FLAG            => l_no_charge_flag ,
                        X_INTERFACE_TO_OE_FLAG      => l_interface_to_oe_flag,
                        X_UPDATE_IB_FLAG            => l_update_ib_flag,
                        X_SRC_REFERENCE_REQD_FLAG   => l_src_reference_reqd_flag,
                        X_SRC_RETURN_REQD_FLAG      => l_src_return_reqd_flag,
                        X_NON_SRC_REFERENCE_REQD    => l_non_src_reference_reqd_flag ,
                        X_NON_SRC_RETURN_REQD       => l_non_src_return_reqd,
                        x_MSG_DATA                  => x_msg_data,
                        x_MSG_COUNT                 => x_msg_count,
                        X_RETURN_STATUS             => l_return_status );



      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        x_charges_detail_rec.transaction_type_id := p_charges_detail_rec.transaction_type_id;
      END IF ;
    END IF;

  ELSIF p_validation_mode = 'U' THEN

    --DBMS_OUTPUT.PUT_LINE('l_bp_changed '||l_bp_changed);

     --Resolve Bug # 3078244

    IF l_bp_changed = 'Y' THEN

      --DBMS_OUTPUT.PUT_LINE(' p_charges_detail_rec.transaction_type_id '||p_charges_detail_rec.transaction_type_id);

      --Check to see if the

      IF p_charges_detail_rec.transaction_type_id <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.transaction_type_id IS NOT NULL THEN

        --DBMS_OUTPUT.PUT_LINE('Transaction Type Passed BP Changed');

        VALIDATE_TXN_TYPE(P_API_NAME                  => p_api_name,
                          P_BUSINESS_PROCESS_ID       => x_charges_detail_rec.business_process_id,
                          P_TXN_TYPE_ID               => p_charges_detail_rec.transaction_type_id,
                          P_SOURCE_CODE               => x_charges_detail_rec.source_code,
                          X_LINE_ORDER_CATEGORY_CODE  => l_line_order_category_code,
                          X_NO_CHARGE_FLAG            => l_no_charge_flag ,
                          X_INTERFACE_TO_OE_FLAG      => l_interface_to_oe_flag,
                          X_UPDATE_IB_FLAG            => l_update_ib_flag,
                          X_SRC_REFERENCE_REQD_FLAG   => l_src_reference_reqd_flag,
                          X_SRC_RETURN_REQD_FLAG      => l_src_return_reqd_flag,
                          X_NON_SRC_REFERENCE_REQD    => l_non_src_reference_reqd_flag ,
                          X_NON_SRC_RETURN_REQD       => l_non_src_return_reqd,
                          X_MSG_DATA                  => l_msg_data,
                          X_MSG_COUNT                 => l_msg_count,
                          X_RETURN_STATUS             => l_return_status );

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
          x_charges_detail_rec.transaction_type_id := p_charges_detail_rec.transaction_type_id;
          l_transaction_type_changed := 'Y';
        END IF ;

      ELSE

        --DBMS_OUTPUT.PUT_LINE('Transaction Type Not Passed BP Changed');
        -- p_charges_detail_rec.transaction_type_id is not passed
        -- validate the one from database against the business process changed
        VALIDATE_TXN_TYPE(P_API_NAME                  => p_api_name,
                          P_BUSINESS_PROCESS_ID       => x_charges_detail_rec.business_process_id,
                          P_TXN_TYPE_ID               => l_db_det_rec.transaction_type_id,
                          P_SOURCE_CODE               => x_charges_detail_rec.source_code,
                          X_LINE_ORDER_CATEGORY_CODE  => l_line_order_category_code,
                          X_NO_CHARGE_FLAG            => l_no_charge_flag ,
                          X_INTERFACE_TO_OE_FLAG      => l_interface_to_oe_flag,
                          X_UPDATE_IB_FLAG            => l_update_ib_flag,
                          X_SRC_REFERENCE_REQD_FLAG   => l_src_reference_reqd_flag,
                          X_SRC_RETURN_REQD_FLAG      => l_src_return_reqd_flag,
                          X_NON_SRC_REFERENCE_REQD    => l_non_src_reference_reqd_flag ,
                          X_NON_SRC_RETURN_REQD       => l_non_src_return_reqd,
                          X_MSG_DATA                  => l_msg_data,
                          X_MSG_COUNT                 => l_msg_count,
                          X_RETURN_STATUS             => l_return_status );

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
          x_charges_detail_rec.transaction_type_id := l_db_det_rec.transaction_type_id;
          l_transaction_type_changed := 'N';
        END IF ;
      END IF;
    ELSE
      -- l_bp_changed = 'N'
      -- p_charges_detail_rec.transaction_type_id is NOT NULL
      --DBMS_OUTPUT.PUT_LINE('l_bp_changed = N');


      IF p_charges_detail_rec.transaction_type_id <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.transaction_type_id IS NOT NULL THEN

        --DBMS_OUTPUT.PUT_LINE('Transaction Type Passed BP  not Changed');
        VALIDATE_TXN_TYPE(P_API_NAME                  => p_api_name,
                          P_BUSINESS_PROCESS_ID       => x_charges_detail_rec.business_process_id,
                          P_TXN_TYPE_ID               => p_charges_detail_rec.transaction_type_id,
                          P_SOURCE_CODE               => x_charges_detail_rec.source_code,
                          X_LINE_ORDER_CATEGORY_CODE  => l_line_order_category_code,
                          X_NO_CHARGE_FLAG            => l_no_charge_flag ,
                          X_INTERFACE_TO_OE_FLAG      => l_interface_to_oe_flag,
                          X_UPDATE_IB_FLAG            => l_update_ib_flag,
                          X_SRC_REFERENCE_REQD_FLAG   => l_src_reference_reqd_flag,
                          X_SRC_RETURN_REQD_FLAG      => l_src_return_reqd_flag,
                          X_NON_SRC_REFERENCE_REQD    => l_non_src_reference_reqd_flag ,
                          X_NON_SRC_RETURN_REQD       => l_non_src_return_reqd,
                          X_MSG_DATA                  => l_msg_data,
                          X_MSG_COUNT                 => l_msg_count,
                          X_RETURN_STATUS             => l_return_status );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        x_charges_detail_rec.transaction_type_id := p_charges_detail_rec.transaction_type_id;
        l_transaction_type_changed := 'Y';

      ELSE

        IF p_charges_detail_rec.transaction_type_id = FND_API.G_MISS_NUM OR
           p_charges_detail_rec.transaction_type_id  IS NULL THEN

           --DBMS_OUTPUT.PUT_LINE('Transaction Type Not Passed BP not Changed');
           -- transaction type is not passed
           -- transaction type has not changed
           x_charges_detail_rec.transaction_type_id := l_db_det_rec.transaction_type_id;
           l_transaction_type_changed := 'N';

           -- however call validate_txn_type just to get all the values which will be useful
           -- while validating instance

           VALIDATE_TXN_TYPE(P_API_NAME               => p_api_name,
                          P_BUSINESS_PROCESS_ID       => x_charges_detail_rec.business_process_id,
                          P_TXN_TYPE_ID               => x_charges_detail_rec.transaction_type_id,
                          P_SOURCE_CODE               => x_charges_detail_rec.source_code,
                          X_LINE_ORDER_CATEGORY_CODE  => l_line_order_category_code,
                          X_NO_CHARGE_FLAG            => l_no_charge_flag ,
                          X_INTERFACE_TO_OE_FLAG      => l_interface_to_oe_flag,
                          X_UPDATE_IB_FLAG            => l_update_ib_flag,
                          X_SRC_REFERENCE_REQD_FLAG   => l_src_reference_reqd_flag,
                          X_SRC_RETURN_REQD_FLAG      => l_src_return_reqd_flag,
                          X_NON_SRC_REFERENCE_REQD    => l_non_src_reference_reqd_flag ,
                          X_NON_SRC_RETURN_REQD       => l_non_src_return_reqd,
                          X_MSG_DATA                  => l_msg_data,
                          X_MSG_COUNT                 => l_msg_count,
                          X_RETURN_STATUS             => l_return_status );
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

        END IF;
      END IF;
    END IF;
    --DBMS_OUTPUT.PUT_LINE('passed transaction_type id validation in update ');
    --DBMS_OUTPUT.PUT_LINE('l_line_order_category_code = '||l_line_order_category_code);
    --DBMS_OUTPUT.PUT_LINE('l_no_charge_flag = '||l_no_charge_flag);
    --DBMS_OUTPUT.PUT_LINE('l_update_ib_flag = '||l_update_ib_flag);
    --DBMS_OUTPUT.PUT_LINE('l_src_reference_reqd_flag = '||l_src_reference_reqd_flag);
    --DBMS_OUTPUT.PUT_LINE('l_src_return_reqd_flag = '||l_src_return_reqd_flag);
    --DBMS_OUTPUT.PUT_LINE('l_non_src_reference_reqd_flag = '||l_non_src_reference_reqd_flag);
    --DBMS_OUTPUT.PUT_LINE('l_non_src_return_reqd = '||l_non_src_return_reqd);
    --DBMS_OUTPUT.PUT_LINE('l_return_status '||l_return_status );
  END IF;

--====================================
-- Line Order Category Code Validation
--====================================
  --DBMS_OUTPUT.PUT_LINE('Line Order Category Code Validation ...');

  l_line_order_category_code  :=  NVL(l_line_order_category_code, p_charges_detail_rec.line_category_code);

  IF p_validation_mode = 'I' THEN
    IF p_charges_detail_rec.line_category_code IS NOT NULL THEN

      IF p_charges_detail_rec.line_category_code <> l_line_order_category_code THEN
        --raise error
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_LN_ORD_CATEGORY');
        FND_MESSAGE.SET_TOKEN('LINE_ORDER_CATEGORY', p_charges_detail_rec.line_category_code);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        -- the p_charges_detail_rec.line_category_code
        -- matches l_line_order_category_code
        -- assign to out record
        x_charges_detail_rec.line_category_code := p_charges_detail_rec.line_category_code;
      END IF;

    ELSE
      -- p_charges_detail_rec.line_category_code IS NULL
      -- assign the l_line_order_category_code to out record
      x_charges_detail_rec.line_category_code := l_line_order_category_code;

    END IF;

  ELSIF p_validation_mode = 'U' THEN

    -- Resolve Bug # 3078244
    -- line_order_category can change due to changed transaction type

    IF l_transaction_type_changed = 'Y' THEN
      IF p_charges_detail_rec.line_category_code <> FND_API.G_MISS_CHAR AND
         p_charges_detail_rec.line_category_code IS NOT NULL THEN
        IF p_charges_detail_rec.line_category_code <> l_line_order_category_code THEN
          --raise error
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_LN_ORD_CATEGORY');
          FND_MESSAGE.SET_TOKEN('LINE_ORDER_CATEGORY', p_charges_detail_rec.line_category_code);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          -- the p_charges_detail_rec.line_category_code
          -- matches l_line_order_category_code
          -- assign to out record
          x_charges_detail_rec.line_category_code := p_charges_detail_rec.line_category_code;
        END IF;
      ELSE
        -- p_charges_detail_rec.line_category_code is not passed
        -- assign the l_line_order_category_code to out record
        x_charges_detail_rec.line_category_code := l_line_order_category_code;
      END IF;
    ELSE
      -- l_transaction_type_changed := 'N'
      IF p_charges_detail_rec.line_category_code <> FND_API.G_MISS_CHAR AND
         p_charges_detail_rec.line_category_code IS NOT NULL THEN
        IF p_charges_detail_rec.line_category_code <> l_db_det_rec.line_category_code THEN
          --raise error
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_LN_ORD_CATEGORY');
          FND_MESSAGE.SET_TOKEN('LINE_ORDER_CATEGORY', p_charges_detail_rec.line_category_code);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          -- the p_charges_detail_rec.line_category_code
          -- matches l_db_det_rec.line_category_code
          -- assign to out record
          x_charges_detail_rec.line_category_code := p_charges_detail_rec.line_category_code;
        END IF;
      ELSE
        -- p_charges_detail_rec.line_category_code IS not passed
        -- assign the l_line_order_category_code to out record
        x_charges_detail_rec.line_category_code := l_db_det_rec.line_category_code;
      END IF;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('passed line order category code validation');

  END IF;

--===================================
--Intreface To OE Flag Validation
--===================================
  IF p_validation_mode = 'I' THEN

    -- If the interface_to_oe_flag is passed then use the interface_oe_flag passed by
    -- upstream application.
    -- If not passed then default this from the Transaction Type Setup

    -- Added for Bug # 5135284
    IF p_charges_detail_rec.interface_to_oe_flag IS NOT NULL AND
       p_charges_detail_rec.interface_to_oe_flag IN ('Y', 'N') THEN
       x_charges_detail_rec.interface_to_oe_flag := p_charges_detail_rec.interface_to_oe_flag;
    ELSE
      -- p_charges_detail_rec.interface_to_oe_flag is null
      -- default it to l_interface_to_oe_flag
      x_charges_detail_rec.interface_to_oe_flag := l_interface_to_oe_flag;
    END IF;

  ELSIF p_validation_mode = 'U' THEN


    -- Added for Bug # 5135284
     IF l_transaction_type_changed = 'Y' THEN
       IF p_charges_detail_rec.interface_to_oe_flag <> FND_API.G_MISS_CHAR AND
          p_charges_detail_rec.interface_to_oe_flag IS NOT NULL THEN

          IF p_charges_detail_rec.interface_to_oe_flag IN ('Y', 'N') THEN
            x_charges_detail_rec.interface_to_oe_flag := p_charges_detail_rec.interface_to_oe_flag;
          ELSE
            x_charges_detail_rec.interface_to_oe_flag := l_interface_to_oe_flag;
          END IF;

       ELSIF p_charges_detail_rec.interface_to_oe_flag IS NULL THEN
          x_charges_detail_rec.interface_to_oe_flag := 'N';
       ELSE
          x_charges_detail_rec.interface_to_oe_flag := l_interface_to_oe_flag;
       END IF;

     ELSE
        -- l_transaction_type_changed = 'N'
        IF p_charges_detail_rec.interface_to_oe_flag <> FND_API.G_MISS_CHAR AND
           p_charges_detail_rec.interface_to_oe_flag IS NOT NULL THEN

            IF p_charges_detail_rec.interface_to_oe_flag IN ('Y', 'N') THEN
              x_charges_detail_rec.interface_to_oe_flag := p_charges_detail_rec.interface_to_oe_flag;
            ELSE
              x_charges_detail_rec.interface_to_oe_flag := l_db_det_rec.interface_to_oe_flag;
            END IF;

        ELSIF p_charges_detail_rec.interface_to_oe_flag IS NULL THEN
           x_charges_detail_rec.interface_to_oe_flag := 'N';
        ELSE
           x_charges_detail_rec.interface_to_oe_flag := l_db_det_rec.interface_to_oe_flag;
        END IF;

     END IF;

     --DBMS_OUTPUT.PUT_LINE('passed interface_oe_flag validation');
  END IF;

--====================================
-- No Charge Flag Validation
--====================================
  IF p_validation_mode = 'I' THEN

    -- If the no_charge_flag is passed then use the no_charge_flag passed by
    -- upstream application.
    -- If not passed then default this from the Transaction Type Setup
    -- Added for Bug # 5135284
    IF p_charges_detail_rec.no_charge_flag IS NOT NULL AND
       p_charges_detail_rec.no_charge_flag IN ('Y', 'N') THEN
      x_charges_detail_rec.no_charge_flag := p_charges_detail_rec.no_charge_flag;
    ELSE
      -- p_charges_detail_rec.no_charge_flag is null
      -- default it to l_no_charge_flag
      x_charges_detail_rec.no_charge_flag := l_no_charge_flag;
    END IF;

  ELSIF p_validation_mode = 'U' THEN

     -- Resolve Bug # 3078244
     -- If Transaction Type is changed and then
     -- if no_charge_flag is passed then use the no_charge_flag passed by
     -- upstream application
     -- if not passed then use the one from the database

     IF l_transaction_type_changed = 'Y' THEN
       IF p_charges_detail_rec.no_charge_flag <> FND_API.G_MISS_CHAR AND
          p_charges_detail_rec.no_charge_flag IS NOT NULL THEN
          IF p_charges_detail_rec.no_charge_flag IN ('Y', 'N') THEN
            x_charges_detail_rec.no_charge_flag := p_charges_detail_rec.no_charge_flag;
          ELSE
            x_charges_detail_rec.no_charge_flag := l_no_charge_flag;
          END IF;
       ELSIF p_charges_detail_rec.no_charge_flag IS NULL THEN
          x_charges_detail_rec.no_charge_flag := 'N';
       ELSE
          x_charges_detail_rec.no_charge_flag := l_no_charge_flag;
       END IF;

     ELSE
        -- l_transaction_type_changed = 'N'
        IF p_charges_detail_rec.no_charge_flag <> FND_API.G_MISS_CHAR AND
           p_charges_detail_rec.no_charge_flag IS NOT NULL THEN
           IF p_charges_detail_rec.no_charge_flag IN ('Y', 'N') THEN
            x_charges_detail_rec.no_charge_flag := p_charges_detail_rec.no_charge_flag;
          ELSE
            x_charges_detail_rec.no_charge_flag := l_db_det_rec.no_charge_flag;
          END IF;
        ELSIF p_charges_detail_rec.no_charge_flag IS NULL THEN
          x_charges_detail_rec.no_charge_flag := 'N';
        ELSE
           x_charges_detail_rec.no_charge_flag := l_db_det_rec.no_charge_flag;
        END IF;

     END IF;

     --DBMS_OUTPUT.PUT_LINE('passed no charge flag validation');
  END IF;

 --======================
 --Item Validation
 --======================
  --DBMS_OUTPUT.PUT_LINE('Item Validation ...');

  IF p_validation_mode = 'I' THEN

    IF p_charges_detail_rec.inventory_item_id_in IS NULL THEN
      Add_Null_Parameter_Msg(l_api_name,
                             'inventory_item_id') ;

      Add_Invalid_Argument_Msg(l_api_name,
                               to_char(p_charges_detail_rec.inventory_item_id_in),
                               'inventory_item_id');
      RAISE FND_API.G_EXC_ERROR ;

    ELSE
      -- Inventory_Item_ID is not null, call Validate Item

      --DBMS_OUTPUT.PUT_LINE('Calling VALIDATE_ITEM. p_charges_detail_rec.inventory_item_id_in='||p_charges_detail_rec.inventory_item_id_in);

      VALIDATE_ITEM(P_API_NAME            => p_api_name,
                    P_INV_ID              => p_charges_detail_rec.inventory_item_id_in,
                    P_UPDATE_IB_FLAG      => l_update_ib_flag,
                    X_COMMS_TRACKABLE_FLAG=> l_comms_trackable_flag,
                    X_SERIAL_CONTROL_FLAG => l_serial_control_flag,
                    X_REV_CONTROL_FLAG    => l_rev_control_flag,
                    X_MSG_DATA            => l_msg_data,
                    X_MSG_COUNT           => l_msg_count,
                    X_RETURN_STATUS       => l_return_status);

      --DBMS_OUTPUT.PUT_LINE('Back from VALIDATE_ITEM '||l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_VALIDATE_ITEM_ERROR');
        FND_MESSAGE.SET_TOKEN('INV_ID', p_charges_detail_rec.inventory_item_id_in);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        --assign to out record
        x_charges_detail_rec.inventory_item_id_in := p_charges_detail_rec.inventory_item_id_in;
      END IF;

    END IF;

  ELSIF p_validation_mode = 'U' THEN

    --DBMS_OUTPUT.PUT_LINE( 'In update for item val');
    --DBMS_OUTPUT.PUT_LINE( 'p_charges_detail_rec.inventory_item_id_in '||p_charges_detail_rec.inventory_item_id_in);

    -- Resolve Bug # 3078244
    IF p_charges_detail_rec.inventory_item_id_in <> FND_API.G_MISS_NUM AND
       p_charges_detail_rec.inventory_item_id_in IS NOT NULL THEN

      IF l_db_det_rec.customer_product_id IS NOT NULL AND
        p_charges_detail_rec.inventory_item_id_in <> l_db_det_rec.inventory_item_id AND
        p_charges_detail_rec.customer_product_id IS NULL AND
        l_src_reference_reqd_flag = 'Y' AND
        l_src_return_reqd_flag = 'Y' AND
        l_update_ib_flag = 'Y' AND
        l_line_order_category_code = 'RETURN' THEN

        --DBMS_OUTPUT.PUT_LINE('Cannot change item');

        Cant_Update_Detail_Param_Msg(l_api_name_full,
                                     'INVENTORY_ITEM_ID',
                                     to_char(p_charges_DETAIL_rec.inventory_item_id_in));

        RAISE FND_API.G_EXC_ERROR ;


      ELSE

        --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.inventory_item_id_in not null');
        -- Validate Item
        VALIDATE_ITEM(P_API_NAME                  => p_api_name,
                      P_INV_ID                    => p_charges_detail_rec.inventory_item_id_in,
                      P_UPDATE_IB_FLAG            => l_update_ib_flag,
                      X_COMMS_TRACKABLE_FLAG      => l_comms_trackable_flag,
                      X_SERIAL_CONTROL_FLAG       => l_serial_control_flag,
                      X_REV_CONTROL_FLAG          => l_rev_control_flag,
                      X_MSG_DATA                  => l_msg_data,
                      X_MSG_COUNT                 => l_msg_count,
                      X_RETURN_STATUS             => l_return_status);

        --DBMS_OUTPUT.PUT_LINE('l_return_status = '||l_return_status);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_VALIDATE_ITEM_ERROR');
          FND_MESSAGE.SET_TOKEN('INV_ID', p_charges_detail_rec.inventory_item_id_in);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --assign to out record
        x_charges_detail_rec.inventory_item_id_in := p_charges_detail_rec.inventory_item_id_in;

        --Condition added to fix Bug # 3358531
        --the flags will only be set to Y if they do not match the database
        IF x_charges_detail_rec.inventory_item_id_in <> l_db_det_rec.inventory_item_id THEN
          -- Item is changed so recalculate the price
          l_calc_sp := 'Y' ;
          l_item_changed := 'Y';
        END IF;

        --DBMS_OUTPUT.PUT_LINE('Item Valid');

      END IF ;

    ELSE
      --p_charges_detail_rec.inventory_item_id_in is not passed
      --assign to out record
      IF p_charges_detail_rec.inventory_item_id_in = FND_API.G_MISS_NUM OR
         p_charges_detail_rec.inventory_item_id_in IS NULL THEN

         x_charges_detail_rec.inventory_item_id_in := l_db_det_rec.inventory_item_id;

         --again need to validate the item as all flags are not stored in DB
         VALIDATE_ITEM(P_API_NAME                 => p_api_name,
                      P_INV_ID                    => x_charges_detail_rec.inventory_item_id_in,
                      P_UPDATE_IB_FLAG            => l_update_ib_flag,
                      X_COMMS_TRACKABLE_FLAG      => l_comms_trackable_flag,
                      X_SERIAL_CONTROL_FLAG       => l_serial_control_flag,
                      X_REV_CONTROL_FLAG          => l_rev_control_flag,
                      X_MSG_DATA                  => l_msg_data,
                      X_MSG_COUNT                 => l_msg_count,
                      X_RETURN_STATUS             => l_return_status);

         --DBMS_OUTPUT.PUT_LINE('item from db');
      END IF;

    END IF;

    --DBMS_OUTPUT.PUT_LINE('Passed Item Validation');
    --DBMS_OUTPUT.PUT_LINE('Item is = '||x_charges_detail_rec.inventory_item_id_in);
  END IF;



 --=========================
 --Item Revision Validation
 --=========================
  --DBMS_OUTPUT.PUT_LINE('Item Revision Validation ...');
  IF p_validation_mode = 'I' THEN
    IF l_rev_control_flag = 'Y' THEN
      IF p_charges_detail_rec.item_revision IS NOT NULL AND
         p_charges_detail_rec.item_revision <> FND_API.G_MISS_CHAR THEN
           -- Added for fix:5125858
            IF IS_ITEM_REVISION_VALID(
                 p_inventory_item_id => p_charges_detail_rec.inventory_item_id_in,
                 p_item_revision    => p_charges_detail_rec.item_revision,
                 x_msg_data         => l_msg_data,
                 x_msg_count        => l_msg_count,
                 x_return_status    => l_return_status) = 'N' THEN

                 Add_Invalid_Argument_Msg(l_api_name,
                                          TO_CHAR(p_charges_detail_rec.item_revision),
                                          'item_revision');
                  RAISE FND_API.G_EXC_ERROR;
             ELSE
                  x_charges_detail_rec.item_revision := p_charges_detail_rec.item_revision;

            END IF;
      ELSE
        --item is revision controlled but item revsion is null
        --raise error
        --FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_ITEM_REVISION');
        --FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_charges_detail_rec.inventory_item_id_in, TRUE);
        --FND_MESSAGE.SET_TOKEN('ITEM_REVISION', p_charges_detail_rec.item_revision, TRUE);
        --FND_MSG_PUB.ADD;
        --RAISE FND_API.G_EXC_ERROR;
        x_charges_detail_rec.item_revision := NULL;
      END IF;
    ELSE
      -- l_rev_control_flag = 'N'
      x_charges_detail_rec.item_revision := NULL;
    END IF;

  ELSIF p_validation_mode = 'U' THEN

    -- Resolve Bug # 3078244

    IF l_item_changed = 'Y' THEN
      IF l_rev_control_flag = 'Y' THEN
        IF p_charges_detail_rec.item_revision <> FND_API.G_MISS_CHAR AND
           p_charges_detail_rec.item_revision IS NOT NULL THEN

           -- Added for fix:5125858
            IF IS_ITEM_REVISION_VALID(
                 p_inventory_item_id => p_charges_detail_rec.inventory_item_id_in,
                 p_item_revision    => p_charges_detail_rec.item_revision,
                 x_msg_data         => l_msg_data,
                 x_msg_count        => l_msg_count,
                 x_return_status    => l_return_status) = 'N' THEN

                 Add_Invalid_Argument_Msg(l_api_name,
                                          TO_CHAR(p_charges_detail_rec.item_revision),
                                          'item_revision');
                  RAISE FND_API.G_EXC_ERROR;
             ELSE
                  x_charges_detail_rec.item_revision := p_charges_detail_rec.item_revision;

            END IF;

        ELSE
          --item is revision controlled but item revsion is null, raise error
          --FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_ITEM_REVISION');
          --FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_charges_detail_rec.inventory_item_id_in, TRUE);
          --FND_MESSAGE.SET_TOKEN('ITEM_REVISION', p_charges_detail_rec.item_revision, TRUE);
          --FND_MSG_PUB.ADD;
          --RAISE FND_API.G_EXC_ERROR;
          x_charges_detail_rec.item_revision := NULL;
        END IF;
      ELSE
        --l_rev_control_flag = 'N' THEN ignore the item revision
        x_charges_detail_rec.item_revision := NULL;
      END IF;
    ELSE
      --l_item_changed = 'N'
      IF l_db_det_rec.item_revision IS NOT NULL THEN
        l_rev_control_flag := 'Y' ;
      ELSE
        l_rev_control_flag := 'N' ;
      END IF;

      IF l_rev_control_flag = 'Y' THEN
        IF p_charges_detail_rec.item_revision <> FND_API.G_MISS_CHAR AND
           p_charges_detail_rec.item_revision IS NOT NULL THEN
           --
           -- Added for fix:5125858
            IF IS_ITEM_REVISION_VALID(
                 p_inventory_item_id => p_charges_detail_rec.inventory_item_id_in,
                 p_item_revision    => p_charges_detail_rec.item_revision,
                 x_msg_data         => l_msg_data,
                 x_msg_count        => l_msg_count,
                 x_return_status    => l_return_status) = 'N' THEN

                 Add_Invalid_Argument_Msg(l_api_name,
                                          TO_CHAR(p_charges_detail_rec.item_revision),
                                          'item_revision');
                  RAISE FND_API.G_EXC_ERROR;
             ELSE
                  x_charges_detail_rec.item_revision := p_charges_detail_rec.item_revision;

            END IF;
           --
           -- Added for fix:5125858
        ELSE
           --get the revision from the database
           x_charges_detail_rec.item_revision := l_db_det_rec.item_revision;
        END IF;
      ELSE
        --l_rev_control_flag = 'N' THEN ignore the item revision
        x_charges_detail_rec.item_revision := NULL;
      END IF;

    END IF;

    --DBMS_OUTPUT.PUT_LINE('Item Revision '||x_charges_detail_rec.item_revision);


  END IF;

 --=========================
 --Line Number Validation
 --=========================
  --DBMS_OUTPUT.PUT_LINE('Line Number Validation ...');
  -- Added for fix:5125385
  IF p_validation_mode = 'I' THEN
     IF p_charges_detail_rec.line_number IS NOT NULL AND
        p_charges_detail_rec.line_number <> FND_API.G_MISS_NUM THEN
           -- If the line number already exists or <= 0, then raise an error message
            IF IS_LINE_NUMBER_VALID(
                 p_line_number => p_charges_detail_rec.line_number,
                 p_incident_id => p_charges_detail_rec.incident_id,
                 x_msg_data         => l_msg_data,
                 x_msg_count        => l_msg_count,
                 x_return_status    => l_return_status) = 'Y' THEN

                 Add_Invalid_Argument_Msg(l_api_name,
                                          TO_CHAR(p_charges_detail_rec.line_number),
                                          'line_number');
                  RAISE FND_API.G_EXC_ERROR;
             ELSE
                  x_charges_detail_rec.line_number := p_charges_detail_rec.line_number;

            END IF;

      END IF;

  ELSIF p_validation_mode = 'U' THEN
    -- no validation is performed for update mode
    null;

 END IF;
 --======================
 --UOM Validation
 --======================
  --DBMS_OUTPUT.PUT_LINE('UOM Validation ...  p_charges_detail_rec.unit_of_measure_code='||p_charges_detail_rec.unit_of_measure_code);
  IF p_validation_mode = 'I' THEN

    IF p_charges_detail_rec.unit_of_measure_code IS NOT NULL THEN


       l_valid_check := IS_UOM_VALID(
                        p_inv_id        => p_charges_detail_rec.inventory_item_id_in,
                        p_uom_code      => p_charges_detail_rec.unit_of_measure_code,
                        x_msg_data      => l_msg_data,
                        x_msg_count     => l_msg_count,
                        x_return_status => l_return_status);

        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      IF l_valid_check <> 'Y' THEN
        Add_Invalid_Argument_Msg(l_api_name,
                                 p_charges_detail_rec.unit_of_measure_code,
                                 'Unit_of_Measure_Code');
        RAISE FND_API.G_EXC_ERROR;

      ELSE
        --assign to out record
        x_charges_detail_rec.unit_of_measure_code := p_charges_detail_rec.unit_of_measure_code;
      END IF;

    ELSE
      -- p_charges_detail_rec.unit_of_measure_code IS NULL, call get primary UOM Proc

      --DBMS_OUTPUT.PUT_LINE('Calling GET_PRIMARY_UOM');
      GET_PRIMARY_UOM(P_INV_ID        =>    p_charges_detail_rec.inventory_item_id_in,
                      X_PRIMARY_UOM   =>    l_primary_uom,
                      X_MSG_DATA      =>    l_msg_data ,
                      X_MSG_COUNT     =>    l_msg_count,
                      X_RETURN_STATUS =>    l_return_status);

      --DBMS_OUTPUT.PUT_LINE('Back from GET_PRIMARY_UOM status='||l_return_status || '   l_primary_uom '||l_primary_uom);

      --IF l_return_status <> 'S' THEN
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        --raise error
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_PRIMARY_UOM_ERROR');
        FND_MESSAGE.SET_TOKEN('INV_ID', p_charges_detail_rec.inventory_item_id_in);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --assign to out record
      x_charges_detail_rec.unit_of_measure_code := l_primary_uom;

    END IF;

  ELSIF p_validation_mode = 'U' THEN

  -- Resolve Bug # 3078244

  IF l_item_changed = 'Y' THEN
   IF p_charges_detail_rec.unit_of_measure_code <> FND_API.G_MISS_CHAR AND
      p_charges_detail_rec.unit_of_measure_code IS NOT NULL THEN

        l_valid_check := IS_UOM_VALID(
                        p_inv_id        => p_charges_detail_rec.inventory_item_id_in,
                        p_uom_code      => p_charges_detail_rec.unit_of_measure_code,
                        x_msg_data      => l_msg_data,
                        x_msg_count     => l_msg_count,
                        x_return_status => l_return_status);

        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      IF l_valid_check <> 'Y' THEN
          Add_Invalid_Argument_Msg(l_api_name,
                                 p_charges_detail_rec.unit_of_measure_code,
                                 'Unit_of_Measure_Code');
        RAISE FND_API.G_EXC_ERROR;

      ELSE
        --assign to out record
        x_charges_detail_rec.unit_of_measure_code := p_charges_detail_rec.unit_of_measure_code;

         --Condition added to fix Bug # 3358531
        IF x_charges_detail_rec.unit_of_measure_code <> l_db_det_rec.unit_of_measure_code THEN
          --Unit Of Measure is changed need to re-calculate the list price
          l_calc_sp := 'Y';
        END IF;

      END IF;


    ELSE
        -- p_charges_detail_rec.unit_of_measure_code is not passed
        -- get primary UOM Proc
        GET_PRIMARY_UOM(P_INV_ID        =>    p_charges_detail_rec.inventory_item_id_in,
                        X_PRIMARY_UOM   =>    l_primary_uom,
                        X_MSG_DATA      =>    l_msg_data,
                        X_MSG_COUNT     =>    l_msg_count,
                        X_RETURN_STATUS =>    l_return_status);

        --IF l_return_status <> 'S' THEN
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          --raise error
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_PRIMARY_UOM_ERROR');
          FND_MESSAGE.SET_TOKEN('INV_ID', p_charges_detail_rec.inventory_item_id_in);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --assign to out record
        x_charges_detail_rec.unit_of_measure_code := l_primary_uom;

        --Condition added to fix Bug # 3358531
        IF x_charges_detail_rec.unit_of_measure_code <> l_db_det_rec.unit_of_measure_code THEN
          --Unit Of Measure is changed need to re-calculate the list price
          l_calc_sp := 'Y';
        END IF;

      END IF;

    ELSE

      -- l_item_changed = 'N';
      IF p_charges_detail_rec.unit_of_measure_code <> FND_API.G_MISS_CHAR AND
         p_charges_detail_rec.unit_of_measure_code IS NOT NULL THEN

        l_valid_check := IS_UOM_VALID(
                        p_inv_id        => p_charges_detail_rec.inventory_item_id_in,
                        p_uom_code      => p_charges_detail_rec.unit_of_measure_code,
                        x_msg_data      => l_msg_data,
                        x_msg_count     => l_msg_count,
                        x_return_status => l_return_status);

        IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      IF l_valid_check <> 'Y' THEN
        Add_Invalid_Argument_Msg(l_api_name,
                                 p_charges_detail_rec.unit_of_measure_code,
                                 'Unit_of_Measure_Code');
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        --assign to out record
        x_charges_detail_rec.unit_of_measure_code := p_charges_detail_rec.unit_of_measure_code;

        --Condition added to fix Bug # 3358531
        IF x_charges_detail_rec.unit_of_measure_code <> l_db_det_rec.unit_of_measure_code THEN
          --Unit Of Measure is changed need to re-calculate the list price
          l_calc_sp := 'Y';
        END IF;
      END IF;
    ELSE
        -- p_charges_rec.unit_of_measure_code is not passed or null
        -- assign db record to out record
        x_charges_detail_rec.unit_of_measure_code := l_db_det_rec.unit_of_measure_code;
    END IF;

  END IF;

  END IF;
  --DBMS_OUTPUT.PUT_LINE('UOM Validation completed...  x_charges_detail_rec.unit_of_measure_code='||x_charges_detail_rec.unit_of_measure_code);


 --==========================================
 --Billing Flag Validation    Note: billing flag means billing category
 --==========================================
  --DBMS_OUTPUT.PUT_LINE('Billing Flag Validation ...');
  IF p_validation_mode = 'I' THEN

    --DBMS_OUTPUT.PUT_LINE('Calling GET_BILLING_FLAG. p_charges_detail_rec.inventory_item_id_in=' || p_charges_detail_rec.inventory_item_id_in);
    --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.transaction_type_id=' || p_charges_detail_rec.transaction_type_id);

    GET_BILLING_FLAG(
                     P_API_NAME           => p_api_name,
                     P_INV_ID             => p_charges_detail_rec.inventory_item_id_in,
                     P_TXN_TYPE_ID        => p_charges_detail_rec.transaction_type_id,
                     X_BILLING_FLAG       => l_billing_flag,
                     X_MSG_DATA           => l_msg_data,
                     X_MSG_COUNT          => l_msg_count,
                     X_RETURN_STATUS      => l_return_status);

    --DBMS_OUTPUT.PUT_LINE('Back from GET_BILLING_FLAG. Status='||l_return_status||'  l_billing_flag='||l_billing_flag);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.billing_flag = ' || p_charges_detail_rec.billing_flag);
    --DBMS_OUTPUT.PUT_LINE('l_billing_flag = ' || l_billing_flag);

    IF p_charges_detail_rec.billing_flag IS NOT NULL THEN
      --DBMS_OUTPUT.PUT_LINE('P_Billing_Flag is not null');
      IF p_charges_detail_rec.billing_flag = l_billing_flag THEN
        x_charges_detail_rec.billing_flag := p_charges_detail_rec.billing_flag;
      ELSE
        -- Billing Flag does not match, raise Error
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_BILLING_FLAG');
        FND_MESSAGE.SET_TOKEN('BILLING_FLAG', p_charges_detail_rec.billing_flag);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      -- p_charges_detail_rec.billing_flag is null
      -- assign l_billing_flag to out record
      --DBMS_OUTPUT.PUT_LINE('P_Billing_Flag is not null');
      x_charges_detail_rec.billing_flag := l_billing_flag;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('Billing Flag is '||x_charges_detail_rec.billing_flag);

  ELSIF p_validation_mode = 'U' THEN

    IF l_item_changed = 'Y' OR
       l_transaction_type_changed = 'Y' THEN
       --get the new billing flag
      GET_BILLING_FLAG(
                       P_API_NAME           => p_api_name,
                       P_INV_ID             => x_charges_detail_rec.inventory_item_id_in,
                       P_TXN_TYPE_ID        => x_charges_detail_rec.transaction_type_id,
                       X_BILLING_FLAG       => l_billing_flag,
                       X_MSG_DATA           => l_msg_data,
                       X_MSG_COUNT          => l_msg_count,
                       X_RETURN_STATUS      => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

      IF p_charges_detail_rec.billing_flag <> FND_API.G_MISS_CHAR AND
         p_charges_detail_rec.billing_flag IS NOT NULL THEN
        IF p_charges_detail_rec.billing_flag = l_billing_flag THEN
          x_charges_detail_rec.billing_flag := p_charges_detail_rec.billing_flag;
        ELSE
          -- Billing Flag does not match
          -- Raise Error
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_BILLING_FLAG');
          FND_MESSAGE.SET_TOKEN('BILLING_FLAG', p_charges_detail_rec.billing_flag);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      ELSE
        -- p_charges_detail_rec.billing_flag is is not passed or is null
        -- assign l_billing_flag to out record
        x_charges_detail_rec.billing_flag := l_billing_flag;
      END IF;

    ELSE
      --niether item nor transaction type changed
      --assign attribute from db_record
      --x_charges_detail_rec.billing_flag := l_db_det_rec.billing_flag;  -- no such column

      GET_BILLING_FLAG(
                       P_API_NAME           => p_api_name,
                       P_INV_ID             => x_charges_detail_rec.inventory_item_id_in,
                       P_TXN_TYPE_ID        => x_charges_detail_rec.transaction_type_id,
                       X_BILLING_FLAG       => l_billing_flag,
                       X_MSG_DATA           => l_msg_data,
                       X_MSG_COUNT          => l_msg_count,
                       X_RETURN_STATUS      => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

      x_charges_detail_rec.billing_flag := l_billing_flag;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('Completes Billing Flag Validation ...');

  END IF;

 --=======================================
 --Transaction Billing Type ID Validation
 --=======================================
  --DBMS_OUTPUT.PUT_LINE('Transaction Billing Type ID Validation ...');
  IF p_validation_mode = 'I' THEN

    --DBMS_OUTPUT.PUT_LINE('Calling GET_TXN_BILLING_TYPE');
    GET_TXN_BILLING_TYPE(P_API_NAME            => p_api_name,
                         P_INV_ID              => p_charges_detail_rec.inventory_item_id_in,
                         P_TXN_TYPE_ID         => p_charges_detail_rec.transaction_type_id,
                         X_TXN_BILLING_TYPE_ID => l_txn_billing_type_id,
                         X_MSG_DATA            => l_msg_data,
                         X_MSG_COUNT           => l_msg_count,
                         X_RETURN_STATUS       => l_return_status);
    --DBMS_OUTPUT.PUT_LINE('Back from GET_TXN_BILLING_TYPE '||l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

      RAISE FND_API.G_EXC_ERROR ;

    ELSE

      IF p_charges_detail_rec.txn_billing_type_id IS NOT NULL THEN

        IF p_charges_detail_rec.txn_billing_type_id <> l_txn_billing_type_id THEN
          --RAISE ERROR
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_TXN_BILLING_TYP');
          FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID', p_charges_detail_rec.txn_billing_type_id);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE --
          --the ids match
          --assign to the out record
          x_charges_detail_rec.txn_billing_type_id := p_charges_detail_rec.txn_billing_type_id ;
        END IF;

      ELSE
        -- p_charges_detail_rec.txn_billing_type_id is null
        -- assign l_txn_billing_type_id to out record
        x_charges_detail_rec.txn_billing_type_id := l_txn_billing_type_id;
      END IF;

    END IF;

  ELSIF p_validation_mode = 'U' THEN

    IF l_item_changed = 'Y' OR
       l_transaction_type_changed = 'Y' THEN

      --need to get the txn billing type for changed parameters

      GET_TXN_BILLING_TYPE(P_API_NAME            => p_api_name,
                           P_INV_ID              => x_charges_detail_rec.inventory_item_id_in,
                           P_TXN_TYPE_ID         => x_charges_detail_rec.transaction_type_id,
                           X_TXN_BILLING_TYPE_ID => l_txn_billing_type_id,
                           X_MSG_DATA            => l_msg_data,
                           X_MSG_COUNT           => l_msg_count,
                           X_RETURN_STATUS       => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

      IF p_charges_detail_rec.txn_billing_type_id  <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.txn_billing_type_id IS NOT NULL THEN
        IF p_charges_detail_rec.txn_billing_type_id <> l_txn_billing_type_id THEN
          --RAISE ERROR
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_TXN_BILLING_TYP');
          FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID', p_charges_detail_rec.txn_billing_type_id);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE --
          --the ids match
          --assign to the out record
          x_charges_detail_rec.txn_billing_type_id := p_charges_detail_rec.txn_billing_type_id ;
        END IF;

      ELSE

        -- p_charges_detail_rec.txn_billing_type_id is not passed
        -- assign l_txn_billing_type_id to out record
        x_charges_detail_rec.txn_billing_type_id := l_txn_billing_type_id;

      END IF;

    ELSE

      -- niether the item nor the transaction type is changed
      -- assign the billing type from db
      x_charges_detail_rec.txn_billing_type_id := l_db_det_rec.txn_billing_type_id;

    END IF;

    --DBMS_OUTPUT.PUT_LINE('Completed the txn billing type id');

  END IF;


 --=======================================
 --Line Type ID
 --=======================================
  --DBMS_OUTPUT.PUT_LINE('Line Type ID Validation ...');
  IF p_validation_mode = 'I' THEN

    --DBMS_OUTPUT.PUT_LINE('Calling get_line_type ...');
    --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.transaction_type_id = ' || p_charges_detail_rec.transaction_type_id);
    --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.transaction_type_id = ' || x_charges_detail_rec.transaction_type_id);
    --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.txn_billing_type_id = ' || x_charges_detail_rec.txn_billing_type_id);
        --Fixed Bug # 3325667 added p_org_id to procedure get_line_type
        Get_Line_Type(
          p_api_name       => p_api_name,
          p_txn_billing_type_id => x_charges_detail_rec.txn_billing_type_id,
          p_org_id              => x_charges_detail_rec.org_id,
          x_line_type_id  => l_line_type_id,
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data);

    --DBMS_OUTPUT.PUT_LINE('Back from Calling get_line_type. status = '||l_return_status);
    --DBMS_OUTPUT.PUT_LINE('msg_data = '||l_msg_data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

      RAISE FND_API.G_EXC_ERROR ;

    ELSE

      --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.line_type_id = '||p_charges_detail_rec.line_type_id);
      --DBMS_OUTPUT.PUT_LINE('l_line_type_id = '||l_line_type_id);
      --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.txn_billing_type_id = '||x_charges_detail_rec.txn_billing_type_id);

      IF p_charges_detail_rec.line_type_id IS NOT NULL THEN

        IF p_charges_detail_rec.line_type_id <> l_line_type_id THEN
          --RAISE ERROR
          --DBMS_OUTPUT.PUT_LINE('here is the error');
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_LINE_TYPE');
          FND_MESSAGE.SET_TOKEN('LINE_TYPE_ID', p_charges_detail_rec.line_type_id);
          FND_MESSAGE.SET_TOKEN('TXN_LINE_TYPE_ID', l_line_type_id);
          FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID', x_charges_detail_rec.txn_billing_type_id);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE --
          --the ids match
          --assign to the out record
          x_charges_detail_rec.line_type_id := p_charges_detail_rec.line_type_id;
        END IF;

      ELSE
        -- p_charges_detail_rec.line_type_id is null
        -- assign l_line_type_id to out record
        x_charges_detail_rec.line_type_id := l_line_type_id;
      END IF;

    END IF;

  ELSIF p_validation_mode = 'U' THEN

    IF l_item_changed = 'Y' OR
       l_transaction_type_changed = 'Y' THEN

      --need to get the line type id for changed parameters
      --Fixed Bug # 3325667 added p_org_id to procedure get_line_type

      Get_Line_Type(p_api_name            => p_api_name,
                    p_txn_billing_type_id => x_charges_detail_rec.txn_billing_type_id,
                    p_org_id              => x_charges_detail_rec.org_id,
                    x_line_type_id        => l_line_type_id,
                    x_return_status       => l_return_status,
                    x_msg_count           => l_msg_count,
                    x_msg_data            => l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

      IF p_charges_detail_rec.line_type_id <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.line_type_id IS NOT NULL THEN
        IF p_charges_detail_rec.line_type_id <> l_line_type_id THEN
          --RAISE ERROR
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_LINE_TYPE');
          FND_MESSAGE.SET_TOKEN('LINE_TYPE_ID', p_charges_detail_rec.line_type_id);
          FND_MESSAGE.SET_TOKEN('TXN_LINE_TYPE_ID', l_line_type_id);
          FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID', x_charges_detail_rec.txn_billing_type_id);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE --
          --the ids match
          --assign to the out record
          x_charges_detail_rec.line_type_id := p_charges_detail_rec.line_type_id;
        END IF;

      ELSE

        -- p_charges_detail_rec.line_type_id is null
        -- assign l_line_type_id to out record
        x_charges_detail_rec.line_type_id := l_line_type_id;

      END IF;

    ELSE

      -- niether the item nor the transaction type is changed
      -- assign the line_type_id from db
      x_charges_detail_rec.line_type_id := l_db_det_rec.line_type_id;

    END IF;

    --DBMS_OUTPUT.PUT_LINE('Completed Line Type Id Validation successfully ...');

  END IF;


--=====================================
--TCA Validation
--=====================================
--DBMS_OUTPUT.PUT_LINE('TCA Validation ...');

IF p_validation_mode = 'I' THEN

  -- Bill to Valdation
  --
  --DBMS_OUTPUT.PUT_LINE('In the the TCA Validation');

  IF p_charges_detail_rec.bill_to_party_id IS NOT NULL THEN

    IF IS_PARTY_VALID(p_party_id      => p_charges_detail_rec.bill_to_party_id,
                      x_msg_data         => l_msg_data,
                      x_msg_count        => l_msg_count,
                      x_return_status    => l_return_status) = 'N' THEN

      Add_Invalid_Argument_Msg(l_api_name,
                               to_char(p_charges_detail_rec.bill_to_party_id),
                               'Bill_to_Party_Id');
      RAISE FND_API.G_EXC_ERROR;

    ELSE
      --assign to out record
      x_charges_detail_rec.bill_to_party_id := p_charges_detail_rec.bill_to_party_id;

      IF p_charges_detail_rec.bill_to_account_id IS NOT NULL THEN


         IF IS_ACCOUNT_VALID(p_party_id      => p_charges_detail_rec.bill_to_party_id,
                             p_account_id    => p_charges_detail_rec.bill_to_account_id,
                             x_msg_data      => l_msg_data,
                             x_msg_count     => l_msg_count,
                             x_return_status => l_return_status) = 'U' THEN
           --raise unexpected error
           Raise FND_API.G_EXC_UNEXPECTED_ERROR;
           null;
         ELSIF IS_ACCOUNT_VALID(p_party_id      => p_charges_detail_rec.bill_to_party_id,
                                p_account_id    => p_charges_detail_rec.bill_to_account_id,
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'N' THEN

           Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.bill_to_account_id),
                                 'Bill_to_Account_Id');
           RAISE FND_API.G_EXC_ERROR;
           null;
         ELSE
           -- assign to out record
           x_charges_detail_rec.bill_to_account_id := p_charges_detail_rec.bill_to_account_id;
         END IF;
      ELSE
        -- bill_to_account IS NULL
        -- assign NULL to out record
        x_charges_detail_rec.bill_to_account_id := NULL;
      END IF;
      IF  p_charges_detail_rec.bill_to_contact_id IS NOT NULL THEN


        IF IS_CONTACT_VALID(p_party_id      => p_charges_detail_rec.bill_to_party_id,
                            p_contact_id    => p_charges_detail_rec.bill_to_contact_id,
                            x_msg_data      => l_msg_data,
                            x_msg_count     => l_msg_count,
                            x_return_status => l_return_status) = 'U' THEN
          --raise unexpected error
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
          null;

        ELSIF IS_CONTACT_VALID(p_party_id      => p_charges_detail_rec.bill_to_party_id,
                               p_contact_id    => p_charges_detail_rec.bill_to_contact_id,
                               x_msg_data      => l_msg_data,
                               x_msg_count     => l_msg_count,
                               x_return_status => l_return_status) = 'N' THEN

          Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.bill_to_contact_id),
                                 'Bill_to_Contact_Id');
          RAISE FND_API.G_EXC_ERROR;
          null;
        ELSE
          -- assign to out record
          x_charges_detail_rec.bill_to_contact_id := p_charges_detail_rec.bill_to_contact_id;
        END IF;
      ELSE
        -- bill_to_contact IS NULL
        -- assign NULL to out record
        x_charges_detail_rec.bill_to_contact_id := NULL;
      END IF;

      IF p_charges_detail_rec.invoice_to_org_id IS NOT NULL THEN


        IF IS_PARTY_SITE_VALID( p_party_site_id => p_charges_detail_rec.invoice_to_org_id,
                                p_party_id      => p_charges_detail_rec.bill_to_party_id,
                                p_val_mode      => 'BILL_TO',
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'U' THEN
          --raise unexpected error
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
          null;
        ELSIF IS_PARTY_SITE_VALID( p_party_site_id => p_charges_detail_rec.invoice_to_org_id,
                                p_party_id         => p_charges_detail_rec.bill_to_party_id,
                                p_val_mode         => 'BILL_TO',
                                x_msg_data         => l_msg_data,
                                x_msg_count        => l_msg_count,
                                x_return_status    => l_return_status) = 'N' THEN
          Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.invoice_to_org_id),
                                 'Invoice_to_org_Id');
          RAISE FND_API.G_EXC_ERROR;
          null;
        ELSE
          --assign to out record
          x_charges_detail_rec.invoice_to_org_id := p_charges_detail_rec.invoice_to_org_id;
        END IF;

      ELSE
        --invoice_to_org_id IS NULL
        --assign NULL to out record
        x_charges_detail_rec.invoice_to_org_id := NULL;
      END IF;
    END IF;

  ELSE
    -- p_charges_detail_rec.bill_to_party_id IS NULL
    -- default TCA information from SR

    --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.bill_to_party_id IS NULL............');
    --DBMS_OUTPUT.PUT_LINE('l_bill_to_party_id'||l_bill_to_party_id);

    IF l_bill_to_party_id <> -999 THEN

      IF IS_PARTY_VALID(p_party_id         => l_bill_to_party_id,
                        x_msg_data         => l_msg_data,
                        x_msg_count        => l_msg_count,
                        x_return_status    => l_return_status) = 'N' THEN

        Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(l_bill_to_party_id),
                                 'Bill_to_Party_Id');
        RAISE FND_API.G_EXC_ERROR;
        null;
      ELSE

        --DBMS_OUTPUT.PUT_LINE('l_bill_to_party_id assigned ...' || l_bill_to_party_id);

        --assign to out record
        x_charges_detail_rec.bill_to_party_id := l_bill_to_party_id;

        IF l_bill_to_account_id <> -999 THEN
          IF IS_ACCOUNT_VALID(p_party_id      => l_bill_to_party_id,
                              p_account_id    => l_bill_to_account_id,
                              x_msg_data      => l_msg_data,
                              x_msg_count     => l_msg_count,
                              x_return_status => l_return_status) = 'U' THEN
            --raise unexpected error
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
            null;

          ELSIF IS_ACCOUNT_VALID(p_party_id      => l_bill_to_party_id,
                              p_account_id    => l_bill_to_account_id,
                              x_msg_data      => l_msg_data,
                              x_msg_count     => l_msg_count,
                              x_return_status => l_return_status) = 'N' THEN

             Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(l_bill_to_account_id),
                                 'Bill_to_Account_Id');
             RAISE FND_API.G_EXC_ERROR;
             null;
           ELSE
             --DBMS_OUTPUT.PUT_LINE(' l_bill_to_account_id assigned ....'||l_bill_to_account_id);

             -- assign to out record
             x_charges_detail_rec.bill_to_account_id := l_bill_to_account_id;
           END IF;
        ELSE
          --l_bill_to_account is -999
          --assign NULL to out record
          --DBMS_OUTPUT.PUT_LINE(' l_bill_to_account_id assigned is null ');
          x_charges_detail_rec.bill_to_account_id := NULL;

        END IF;

        IF  l_bill_to_contact_id <> -999 THEN
          IF IS_CONTACT_VALID(p_party_id      => l_bill_to_party_id,
                              p_contact_id    => l_bill_to_contact_id,
                              x_msg_data      => l_msg_data,
                              x_msg_count     => l_msg_count,
                              x_return_status => l_return_status) = 'U' THEN
            --raise unexpected error
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
            null;

          ELSIF IS_CONTACT_VALID(p_party_id   => l_bill_to_party_id,
                              p_contact_id    => l_bill_to_contact_id,
                              x_msg_data      => l_msg_data,
                              x_msg_count     => l_msg_count,
                              x_return_status => l_return_status) = 'N' THEN

            Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(l_bill_to_contact_id),
                                 'Bill_to_Contact_Id');
            RAISE FND_API.G_EXC_ERROR;
            null;
          ELSE
            -- assign to out record
            --DBMS_OUTPUT.PUT_LINE(' l_bill_to_contact_id assigned....'||l_bill_to_contact_id);

            x_charges_detail_rec.bill_to_contact_id := l_bill_to_contact_id;
          END IF;
        ELSE
          --l_bill_to_contact_id IS NULL
          --assign NULL to out record
          --DBMS_OUTPUT.PUT_LINE(' l_bill_to_contact_id assigned null');
          x_charges_detail_rec.bill_to_contact_id := NULL;
        END IF;

        IF  l_bill_to_site_id <> -999 THEN
          x_charges_detail_rec.invoice_to_org_id := l_bill_to_site_id;
        ELSE
          --l_bill_to_site_use_id IS NULL
          --assign NULL to the out record
          --assign the customer_site_id
          x_charges_detail_rec.invoice_to_org_id := l_customer_site_id;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.invoice_to_org_id ...'||x_charges_detail_rec.invoice_to_org_id);

      END IF;
    ELSE
      --l_bill_to_party_id is -999
      --Check If l_customer_id is not null
      IF l_customer_id IS NOT NULL THEN

        IF IS_PARTY_VALID(p_party_id      => l_customer_id,
                          x_msg_data      => l_msg_data,
                          x_msg_count     => l_msg_count,
                          x_return_status => l_return_status) = 'N' THEN

          Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(l_customer_id),
                                 'Bill_to_Party_Id');
          RAISE FND_API.G_EXC_ERROR;
          null;
        ELSE
          --assign to out record
          x_charges_detail_rec.bill_to_party_id := l_customer_id;
          -- Fix For Bug 6356247--Start
	  --x_charges_detail_rec.bill_to_contact_id := l_customer_id;
	  x_charges_detail_rec.bill_to_contact_id := Null;
	  -- Fix For Bug 6356247--End

          IF l_account_id IS NOT NULL THEN


            IF IS_ACCOUNT_VALID(p_party_id      => l_customer_id,
                                p_account_id    => l_account_id,
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'U' THEN
              --raise unexpected error
              Raise FND_API.G_EXC_UNEXPECTED_ERROR;
              null;

            ELSIF IS_ACCOUNT_VALID(p_party_id      => l_customer_id,
                                p_account_id    => l_account_id,
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'N' THEN

              Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(l_account_id),
                                 'Bill_to_Account_Id');
              RAISE FND_API.G_EXC_ERROR;
              null;
            ELSE
              -- assign to out record
              x_charges_detail_rec.bill_to_account_id :=l_account_id;
            END IF;
          END IF;

          IF l_customer_site_id IS NOT NULL THEN

            IF IS_PARTY_SITE_VALID( p_party_site_id => l_customer_site_id,
                                    p_party_id      => l_customer_id,
                                    p_val_mode      => 'NONE',
                                    x_msg_data      => l_msg_data,
                                    x_msg_count     => l_msg_count,
                                    x_return_status => l_return_status) = 'U' THEN
              --raise unexpected error
              Raise FND_API.G_EXC_UNEXPECTED_ERROR;
              null;
            ELSIF IS_PARTY_SITE_VALID( p_party_site_id => l_customer_site_id,
                                    p_party_id      => l_customer_id,
                                    p_val_mode      => 'NONE',
                                    x_msg_data      => l_msg_data,
                                    x_msg_count     => l_msg_count,
                                    x_return_status => l_return_status) = 'N' THEN

              Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(l_customer_site_id),
                                 'Invoice_to_Org_Id');
              RAISE FND_API.G_EXC_ERROR;
              null;
            ELSE
              --assign to out record
              x_charges_detail_rec.invoice_to_org_id := l_customer_site_id;
            END IF;
          ELSE
            --l_customer_site_id IS NULL
            --assign NULL to out record
            x_charges_detail_rec.invoice_to_org_id := NULL;
          END IF;
        END IF;
      ELSE
        x_charges_detail_rec.bill_to_party_id   := NULL;
        x_charges_detail_rec.bill_to_account_id := NULL;
        x_charges_detail_rec.bill_to_contact_id := NULL;
        x_charges_detail_rec.invoice_to_org_id  := NULL;
      END IF;
    END IF;
  END IF;

  --DBMS_OUTPUT.PUT_LINE('Passed Bill To Validation .....');

  -- Ship To Validation
  --
  --DBMS_OUTPUT.PUT_LINE(' ship tp party id '||p_charges_detail_rec.ship_to_party_id );

  IF p_charges_detail_rec.ship_to_party_id IS NOT NULL THEN

    IF IS_PARTY_VALID(p_party_id   => p_charges_detail_rec.ship_to_party_id,
                      x_msg_data      => l_msg_data,
                      x_msg_count     => l_msg_count,
                      x_return_status => l_return_status) = 'N' THEN


       Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.ship_to_party_id),
                                 'Ship_to_Party_Id');

        x_msg_data      :=  l_msg_data;
        x_return_status :=  l_return_status;

       RAISE FND_API.G_EXC_ERROR;

    ELSE

      --DBMS_OUTPUT.PUT_LINE('Assigning the ship_to_party_id '||p_charges_detail_rec.ship_to_party_id);

      --assign to out record
      x_charges_detail_rec.ship_to_party_id := p_charges_detail_rec.ship_to_party_id;

      IF p_charges_detail_rec.ship_to_account_id IS NOT NULL THEN

         IF IS_ACCOUNT_VALID(p_party_id         => p_charges_detail_rec.ship_to_party_id,
                             p_account_id       => p_charges_detail_rec.ship_to_account_id,
                             x_msg_data         => l_msg_data,
                             x_msg_count        => l_msg_count,
                             x_return_status    => l_return_status) = 'U' THEN
           --raise unexpected error
           Raise FND_API.G_EXC_UNEXPECTED_ERROR;
           null;

         ELSIF IS_ACCOUNT_VALID(p_party_id      => p_charges_detail_rec.ship_to_party_id,
                             p_account_id       => p_charges_detail_rec.ship_to_account_id,
                             x_msg_data         => l_msg_data,
                             x_msg_count        => l_msg_count,
                             x_return_status    => l_return_status) = 'N' THEN

           Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.ship_to_account_id),
                                 'Ship_to_Account_Id');

           x_msg_data      :=  l_msg_data;
           x_return_status :=  l_return_status;

           RAISE FND_API.G_EXC_ERROR;
         ELSE
           -- assign to out record
           x_charges_detail_rec.ship_to_account_id := p_charges_detail_rec.ship_to_account_id;
         END IF;
      ELSE
        -- Ship To Account ID is NULL
        -- assign NULL to out record
        x_charges_detail_rec.ship_to_account_id := NULL;
      END IF;

      IF  p_charges_detail_rec.ship_to_contact_id IS NOT NULL THEN

        IF IS_CONTACT_VALID(p_party_id      => p_charges_detail_rec.ship_to_party_id,
                            p_contact_id    => p_charges_detail_rec.ship_to_contact_id,
                            x_msg_data      => l_msg_data,
                            x_msg_count     => l_msg_count,
                            x_return_status => l_return_status) = 'U' THEN
          --raise unexpected error
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
          null;
        ELSIF IS_CONTACT_VALID(p_party_id   => p_charges_detail_rec.ship_to_party_id,
                            p_contact_id    => p_charges_detail_rec.ship_to_contact_id,
                            x_msg_data      => l_msg_data,
                            x_msg_count     => l_msg_count,
                            x_return_status => l_return_status) = 'N' THEN

          Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.ship_to_contact_id),
                                 'Ship_to_Contact_Id');
          RAISE FND_API.G_EXC_ERROR;

        ELSE
          -- assign to out record
          x_charges_detail_rec.ship_to_contact_id := p_charges_detail_rec.ship_to_contact_id;
        END IF;
      ELSE
        -- Ship To Contact is NULL
        -- assign NULL to out record
        x_charges_detail_rec.ship_to_contact_id := NULL;
      END IF;

      IF p_charges_detail_rec.ship_to_org_id IS NOT NULL THEN


        IF IS_PARTY_SITE_VALID( p_party_site_id => p_charges_detail_rec.ship_to_org_id,
                                p_party_id      => p_charges_detail_rec.ship_to_party_id,
                                p_val_mode      => 'SHIP_TO',
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'U' THEN
          --raise unexpected error
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
          null;
        ELSIF IS_PARTY_SITE_VALID( p_party_site_id => p_charges_detail_rec.ship_to_org_id,
                                p_party_id         => p_charges_detail_rec.ship_to_party_id,
                                p_val_mode         => 'SHIP_TO',
                                x_msg_data         => l_msg_data,
                                x_msg_count        => l_msg_count,
                                x_return_status    => l_return_status) = 'N' THEN

          Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.ship_to_org_id),
                                 'Ship_to_org_Id');
          RAISE FND_API.G_EXC_ERROR;
          null;
        ELSE
          --assign to out record
          x_charges_detail_rec.ship_to_org_id := p_charges_detail_rec.ship_to_org_id;
        END IF;

      ELSE
        --ship_to_org_id IS NULL
        --assign NULL to out record
        x_charges_detail_rec.ship_to_org_id := NULL;
      END IF;

    END IF;

  ELSE
    -- p_charges_detail_rec.ship_to_party_id IS NULL
    -- default TCA information from SR

    --DBMS_OUTPUT.PUT_LINE('ship to party id is null');

    IF l_ship_to_party_id <> -999 THEN
      IF IS_PARTY_VALID(p_party_id   => l_ship_to_party_id,
                        x_msg_data      => l_msg_data,
                        x_msg_count     => l_msg_count,
                        x_return_status => l_return_status) = 'N' THEN
        RAISE FND_API.G_EXC_ERROR;
        null;
      ELSE
        --assign to out record
        x_charges_detail_rec.ship_to_party_id := l_ship_to_party_id;

        IF l_ship_to_account_id <> -999 THEN


          IF IS_ACCOUNT_VALID(p_party_id      => l_ship_to_party_id,
                              p_account_id    => l_ship_to_account_id,
                              x_msg_data      => l_msg_data,
                              x_msg_count     => l_msg_count,
                              x_return_status => l_return_status) = 'U' THEN
            --raise unexpected error
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
            null;

          ELSIF IS_ACCOUNT_VALID(p_party_id   => l_ship_to_party_id,
                              p_account_id    => l_ship_to_account_id,
                              x_msg_data      => l_msg_data,
                              x_msg_count     => l_msg_count,
                              x_return_status => l_return_status) = 'N' THEN
             Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(l_ship_to_account_id),
                                 'Ship_to_Account_Id');

             x_msg_data      :=  l_msg_data;
             x_return_status :=  l_return_status;

             RAISE FND_API.G_EXC_ERROR;
          ELSE
             -- assign to out record
             x_charges_detail_rec.ship_to_account_id := l_ship_to_account_id;
          END IF;
        ELSE
          -- Ship To Account is -999
          -- assign NULL to out record
           x_charges_detail_rec.ship_to_account_id := NULL;
        END IF;

        IF  l_ship_to_contact_id <> -999 THEN

          IF IS_CONTACT_VALID(p_party_id      => l_ship_to_party_id,
                              p_contact_id    => l_ship_to_contact_id,
                              x_msg_data      => l_msg_data,
                              x_msg_count     => l_msg_count,
                              x_return_status => l_return_status) = 'U' THEN
            --raise unexpected error
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
            null;

          ELSIF IS_CONTACT_VALID(p_party_id   => l_ship_to_party_id,
                              p_contact_id    => l_ship_to_contact_id,
                              x_msg_data      => l_msg_data,
                              x_msg_count     => l_msg_count,
                              x_return_status => l_return_status) = 'N' THEN

            Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(l_ship_to_contact_id),
                                 'Ship_to_Contact_Id');
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            -- assign to out record
            x_charges_detail_rec.ship_to_contact_id := l_ship_to_contact_id;
          END IF;
        ELSE
          -- Ship To Contact is -999
          -- assign NULL to out record
          x_charges_detail_rec.ship_to_contact_id := NULL;
        END IF;

        IF  l_ship_to_site_id <> -999 THEN
          x_charges_detail_rec.ship_to_org_id := l_ship_to_site_id;
        ELSE
          --l_ship_to_site_use_id IS NULL
          --assign l_customer_site_id
          x_charges_detail_rec.ship_to_org_id := l_customer_site_id;
        END IF;

      END IF;
    ELSE
      --l_ship_to_party_id is -999
      --Check If l_customer_id is not null
      IF l_customer_id IS NOT NULL THEN

        IF IS_PARTY_VALID(p_party_id   => l_customer_id,
                          x_msg_data      => l_msg_data,
                          x_msg_count     => l_msg_count,
                          x_return_status => l_return_status) = 'N' THEN
          RAISE FND_API.G_EXC_ERROR;
          null;
        ELSE
          --assign to out record
          x_charges_detail_rec.ship_to_party_id := l_customer_id;
	  --Fix for Bug 6356247--Start
          --x_charges_detail_rec.ship_to_contact_id := l_customer_id;
	  x_charges_detail_rec.ship_to_contact_id := Null;
	  --Fix for Bug 6356247--End

          IF l_account_id IS NOT NULL THEN

            IF IS_ACCOUNT_VALID(p_party_id      => l_customer_id,
                                p_account_id    => l_account_id,
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'U' THEN
              --raise unexpected error
              Raise FND_API.G_EXC_UNEXPECTED_ERROR;
              null;

            ELSIF IS_ACCOUNT_VALID(p_party_id   => l_customer_id,
                                p_account_id    => l_account_id,
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'N' THEN

               Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(l_account_id),
                                 'Ship_to_Account_Id');

               x_msg_data      :=  l_msg_data;
               x_return_status :=  l_return_status;

               RAISE FND_API.G_EXC_ERROR;
            ELSE
              -- assign to out record
              x_charges_detail_rec.ship_to_account_id := l_account_id;
            END IF;
          ELSE
            -- Account is NULL
            -- assign NULL to out record
            x_charges_detail_rec.ship_to_account_id := NULL;
          END IF;

          IF l_customer_site_id IS NOT NULL THEN

            IF IS_PARTY_SITE_VALID( p_party_site_id => l_customer_site_id,
                                    p_party_id      => l_customer_id,
                                    p_val_mode      => 'NONE',
                                    x_msg_data      => l_msg_data,
                                    x_msg_count     => l_msg_count,
                                    x_return_status => l_return_status) = 'U' THEN
              --raise unexpected error
              Raise FND_API.G_EXC_UNEXPECTED_ERROR;
              null;

            ELSIF IS_PARTY_SITE_VALID( p_party_site_id => l_customer_site_id,
                                    p_party_id      => l_customer_id,
                                    p_val_mode      => 'NONE',
                                    x_msg_data      => l_msg_data,
                                    x_msg_count     => l_msg_count,
                                    x_return_status => l_return_status) = 'N' THEN
              RAISE FND_API.G_EXC_ERROR;
              null;
            ELSE
              --assign to out record
              x_charges_detail_rec.ship_to_org_id := l_customer_site_id;
            END IF;
          ELSE
            --l_customer_site_id IS NULL
            --assign NULL to out record
            x_charges_detail_rec.ship_to_org_id := NULL;
          END IF;

        END IF;
      ELSE
        x_charges_detail_rec.ship_to_party_id := NULL;
        x_charges_detail_rec.ship_to_account_id := NULL;
        x_charges_detail_rec.ship_to_contact_id := NULL;
        x_charges_detail_rec.ship_to_org_id  := NULL;
      END IF;
    END IF;
  END IF;
  --DBMS_OUTPUT.PUT_LINE('Passed Ship To Validation .....');

ELSIF p_validation_mode = 'U' THEN

  -- Bill to Valdation
  --
  --DBMS_OUTPUT.PUT_LINE('In the the TCA Update Validation');

  IF p_charges_detail_rec.bill_to_party_id <> FND_API.G_MISS_NUM AND
     p_charges_detail_rec.bill_to_party_id IS NOT NULL THEN

    IF IS_PARTY_VALID(p_party_id      => p_charges_detail_rec.bill_to_party_id,
                      x_msg_data         => l_msg_data,
                      x_msg_count        => l_msg_count,
                      x_return_status    => l_return_status) = 'N' THEN

      Add_Invalid_Argument_Msg(l_api_name,
                               to_char(p_charges_detail_rec.bill_to_party_id),
                               'Bill_to_Party_Id');
      RAISE FND_API.G_EXC_ERROR;

    ELSE
      --assign to out record
      x_charges_detail_rec.bill_to_party_id := p_charges_detail_rec.bill_to_party_id;

      IF p_charges_detail_rec.bill_to_account_id <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.bill_to_account_id IS NOT NULL THEN

         IF IS_ACCOUNT_VALID(p_party_id      => p_charges_detail_rec.bill_to_party_id,
                             p_account_id    => p_charges_detail_rec.bill_to_account_id,
                             x_msg_data      => l_msg_data,
                             x_msg_count     => l_msg_count,
                             x_return_status => l_return_status) = 'U' THEN
           --raise unexpected error
           Raise FND_API.G_EXC_UNEXPECTED_ERROR;
           null;
         ELSIF IS_ACCOUNT_VALID(p_party_id      => p_charges_detail_rec.bill_to_party_id,
                                p_account_id    => p_charges_detail_rec.bill_to_account_id,
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'N' THEN

           Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.bill_to_account_id),
                                 'Bill_to_Account_Id');
           RAISE FND_API.G_EXC_ERROR;
           null;
         ELSE
           -- assign to out record
           x_charges_detail_rec.bill_to_account_id := p_charges_detail_rec.bill_to_account_id;
         END IF;

--Bug# 4870037
      ELSIF p_charges_detail_rec.bill_to_account_id = FND_API.G_MISS_NUM THEN
         x_charges_detail_rec.bill_to_account_id := l_db_det_rec.invoice_to_account_id;
      ELSE
        -- bill_to_account IS NULL
        -- assign NULL to out record
        x_charges_detail_rec.bill_to_account_id := NULL;
      END IF;
      IF  p_charges_detail_rec.bill_to_contact_id <> FND_API.G_MISS_NUM AND
          p_charges_detail_rec.bill_to_contact_id IS NOT NULL THEN


        IF IS_CONTACT_VALID(p_party_id      => p_charges_detail_rec.bill_to_party_id,
                            p_contact_id    => p_charges_detail_rec.bill_to_contact_id,
                            x_msg_data      => l_msg_data,
                            x_msg_count     => l_msg_count,
                            x_return_status => l_return_status) = 'U' THEN
          --raise unexpected error
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
          null;

        ELSIF IS_CONTACT_VALID(p_party_id      => p_charges_detail_rec.bill_to_party_id,
                               p_contact_id    => p_charges_detail_rec.bill_to_contact_id,
                               x_msg_data      => l_msg_data,
                               x_msg_count     => l_msg_count,
                               x_return_status => l_return_status) = 'N' THEN

          Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.bill_to_contact_id),
                                 'Bill_to_Contact_Id');
          RAISE FND_API.G_EXC_ERROR;
          null;
        ELSE
          -- assign to out record
          x_charges_detail_rec.bill_to_contact_id := p_charges_detail_rec.bill_to_contact_id;
        END IF;
      ELSE
        -- bill_to_contact IS NULL
        -- assign NULL to out record
        x_charges_detail_rec.bill_to_contact_id := NULL;
      END IF;

      IF p_charges_detail_rec.invoice_to_org_id <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.invoice_to_org_id IS NOT NULL THEN


        IF IS_PARTY_SITE_VALID( p_party_site_id => p_charges_detail_rec.invoice_to_org_id,
                                p_party_id      => p_charges_detail_rec.bill_to_party_id,
                                p_val_mode      => 'BILL_TO',
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'U' THEN
          --raise unexpected error
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
          null;
        ELSIF IS_PARTY_SITE_VALID( p_party_site_id => p_charges_detail_rec.invoice_to_org_id,
                                p_party_id         => p_charges_detail_rec.bill_to_party_id,
                                p_val_mode         => 'BILL_TO',
                                x_msg_data         => l_msg_data,
                                x_msg_count        => l_msg_count,
                                x_return_status    => l_return_status) = 'N' THEN
          Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.invoice_to_org_id),
                                 'Invoice_to_org_Id');
          RAISE FND_API.G_EXC_ERROR;
          null;
        ELSE
          --assign to out record
          x_charges_detail_rec.invoice_to_org_id := p_charges_detail_rec.invoice_to_org_id;
        END IF;

      ELSE
        --invoice_to_org_id IS NULL
        --assign NULL to out record
        x_charges_detail_rec.invoice_to_org_id := NULL;
      END IF;
    END IF;

 ELSIF

     p_charges_detail_rec.bill_to_party_id = FND_API.G_MISS_NUM THEN

      -- assign the value from the database
      x_charges_detail_rec.bill_to_party_id := l_db_det_rec.bill_to_party_id;

      IF p_charges_detail_rec.bill_to_account_id <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.bill_to_account_id IS NOT NULL THEN


         IF IS_ACCOUNT_VALID(p_party_id      => x_charges_detail_rec.bill_to_party_id,
                             p_account_id    => p_charges_detail_rec.bill_to_account_id,
                             x_msg_data      => l_msg_data,
                             x_msg_count     => l_msg_count,
                             x_return_status => l_return_status) = 'U' THEN
           --raise unexpected error
           Raise FND_API.G_EXC_UNEXPECTED_ERROR;
           null;
         ELSIF IS_ACCOUNT_VALID(p_party_id      => x_charges_detail_rec.bill_to_party_id,
                                p_account_id    => p_charges_detail_rec.bill_to_account_id,
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'N' THEN

           Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.bill_to_account_id),
                                 'Bill_to_Account_Id');
           RAISE FND_API.G_EXC_ERROR;
           null;
         ELSE
           -- assign to out record
           x_charges_detail_rec.bill_to_account_id := p_charges_detail_rec.bill_to_account_id;
         END IF;
      ELSE
        -- bill_to_account is not passed
        -- assign the value from the database
        x_charges_detail_rec.bill_to_account_id := l_db_det_rec.invoice_to_account_id;
      END IF;

      IF  p_charges_detail_rec.bill_to_contact_id <> FND_API.G_MISS_NUM AND
          p_charges_detail_rec.bill_to_contact_id IS NOT NULL THEN


        IF IS_CONTACT_VALID(p_party_id      => x_charges_detail_rec.bill_to_party_id,
                            p_contact_id    => p_charges_detail_rec.bill_to_contact_id,
                            x_msg_data      => l_msg_data,
                            x_msg_count     => l_msg_count,
                            x_return_status => l_return_status) = 'U' THEN
          --raise unexpected error
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
          null;

        ELSIF IS_CONTACT_VALID(p_party_id      => x_charges_detail_rec.bill_to_party_id,
                               p_contact_id    => p_charges_detail_rec.bill_to_contact_id,
                               x_msg_data      => l_msg_data,
                               x_msg_count     => l_msg_count,
                               x_return_status => l_return_status) = 'N' THEN

          Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.bill_to_contact_id),
                                 'Bill_to_Contact_Id');
          RAISE FND_API.G_EXC_ERROR;
          null;
        ELSE
          -- assign to out record
          x_charges_detail_rec.bill_to_contact_id := p_charges_detail_rec.bill_to_contact_id;
        END IF;
      ELSE
        -- bill_to_contact is not passed
        -- assign values from the database to out record
        x_charges_detail_rec.bill_to_contact_id := l_db_det_rec.bill_to_contact_id;
      END IF;

      IF p_charges_detail_rec.invoice_to_org_id <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.invoice_to_org_id IS NOT NULL THEN


        IF IS_PARTY_SITE_VALID( p_party_site_id => p_charges_detail_rec.invoice_to_org_id,
                                p_party_id      => x_charges_detail_rec.bill_to_party_id,
                                p_val_mode      => 'BILL_TO',
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'U' THEN
          --raise unexpected error
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
          null;
        ELSIF IS_PARTY_SITE_VALID( p_party_site_id => p_charges_detail_rec.invoice_to_org_id,
                                p_party_id         => x_charges_detail_rec.bill_to_party_id,
                                p_val_mode         => 'BILL_TO',
                                x_msg_data         => l_msg_data,
                                x_msg_count        => l_msg_count,
                                x_return_status    => l_return_status) = 'N' THEN
          Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.invoice_to_org_id),
                                 'Invoice_to_org_Id');
          RAISE FND_API.G_EXC_ERROR;
          null;
        ELSE
          --assign to out record
          x_charges_detail_rec.invoice_to_org_id := p_charges_detail_rec.invoice_to_org_id;
        END IF;

      ELSE
        --invoice_to_org_id is not passed
        --assign values from the database to out record
        x_charges_detail_rec.invoice_to_org_id :=  l_db_det_rec.invoice_to_org_id;
      END IF;

 ELSE

    IF p_charges_detail_rec.bill_to_party_id IS NULL THEN

      --all the values for out record for TCA should be nulled out
      x_charges_detail_rec.bill_to_party_id := NULL;
      x_charges_detail_rec.bill_to_account_id := NULL;
      x_charges_detail_rec.bill_to_contact_id := NULL;
      x_charges_detail_rec.invoice_to_org_id := NULL;
    END IF;
  END IF;


  IF p_charges_detail_rec.ship_to_party_id <> FND_API.G_MISS_NUM AND
     p_charges_detail_rec.ship_to_party_id IS NOT NULL THEN

    IF IS_PARTY_VALID(p_party_id      => p_charges_detail_rec.ship_to_party_id,
                      x_msg_data         => l_msg_data,
                      x_msg_count        => l_msg_count,
                      x_return_status    => l_return_status) = 'N' THEN

      Add_Invalid_Argument_Msg(l_api_name,
                               to_char(p_charges_detail_rec.ship_to_party_id),
                               'ship_to_party_id');
      RAISE FND_API.G_EXC_ERROR;

    ELSE
      --assign to out record
      x_charges_detail_rec.ship_to_party_id := p_charges_detail_rec.ship_to_party_id;

      IF p_charges_detail_rec.ship_to_account_id <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.ship_to_account_id IS NOT NULL THEN

         IF IS_ACCOUNT_VALID(p_party_id      => p_charges_detail_rec.ship_to_party_id,
                             p_account_id    => p_charges_detail_rec.ship_to_account_id,
                             x_msg_data      => l_msg_data,
                             x_msg_count     => l_msg_count,
                             x_return_status => l_return_status) = 'U' THEN
           --raise unexpected error
           Raise FND_API.G_EXC_UNEXPECTED_ERROR;
           null;
         ELSIF IS_ACCOUNT_VALID(p_party_id      => p_charges_detail_rec.ship_to_party_id,
                                p_account_id    => p_charges_detail_rec.ship_to_account_id,
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'N' THEN

           Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.ship_to_account_id),
                                 'ship_to_account_id');
           RAISE FND_API.G_EXC_ERROR;
           null;
         ELSE
           -- assign to out record
           x_charges_detail_rec.ship_to_account_id := p_charges_detail_rec.ship_to_account_id;
         END IF;

      --Bug# 4870037
      ELSIF p_charges_detail_rec.ship_to_account_id = FND_API.G_MISS_NUM THEN
          x_charges_detail_rec.ship_to_account_id := l_db_det_rec.ship_to_account_id;
      ELSE
        -- ship_to_account IS NULL
        -- assign NULL to out record
        x_charges_detail_rec.ship_to_account_id := NULL;
      END IF;
      IF  p_charges_detail_rec.ship_to_contact_id <> FND_API.G_MISS_NUM AND
          p_charges_detail_rec.ship_to_contact_id IS NOT NULL THEN


        IF IS_CONTACT_VALID(p_party_id      => p_charges_detail_rec.ship_to_party_id,
                            p_contact_id    => p_charges_detail_rec.ship_to_contact_id,
                            x_msg_data      => l_msg_data,
                            x_msg_count     => l_msg_count,
                            x_return_status => l_return_status) = 'U' THEN
          --raise unexpected error
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
          null;

        ELSIF IS_CONTACT_VALID(p_party_id      => p_charges_detail_rec.ship_to_party_id,
                               p_contact_id    => p_charges_detail_rec.ship_to_contact_id,
                               x_msg_data      => l_msg_data,
                               x_msg_count     => l_msg_count,
                               x_return_status => l_return_status) = 'N' THEN

          Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.ship_to_contact_id),
                                 'ship_to_contact_id');
          RAISE FND_API.G_EXC_ERROR;
          null;
        ELSE
          -- assign to out record
          x_charges_detail_rec.ship_to_contact_id := p_charges_detail_rec.ship_to_contact_id;
        END IF;
      ELSE
        -- ship_to_contact IS NULL
        -- assign NULL to out record
        x_charges_detail_rec.ship_to_contact_id := NULL;
      END IF;

       -- Fixed Bug # 3325675
      IF p_charges_detail_rec.ship_to_org_id <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.ship_to_org_id IS NOT NULL THEN


        IF IS_PARTY_SITE_VALID( p_party_site_id => p_charges_detail_rec.ship_to_org_id,
                                p_party_id      => p_charges_detail_rec.ship_to_party_id,
                                p_val_mode      => 'SHIP_TO',
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'U' THEN
          --raise unexpected error
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
          null;
        ELSIF IS_PARTY_SITE_VALID( p_party_site_id => p_charges_detail_rec.ship_to_org_id,
                                p_party_id         => p_charges_detail_rec.ship_to_party_id,
                                p_val_mode         => 'SHIP_TO',
                                x_msg_data         => l_msg_data,
                                x_msg_count        => l_msg_count,
                                x_return_status    => l_return_status) = 'N' THEN
          Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.ship_to_org_id),
                                 'Ship_to_org_Id');
          RAISE FND_API.G_EXC_ERROR;
          null;
        ELSE
          --assign to out record
          x_charges_detail_rec.ship_to_org_id := p_charges_detail_rec.ship_to_org_id;
        END IF;

      ELSE
        --ship_to_org_id IS NULL
        --assign NULL to out record
        x_charges_detail_rec.ship_to_org_id := NULL;
      END IF;
    END IF;

 ELSIF

     p_charges_detail_rec.ship_to_party_id = FND_API.G_MISS_NUM THEN

      -- assign the value from the database
      x_charges_detail_rec.ship_to_party_id := l_db_det_rec.ship_to_party_id;

      IF p_charges_detail_rec.ship_to_account_id <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.ship_to_account_id IS NOT NULL THEN


         IF IS_ACCOUNT_VALID(p_party_id      => x_charges_detail_rec.ship_to_party_id,
                             p_account_id    => p_charges_detail_rec.ship_to_account_id,
                             x_msg_data      => l_msg_data,
                             x_msg_count     => l_msg_count,
                             x_return_status => l_return_status) = 'U' THEN
           --raise unexpected error
           Raise FND_API.G_EXC_UNEXPECTED_ERROR;
           null;
         ELSIF IS_ACCOUNT_VALID(p_party_id      => x_charges_detail_rec.ship_to_party_id,
                                p_account_id    => p_charges_detail_rec.ship_to_account_id,
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'N' THEN

           Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.ship_to_account_id),
                                 'ship_to_account_id');
           RAISE FND_API.G_EXC_ERROR;
           null;
         ELSE
           -- assign to out record
           x_charges_detail_rec.ship_to_account_id := p_charges_detail_rec.ship_to_account_id;
         END IF;
      ELSE
        -- ship_to_account is not passed
        -- assign the value from the database
        x_charges_detail_rec.ship_to_account_id := l_db_det_rec.ship_to_account_id;
      END IF;

      IF  p_charges_detail_rec.ship_to_contact_id <> FND_API.G_MISS_NUM AND
          p_charges_detail_rec.ship_to_contact_id IS NOT NULL THEN


        IF IS_CONTACT_VALID(p_party_id      => x_charges_detail_rec.ship_to_party_id,
                            p_contact_id    => p_charges_detail_rec.ship_to_contact_id,
                            x_msg_data      => l_msg_data,
                            x_msg_count     => l_msg_count,
                            x_return_status => l_return_status) = 'U' THEN
          --raise unexpected error
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
          null;

        ELSIF IS_CONTACT_VALID(p_party_id      => x_charges_detail_rec.ship_to_party_id,
                               p_contact_id    => p_charges_detail_rec.ship_to_contact_id,
                               x_msg_data      => l_msg_data,
                               x_msg_count     => l_msg_count,
                               x_return_status => l_return_status) = 'N' THEN

          Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.ship_to_contact_id),
                                 'ship_to_contact_id');
          RAISE FND_API.G_EXC_ERROR;
          null;
        ELSE
          -- assign to out record
          x_charges_detail_rec.ship_to_contact_id := p_charges_detail_rec.ship_to_contact_id;
        END IF;
      ELSE
        -- bill_to_contact is not passed
        -- assign values from the database to out record
        x_charges_detail_rec.ship_to_contact_id := l_db_det_rec.ship_to_contact_id;
      END IF;

       -- Fixed Bug # 3325675
      IF p_charges_detail_rec.ship_to_org_id <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.ship_to_org_id IS NOT NULL THEN


        IF IS_PARTY_SITE_VALID( p_party_site_id => p_charges_detail_rec.ship_to_org_id,
                                p_party_id      => x_charges_detail_rec.ship_to_party_id,
                                p_val_mode      => 'SHIP_TO',
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                x_return_status => l_return_status) = 'U' THEN
          --raise unexpected error
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
          null;
        ELSIF IS_PARTY_SITE_VALID( p_party_site_id => p_charges_detail_rec.ship_to_org_id,
                                p_party_id         => x_charges_detail_rec.ship_to_party_id,
                                p_val_mode         => 'SHIP_TO',
                                x_msg_data         => l_msg_data,
                                x_msg_count        => l_msg_count,
                                x_return_status    => l_return_status) = 'N' THEN
          Add_Invalid_Argument_Msg(l_api_name,
                                 to_char(p_charges_detail_rec.ship_to_org_id),
                                 'ship_to_org_id');
          RAISE FND_API.G_EXC_ERROR;
          null;
        ELSE
          --assign to out record
          x_charges_detail_rec.ship_to_org_id := p_charges_detail_rec.ship_to_org_id;
        END IF;

      ELSE
        --ship_to_org_id is not passed
        --assign values from the database to out record
        x_charges_detail_rec.ship_to_org_id := l_db_det_rec.ship_to_org_id;
      END IF;

 ELSE

    IF p_charges_detail_rec.ship_to_party_id IS NULL THEN

      --all the values for out record for TCA should be nulled out
      x_charges_detail_rec.ship_to_party_id := NULL;
      x_charges_detail_rec.ship_to_account_id := NULL;
      x_charges_detail_rec.ship_to_contact_id := NULL;
      x_charges_detail_rec.ship_to_org_id := NULL;
    END IF;
  END IF;
END IF;


--DBMS_OUTPUT.PUT_LINE('TCA VALID');
--DBMS_OUTPUT.PUT_LINE('Customer ID '||l_customer_id);

--==================================================
-- Sold to party Validation
--==================================================
--DBMS_OUTPUT.PUT_LINE('Sold To Party Validation ...');

--DBMS_OUTPUT.PUT_LINE('sold_to_party_id'||p_charges_detail_rec.sold_to_party_id);
--DBMS_OUTPUT.PUT_LINE('customer id '||l_customer_id);

IF p_validation_mode = 'I' THEN
  IF p_charges_detail_rec.sold_to_party_id IS NOT NULL THEN
    IF p_charges_detail_rec.sold_to_party_id <> l_customer_id THEN
      --raise error
      FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_SOLD_TO_PARTY');
      FND_MESSAGE.SET_TOKEN('SOLD_TO_PARTY', p_charges_detail_rec.sold_to_party_id);
      FND_MESSAGE.SET_TOKEN('INCIDENT_ID', p_charges_detail_rec.incident_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      --assign the sold to party to the out record
      x_charges_detail_rec.sold_to_party_id := l_customer_id;
    END IF;
  ELSE
    --p_charges_detail_rec.sold_to_party_id
    IF l_customer_id IS NOT NULL THEN
      --assign the l_customer_id to the out rec
      x_charges_detail_rec.sold_to_party_id  := l_customer_id;
    ELSE
      x_charges_detail_rec.sold_to_party_id  := NULL;
    END IF;
  END IF;

ElSIF p_validation_mode  = 'U' THEN

  IF p_charges_detail_rec.sold_to_party_id <> FND_API.G_MISS_NUM AND
    p_charges_detail_rec.sold_to_party_id IS NOT NULL THEN
    IF p_charges_detail_rec.sold_to_party_id <> l_customer_id THEN
      --raise error
      FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_SOLD_TO_PARTY');
      FND_MESSAGE.SET_TOKEN('SOLD_TO_PARTY', p_charges_detail_rec.sold_to_party_id);
      FND_MESSAGE.SET_TOKEN('INCIDENT_ID', p_charges_detail_rec.incident_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      --assign the sold to party to the out record
      x_charges_detail_rec.sold_to_party_id := p_charges_detail_rec.sold_to_party_id;
    END IF;

  ELSIF p_charges_detail_rec.sold_to_party_id = FND_API.G_MISS_NUM THEN
    --assign the database value to the field
    --assign the sold to party to the out record
    x_charges_detail_rec.sold_to_party_id := l_customer_id ;

  ELSE
    IF p_charges_detail_rec.sold_to_party_id IS NULL THEN
      IF l_customer_id IS NOT NULL THEN
        -- raise error
        null;
      ELSE
        x_charges_detail_rec.sold_to_party_id := NULL;
      END IF;
    END IF;
  END IF;
 END IF;

--DBMS_OUTPUT.PUT_LINE('Sold To Party Validation successful...');

--============================================
--Valid the Item Instance
--============================================
-- DBMS_OUTPUT.PUT_LINE('Item Instance Validation ...');
IF p_validation_mode = 'I' THEN

   -- DBMS_OUTPUT.PUT_LINE('Update_ib_flag '||l_update_ib_flag);
   -- DBMS_OUTPUT.PUT_LINE('src_reference_reqd_flag '||l_src_reference_reqd_flag);
   -- DBMS_OUTPUT.PUT_LINE('line_order_category_code '||l_line_order_category_code);
   -- DBMS_OUTPUT.PUT_LINE('customer_product_id '||p_charges_detail_rec.customer_product_id);


   x_charges_detail_rec.customer_product_id := p_charges_detail_rec.customer_product_id;
   x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;

    --item instance validation
    --fixed Bug # 3362130 - added l_comms_trackable_flag = 'Y' condition
    IF(l_src_reference_reqd_flag = 'Y') AND
      (l_line_order_category_code = 'RETURN') AND
      (l_comms_trackable_flag = 'Y') THEN
      IF p_charges_detail_rec.customer_product_id IS NULL THEN

        -- --DBMS_OUTPUT.PUT_LINE('Customer product id null');
        --RAISE FND_API.G_EXC_ERROR;
        --null;
        FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_IB_INSTANCE_MISSING');
        FND_MESSAGE.Set_Token('API_NAME', p_api_name);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        -- Check if instance is of the same inventory_item_id
        -- If not of the same inv id the error
        -- Call IS_INSTANCE_FOR_INVENTORY

        -- --DBMS_OUTPUT.PUT_LINE('Customer product id is not null');

        l_valid_check := IS_INSTANCE_FOR_INVENTORY(
                                     p_instance_id   => p_charges_detail_rec.customer_product_id,
                                     p_inv_id        => x_charges_detail_rec.inventory_item_id_in,
                                     x_msg_data      => l_msg_data,
                                     x_msg_count     => l_msg_count,
                                     x_return_status => l_return_status);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

        IF l_valid_check <> 'Y' THEN

            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_IB_INSTANCE_INV');
            FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_charges_detail_rec.inventory_item_id_in);
            FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        ELSE

          l_valid_check := IS_INSTANCE_VALID(p_instance_id   => p_charges_detail_rec.customer_product_id,
                               p_party_id      => x_charges_detail_rec.sold_to_party_id,
                               x_msg_data      => l_msg_data,
                               x_msg_count     => l_msg_count,
                               x_return_status => l_return_status);

              IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF l_return_status = G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

--taklam
          IF l_valid_check <> 'Y' THEN
             --Check if Service activity has 'change owner flag' set to 'N'
             --(See the csi_ib_txn_types table for the flag value)
             --'change owner flag'

             OPEN C_SRC_CHANGE_OWNER(p_charges_detail_rec.txn_billing_type_id);
             FETCH C_SRC_CHANGE_OWNER INTO l_src_change_owner;
             CLOSE C_SRC_CHANGE_OWNER;

             If (l_src_change_owner = 'N') or (l_src_change_owner is null) THEN
               --Pass the internal_party_id to the existing "IS_INSTANCE_VALID" method.
               --select internal_party_id from csi_install_parameters,
               SELECT internal_party_id into l_internal_party_id
               FROM csi_install_parameters WHERE rownum = 1;

               l_valid_check := IS_INSTANCE_VALID( p_instance_id   => p_charges_detail_rec.customer_product_id,
                                                   p_party_id      => l_internal_party_id,
                                                   x_msg_data      => l_msg_data,
                                                   x_msg_count     => l_msg_count,
                                                   x_return_status => l_return_status);
               IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF l_return_status = G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;
             End if;
          End if;


          IF l_valid_check <> 'Y' THEN

               FND_MESSAGE.SET_NAME ('CS', 'CS_CHG_INVALID_INSTANCE_RMA_PT');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
--taklam
          ELSE
            --assign the customer product id to out record
            x_charges_detail_rec.customer_product_id := p_charges_detail_rec.customer_product_id;
            --DBMS_OUTPUT.PUT_LINE('Cust prod id '||x_charges_detail_rec.customer_product_id);
          END IF;
        END IF;
      END IF;

      -- check to see if its a serialized item
      -- Added for Bug # 4073602
      IF l_serial_control_flag = 'Y' THEN
        IF p_charges_detail_rec.serial_number IS NULL THEN
          -- no error raised
          -- Fix bug#5125934
          OPEN c_serial_number(p_charges_detail_rec.customer_product_id);
          FETCH c_serial_number
          INTO  l_serial_number;
          CLOSE c_serial_number;

          -- x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
          x_charges_detail_rec.serial_number := l_serial_number;
        ELSE
          --validate the serial number
          l_valid_check := IS_INSTANCE_SERIAL_VALID( p_instance_id   => x_charges_detail_rec.customer_product_id
                                                    ,p_serial_number => p_charges_detail_rec.serial_number
                                                    ,x_msg_data      => l_msg_data
                                                    ,x_msg_count     => l_msg_count
                                                    ,x_return_status => l_return_status);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF l_valid_check <> 'Y' THEN
            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_SERIAL_NUMBER');
            FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
            FND_MESSAGE.Set_Token('SERIAL_NUMBER', p_charges_detail_rec.serial_number);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            --assign the customer product id to out record
            x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
          END IF;
        END IF;

      ELSE
        x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
      END IF; -- check to see if its a serialized item


    --fixed Bug # 3362130 - added l_comms_trackable_flag = 'Y' condition
    ELSIF (l_non_src_reference_reqd_flag = 'Y') AND
      (l_line_order_category_code = 'ORDER') AND
      (l_comms_trackable_flag = 'Y') THEN
      IF p_charges_detail_rec.customer_product_id IS NULL THEN
        --DBMS_OUTPUT.PUT_LINE('Customer product id null');
        --RAISE FND_API.G_EXC_ERROR;
        --null;
        FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_IB_INSTANCE_MISSING');
        FND_MESSAGE.Set_Token('API_NAME', p_api_name);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE


        l_valid_check := IS_INSTANCE_VALID(p_instance_id   => p_charges_detail_rec.customer_product_id,
                               p_party_id      => x_charges_detail_rec.sold_to_party_id,
                               x_msg_data      => l_msg_data,
                               x_msg_count     => l_msg_count,
                               x_return_status => l_return_status);

              IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF l_return_status = G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;
        --DBMS_OUTPUT.PUT_LINE('Instance is l_valid_check'||l_valid_check);

        IF l_valid_check <> 'Y' THEN

              FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_IB_INSTANCE_PTY');
              FND_MESSAGE.Set_Token('PARTY_ID', x_charges_detail_rec.sold_to_party_id);
              FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;

        ELSE
          --assign to out record
          x_charges_detail_rec.customer_product_id := p_charges_detail_rec.customer_product_id;
          --DBMS_OUTPUT.PUT_LINE('Cust prod id '||x_charges_detail_rec.customer_product_id);
        END IF;
      END IF;

      -- check to see if its a serialized item
      -- Added for Bug # 4073602
      IF l_serial_control_flag = 'Y' THEN
        IF p_charges_detail_rec.serial_number IS NULL THEN
          -- no error raised
          -- Fix bug#5125934
          OPEN c_serial_number(p_charges_detail_rec.customer_product_id);
          FETCH c_serial_number
          INTO  l_serial_number;
          CLOSE c_serial_number;

          -- x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
          x_charges_detail_rec.serial_number := l_serial_number;

        ELSE
          --validate the serial number
          l_valid_check := IS_INSTANCE_SERIAL_VALID( p_instance_id => x_charges_detail_rec.customer_product_id
                                                    ,p_serial_number => p_charges_detail_rec.serial_number
                                                    ,x_msg_data      => l_msg_data
                                                    ,x_msg_count     => l_msg_count
                                                    ,x_return_status => l_return_status);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF l_valid_check <> 'Y' THEN
            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_SERIAL_NUMBER');
            FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
            FND_MESSAGE.Set_Token('SERIAL_NUMBER', p_charges_detail_rec.serial_number);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            --assign the customer product id to out record
            x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
          END IF;
        END IF;

      ELSE
        x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
      END IF; -- check to see if its a serialized item

    ELSE -- IF1

      --DBMS_OUTPUT.PUT_LINE('In the IF1');
      -- Added customer_product_id is not null condition
      IF (p_charges_detail_rec.customer_product_id IS NOT NULL AND -- IF2
          p_charges_detail_rec.customer_product_id <> FND_API.G_MISS_NUM) THEN
        -- Added the FND Messages for Bug# 5141369
        IF (l_comms_trackable_flag = 'N') THEN
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_INST_AND_INV');
          FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
          FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_charges_detail_rec.inventory_item_id_in);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          -- Check if the Instance Is Valid for all other cases
          l_valid_check := IS_INSTANCE_VALID(
                p_instance_id   => p_charges_detail_rec.customer_product_id,
                p_party_id      => x_charges_detail_rec.sold_to_party_id,
                x_msg_data      => l_msg_data,
                x_msg_count     => l_msg_count,
                x_return_status => l_return_status);
          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;

        --DBMS_OUTPUT.PUT_LINE('l_valid_check'||l_valid_check);

--taklam
        IF l_valid_check <> 'Y' THEN
          --Check if Service activity has 'change owner flag' set to 'N'
          --(See the csi_ib_txn_types table for the flag value)
          --'change owner flag'

          OPEN C_SRC_CHANGE_OWNER(p_charges_detail_rec.txn_billing_type_id);
          FETCH C_SRC_CHANGE_OWNER INTO l_src_change_owner;
          CLOSE C_SRC_CHANGE_OWNER;

          --DBMS_OUTPUT.PUT_LINE('l_src_change_owner'||l_src_change_owner);

          If (l_src_change_owner = 'N') or (l_src_change_owner is null) THEN
            --Pass the internal_party_id to the existing "IS_INSTANCE_VALID" method.
            --select internal_party_id from csi_install_parameters,
            SELECT internal_party_id into l_internal_party_id
            FROM csi_install_parameters WHERE rownum = 1;

            l_valid_check := IS_INSTANCE_VALID( p_instance_id   => p_charges_detail_rec.customer_product_id,
                                                p_party_id      => l_internal_party_id,
                                                x_msg_data      => l_msg_data,
                                                x_msg_count     => l_msg_count,
                                                x_return_status => l_return_status);
            IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          End if;
        End if;

        --DBMS_OUTPUT.PUT_LINE('l_valid_check'||l_valid_check);

        IF l_valid_check <> 'Y' THEN

            --FND_MESSAGE.SET_NAME ('CS', 'CS_CHG_INVALID_INSTANCE_RMA_PT');
            --FND_MSG_PUB.Add;
            Add_Invalid_Argument_Msg(l_api_name_full,
                             to_char(p_charges_detail_rec.customer_product_id),
                             'Customer_Product_Id');
            RAISE FND_API.G_EXC_ERROR;
--taklam
        ELSE
          x_charges_detail_rec.customer_product_id := p_charges_detail_rec.customer_product_id;
        END IF;

        -- check to see if its a serialized item
        -- Added for Bug # 4073602
        IF l_serial_control_flag = 'Y' THEN
           --DBMS_OUTPUT.PUT_LINE('l_serial_control_flag'||l_serial_control_flag);
          IF p_charges_detail_rec.serial_number IS NULL THEN
            -- no error raised
            -- Fix bug#5125934
            OPEN c_serial_number(p_charges_detail_rec.customer_product_id);
            FETCH c_serial_number
            INTO  l_serial_number;
            CLOSE c_serial_number;

          -- x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
          x_charges_detail_rec.serial_number := l_serial_number;

          ELSE
            --validate the serial number
            --DBMS_OUTPUT.PUT_LINE('Calling IS_INSTANCE_SERIAL_VALID');
            --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.customer_product_id'||x_charges_detail_rec.customer_product_id);
            --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.serial_number'||p_charges_detail_rec.serial_number);

            l_valid_check := IS_INSTANCE_SERIAL_VALID( p_instance_id => x_charges_detail_rec.customer_product_id
                                                    ,p_serial_number => p_charges_detail_rec.serial_number
                                                    ,x_msg_data      => l_msg_data
                                                    ,x_msg_count     => l_msg_count
                                                    ,x_return_status => l_return_status);
            IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF l_valid_check <> 'Y' THEN
              FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_SERIAL_NUMBER');
              FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
              FND_MESSAGE.Set_Token('SERIAL_NUMBER', p_charges_detail_rec.serial_number);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            ELSE
              --assign the customer product id to out record
              x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
            END IF;
          END IF;

        ELSE
          x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
        END IF; -- check to see if its a serialized item

      END IF; -- IF2
    END IF; -- IF1

    --DBMS_OUTPUT.PUT_LINE('Checking  src');

    -- Fix for Bug # 3325686
    --fixed Bug # 3362130 - added l_comms_trackable_flag = 'Y' condition
    /*** IF l_src_reference_reqd_flag = 'Y' AND
       l_src_return_reqd_flag = 'Y' AND
       l_line_order_category_code = 'RETURN' AND
       l_comms_trackable_flag = 'Y' THEN
        IF p_charges_detail_rec.installed_cp_return_by_date IS NULL THEN
          --RAISE FND_API.G_EXC_ERROR;
          --null;
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INST_CP_RETURN_BY_DATE');
          FND_MESSAGE.Set_Token('INST_CP_RTN_BY_DATE', p_charges_detail_rec.installed_cp_return_by_date);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          --assign to out record
          x_charges_detail_rec.installed_cp_return_by_date := p_charges_detail_rec.installed_cp_return_by_date;
        END IF;

    ELSE
      -- the flag is 'N'
      -- ignore the installed_cp_return_by_date
      x_charges_detail_rec.installed_cp_return_by_date := NULL;
    END IF; ****/

    -- Return_by_date fix. If the flags are not set, then assign
    --whatever value comes in and do not set the installed_cp_return_date to NULL
    -- Fix for bug#5136691
    IF l_src_return_reqd_flag = 'Y' AND
       l_line_order_category_code = 'RETURN' AND
       l_comms_trackable_flag = 'Y' THEN

        IF p_charges_detail_rec.installed_cp_return_by_date IS NULL THEN
          --RAISE FND_API.G_EXC_ERROR;
          --null;
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INST_CP_RETURN_BY_DATE');
          FND_MESSAGE.Set_Token('INST_CP_RTN_BY_DATE', p_charges_detail_rec.installed_cp_return_by_date);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          --assign to out record
          x_charges_detail_rec.installed_cp_return_by_date := p_charges_detail_rec.installed_cp_return_by_date;
        END IF;
    ELSE
      -- the flag is 'N'
      -- ignore installed_cp_return_by_date
      x_charges_detail_rec.installed_cp_return_by_date := p_charges_detail_rec.installed_cp_return_by_date;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('Done Checking src');
    --DBMS_OUTPUT.PUT_LINE('Checking  non src');

    -- Depot Loaner fix - Bug#4586140
    -- Commenting out for return_by_date fix
    /* Open c_get_depot_txns_details(p_charges_detail_rec.estimate_detail_id);
    Fetch c_get_depot_txns_details into l_action_code;
    Close c_get_depot_txns_details; */

    -- Fix for Bug # 3325686
    --fixed Bug # 3362130 - added l_comms_trackable_flag = 'Y' condition
    -- commented out the old code
    -- Modified for the return_by_date fix. Bug:5136853
    -- If the instance is not null and the non_src retur_reqd flag is 'Y' ,
    -- then installed_cp_return_by_date column should have a value.
    -- Likewise if the instance is null and the item is trackable and the
    -- src_return_reqd field is 'y', the the new_cp_return_by_date should have a value.
    -- Otherwise raise appropriate errors. This validation is for 'ORDER'

    /*** non source flag checked for the 'ORDER' ***/
    IF l_non_src_return_reqd_flag = 'Y' AND
       l_line_order_category_code = 'ORDER' AND
       l_comms_trackable_flag = 'Y' AND
       p_charges_detail_rec.customer_product_id IS NOT NULL THEN
      IF p_charges_detail_rec.installed_cp_return_by_date IS NULL THEN
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INSTALLED_CP_RETURN_BY_DATE');
        FND_MESSAGE.Set_Token('INSTALLED_CP_RTN_BY_DATE', p_charges_detail_rec.installed_cp_return_by_date);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_charges_detail_rec.installed_cp_return_by_date := p_charges_detail_rec.installed_cp_return_by_date;
      END IF;
    ELSE
      -- Assign whatever value is passed in the parameter.
      x_charges_detail_rec.installed_cp_return_by_date := p_charges_detail_rec.installed_cp_return_by_date;
    END IF;

    /*** Source Flag checked for the 'Order' ***/
    IF l_src_return_reqd_flag = 'Y' AND
       l_line_order_category_code = 'ORDER' AND
       l_comms_trackable_flag = 'Y' AND
       p_charges_detail_rec.customer_product_id IS NULL THEN
      IF p_charges_detail_rec.new_cp_return_by_date IS NULL THEN
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_NEW_CP_RETURN_BY_DATE');
        FND_MESSAGE.Set_Token('NEW_CP_RTN_BY_DATE', p_charges_detail_rec.new_cp_return_by_date);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_charges_detail_rec.new_cp_return_by_date := p_charges_detail_rec.new_cp_return_by_date;
      END IF;
    ELSE
      -- Assign whatever value is passed in the parameter.
      x_charges_detail_rec.new_cp_return_by_date := p_charges_detail_rec.new_cp_return_by_date;
    END IF;


    /*****
    IF l_non_src_reference_reqd_flag = 'Y' AND
       l_non_src_return_reqd = 'Y' AND
       l_line_order_category_code = 'ORDER' AND
       l_comms_trackable_flag = 'Y' THEN
      IF p_charges_detail_rec.new_cp_return_by_date IS NULL THEN
        --RAISE FND_API.G_EXC_ERROR;
        --null;
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_NEW_CP_RETURN_BY_DATE');
        FND_MESSAGE.Set_Token('NEW_CP_RTN_BY_DATE', p_charges_detail_rec.new_cp_return_by_date);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_charges_detail_rec.new_cp_return_by_date := p_charges_detail_rec.new_cp_return_by_date;
      END IF;

     -- Depot Loaner fix - Bug#4586140
    ELSIF ( l_line_order_category_code = 'ORDER' AND
            l_comms_trackable_flag = 'Y' AND
            l_src_return_reqd_flag = 'Y' AND
            l_action_code = 'LOANER') THEN

        x_charges_detail_rec.new_cp_return_by_date := p_charges_detail_rec.new_cp_return_by_date;
    ELSE
      --the flag is 'N'
      --ignore the new_cp_return_by_date
      x_charges_detail_rec.new_cp_return_by_date := NULL;
    END IF;  *****/


  --DBMS_OUTPUT.PUT_LINE('Done Checking non src');
  --DBMS_OUTPUT.PUT_LINE('Cust_product_id is '||P_CHARGES_DETAIL_REC.customer_product_id);


ELSIF p_validation_mode = 'U' THEN

    -- If no customer_product_id is passed
	    IF  p_charges_detail_rec.customer_product_id = FND_API.G_MISS_NUM THEN
	      IF l_db_det_rec.customer_product_id  IS NOT NULL AND
	         l_item_changed = 'Y' AND
	         x_charges_detail_rec.line_category_code = 'RETURN' AND
	         l_src_reference_reqd_flag = 'Y' AND
	         l_comms_trackable_flag = 'Y' THEN

	         --check if instance is for the same inventory
	          l_valid_check := IS_INSTANCE_FOR_INVENTORY(
	                                     p_instance_id   => p_charges_detail_rec.customer_product_id,
	                                     p_inv_id        => x_charges_detail_rec.inventory_item_id_in,
	                                     x_msg_data      => l_msg_data,
	                                     x_msg_count     => l_msg_count,
	                                     x_return_status => l_return_status);

	          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	          ELSIF l_return_status = G_RET_STS_ERROR THEN
	            RAISE FND_API.G_EXC_ERROR;
	          END IF;

	        IF l_valid_check <> 'Y' THEN

	            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_IB_INSTANCE_INV');
	            FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_charges_detail_rec.inventory_item_id_in);
	            FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
	            FND_MSG_PUB.Add;
	            RAISE FND_API.G_EXC_ERROR;

	        ELSE
	          l_valid_check := IS_INSTANCE_VALID(p_instance_id   => p_charges_detail_rec.customer_product_id,
	                               p_party_id      => x_charges_detail_rec.sold_to_party_id,
	                               x_msg_data      => l_msg_data,
	                               x_msg_count     => l_msg_count,
	                               x_return_status => l_return_status);

	              IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	              ELSIF l_return_status = G_RET_STS_ERROR THEN
	                RAISE FND_API.G_EXC_ERROR;
	              END IF;

	--taklam
	          IF l_valid_check <> 'Y' THEN
	             --Check if Service activity has 'change owner flag' set to 'N'
	             --(See the csi_ib_txn_types table for the flag value)
	             --'change owner flag'

	             OPEN C_SRC_CHANGE_OWNER(p_charges_detail_rec.txn_billing_type_id);
	             FETCH C_SRC_CHANGE_OWNER INTO l_src_change_owner;
	             CLOSE C_SRC_CHANGE_OWNER;

	             If (l_src_change_owner = 'N') or (l_src_change_owner is null) THEN
	               --Pass the internal_party_id to the existing "IS_INSTANCE_VALID" method.
	               --select internal_party_id from csi_install_parameters,
	               SELECT internal_party_id into l_internal_party_id
	               FROM csi_install_parameters;

	               l_valid_check := IS_INSTANCE_VALID( p_instance_id   => p_charges_detail_rec.customer_product_id,
	                                                   p_party_id      => l_internal_party_id,
	                                                   x_msg_data      => l_msg_data,
	                                                   x_msg_count     => l_msg_count,
	                                                   x_return_status => l_return_status);
	               IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	               ELSIF l_return_status = G_RET_STS_ERROR THEN
	                 RAISE FND_API.G_EXC_ERROR;
	               END IF;
	             End if;
	          End if;


	          IF l_valid_check <> 'Y' THEN

	               FND_MESSAGE.SET_NAME ('CS', 'CS_CHG_INVALID_INSTANCE_RMA_PT');
	               FND_MSG_PUB.Add;
	               RAISE FND_API.G_EXC_ERROR;
	--taklam
	          ELSE
	            --assign the customer product id to out record
	            x_charges_detail_rec.customer_product_id := p_charges_detail_rec.customer_product_id;
	            --DBMS_OUTPUT.PUT_LINE('Cust prod id '||x_charges_detail_rec.customer_product_id);
	          END IF;
	        END IF;
	     ELSE
	      --assign the values from the database
	      x_charges_detail_rec.customer_product_id := l_db_det_rec.customer_product_id;
	    END IF;

    -- check to see if its a serialized item
    -- Added for Bug # 4073602
    IF l_serial_control_flag = 'Y' THEN
        IF p_charges_detail_rec.serial_number IS NULL AND
           x_charges_detail_rec.customer_product_id IS NOT NULL THEN
          -- no error raised
          -- Fix bug#5125934
            OPEN c_serial_number(p_charges_detail_rec.customer_product_id);
            FETCH c_serial_number
            INTO  l_serial_number;
            CLOSE c_serial_number;

          -- x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
          x_charges_detail_rec.serial_number := l_serial_number;

        ELSIF p_charges_detail_rec.serial_number = FND_API.G_MISS_CHAR THEN
          -- Remove serial_number validation. Fix bug#5176423
          --validate the serial number
          /* l_valid_check := IS_INSTANCE_SERIAL_VALID( p_instance_id   => x_charges_detail_rec.customer_product_id
                                                    ,p_serial_number => l_db_det_rec.serial_number
                                                    ,x_msg_data      => l_msg_data
                                                    ,x_msg_count     => l_msg_count
                                                    ,x_return_status => l_return_status);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF l_valid_check <> 'Y' THEN
            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_SERIAL_NUMBER');
            FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
            FND_MESSAGE.Set_Token('SERIAL_NUMBER', p_charges_detail_rec.serial_number);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          ELSE */

            --assign the customer product id to out record
            -- x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
            x_charges_detail_rec.serial_number := l_db_det_rec.serial_number;

          -- END IF;
        -- Added for bug fix:5259686
        ELSIF p_charges_detail_rec.serial_number IS NOT NULL AND
              x_charges_detail_rec.customer_product_id IS NOT NULL THEN

          --serial number is neither null nor fnd_api.g_miss
          -- value is passed
          --validate the serial number
          x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;    --5887316
          /*
          l_valid_check := IS_INSTANCE_SERIAL_VALID( p_instance_id   => x_charges_detail_rec.customer_product_id
                                                    ,p_serial_number => p_charges_detail_rec.serial_number
                                                    ,x_msg_data      => l_msg_data
                                                    ,x_msg_count     => l_msg_count
                                                    ,x_return_status => l_return_status);


          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF l_valid_check <> 'Y' THEN
            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_SERIAL_NUMBER');
            FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
            FND_MESSAGE.Set_Token('SERIAL_NUMBER', p_charges_detail_rec.serial_number);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            --assign the serial_number to out record
            x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
          END IF;
	  */ --5887316
        END IF;
      ELSE
        --customerproduct  id is null
        x_charges_detail_rec.serial_number := l_db_det_rec.serial_number ;
      END IF;
    END IF;

  -- If null is passed to customer_product_id

    IF p_charges_detail_rec.customer_product_id IS NULL THEN

      --item instance validation
      --fixed Bug # 3362130 - added l_comms_trackable_flag = 'Y' condition
      IF (l_src_reference_reqd_flag = 'Y') AND
         (l_line_order_category_code = 'RETURN') AND
         (l_comms_trackable_flag = 'Y') THEN
        --DBMS_OUTPUT.PUT_LINE('Customer product id null');

        --RAISE FND_API.G_EXC_ERROR;
        --null;
        FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_IB_INSTANCE_MISSING');
        FND_MESSAGE.Set_Token('API_NAME', p_api_name);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

      --fixed Bug # 3362130 - added l_comms_trackable_flag = 'Y' condition
      ELSIF (l_non_src_reference_reqd_flag = 'Y') AND
        (l_line_order_category_code = 'ORDER') AND
        (l_comms_trackable_flag = 'Y') THEN
        --DBMS_OUTPUT.PUT_LINE('Customer product id null');
        --RAISE FND_API.G_EXC_ERROR;
        --null;
        FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_IB_INSTANCE_MISSING');
        FND_MESSAGE.Set_Token('API_NAME', p_api_name);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_charges_detail_rec.customer_product_id := NULL;
      END IF;
   END IF;

   -- If new CP is passed
   -- Fix for Bug # 3325686
   --IF l_db_det_rec.customer_product_id  IS NOT NULL AND
/*cnemalik bug 3913714
 IN 11.5.9 customer_product_id is mandatory for certain setups. But in 11.5.10, for the same setups it is optional*/

     IF  p_charges_detail_rec.customer_product_id <> FND_API.G_MISS_NUM AND
       p_charges_detail_rec.customer_product_id IS NOT NULL AND
       x_charges_detail_rec.line_category_code = 'RETURN' THEN

         -- Added the FND Messages for Bug# 5141369
         IF (l_comms_trackable_flag = 'N') THEN
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_INST_AND_INV');
          FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
          FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_charges_detail_rec.inventory_item_id_in);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;

         ELSE

          --check if instance is for the same inventory
          l_valid_check := IS_INSTANCE_FOR_INVENTORY(
                                     p_instance_id   => p_charges_detail_rec.customer_product_id,
                                     p_inv_id        => x_charges_detail_rec.inventory_item_id_in,
                                     x_msg_data      => l_msg_data,
                                     x_msg_count     => l_msg_count,
                                     x_return_status => l_return_status);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          END IF;

        IF l_valid_check <> 'Y' THEN

            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_IB_INSTANCE_INV');
            FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_charges_detail_rec.inventory_item_id_in);
            FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;

        ELSE
          l_valid_check := IS_INSTANCE_VALID(p_instance_id   => p_charges_detail_rec.customer_product_id,
                               p_party_id      => x_charges_detail_rec.sold_to_party_id,
                               x_msg_data      => l_msg_data,
                               x_msg_count     => l_msg_count,
                               x_return_status => l_return_status);

              IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF l_return_status = G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

   --taklam
             IF l_valid_check <> 'Y' THEN
                --Check if Service activity has 'change owner flag' set to 'N'
                --(See the csi_ib_txn_types table for the flag value)
                --'change owner flag'

                OPEN C_SRC_CHANGE_OWNER(p_charges_detail_rec.txn_billing_type_id);
                FETCH C_SRC_CHANGE_OWNER INTO l_src_change_owner;
                CLOSE C_SRC_CHANGE_OWNER;

                If (l_src_change_owner = 'N') or (l_src_change_owner is null) THEN
                  --Pass the internal_party_id to the existing "IS_INSTANCE_VALID" method.
                  --select internal_party_id from csi_install_parameters,
                  SELECT internal_party_id into l_internal_party_id
                  FROM csi_install_parameters;

                  l_valid_check := IS_INSTANCE_VALID( p_instance_id   => p_charges_detail_rec.customer_product_id,
                                                      p_party_id      => l_internal_party_id,
                                                      x_msg_data      => l_msg_data,
                                                      x_msg_count     => l_msg_count,
                                                      x_return_status => l_return_status);
                  IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  ELSIF l_return_status = G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                  END IF;
                End if;
             End if;


            IF l_valid_check <> 'Y' THEN

                  FND_MESSAGE.SET_NAME ('CS', 'CS_CHG_INVALID_INSTANCE_RMA_PT');
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
   --taklam
            ELSE
              --assign the customer product id to out record
              x_charges_detail_rec.customer_product_id := p_charges_detail_rec.customer_product_id;
              --DBMS_OUTPUT.PUT_LINE('Cust prod id '||x_charges_detail_rec.customer_product_id);
            END IF;

           -- check to see if its a serialized item
           -- Added for Bug # 4073602
           IF l_serial_control_flag = 'Y' THEN
             IF p_charges_detail_rec.serial_number IS NULL THEN
               -- no error raised
               -- Fix bug#5125934
               OPEN c_serial_number(p_charges_detail_rec.customer_product_id);
               FETCH c_serial_number
               INTO  l_serial_number;
               CLOSE c_serial_number;

               -- x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
               -- x_charges_detail_rec.serial_number := l_serial_number;

             ELSIF p_charges_detail_rec.serial_number = FND_API.G_MISS_CHAR THEN

               --validate the serial number
               x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number; --5887316
	       /*
	       l_valid_check := IS_INSTANCE_SERIAL_VALID( p_instance_id   => x_charges_detail_rec.customer_product_id
                                                    ,p_serial_number => l_db_det_rec.serial_number
                                                    ,x_msg_data      => l_msg_data
                                                    ,x_msg_count     => l_msg_count
                                                    ,x_return_status => l_return_status);

               IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF l_return_status = G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

               IF l_valid_check <> 'Y' THEN
                 FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_SERIAL_NUMBER');
                 FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
                 FND_MESSAGE.Set_Token('SERIAL_NUMBER', p_charges_detail_rec.serial_number);
                 FND_MSG_PUB.Add;
                 RAISE FND_API.G_EXC_ERROR;
               ELSE
                 --assign the customer product id to out record
                 x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
               END IF;
               */--5887316
             ELSE

               --serial number is neither null nor fnd_api.g_miss
               -- value is passed
               --validate the serial number
               x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number; --5887316
	       /*
	       l_valid_check := IS_INSTANCE_SERIAL_VALID( p_instance_id   => x_charges_detail_rec.customer_product_id
                                                    ,p_serial_number => p_charges_detail_rec.serial_number
                                                    ,x_msg_data      => l_msg_data
                                                    ,x_msg_count     => l_msg_count
                                                    ,x_return_status => l_return_status);
               IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF l_return_status = G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

               IF l_valid_check <> 'Y' THEN
                 FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_SERIAL_NUMBER');
                 FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
                 FND_MESSAGE.Set_Token('SERIAL_NUMBER', p_charges_detail_rec.serial_number);
                 FND_MSG_PUB.Add;
                 RAISE FND_API.G_EXC_ERROR;
               ELSE
                 --assign the customer product id to out record
                 x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
               END IF;
               */ --5887316
	     END IF;
           ELSE
             --customerproduct  id is null
             x_charges_detail_rec.serial_number := l_db_det_rec.serial_number ;
           END IF;
        END IF;


      --Fix for Bug # 3325686
      ELSIF
         p_charges_detail_rec.customer_product_id <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.customer_product_id IS NOT NULL AND
         x_charges_detail_rec.line_category_code = 'ORDER' THEN

          -- Added the FND Messages for Bug# 5141369
         IF (l_comms_trackable_flag = 'N') THEN
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_INST_AND_INV');
          FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
          FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', p_charges_detail_rec.inventory_item_id_in);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
         ELSE
         --Check if instance is valid for the party
         l_valid_check := IS_INSTANCE_VALID(p_instance_id   => p_charges_detail_rec.customer_product_id,
                               p_party_id      => x_charges_detail_rec.sold_to_party_id,
                               x_msg_data      => l_msg_data,
                               x_msg_count     => l_msg_count,
                               x_return_status => l_return_status);

              IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF l_return_status = G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;
         END IF;

          IF l_valid_check <> 'Y' THEN

              FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_IB_INSTANCE_PTY');
              FND_MESSAGE.Set_Token('PARTY_ID', x_charges_detail_rec.sold_to_party_id);
              FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;

          ELSE
            --assign the customer product id to out record
            x_charges_detail_rec.customer_product_id := p_charges_detail_rec.customer_product_id;
            --DBMS_OUTPUT.PUT_LINE('Cust prod id '||x_charges_detail_rec.customer_product_id);
          END IF;

          -- check to see if its a serialized item
          -- Added for Bug # 4073602
          IF l_serial_control_flag = 'Y' THEN
            IF p_charges_detail_rec.serial_number IS NULL THEN
              -- Fix bug#5125934
               OPEN c_serial_number(p_charges_detail_rec.customer_product_id);
               FETCH c_serial_number
               INTO  l_serial_number;
               CLOSE c_serial_number;

               -- x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
               x_charges_detail_rec.serial_number := l_serial_number;

            ELSIF p_charges_detail_rec.serial_number = FND_API.G_MISS_CHAR THEN
              --validate the serial number
              -- Added for Bug # 5471849
	             IF l_db_det_rec.serial_number IS NOT NULL THEN
	                -- dbms_output.put_line('Serial number test bug:5471849');
	                x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;  --5887316
			/*
			l_valid_check := IS_INSTANCE_SERIAL_VALID( p_instance_id   => x_charges_detail_rec.customer_product_id
	                                                    ,p_serial_number => l_db_det_rec.serial_number
	                                                    ,x_msg_data      => l_msg_data
	                                                    ,x_msg_count     => l_msg_count
	                                                    ,x_return_status => l_return_status);

	                 IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	                 ELSIF l_return_status = G_RET_STS_ERROR THEN
	                 RAISE FND_API.G_EXC_ERROR;
	                 END IF;

	                 IF l_valid_check <> 'Y' THEN
	                 FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_SERIAL_NUMBER');
	                 FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
	                 FND_MESSAGE.Set_Token('SERIAL_NUMBER', p_charges_detail_rec.serial_number);
	                 FND_MSG_PUB.Add;
	                 RAISE FND_API.G_EXC_ERROR;
	                 ELSE
	                 --assign the customer product id to out record
	                 x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
	                 END IF;
                        */ --5887316
	              ELSE
	                -- Added for the bug:5471849
	                OPEN c_serial_number(p_charges_detail_rec.customer_product_id);
	                FETCH c_serial_number
	                INTO  l_serial_number;
	                CLOSE c_serial_number;

	                -- x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
	                 x_charges_detail_rec.serial_number := l_serial_number;
	              END IF;

           ELSE

              --serial number is neither null nor fnd_api.g_miss
              -- value is passed
              --validate the serial number
              x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number; --5887316
	      /*
	      l_valid_check := IS_INSTANCE_SERIAL_VALID( p_instance_id   => x_charges_detail_rec.customer_product_id
                                                    ,p_serial_number => p_charges_detail_rec.serial_number
                                                    ,x_msg_data      => l_msg_data
                                                    ,x_msg_count     => l_msg_count
                                                    ,x_return_status => l_return_status);

              IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF l_return_status = G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              IF l_valid_check <> 'Y' THEN
                FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_SERIAL_NUMBER');
                FND_MESSAGE.Set_Token('INSTANCE_ID', p_charges_detail_rec.customer_product_id);
                FND_MESSAGE.Set_Token('SERIAL_NUMBER', p_charges_detail_rec.serial_number);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
              ELSE
                --assign the customer product id to out record
                x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
              END IF;
              */ --5887316
	    END IF;
	  ELSE
            x_charges_detail_rec.serial_number := p_charges_detail_rec.serial_number;
          END IF; --serial number check

      ELSE
          --customerproduct  id is null
          x_charges_detail_rec.serial_number := l_db_det_rec.serial_number ;
      END IF;


    -- Checking for source and RETURN transactions to update installed_cp_return_by_date
    -- Fix for Bug # 3325686
    --fixed Bug # 3362130 - added l_comms_trackable_flag = 'Y' condition
    IF l_src_reference_reqd_flag = 'Y' AND
       l_src_return_reqd_flag = 'Y' AND
       l_line_order_category_code = 'RETURN' AND
       l_comms_trackable_flag = 'Y' THEN
       IF p_charges_detail_rec.installed_cp_return_by_date IS NULL THEN
         --RAISE FND_API.G_EXC_ERROR;
         --null;
         FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INST_CP_RETURN_BY_DATE');
         FND_MESSAGE.Set_Token('INST_CP_RTN_BY_DATE', p_charges_detail_rec.installed_cp_return_by_date);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       ELSIF p_charges_detail_rec.installed_cp_return_by_date <> FND_API.G_MISS_DATE THEN
         --assign to out record
         x_charges_detail_rec.installed_cp_return_by_date := p_charges_detail_rec.installed_cp_return_by_date;
       ELSE
         x_charges_detail_rec.installed_cp_return_by_date := l_db_det_rec.installed_cp_return_by_date;
       END IF;
      --ELSE
      -- the flag is 'N'
      -- ignore the installed_cp_return_by_date
      --x_charges_detail_rec.installed_cp_return_by_date := NULL;
    -- if the flags are not set, check for g_miss_date
    -- Modified for the return_by_date fix. Bug:5136853
    ELSIF p_charges_detail_rec.installed_cp_return_by_date <> FND_API.G_MISS_DATE THEN
      --assign to out record
      x_charges_detail_rec.installed_cp_return_by_date := p_charges_detail_rec.installed_cp_return_by_date;
    ELSE
      x_charges_detail_rec.installed_cp_return_by_date := l_db_det_rec.installed_cp_return_by_date;
    END IF;

    /***** RETURN BY DATE FIX FOR ORDER TRANSACTIONS *****/
    --
    -- Modified for the return_by_date fix. Bug:5136853
    -- If the instance is not null and the non_src retur_reqd flag is 'Y' ,
    -- then installed_cp_return_by_date column should have a value.
    -- Likewise if the instance is null and the item is trackable and the
    -- src_return_reqd field is 'y', the the new_cp_return_by_date should have a value.
    -- Otherwise raise appropriate errors. This validation is for 'ORDER'

    /*** non source flag checked for the 'ORDER' ***/
     IF l_non_src_reference_reqd_flag = 'Y' AND
        l_non_src_return_reqd_flag = 'Y' AND
        l_line_order_category_code = 'ORDER' AND
        l_comms_trackable_flag = 'Y' AND
        p_charges_detail_rec.customer_product_id IS NOT NULL THEN
       IF p_charges_detail_rec.installed_cp_return_by_date IS NULL THEN
         FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INSTALLED_CP_RETURN_BY_DATE');
         FND_MESSAGE.Set_Token('INSTALLED_CP_RTN_BY_DATE', p_charges_detail_rec.installed_cp_return_by_date);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       ELSIF  p_charges_detail_rec.installed_cp_return_by_date  <> FND_API.G_MISS_DATE THEN
         x_charges_detail_rec.installed_cp_return_by_date := p_charges_detail_rec.installed_cp_return_by_date;
       ELSE
         x_charges_detail_rec.installed_cp_return_by_date := l_db_det_rec.installed_cp_return_by_date;
       END IF;
     -- if the flags are not set, check for g_miss_date
     ELSIF p_charges_detail_rec.installed_cp_return_by_date <> FND_API.G_MISS_DATE THEN
       -- Assign whatever value is passed in the parameter.
       x_charges_detail_rec.installed_cp_return_by_date := p_charges_detail_rec.installed_cp_return_by_date;
     ELSE
       x_charges_detail_rec.installed_cp_return_by_date := l_db_det_rec.installed_cp_return_by_date;
     END IF;

    /*** Source Flag checked for the 'Order' ***/
    IF  l_src_reference_reqd_flag = 'Y' AND
        l_src_return_reqd_flag = 'Y' AND
        l_line_order_category_code = 'ORDER' AND
        l_comms_trackable_flag = 'Y' AND
        p_charges_detail_rec.customer_product_id IS NULL THEN
      IF p_charges_detail_rec.new_cp_return_by_date IS NULL THEN
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_NEW_CP_RETURN_BY_DATE');
        FND_MESSAGE.Set_Token('NEW_CP_RTN_BY_DATE', p_charges_detail_rec.new_cp_return_by_date);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF p_charges_detail_rec.new_cp_return_by_date <> FND_API.G_MISS_DATE THEN
        -- Assign whatever value is passed in the parameter.
        x_charges_detail_rec.new_cp_return_by_date := p_charges_detail_rec.new_cp_return_by_date;
      ELSE
        x_charges_detail_rec.new_cp_return_by_date := l_db_det_rec.new_cp_return_by_date;
      END IF;
    ELSIF p_charges_detail_rec.new_cp_return_by_date <> FND_API.G_MISS_DATE THEN
      -- Assign whatever value is passed in the parameter.
      x_charges_detail_rec.new_cp_return_by_date := p_charges_detail_rec.new_cp_return_by_date;
    ELSE
      x_charges_detail_rec.new_cp_return_by_date := l_db_det_rec.new_cp_return_by_date;
    END IF;


    /**** -- Depot Loaner fix - Bug#4586140
    Open c_get_depot_txns_details(p_charges_detail_rec.estimate_detail_id);
    Fetch c_get_depot_txns_details into l_action_code;
    Close c_get_depot_txns_details;

    -- Checking for non-source and ORDER transactions to update new_cp_return_by_date
    -- Fix for Bug # 3325686
    --fixed Bug # 3362130 - added l_comms_trackable_flag = 'Y' condition
    IF l_non_src_reference_reqd_flag = 'Y' AND
       l_non_src_return_reqd  = 'Y' AND
       l_line_order_category_code = 'ORDER' AND
       l_comms_trackable_flag = 'Y' THEN
      IF p_charges_detail_rec.new_cp_return_by_date IS NULL THEN
        --RAISE FND_API.G_EXC_ERROR;
        --null;
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INST_CP_RETURN_BY_DATE');
        FND_MESSAGE.Set_Token('INST_CP_RTN_BY_DATE', p_charges_detail_rec.installed_cp_return_by_date);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF p_charges_detail_rec.new_cp_return_by_date <> FND_API.G_MISS_DATE THEN
            --assign to out record
            x_charges_detail_rec.new_cp_return_by_date := p_charges_detail_rec.new_cp_return_by_date;
      ELSE
            x_charges_detail_rec.new_cp_return_by_date := l_db_det_rec.new_cp_return_by_date;
      END IF;
    -- Depot Loaner fix - Bug#4586140
    ELSIF ( l_line_order_category_code = 'ORDER' AND
            l_comms_trackable_flag = 'Y' AND
            l_src_return_reqd_flag = 'Y' AND
            l_action_code = 'LOANER') THEN

        x_charges_detail_rec.new_cp_return_by_date := p_charges_detail_rec.new_cp_return_by_date;
    ELSE
      -- the flag is 'N'
      -- ignore the installed_cp_return_by_date
      x_charges_detail_rec.new_cp_return_by_date := NULL;
    END IF;  ****/
END IF;
--DBMS_OUTPUT.PUT_LINE('Item Instance Valid');

--=====================================
-- Return Reason Code Validation
--=====================================
--DBMS_OUTPUT.PUT_LINE('Return Reason Code Validation ...');
IF p_validation_mode = 'I' THEN

  IF l_line_order_category_code = 'RETURN' THEN
    IF p_charges_detail_rec.return_reason_code IS NULL THEN
      --RAISE FND_API.G_EXC_ERROR;
      --null;
      FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_RETURN_REASON');
      FND_MESSAGE.Set_Token('RETURN_REASON_CODE', p_charges_detail_rec.return_reason_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE

      --return reason code is not null
      --validate the return reason code

      l_valid_check := IS_RETURN_REASON_VALID(p_return_reason_code => p_charges_detail_rec.return_reason_code,
                                x_msg_data           => l_msg_data,
                                x_msg_count          => l_msg_count,
                                x_return_status      => l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_valid_check <> 'Y' THEN

        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_RETURN_REASON');
        FND_MESSAGE.Set_Token('RETURN_REASON_CODE', p_charges_detail_rec.return_reason_code);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_charges_detail_rec.return_reason_code := p_charges_detail_rec.return_reason_code;
      END IF;

    END IF;

  ELSE

    IF l_line_order_category_code = 'ORDER' OR l_line_order_category_code IS NULL THEN
      IF p_charges_detail_rec.return_reason_code IS NOT NULL THEN
        --RAISE FND_API.G_EXC_ERROR;
        --null;
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_RETURN_REASON');
        FND_MESSAGE.Set_Token('RETURN_REASON_CODE', p_charges_detail_rec.return_reason_code);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    x_charges_detail_rec.return_reason_code := p_charges_detail_rec.return_reason_code;

  END IF;

ELSIF p_validation_mode = 'U' THEN

  IF l_line_order_category_code = 'RETURN' THEN

    IF p_charges_detail_rec.return_reason_code <> FND_API.G_MISS_CHAR AND
       p_charges_detail_rec.return_reason_code IS NOT NULL THEN

      l_valid_check := IS_RETURN_REASON_VALID(p_return_reason_code => p_charges_detail_rec.return_reason_code,
                                x_msg_data           => l_msg_data,
                                x_msg_count          => l_msg_count,
                                x_return_status      => l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_valid_check <> 'Y' THEN

        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_RETURN_REASON');
        FND_MESSAGE.Set_Token('RETURN_REASON_CODE', p_charges_detail_rec.return_reason_code);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_charges_detail_rec.return_reason_code := p_charges_detail_rec.return_reason_code;
      END IF;

    ELSE
      -- If not passed then
      -- assign from db record
      x_charges_detail_rec.return_reason_code := l_db_det_rec.return_reason_code;
    END IF;
  END IF;
END IF;

--DBMS_OUTPUT.PUT_LINE('Return Reason COde Successful ....');

--========================================
-- Qty Required Validation
--========================================

--DBMS_OUTPUT.PUT_LINE('Qty Required Validation ...');

IF p_validation_mode = 'I' THEN

  --DBMS_OUTPUT.PUT_LINE('Insert Mode');

  IF (((l_line_order_category_code = 'RETURN') AND
       (p_charges_detail_rec.return_reason_code IS NOT NULL) AND
       (p_charges_detail_rec.quantity_required IS NOT NULL))) THEN

       IF sign(p_charges_detail_rec.quantity_required) = -1 THEN
         x_charges_detail_rec.quantity_required := p_charges_detail_rec.quantity_required;
       ELSE
         --assign -ve qty to out record
         x_charges_detail_rec.quantity_required := (p_charges_detail_rec.quantity_required * -1);
       END IF;
  ELSE

    IF p_charges_detail_rec.quantity_required IS NOT NULL THEN
      -- Added to fix bug # 5147727
      IF sign(p_charges_detail_rec.quantity_required) = -1 THEN
        -- need to make this positive as no -ve quantity for orders
        x_charges_detail_rec.quantity_required := (p_charges_detail_rec.quantity_required * -1);
      ELSE
        x_charges_detail_rec.quantity_required := p_charges_detail_rec.quantity_required;
      END IF;

    ELSE
      --Added to fix bug # 3217757
      --debriefed expense line not displaying correct amount
      --This is to default 1 for qty if qty is null

      --Added to fix bug # 4205915
      IF ((l_line_order_category_code = 'RETURN') AND
         (p_charges_detail_rec.return_reason_code IS NOT NULL)) THEN

         x_charges_detail_rec.quantity_required := -1;
      ELSE
         x_charges_detail_rec.quantity_required := 1;
      END IF;
    END IF;
  END IF;

ELSIF p_validation_mode = 'U' THEN

  --DBMS_OUTPUT.PUT_LINE('Update Mode');

  --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.quantity_required '||p_charges_detail_rec.quantity_required);

  IF p_charges_detail_rec.quantity_required = FND_API.G_MISS_NUM OR
     p_charges_detail_rec.quantity_required IS NULL THEN

     --DBMS_OUTPUT.PUT_LINE('Quantity Required not passed');
     x_charges_detail_rec.quantity_required  := l_db_det_rec.quantity_required ;
     --DBMS_OUTPUT.PUT_LINE('Quantity required is '||x_charges_detail_rec.quantity_required);

  ELSE
     /* Bug# 4870051
     IF l_db_det_rec.rollup_flag = 'Y'  THEN
         Cant_Update_Detail_Param_Msg(l_api_name_full,
                                      'QUANTITY_REQUIRED',
                                      to_char(p_charges_detail_rec.quantity_required));
         RAISE FND_API.G_EXC_ERROR;
     ELSE*/
         IF (((l_line_order_category_code = 'RETURN') AND
              (x_charges_detail_rec.return_reason_code IS NOT NULL) AND
              (p_charges_detail_rec.quantity_required IS NOT NULL))) THEN

               IF sign(p_charges_detail_rec.quantity_required) = -1 THEN
                 x_charges_detail_rec.quantity_required := p_charges_detail_rec.quantity_required;
               ELSE
                 --assign -ve qty to out record
                 x_charges_detail_rec.quantity_required := (p_charges_detail_rec.quantity_required * -1);
               END IF;
         ELSE
           -- Added below for Bug# 5147727
           IF sign(p_charges_detail_rec.quantity_required) = -1 THEN
             -- need to make this positive as no -ve quantity for orders
             x_charges_detail_rec.quantity_required := (p_charges_detail_rec.quantity_required * -1);
           ELSE
             x_charges_detail_rec.quantity_required  := p_charges_detail_rec.quantity_required ;
           END IF;
            --DBMS_OUTPUT.PUT_LINE('Quantity required is '||x_charges_detail_rec.quantity_required);

         END IF;

         --Condition added to fix Bug # 3358531
         IF x_charges_detail_rec.quantity_required  <> l_db_det_rec.quantity_required THEN
          --quantity required is changed need to re-calculate the list price
          l_calc_sp := 'Y';
        END IF;
      --Bug# 4870051 END IF ;
  END IF ;
END IF;

--DBMS_OUTPUT.PUT_LINE('Qty Required Validation Successful...');


--=================================================
--Validate Incoming Price List and Currency Code
--=================================================
--DBMS_OUTPUT.PUT_LINE('Validate Incoming Price List and Currency Code ...');

IF p_validation_mode IN ( 'I', 'U') THEN

  --DBMS_OUTPUT.PUT_LINE(' Price List '||p_charges_detail_rec.price_list_id);
  --DBMS_OUTPUT.PUT_LINE(' Currency_code '||p_charges_detail_rec.currency_code);

  IF p_charges_detail_rec.price_list_id <> FND_API.G_MISS_NUM AND
     p_charges_detail_rec.price_list_id IS NOT NULL THEN

    l_valid_check := IS_PRICE_LIST_VALID(p_price_list_id => p_charges_detail_rec.price_list_id,
                           x_msg_data      => l_msg_data,
                           x_msg_count     => l_msg_count,
                           x_return_status => l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    IF l_valid_check <> 'Y' THEN
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_PRICE_LIST');
        FND_MESSAGE.Set_Token('PRICE_LIST_ID', p_charges_detail_rec.price_list_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

    ELSE

      --DBMS_OUTPUT.PUT_LINE('Price List is valid');

      --assign the price_list_id to the out record
      x_charges_detail_rec.price_list_id := p_charges_detail_rec.price_list_id;

      -- get currency_code for the price_list_id
      GET_CURRENCY_CODE(
        p_api_name        => l_api_name,
        p_price_list_id   => p_charges_detail_rec.price_list_id,
        x_currency_code   => l_currency_code,
        x_msg_data        => l_msg_data,
        x_msg_count       => l_msg_count,
        x_return_status   => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
        FND_MESSAGE.Set_Token('PRICE_LIST_ID', p_charges_detail_rec.price_list_id);
        --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF ;

      --DBMS_OUTPUT.PUT_LINE('Currency_code '||l_currency_code);

      IF (p_charges_detail_rec.currency_code <> FND_API.G_MISS_CHAR AND
          p_charges_detail_rec.currency_code IS NOT NULL) AND
         (l_currency_code IS NOT NULL) AND
         (p_charges_detail_rec.currency_code <> l_currency_code) THEN
        --RAISE FND_API.G_EXC_ERROR;
        --null;
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_CURRENCY_CODE');
        FND_MESSAGE.Set_Token('CURRENCY_CODE', p_charges_detail_rec.currency_code);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (p_charges_detail_rec.currency_code IS NULL) AND
            (l_currency_code IS NOT NULL) THEN

          x_charges_detail_rec.currency_code := l_currency_code;

      --ELSIF (p_charges_detail_rec.currency_code IS NOT NULL) AND
      --        (l_currency_code IS NULL) THEN
      ELSE
          --assign currency_code to out record
          x_charges_detail_rec.currency_code := p_charges_detail_rec.currency_code;
      END IF;
    END IF;

  END IF;
END IF;


--===================================
--Validate Contract Information
--===================================
--DBMS_OUTPUT.PUT_LINE('Validate Contract Information ...');


IF l_incident_date is NOT NULL THEN
  l_request_date := l_incident_date;
  --DBMS_OUTPUT.PUT_LINE('l_request_date : '||l_request_date);

ELSE
  l_request_date := l_creation_date;
  --DBMS_OUTPUT.PUT_LINE('l_request_date : '||l_request_date);
END IF;

IF p_validation_mode = 'I' THEN

  --DBMS_OUTPUT.PUT_LINE('Contract Validation');
  --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.contract_id = ' || p_charges_detail_rec.contract_id);
  --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.coverage_id = ' || p_charges_detail_rec.coverage_id);
  --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.coverage_txn_group_id = ' || p_charges_detail_rec.coverage_txn_group_id);

  -- if rate_type is passed then pass it down to the application
  IF p_charges_detail_rec.rate_type_code IS NOT NULL THEN
    x_charges_detail_rec.rate_type_code := p_charges_detail_rec.rate_type_code;
  ELSE
    x_charges_detail_rec.rate_type_code := null;
  END IF;



  --Changed for R12 - always use the contract_line_id
  IF p_charges_detail_rec.contract_line_id IS NOT NULL THEN
    --validate the contract_line_id
    l_valid_check := IS_CONTRACT_LINE_VALID(
                      p_contract_line_id      => p_charges_detail_rec.contract_line_id,
                      x_contract_id           => x_charges_detail_rec.contract_id,
                      x_msg_data              => l_msg_data,
                      x_msg_count             => l_msg_count,
                      x_return_status         => l_return_status);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_valid_check <> 'Y' THEN

      FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_CONTRACT_LINE');
      FND_MESSAGE.Set_Token('CONTRACT_LINE_ID', p_charges_detail_rec.contract_Line_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      --assign this value to the out parameter
      x_charges_detail_rec.contract_line_id := p_charges_detail_rec.contract_line_id;
    END IF;
  ELSIF p_charges_detail_rec.coverage_id IS NOT NULL THEN
    --need to derive the coverage_line_id using the coverage_id

      x_charges_detail_rec.contract_line_id  := GET_CONTRACT_LINE_ID(p_charges_detail_rec.coverage_id,
                                                                     l_msg_data,
                                                                     x_msg_count,
                                                                     x_return_status);

         IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF x_charges_detail_rec.contract_line_id = 0 THEN
            Add_Invalid_Argument_Msg(l_api_name,
                                 l_contract_line_id,
                                 'Contract Line ID');

            RAISE FND_API.G_EXC_ERROR;
         END IF;
   ELSE
       --Fixed Bug # 5022118  Added condition for Depot Repair Task lines
       IF l_contract_service_id IS NOT NULL AND
          p_charges_detail_rec.original_source_code <> 'DR' AND
          p_charges_detail_rec.source_code <> 'SD' THEN
         --assign this to the x_charges_detail_rec.contract_line_id
         x_charges_detail_rec.contract_line_id := l_contract_service_id;
       ELSE
         x_charges_detail_rec.contract_line_id := null;
       END IF;
   END IF;



  -- Initialize contract values.
  x_charges_detail_rec.contract_id := null;
  x_charges_detail_rec.coverage_id := null;
  x_charges_detail_rec.coverage_txn_group_id := null;

  IF (p_charges_detail_rec.contract_id IS NOT NULL) THEN
     --(p_charges_detail_rec.coverage_id IS NOT NULL) AND
     --(p_charges_detail_rec.coverage_txn_group_id IS NOT NULL) THEN

    --Validate Contract

    l_valid_check := IS_CONTRACT_VALID(
                         p_contract_id           =>  p_charges_detail_rec.contract_id,
                         x_msg_data              =>  l_msg_data,
                         x_msg_count             =>  l_msg_count,
                         x_return_status         =>  l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_valid_check <> 'Y' THEN

        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_CONTRACT');
        FND_MESSAGE.Set_Token('CONTRACT_ID', p_charges_detail_rec.contract_id);
        --FND_MESSAGE.Set_Token('COVERAGE_ID', p_charges_detail_rec.coverage_id, TRUE);
        --FND_MESSAGE.Set_Token('BUSINESS_PROCESS_ID', p_charges_detail_rec.business_process_id, TRUE);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

      ELSE

      --Contract is valid, assign to out record
      x_charges_detail_rec.contract_id := p_charges_detail_rec.contract_id;

      -- get price list for the contract
      GET_CONTRACT_PRICE_LIST(
          p_api_name              => l_api_name,
          p_business_process_id   => x_charges_detail_rec.business_process_id,
          p_request_date          => l_request_date,
          p_contract_line_id      => x_charges_detail_rec.contract_line_id,
          x_price_list_id         => l_price_list_id,
          x_currency_code         => l_currency_code,
          x_msg_data              => l_msg_data,
          x_msg_count             => l_msg_count,
          x_return_status         => l_return_status);

      IF p_charges_detail_rec.price_list_id IS NOT NULL AND
         l_price_list_id IS NOT NULL AND
         p_charges_detail_rec.price_list_id <> l_price_list_id THEN

         --Fixed To resolve Bug # 3557490
         --do nothing
         --since the price list is already derived there is no need to validate again
         --use the price list sent by the upstream application
         x_charges_detail_rec.price_list_id := p_charges_detail_rec.price_list_id;

         -- get currency_code for the price_list_id
         GET_CURRENCY_CODE(
              p_api_name        => l_api_name,
              p_price_list_id   => x_charges_detail_rec.price_list_id,
              x_currency_code   => l_currency_code,
              x_msg_data        => l_msg_data,
              x_msg_count       => l_msg_count,
              x_return_status   => l_return_status);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
          FND_MESSAGE.Set_Token('PRICE_LIST_ID', p_charges_detail_rec.price_list_id);
          --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
         END IF ;

         x_charges_detail_rec.currency_code := l_currency_code;

      ELSIF p_charges_detail_rec.price_list_id IS NULL AND
            l_price_list_id IS NOT NULL THEN
        x_charges_detail_rec.price_list_id := l_price_list_id;
        x_charges_detail_rec.currency_code := l_currency_code;

      ELSIF p_charges_detail_rec.price_list_id IS NOT NULL AND
            l_price_list_id IS NULL THEN

        x_charges_detail_rec.price_list_id := p_charges_detail_rec.price_list_id;
        -- get currency_code for the price_list_id
        GET_CURRENCY_CODE(
              p_api_name        => l_api_name,
              p_price_list_id   => p_charges_detail_rec.price_list_id,
              x_currency_code   => l_currency_code,
              x_msg_data        => l_msg_data,
              x_msg_count       => l_msg_count,
              x_return_status   => l_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
         FND_MESSAGE.Set_Token('PRICE_LIST_ID', p_charges_detail_rec.price_list_id);
         --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
        END IF ;

        x_charges_detail_rec.currency_code := l_currency_code;

      ELSIF p_charges_detail_rec.price_list_id IS NULL AND
            l_price_list_id IS NULL THEN

        --use the default from the price list
        x_charges_detail_rec.price_list_id := to_number(fnd_profile.value('CS_CHARGE_DEFAULT_PRICE_LIST'));

      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
      THEN
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE || ''
	, 'The Value of profile CS_CHARGE_DEFAULT_PRICE_LIST :' || x_charges_detail_rec.price_list_id
	);
      END IF;

        -- get currency_code for the price_list_id
        GET_CURRENCY_CODE(
              p_api_name        => l_api_name,
              p_price_list_id   => x_charges_detail_rec.price_list_id,
              x_currency_code   => l_currency_code,
              x_msg_data        => l_msg_data,
              x_msg_count       => l_msg_count,
              x_return_status   => l_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
          FND_MESSAGE.Set_Token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
          --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF ;
        x_charges_detail_rec.currency_code := l_currency_code;

      END IF;
    END IF;


  -- For bugfix 3903911, vkjain.
  -- The charge contract is selectively applied for debrief lines.
  -- If the debrief lines originate from Depot Repair than RO contract
  -- is used. If there is no RO contract then SR contract should not be defaulted.
  -- Adding the NOT condition below to address the requirement.
  ELSIF l_contract_service_ID IS NOT NULL AND
        l_business_process_id IS NOT NULL AND
        NOT ( p_charges_detail_rec.original_source_code = 'DR' AND
              p_charges_detail_rec.source_code = 'SD') THEN

    -- p_charges_detail_rec.contract_id IS NULL AND
    -- p_charges_detail_rec.coverage_id IS NULL AND
    -- p_charges_detail_rec.coverage_txn_group_id IS NULL
    -- Check to see if there is a contract on SR

    --DBMS_OUTPUT.PUT_LINE('l_contract_id = ' || l_contract_id);
    --DBMS_OUTPUT.PUT_LINE('l_contract_service_ID = ' || l_contract_service_ID);
    --DBMS_OUTPUT.PUT_LINE('l_business_process_id = ' || l_business_process_id);

    GET_CONTRACT(
        p_api_name               => l_api_name,
        p_contract_SR_ID         => l_contract_service_id,
        p_incident_date          => l_incident_date,
        p_creation_date          => l_creation_date,
        p_customer_id            => l_customer_id,
        p_cust_account_id        => l_account_id,
        p_cust_product_id        => l_cust_product_id,
        p_system_id              => l_system_id,          -- Fix bug
        p_inventory_item_id      => l_inventory_item_id,  -- Fix bug
        p_business_process_id    => p_charges_detail_rec.business_process_id,
        x_contract_id            => l_contract_id,
        x_po_number              => l_po_number,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data);

        --DBMS_OUTPUT.PUT_LINE('l_contract_id = ' || l_contract_id);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CONTRACT_API_ERROR');
          FND_MESSAGE.SET_TOKEN('BUSINESS_PROCESS_ID', p_charges_detail_rec.business_process_id);
          FND_MESSAGE.SET_TOKEN('CONTRACT_SERVICE_LINE_ID', l_contract_service_id);
          --FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_contract_id IS NOT NULL THEN

          x_charges_detail_rec.contract_id := l_contract_id;


          -- get price list for the contract
          GET_CONTRACT_PRICE_LIST(
            p_api_name              => l_api_name,
            p_business_process_id   => l_business_process_id,
            p_request_date          => l_request_date,
            p_contract_line_id      => l_contract_service_id,
            x_price_list_id         => l_price_list_id,
            x_currency_code         => l_currency_code,
            x_msg_data              => l_msg_data,
            x_msg_count             => l_msg_count,
            x_return_status         => l_return_status);

          IF p_charges_detail_rec.price_list_id IS NOT NULL AND
             l_price_list_id IS NOT NULL AND
             p_charges_detail_rec.price_list_id <> l_price_list_id THEN

             --Fixed To resolve Bug # 3557490
             --do nothing
             --since the price list is already derived there is no need to validate again
             --use the price list sent by the upstream application
             x_charges_detail_rec.price_list_id := p_charges_detail_rec.price_list_id;

             -- get currency_code for the price_list_id
             GET_CURRENCY_CODE(
                  p_api_name        => l_api_name,
                  p_price_list_id   => x_charges_detail_rec.price_list_id,
                  x_currency_code   => l_currency_code,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => l_return_status);

             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
               FND_MESSAGE.Set_Token('PRICE_LIST_ID', p_charges_detail_rec.price_list_id);
               --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
             END IF ;

             x_charges_detail_rec.currency_code := l_currency_code;

          ELSIF p_charges_detail_rec.price_list_id IS NULL AND
                l_price_list_id IS NOT NULL THEN
            x_charges_detail_rec.price_list_id := l_price_list_id;
            x_charges_detail_rec.currency_code := l_currency_code;
          ELSIF p_charges_detail_rec.price_list_id IS NOT NULL AND
                l_price_list_id IS NULL THEN
            x_charges_detail_rec.price_list_id := p_charges_detail_rec.price_list_id;

            -- get currency_code for the price_list_id
            GET_CURRENCY_CODE(
                  p_api_name        => l_api_name,
                  p_price_list_id   => p_charges_detail_rec.price_list_id,
                  x_currency_code   => l_currency_code,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => l_return_status);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
              FND_MESSAGE.Set_Token('PRICE_LIST_ID', p_charges_detail_rec.price_list_id);
              --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF ;

            x_charges_detail_rec.currency_code := l_currency_code;

          ELSIF p_charges_detail_rec.price_list_id IS NULL AND
                l_price_list_id IS NULL THEN

            --use the default from the price list
            x_charges_detail_rec.price_list_id := to_number(fnd_profile.value('CS_CHARGE_DEFAULT_PRICE_LIST'));

      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
      THEN
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE || ''
	, 'The Value of profile CS_CHARGE_DEFAULT_PRICE_LIST :' || x_charges_detail_rec.price_list_id
	);
      END IF;

            -- get currency_code for the price_list_id
            GET_CURRENCY_CODE(
                  p_api_name        => l_api_name,
                  p_price_list_id   => x_charges_detail_rec.price_list_id,
                  x_currency_code   => l_currency_code,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => l_return_status);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
              FND_MESSAGE.Set_Token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
              --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF ;
            x_charges_detail_rec.currency_code := l_currency_code;
          END IF;

       ELSE
          -- consider this as no contract exists
          IF p_charges_detail_rec.price_list_id IS NULL THEN
            x_charges_detail_rec.price_list_id := to_number(fnd_profile.value('CS_CHARGE_DEFAULT_PRICE_LIST'));

            -- get currency_code for the price_list_id
            GET_CURRENCY_CODE(
                  p_api_name        => l_api_name,
                  p_price_list_id   => x_charges_detail_rec.price_list_id,
                  x_currency_code   => l_currency_code,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => l_return_status);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              --RAISE FND_API.G_EXC_ERROR;
              FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
              FND_MESSAGE.Set_Token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
              --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF ;
            x_charges_detail_rec.currency_code := l_currency_code;
          ELSE

            x_charges_detail_rec.price_list_id := p_charges_detail_rec.price_list_id;

            -- get currency_code for the price_list_id
            GET_CURRENCY_CODE(
                  p_api_name        => l_api_name,
                  p_price_list_id   => x_charges_detail_rec.price_list_id,
                  x_currency_code   => l_currency_code,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => l_return_status);
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              --RAISE FND_API.G_EXC_ERROR;
              FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
              FND_MESSAGE.Set_Token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
              --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF ;
            x_charges_detail_rec.currency_code := l_currency_code;
          END IF;
        END IF;


  ELSE
    --no contract exists
    IF p_charges_detail_rec.price_list_id IS NULL THEN
       x_charges_detail_rec.price_list_id := to_number(fnd_profile.value('CS_CHARGE_DEFAULT_PRICE_LIST'));

      -- get currency_code for the price_list_id
      GET_CURRENCY_CODE(
            p_api_name        => l_api_name,
            p_price_list_id   => x_charges_detail_rec.price_list_id,
            x_currency_code   => l_currency_code,
            x_msg_data        => l_msg_data,
            x_msg_count       => l_msg_count,
            x_return_status   => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
        FND_MESSAGE.Set_Token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
        --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF ;
      x_charges_detail_rec.currency_code := l_currency_code;

    ELSE
      x_charges_detail_rec.price_list_id := p_charges_detail_rec.price_list_id;

      -- get currency_code for the price_list_id
      GET_CURRENCY_CODE(
            p_api_name        => l_api_name,
            p_price_list_id   => x_charges_detail_rec.price_list_id,
            x_currency_code   => l_currency_code,
            x_msg_data        => l_msg_data,
            x_msg_count       => l_msg_count,
            x_return_status   => l_return_status);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        --RAISE FND_API.G_EXC_ERROR;
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
        FND_MESSAGE.Set_Token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
        --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF ;
      x_charges_detail_rec.currency_code := l_currency_code;
    END IF;
  END IF;

ELSIF p_validation_mode = 'U' THEN

 --DBMS_OUTPUT.PUT_LINE('Contract Validation for update');
 --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.contract_id = ' || p_charges_detail_rec.contract_id);
 --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.coverage_id = ' || p_charges_detail_rec.coverage_id);
 --DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.coverage_txn_group_id = ' || p_charges_detail_rec.coverage_txn_group_id);

  -- if rate_type is passed then pass it down to the application
  IF p_charges_detail_rec.rate_type_code IS NOT NULL AND
     p_charges_detail_rec.rate_type_code <> FND_API.G_MISS_CHAR THEN
     -- value is passed
    x_charges_detail_rec.rate_type_code := p_charges_detail_rec.rate_type_code;
  ELSE
    IF p_charges_detail_rec.rate_type_code IS NULL THEN
      --nullify the rate_type_code on the charge line
      x_charges_detail_rec.rate_type_code := null;
    ELSE
      --take the one from the database;
      x_charges_detail_rec.rate_type_code := l_db_det_rec.rate_type_code;
    END IF;

  END IF;



  --Changed for R12 - always use the contract_line_id
  IF p_charges_detail_rec.contract_line_id IS NOT NULL AND
     p_charges_detail_rec.contract_line_id <> FND_API.G_MISS_NUM THEN
    --validate the contract_line_id
    l_valid_check := IS_CONTRACT_LINE_VALID(
                      p_contract_line_id      => p_charges_detail_rec.contract_line_id,
                      x_contract_id           => x_charges_detail_rec.contract_id,
                      x_msg_data              => l_msg_data,
                      x_msg_count             => l_msg_count,
                      x_return_status         => l_return_status);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_valid_check <> 'Y' THEN

      FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_CONTRACT');
      FND_MESSAGE.Set_Token('CONTRACT_ID', p_charges_detail_rec.contract_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      --assign this value to the out parameter
      x_charges_detail_rec.contract_line_id := p_charges_detail_rec.contract_line_id;
    END IF;
  ELSIF p_charges_detail_rec.coverage_id IS NOT NULL AND
        p_charges_detail_rec.coverage_id <> FND_API.G_MISS_NUM THEN

    --need to derive the coverage_line_id using the new coverage_id

      x_charges_detail_rec.contract_line_id  := GET_CONTRACT_LINE_ID(p_charges_detail_rec.coverage_id,
                                                                     l_msg_data,
                                                                     x_msg_count,
                                                                     x_return_status);

         IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF x_charges_detail_rec.contract_line_id = 0 THEN
            Add_Invalid_Argument_Msg(l_api_name,
                                 l_contract_line_id,
                                 'Contract Line ID');

            RAISE FND_API.G_EXC_ERROR;
         END IF;
   ELSE
       IF p_charges_detail_rec.contract_line_id IS NULL THEN
         --nullify the contract line id on the charge line
         x_charges_detail_rec.contract_line_id := null;
       ELSE
         --take the one from the database;
         x_charges_detail_rec.contract_line_id := l_db_det_rec.contract_line_id;
       END IF;

   END IF;


   -- Initialize contract values.
   --x_charges_detail_rec.contract_id := null;
   x_charges_detail_rec.coverage_id := null;
   x_charges_detail_rec.coverage_txn_group_id := null;



 IF(p_charges_detail_rec.contract_id <> FND_API.G_MISS_NUM) AND
   (p_charges_detail_rec.contract_id IS NOT NULL) THEN

   -- Fixed Bug # 4126979

    --Validate Contract
    l_valid_check := IS_CONTRACT_VALID(
                         p_contract_id           =>  p_charges_detail_rec.contract_id,
                         x_msg_data              =>  l_msg_data,
                         x_msg_count             =>  l_msg_count,
                         x_return_status         =>  l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_valid_check <> 'Y' THEN

        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_CONTRACT');
        FND_MESSAGE.Set_Token('CONTRACT_ID', p_charges_detail_rec.contract_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

      ELSE

      --Contract is valid, assign to out record
      x_charges_detail_rec.contract_id := p_charges_detail_rec.contract_id;
      -- get price list for the contract
      GET_CONTRACT_PRICE_LIST(
          p_api_name              => l_api_name,
          p_business_process_id   => x_charges_detail_rec.business_process_id,
          p_request_date          => l_request_date,
          p_contract_line_id      => x_charges_detail_rec.contract_line_id,
          x_price_list_id         => l_price_list_id,
          x_currency_code         => l_currency_code,
          x_msg_data              => l_msg_data,
          x_msg_count             => l_msg_count,
          x_return_status         => l_return_status);

      IF p_charges_detail_rec.price_list_id <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.price_list_id IS NOT NULL AND
         l_price_list_id IS NOT NULL AND
         p_charges_detail_rec.price_list_id <> l_price_list_id THEN

         --Fixed To resolve Bug # 3557490
         --do nothing
         --since the price list is already derived there is no need to validate again
         --use the price list sent by the upstream application
         x_charges_detail_rec.price_list_id := p_charges_detail_rec.price_list_id;

         -- get currency_code for the price_list_id
         GET_CURRENCY_CODE(
              p_api_name        => l_api_name,
              p_price_list_id   => x_charges_detail_rec.price_list_id,
              x_currency_code   => l_currency_code,
              x_msg_data        => l_msg_data,
              x_msg_count       => l_msg_count,
              x_return_status   => l_return_status);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
           FND_MESSAGE.Set_Token('PRICE_LIST_ID', p_charges_detail_rec.price_list_id);
           --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         END IF ;

         x_charges_detail_rec.currency_code := l_currency_code;

         --Condition added to fix Bug # 3358531
        IF x_charges_detail_rec.price_list_id <> l_db_det_rec.price_list_header_id OR
           x_charges_detail_rec.currency_code <> l_db_det_rec.currency_code THEN
          --price list or currecy code is changed need to re-calculate the list price
          l_calc_sp := 'Y';
        END IF;

      ELSIF p_charges_detail_rec.price_list_id IS NULL OR
            p_charges_detail_rec.price_list_id = FND_API.G_MISS_NUM AND
            l_price_list_id IS NOT NULL THEN

        -- update the pricelist in the database with the new one

        x_charges_detail_rec.price_list_id := l_price_list_id;
        x_charges_detail_rec.currency_code := l_currency_code;

        --Condition added to fix Bug # 3358531
        IF x_charges_detail_rec.price_list_id <> l_db_det_rec.price_list_header_id OR
           x_charges_detail_rec.currency_code <> l_db_det_rec.currency_code THEN
          --price list or currecy code is changed need to re-calculate the list price
          l_calc_sp := 'Y';
        END IF;

      ELSIF p_charges_detail_rec.price_list_id <> FND_API.G_MISS_NUM AND
            p_charges_detail_rec.price_list_id IS NOT NULL AND
            l_price_list_id IS NULL THEN

        x_charges_detail_rec.price_list_id := p_charges_detail_rec.price_list_id;
        -- get currency_code for the price_list_id
        GET_CURRENCY_CODE(
              p_api_name        => l_api_name,
              p_price_list_id   => p_charges_detail_rec.price_list_id,
              x_currency_code   => l_currency_code,
              x_msg_data        => l_msg_data,
              x_msg_count       => l_msg_count,
              x_return_status   => l_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
          FND_MESSAGE.Set_Token('PRICE_LIST_ID', p_charges_detail_rec.price_list_id);
          --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF ;

        x_charges_detail_rec.currency_code := l_currency_code;

         --Condition added to fix Bug # 3358531
         IF x_charges_detail_rec.price_list_id <> l_db_det_rec.price_list_header_id OR
            x_charges_detail_rec.currency_code <> l_db_det_rec.currency_code THEN
            --price list or currecy code is changed need to re-calculate the list price
            l_calc_sp := 'Y';
         END IF;

      ELSIF p_charges_detail_rec.price_list_id IS NULL OR
            p_charges_detail_rec.price_list_id = FND_API.G_MISS_NUM AND
            l_price_list_id IS NULL THEN

        --use the default from the price list
        x_charges_detail_rec.price_list_id := to_number(fnd_profile.value('CS_CHARGE_DEFAULT_PRICE_LIST'));

        -- get currency_code for the price_list_id
        GET_CURRENCY_CODE(
              p_api_name        => l_api_name,
              p_price_list_id   => x_charges_detail_rec.price_list_id,
              x_currency_code   => l_currency_code,
              x_msg_data        => l_msg_data,
              x_msg_count       => l_msg_count,
              x_return_status   => l_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
          FND_MESSAGE.Set_Token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
          --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF ;
        x_charges_detail_rec.currency_code := l_currency_code;

        --Condition added to fix Bug # 3358531
        IF x_charges_detail_rec.price_list_id <> l_db_det_rec.price_list_header_id OR
           x_charges_detail_rec.currency_code <> l_db_det_rec.currency_code THEN
          --price list or currecy code is changed need to re-calculate the list price
          l_calc_sp := 'Y';
        END IF;
      END IF;
    END IF;

  ELSIF p_charges_detail_rec.contract_id IS NULL  THEN

    --nullify the contract on the charge line
    --x_charges_detail_rec.contract_id := null;
    --x_charges_detail_rec.coverage_id := null;
    --x_charges_detail_rec.coverage_txn_group_id := null;

    -- Check to see if there is a price list passed
    IF p_charges_detail_rec.price_list_id <> FND_API.G_MISS_NUM AND
       p_charges_detail_rec.price_list_id IS NOT NULL THEN

       --assign these to the out parameters as these have already
       --been validated before
       x_charges_detail_rec.price_list_id := x_charges_detail_rec.price_list_id;
       x_charges_detail_rec.currency_code := x_charges_detail_rec.currency_code;

       --Condition added to fix Bug # 3358531
       IF x_charges_detail_rec.price_list_id <> l_db_det_rec.price_list_header_id OR
          x_charges_detail_rec.currency_code <> l_db_det_rec.currency_code THEN
          --price list or currecy code is changed need to re-calculate the list price
          l_calc_sp := 'Y';
       END IF;

    ELSIF p_charges_detail_rec.price_list_id = FND_API.G_MISS_NUM THEN

      IF l_db_det_rec.price_list_header_id IS NOT NULL THEN

          x_charges_detail_rec.price_list_id := l_db_det_rec.price_list_header_id;

          GET_CURRENCY_CODE(
              p_api_name        => l_api_name,
              p_price_list_id   => x_charges_detail_rec.price_list_id,
              x_currency_code   => l_currency_code,
              x_msg_data        => l_msg_data,
              x_msg_count       => l_msg_count,
              x_return_status   => l_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
          FND_MESSAGE.Set_Token('PRICE_LIST_ID', p_charges_detail_rec.price_list_id);
          --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF ;

        x_charges_detail_rec.currency_code := l_currency_code;

        --Condition added to fix Bug # 3358531
        IF x_charges_detail_rec.currency_code <> l_db_det_rec.currency_code THEN
          --currecy code is changed need to re-calculate the list price
          l_calc_sp := 'Y';
        END IF;

    ELSE

      --get the default on the profile
      --use the default from the price list
      x_charges_detail_rec.price_list_id := to_number(fnd_profile.value('CS_CHARGE_DEFAULT_PRICE_LIST'));

      -- get currency_code for the price_list_id
      GET_CURRENCY_CODE(
            p_api_name        => l_api_name,
            p_price_list_id   => x_charges_detail_rec.price_list_id,
            x_currency_code   => l_currency_code,
            x_msg_data        => l_msg_data,
            x_msg_count       => l_msg_count,
            x_return_status   => l_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
          FND_MESSAGE.Set_Token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
          --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF ;
        x_charges_detail_rec.currency_code := l_currency_code;

        --Condition added to fix Bug # 3358531
        IF x_charges_detail_rec.price_list_id <> l_db_det_rec.price_list_header_id OR
           x_charges_detail_rec.currency_code <> l_db_det_rec.currency_code THEN
          --price list or currecy code is changed need to re-calculate the list price
          l_calc_sp := 'Y';
        END IF;

       END IF;
    END IF;

  ELSE
   -- no contract information coming in
   -- get what is in the database
   -- --DBMS_OUTPUT.PUT_LINE('contract coming from database');
    IF (x_charges_detail_rec.contract_id IS NULL) THEN
      x_charges_detail_rec.contract_id           := l_db_det_rec.contract_id;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.contract_id '||x_charges_detail_rec.contract_id);
    --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.coverage_id '||x_charges_detail_rec.coverage_id);
    --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.coverage_txn_group_id '||x_charges_detail_rec.coverage_txn_group_id);


    IF x_charges_detail_rec.contract_id IS NOT NULL THEN

       GET_CONTRACT_PRICE_LIST(
            p_api_name              => l_api_name,
            p_business_process_id   => x_charges_detail_rec.business_process_id,
            p_request_date          => l_request_date,
            p_contract_line_id      => x_charges_detail_rec.contract_line_id,
            x_price_list_id         => l_price_list_id,
            x_currency_code         => l_currency_code,
            x_msg_data              => l_msg_data,
            x_msg_count             => l_msg_count,
            x_return_status         => l_return_status);

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
           FND_MESSAGE.Set_Token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
           --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF ;
       --DBMS_OUTPUT.PUT_LINE ('l_price_list_id '||l_price_list_id);
       --DBMS_OUTPUT.PUT_LINE (' l_currency_code '||l_currency_code);

       IF p_charges_detail_rec.price_list_id <> FND_API.G_MISS_NUM AND
          p_charges_detail_rec.price_list_id IS NOT NULL AND
          l_price_list_id IS NOT NULL AND

          p_charges_detail_rec.price_list_id <> l_price_list_id THEN

          --Fixed To resolve Bug # 3557490
          --do nothing
          --since the price list is already derived there is no need to validate again
          --use the price list sent by the upstream application
          x_charges_detail_rec.price_list_id := p_charges_detail_rec.price_list_id;

          -- get currency_code for the price_list_id
          GET_CURRENCY_CODE(
              p_api_name        => l_api_name,
              p_price_list_id   => x_charges_detail_rec.price_list_id,
              x_currency_code   => l_currency_code,
              x_msg_data        => l_msg_data,
              x_msg_count       => l_msg_count,
              x_return_status   => l_return_status);

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
            FND_MESSAGE.Set_Token('PRICE_LIST_ID', p_charges_detail_rec.price_list_id);
            --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF ;

          x_charges_detail_rec.currency_code := l_currency_code;

          --Condition added to fix Bug # 3358531
          IF x_charges_detail_rec.price_list_id <> l_db_det_rec.price_list_header_id OR
            x_charges_detail_rec.currency_code <> l_db_det_rec.currency_code THEN
            --price list or currecy code is changed need to re-calculate the list price
            l_calc_sp := 'Y';
          END IF;

       ELSIF p_charges_detail_rec.price_list_id = FND_API.G_MISS_NUM THEN

          --DBMS_OUTPUT.PUT_LINE(' price list not passed using from db');

          x_charges_detail_rec.price_list_id := l_db_det_rec.price_list_header_id;
          x_charges_detail_rec.currency_code := l_db_det_rec.currency_code;


          --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.price_list_id'||x_charges_detail_rec.price_list_id);

       ELSIF p_charges_detail_rec.price_list_id IS NULL AND
             l_price_list_id IS NOT NULL THEN

          x_charges_detail_rec.price_list_id := l_price_list_id;
          x_charges_detail_rec.currency_code := l_currency_code;

          --Condition added to fix Bug # 3358531
          IF x_charges_detail_rec.price_list_id <> l_db_det_rec.price_list_header_id OR
            x_charges_detail_rec.currency_code <> l_db_det_rec.currency_code THEN
            --price list or currecy code is changed need to re-calculate the list price
            l_calc_sp := 'Y';
          END IF;

       ELSIF p_charges_detail_rec.price_list_id <> FND_API.G_MISS_NUM AND
             p_charges_detail_rec.price_list_id IS NOT NULL AND
             l_price_list_id IS NULL THEN

           x_charges_detail_rec.price_list_id := p_charges_detail_rec.price_list_id;

            -- get currency_code for the price_list_id
            GET_CURRENCY_CODE(
                  p_api_name        => l_api_name,
                  p_price_list_id   => p_charges_detail_rec.price_list_id,
                  x_currency_code   => l_currency_code,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => l_return_status);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
              FND_MESSAGE.Set_Token('PRICE_LIST_ID', p_charges_detail_rec.price_list_id);
              --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF ;

            x_charges_detail_rec.currency_code := l_currency_code;

            --Condition added to fix Bug # 3346568
            IF x_charges_detail_rec.price_list_id <> l_db_det_rec.price_list_header_id OR
              x_charges_detail_rec.currency_code <> l_db_det_rec.currency_code THEN
              --price list or currecy code is changed need to re-calculate the list price
              l_calc_sp := 'Y';
            END IF;

        ELSIF p_charges_detail_rec.price_list_id IS NULL AND
                l_price_list_id IS NULL THEN

            --use the default from the price list
            x_charges_detail_rec.price_list_id := to_number(fnd_profile.value('CS_CHARGE_DEFAULT_PRICE_LIST'));

            -- get currency_code for the price_list_id
            GET_CURRENCY_CODE(
                  p_api_name        => l_api_name,
                  p_price_list_id   => x_charges_detail_rec.price_list_id,
                  x_currency_code   => l_currency_code,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => l_return_status);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
              FND_MESSAGE.Set_Token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
              --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF ;
            x_charges_detail_rec.currency_code := l_currency_code;

            --Condition added to fix Bug # 3358531
            IF x_charges_detail_rec.price_list_id <> l_db_det_rec.price_list_header_id OR
              x_charges_detail_rec.currency_code <> l_db_det_rec.currency_code THEN
              --price list or currecy code is changed need to re-calculate the list price
              l_calc_sp := 'Y';
            END IF;
       END IF;

    ELSE
      --all three are null
      --update what is come on the line

      --DBMS_OUTPUT.PUT_LINE(' No Contract Information');

      IF p_charges_detail_rec.price_list_id <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.price_list_id IS NOT NULL THEN

            x_charges_detail_rec.price_list_id := p_charges_detail_rec.price_list_id;

            -- get currency_code for the price_list_id
            GET_CURRENCY_CODE(
                  p_api_name        => l_api_name,
                  p_price_list_id   => p_charges_detail_rec.price_list_id,
                  x_currency_code   => l_currency_code,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => l_return_status);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              FND_MESSAGE.Set_Token('PRICE_LIST_ID', p_charges_detail_rec.price_list_id);
              --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF ;

            x_charges_detail_rec.currency_code := l_currency_code;

            --Condition added to fix Bug # 3358531
            IF x_charges_detail_rec.price_list_id <> l_db_det_rec.price_list_header_id OR
              x_charges_detail_rec.currency_code <> l_db_det_rec.currency_code THEN
              --price list or currecy code is changed need to re-calculate the list price
              l_calc_sp := 'Y';
            END IF;

        ELSE


          IF l_db_det_rec.price_list_header_id IS NOT NULL THEN
               x_charges_detail_rec.price_list_id := l_db_det_rec.price_list_header_id;
               -- get currency_code for the price_list_id
               GET_CURRENCY_CODE(
                  p_api_name        => l_api_name,
                  p_price_list_id   => x_charges_detail_rec.price_list_id,
                  x_currency_code   => l_currency_code,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => l_return_status);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
              FND_MESSAGE.Set_Token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
              --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF ;
            x_charges_detail_rec.currency_code := l_currency_code;

            --Condition added to fix Bug # 3358531
            IF x_charges_detail_rec.currency_code <> l_db_det_rec.currency_code THEN
              --currecy code is changed need to re-calculate the list price
              l_calc_sp := 'Y';
            END IF;

          ELSE
            --use the default from the price list
            x_charges_detail_rec.price_list_id := to_number(fnd_profile.value('CS_CHARGE_DEFAULT_PRICE_LIST'));

            -- get currency_code for the price_list_id
            GET_CURRENCY_CODE(
                  p_api_name        => l_api_name,
                  p_price_list_id   => x_charges_detail_rec.price_list_id,
                  x_currency_code   => l_currency_code,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => l_return_status);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CURRENCY_CODE_ERROR');
              FND_MESSAGE.Set_Token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
              --FND_MESSAGE.Set_Token('TEXT', l_msg_data, TRUE);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF ;
            x_charges_detail_rec.currency_code := l_currency_code;

            --Condition added to fix Bug # 3358531
            IF x_charges_detail_rec.price_list_id <> l_db_det_rec.price_list_header_id OR
               x_charges_detail_rec.currency_code <> l_db_det_rec.currency_code THEN
               --price list or currecy code is changed need to re-calculate the list price
               l_calc_sp := 'Y';
            END IF;
         END IF;
       END IF;
    END IF;
  END IF;
END IF;

--DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.price_list_id'||x_charges_detail_rec.price_list_id);
--DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.currency_code '||x_charges_detail_rec.currency_code);
--DBMS_OUTPUT.PUT_LINE('contract_id '||x_charges_detail_rec.contract_id);


-- ========================================
-- Check currency coversion
-- ========================================
--DBMS_OUTPUT.PUT_LINE('Check currency coversion ...');

IF p_validation_mode IN ('I', 'U') THEN

  l_conversion_needed_flag := 'N';
  x_charges_detail_rec.conversion_rate := null;
  x_charges_detail_rec.conversion_type_code := null;
  x_charges_detail_rec.conversion_rate_date := null;

  IF p_charges_detail_rec.currency_code <> FND_API.G_MISS_CHAR AND
     p_charges_detail_rec.currency_code IS NOT NULL AND
     p_charges_detail_rec.currency_code <> x_charges_detail_rec.currency_code THEN

    IF l_billing_flag = 'E' THEN

      -- Contract exists for the Charge Line
      -- Convert the currency to the currency derived from Contract

      --DBMS_OUTPUT.PUT_LINE('Conversion Needed');

      l_conversion_needed_flag := 'Y';

      --call get_conversion_rate API
      Get_Conversion_Rate(
        p_api_name        => p_api_name,
        p_from_currency   => p_charges_detail_rec.currency_code,
        p_to_currency     => x_charges_detail_rec.currency_code,
        x_denominator     => l_denominator,
        x_numerator       => l_numerator,
        x_rate            => l_rate,
        x_return_status   => l_return_status);

        --DBMS_OUTPUT.PUT_LINE('l_rate '||l_rate);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CURRENCY_CONVERSION_ERR');
        FND_MESSAGE.Set_Token('FROM_CURRENCY', p_charges_detail_rec.currency_code);
        FND_MESSAGE.Set_Token('TO_CURRENCY', x_charges_detail_rec.currency_code);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --assign values to out record for conversion_rate, conversion_type_code
      --conversion_rate_date
      x_charges_detail_rec.conversion_rate := l_rate;
      x_charges_detail_rec.conversion_type_code := FND_PROFILE.VALUE('CS_CHG_DEFAULT_CONVERSION_TYPE');
      x_charges_detail_rec.conversion_rate_date := SYSDATE;

    ELSE

      --this should be an error because what comes in must mastch the derived currency code
      --RAISE FND_API.G_EXC_ERROR;
      --null;
      FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_CURRENCY_CODE');
      FND_MESSAGE.Set_Token('CURRENCY_CODE', p_charges_detail_rec.currency_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

    END IF;

  END IF;

END IF;

--DBMS_OUTPUT.PUT_LINE('l_conversion_flag'||l_conversion_needed_flag);


--=========================================
-- Assign Values to Charges Flex fields
-- in the out record
--==========================================
IF p_validation_mode = 'I' THEN
  x_charges_detail_rec.context       := p_charges_detail_rec.context ;
  x_charges_detail_rec.attribute1    := p_charges_detail_rec.attribute1 ;
  x_charges_detail_rec.attribute2    := p_charges_detail_rec.attribute2 ;
  x_charges_detail_rec.attribute3    := p_charges_detail_rec.attribute3 ;
  x_charges_detail_rec.attribute4    := p_charges_detail_rec.attribute4 ;
  x_charges_detail_rec.attribute5    := p_charges_detail_rec.attribute5 ;
  x_charges_detail_rec.attribute6    := p_charges_detail_rec.attribute6 ;
  x_charges_detail_rec.attribute7    := p_charges_detail_rec.attribute7 ;
  x_charges_detail_rec.attribute8    := p_charges_detail_rec.attribute8 ;
  x_charges_detail_rec.attribute9    := p_charges_detail_rec.attribute9 ;
  x_charges_detail_rec.attribute10   := p_charges_detail_rec.attribute10 ;
  x_charges_detail_rec.attribute11   := p_charges_detail_rec.attribute11 ;
  x_charges_detail_rec.attribute12   := p_charges_detail_rec.attribute12 ;
  x_charges_detail_rec.attribute13   := p_charges_detail_rec.attribute13 ;
  x_charges_detail_rec.attribute14   := p_charges_detail_rec.attribute14 ;
  x_charges_detail_rec.attribute15   := p_charges_detail_rec.attribute15 ;

--=========================================
-- Assign values to Pricing Flex fields
-- in out record
--=========================================
  x_charges_detail_rec.pricing_context       := p_charges_detail_rec.pricing_context ;
  x_charges_detail_rec.pricing_attribute1    := p_charges_detail_rec.pricing_attribute1 ;
  x_charges_detail_rec.pricing_attribute2    := p_charges_detail_rec.pricing_attribute2 ;
  x_charges_detail_rec.pricing_attribute3    := p_charges_detail_rec.pricing_attribute3 ;
  x_charges_detail_rec.pricing_attribute4    := p_charges_detail_rec.pricing_attribute4 ;
  x_charges_detail_rec.pricing_attribute5    := p_charges_detail_rec.pricing_attribute5 ;
  x_charges_detail_rec.pricing_attribute6    := p_charges_detail_rec.pricing_attribute6 ;
  x_charges_detail_rec.pricing_attribute7    := p_charges_detail_rec.pricing_attribute7 ;
  x_charges_detail_rec.pricing_attribute8    := p_charges_detail_rec.pricing_attribute8 ;
  x_charges_detail_rec.pricing_attribute9    := p_charges_detail_rec.pricing_attribute9 ;
  x_charges_detail_rec.pricing_attribute10   := p_charges_detail_rec.pricing_attribute10 ;
  x_charges_detail_rec.pricing_attribute11   := p_charges_detail_rec.pricing_attribute11 ;
  x_charges_detail_rec.pricing_attribute12   := p_charges_detail_rec.pricing_attribute12 ;
  x_charges_detail_rec.pricing_attribute13   := p_charges_detail_rec.pricing_attribute13 ;
  x_charges_detail_rec.pricing_attribute14   := p_charges_detail_rec.pricing_attribute14 ;
  x_charges_detail_rec.pricing_attribute15   := p_charges_detail_rec.pricing_attribute15 ;
  x_charges_detail_rec.pricing_attribute16   := p_charges_detail_rec.pricing_attribute16 ;
  x_charges_detail_rec.pricing_attribute17   := p_charges_detail_rec.pricing_attribute17 ;
  x_charges_detail_rec.pricing_attribute18   := p_charges_detail_rec.pricing_attribute18 ;
  x_charges_detail_rec.pricing_attribute19   := p_charges_detail_rec.pricing_attribute19 ;
  x_charges_detail_rec.pricing_attribute20   := p_charges_detail_rec.pricing_attribute20 ;
  x_charges_detail_rec.pricing_attribute21   := p_charges_detail_rec.pricing_attribute21 ;
  x_charges_detail_rec.pricing_attribute22   := p_charges_detail_rec.pricing_attribute22 ;
  x_charges_detail_rec.pricing_attribute23   := p_charges_detail_rec.pricing_attribute23 ;
  x_charges_detail_rec.pricing_attribute24   := p_charges_detail_rec.pricing_attribute24 ;
  x_charges_detail_rec.pricing_attribute25   := p_charges_detail_rec.pricing_attribute25 ;
  x_charges_detail_rec.pricing_attribute26   := p_charges_detail_rec.pricing_attribute26 ;
  x_charges_detail_rec.pricing_attribute27   := p_charges_detail_rec.pricing_attribute27 ;
  x_charges_detail_rec.pricing_attribute28   := p_charges_detail_rec.pricing_attribute28 ;
  x_charges_detail_rec.pricing_attribute29   := p_charges_detail_rec.pricing_attribute29 ;
  x_charges_detail_rec.pricing_attribute30   := p_charges_detail_rec.pricing_attribute30 ;
  x_charges_detail_rec.pricing_attribute31   := p_charges_detail_rec.pricing_attribute31 ;
  x_charges_detail_rec.pricing_attribute32   := p_charges_detail_rec.pricing_attribute32 ;
  x_charges_detail_rec.pricing_attribute33   := p_charges_detail_rec.pricing_attribute33 ;
  x_charges_detail_rec.pricing_attribute34   := p_charges_detail_rec.pricing_attribute34 ;
  x_charges_detail_rec.pricing_attribute35   := p_charges_detail_rec.pricing_attribute35 ;
  x_charges_detail_rec.pricing_attribute36   := p_charges_detail_rec.pricing_attribute36 ;
  x_charges_detail_rec.pricing_attribute37   := p_charges_detail_rec.pricing_attribute37 ;
  x_charges_detail_rec.pricing_attribute38   := p_charges_detail_rec.pricing_attribute38 ;
  x_charges_detail_rec.pricing_attribute39   := p_charges_detail_rec.pricing_attribute39 ;
  x_charges_detail_rec.pricing_attribute40   := p_charges_detail_rec.pricing_attribute40 ;
  x_charges_detail_rec.pricing_attribute41   := p_charges_detail_rec.pricing_attribute41 ;
  x_charges_detail_rec.pricing_attribute42   := p_charges_detail_rec.pricing_attribute42 ;
  x_charges_detail_rec.pricing_attribute43   := p_charges_detail_rec.pricing_attribute43 ;
  x_charges_detail_rec.pricing_attribute44   := p_charges_detail_rec.pricing_attribute44 ;
  x_charges_detail_rec.pricing_attribute45   := p_charges_detail_rec.pricing_attribute45 ;
  x_charges_detail_rec.pricing_attribute46   := p_charges_detail_rec.pricing_attribute46 ;
  x_charges_detail_rec.pricing_attribute47   := p_charges_detail_rec.pricing_attribute47 ;
  x_charges_detail_rec.pricing_attribute48   := p_charges_detail_rec.pricing_attribute48 ;
  x_charges_detail_rec.pricing_attribute49   := p_charges_detail_rec.pricing_attribute49 ;
  x_charges_detail_rec.pricing_attribute50   := p_charges_detail_rec.pricing_attribute50 ;
  x_charges_detail_rec.pricing_attribute51   := p_charges_detail_rec.pricing_attribute51 ;
  x_charges_detail_rec.pricing_attribute52   := p_charges_detail_rec.pricing_attribute52 ;
  x_charges_detail_rec.pricing_attribute53   := p_charges_detail_rec.pricing_attribute53 ;
  x_charges_detail_rec.pricing_attribute54   := p_charges_detail_rec.pricing_attribute54 ;
  x_charges_detail_rec.pricing_attribute55   := p_charges_detail_rec.pricing_attribute55 ;
  x_charges_detail_rec.pricing_attribute56   := p_charges_detail_rec.pricing_attribute56 ;
  x_charges_detail_rec.pricing_attribute57   := p_charges_detail_rec.pricing_attribute57 ;
  x_charges_detail_rec.pricing_attribute58   := p_charges_detail_rec.pricing_attribute58 ;
  x_charges_detail_rec.pricing_attribute59   := p_charges_detail_rec.pricing_attribute59 ;
  x_charges_detail_rec.pricing_attribute60   := p_charges_detail_rec.pricing_attribute60 ;
  x_charges_detail_rec.pricing_attribute61   := p_charges_detail_rec.pricing_attribute61 ;
  x_charges_detail_rec.pricing_attribute62   := p_charges_detail_rec.pricing_attribute62 ;
  x_charges_detail_rec.pricing_attribute63   := p_charges_detail_rec.pricing_attribute63 ;
  x_charges_detail_rec.pricing_attribute64   := p_charges_detail_rec.pricing_attribute64 ;
  x_charges_detail_rec.pricing_attribute65   := p_charges_detail_rec.pricing_attribute65 ;
  x_charges_detail_rec.pricing_attribute66   := p_charges_detail_rec.pricing_attribute66 ;
  x_charges_detail_rec.pricing_attribute67   := p_charges_detail_rec.pricing_attribute67 ;
  x_charges_detail_rec.pricing_attribute68   := p_charges_detail_rec.pricing_attribute68 ;
  x_charges_detail_rec.pricing_attribute69   := p_charges_detail_rec.pricing_attribute69 ;
  x_charges_detail_rec.pricing_attribute70   := p_charges_detail_rec.pricing_attribute70 ;
  x_charges_detail_rec.pricing_attribute71   := p_charges_detail_rec.pricing_attribute71 ;
  x_charges_detail_rec.pricing_attribute72   := p_charges_detail_rec.pricing_attribute72 ;
  x_charges_detail_rec.pricing_attribute73   := p_charges_detail_rec.pricing_attribute73 ;
  x_charges_detail_rec.pricing_attribute74   := p_charges_detail_rec.pricing_attribute74 ;
  x_charges_detail_rec.pricing_attribute75   := p_charges_detail_rec.pricing_attribute75 ;
  x_charges_detail_rec.pricing_attribute76   := p_charges_detail_rec.pricing_attribute76 ;
  x_charges_detail_rec.pricing_attribute77   := p_charges_detail_rec.pricing_attribute77 ;
  x_charges_detail_rec.pricing_attribute78   := p_charges_detail_rec.pricing_attribute78 ;
  x_charges_detail_rec.pricing_attribute79   := p_charges_detail_rec.pricing_attribute79 ;
  x_charges_detail_rec.pricing_attribute80   := p_charges_detail_rec.pricing_attribute80 ;
  x_charges_detail_rec.pricing_attribute81   := p_charges_detail_rec.pricing_attribute81 ;
  x_charges_detail_rec.pricing_attribute82   := p_charges_detail_rec.pricing_attribute82 ;
  x_charges_detail_rec.pricing_attribute83   := p_charges_detail_rec.pricing_attribute83 ;
  x_charges_detail_rec.pricing_attribute84   := p_charges_detail_rec.pricing_attribute84 ;
  x_charges_detail_rec.pricing_attribute85   := p_charges_detail_rec.pricing_attribute85 ;
  x_charges_detail_rec.pricing_attribute86   := p_charges_detail_rec.pricing_attribute86 ;
  x_charges_detail_rec.pricing_attribute87   := p_charges_detail_rec.pricing_attribute87 ;
  x_charges_detail_rec.pricing_attribute88   := p_charges_detail_rec.pricing_attribute88 ;
  x_charges_detail_rec.pricing_attribute89   := p_charges_detail_rec.pricing_attribute89 ;
  x_charges_detail_rec.pricing_attribute90   := p_charges_detail_rec.pricing_attribute90 ;
  x_charges_detail_rec.pricing_attribute91   := p_charges_detail_rec.pricing_attribute91 ;
  x_charges_detail_rec.pricing_attribute92   := p_charges_detail_rec.pricing_attribute92 ;
  x_charges_detail_rec.pricing_attribute93   := p_charges_detail_rec.pricing_attribute93 ;
  x_charges_detail_rec.pricing_attribute94   := p_charges_detail_rec.pricing_attribute94 ;
  x_charges_detail_rec.pricing_attribute95   := p_charges_detail_rec.pricing_attribute95 ;
  x_charges_detail_rec.pricing_attribute96   := p_charges_detail_rec.pricing_attribute96 ;
  x_charges_detail_rec.pricing_attribute97   := p_charges_detail_rec.pricing_attribute97 ;
  x_charges_detail_rec.pricing_attribute98   := p_charges_detail_rec.pricing_attribute98 ;
  x_charges_detail_rec.pricing_attribute99   := p_charges_detail_rec.pricing_attribute99 ;
  x_charges_detail_rec.pricing_attribute100  := p_charges_detail_rec.pricing_attribute100 ;

ELSIF p_validation_mode = 'U' THEN

 -- Bug Fix for Bug # 3078247
 -- Added code to handle the update of attributes

 --=========================================
-- Assign Values to Charges Flex fields
-- in the out record
--==========================================
 IF p_charges_detail_rec.context = FND_API.G_MISS_CHAR THEN

   -- get the values from the database
   x_charges_detail_rec.context      := l_db_det_rec.context;
   x_charges_detail_rec.attribute1   := l_db_det_rec.attribute1;
   x_charges_detail_rec.attribute2   := l_db_det_rec.attribute2;
   x_charges_detail_rec.attribute3   := l_db_det_rec.attribute3;
   x_charges_detail_rec.attribute4   := l_db_det_rec.attribute4;
   x_charges_detail_rec.attribute5   := l_db_det_rec.attribute5;
   x_charges_detail_rec.attribute6   := l_db_det_rec.attribute6;
   x_charges_detail_rec.attribute7   := l_db_det_rec.attribute7;
   x_charges_detail_rec.attribute8   := l_db_det_rec.attribute8;
   x_charges_detail_rec.attribute9   := l_db_det_rec.attribute9;
   x_charges_detail_rec.attribute10  := l_db_det_rec.attribute10;
   x_charges_detail_rec.attribute11  := l_db_det_rec.attribute11;
   x_charges_detail_rec.attribute12  := l_db_det_rec.attribute12;
   x_charges_detail_rec.attribute13  := l_db_det_rec.attribute13;
   x_charges_detail_rec.attribute14  := l_db_det_rec.attribute14;
   x_charges_detail_rec.attribute15  := l_db_det_rec.attribute15;

 ELSIF
   p_charges_detail_rec.context IS NULL THEN

   -- nullify all values for the descriptive flex
   x_charges_detail_rec.context      := null;
   x_charges_detail_rec.attribute1   := null;
   x_charges_detail_rec.attribute2   := null;
   x_charges_detail_rec.attribute3   := null;
   x_charges_detail_rec.attribute4   := null;
   x_charges_detail_rec.attribute5   := null;
   x_charges_detail_rec.attribute6   := null;
   x_charges_detail_rec.attribute7   := null;
   x_charges_detail_rec.attribute8   := null;
   x_charges_detail_rec.attribute9   := null;
   x_charges_detail_rec.attribute10  := null;
   x_charges_detail_rec.attribute11  := null;
   x_charges_detail_rec.attribute12  := null;
   x_charges_detail_rec.attribute13  := null;
   x_charges_detail_rec.attribute14  := null;
   x_charges_detail_rec.attribute15  := null;

  ELSE

    x_charges_detail_rec.context     := p_charges_detail_rec.context ;

    IF p_charges_detail_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute1  := null;
    ELSE
      x_charges_detail_rec.attribute1  := p_charges_detail_rec.attribute1;
    END IF;

    IF p_charges_detail_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute2  := null;
    ELSE
      x_charges_detail_rec.attribute2  := p_charges_detail_rec.attribute2;
    END IF;

    IF p_charges_detail_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute3  := null;
    ELSE
      x_charges_detail_rec.attribute3  := p_charges_detail_rec.attribute3;
    END IF;

    IF p_charges_detail_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute4  := null;
    ELSE
      x_charges_detail_rec.attribute4  := p_charges_detail_rec.attribute4;
    END IF;

    IF p_charges_detail_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute5  := null;
    ELSE
      x_charges_detail_rec.attribute5  := p_charges_detail_rec.attribute5;
    END IF;

     IF p_charges_detail_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute6  := null;
    ELSE
      x_charges_detail_rec.attribute6  := p_charges_detail_rec.attribute6;
    END IF;

    IF p_charges_detail_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute7  := null;
    ELSE
      x_charges_detail_rec.attribute7  := p_charges_detail_rec.attribute7;
    END IF;

    IF p_charges_detail_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute8  := null;
    ELSE
      x_charges_detail_rec.attribute8  := p_charges_detail_rec.attribute8;
    END IF;

    IF p_charges_detail_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute9  := null;
    ELSE
      x_charges_detail_rec.attribute9  := p_charges_detail_rec.attribute9;
    END IF;

    IF p_charges_detail_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute10  := null;
    ELSE
      x_charges_detail_rec.attribute10 := p_charges_detail_rec.attribute10;
    END IF;

    IF p_charges_detail_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute11  := null;
    ELSE
      x_charges_detail_rec.attribute11  := p_charges_detail_rec.attribute11;
    END IF;

    IF p_charges_detail_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute12  := null;
    ELSE
      x_charges_detail_rec.attribute12  := p_charges_detail_rec.attribute12;
    END IF;

    IF p_charges_detail_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute13  := null;
    ELSE
      x_charges_detail_rec.attribute13  := p_charges_detail_rec.attribute13;
    END IF;

    IF p_charges_detail_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute14  := null;
    ELSE
      x_charges_detail_rec.attribute14  := p_charges_detail_rec.attribute14;
    END IF;

    IF p_charges_detail_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.attribute15  := null;
    ELSE
      x_charges_detail_rec.attribute15  := p_charges_detail_rec.attribute15;
    END IF;

 END IF;

 -- Bug Fix for Bug # 3063439
 -- Added code to handle the update of pricing attributes

--=========================================
-- Assign values to Pricing Flex fields
-- in out record
--=========================================
  IF p_charges_detail_rec.pricing_context = FND_API.G_MISS_CHAR THEN

    --DBMS_OUTPUT.PUT_LINE('parameter context is FND_API.G_MISS_CHAR ');

    x_charges_detail_rec.pricing_context      := l_db_det_rec.pricing_context ;
    x_charges_detail_rec.pricing_attribute1   := l_db_det_rec.pricing_attribute1;
    x_charges_detail_rec.pricing_attribute2   := l_db_det_rec.pricing_attribute2;
    x_charges_detail_rec.pricing_attribute3   := l_db_det_rec.pricing_attribute3;
    x_charges_detail_rec.pricing_attribute4   := l_db_det_rec.pricing_attribute4;
    x_charges_detail_rec.pricing_attribute5   := l_db_det_rec.pricing_attribute5;
    x_charges_detail_rec.pricing_attribute6   := l_db_det_rec.pricing_attribute6;
    x_charges_detail_rec.pricing_attribute7   := l_db_det_rec.pricing_attribute7;
    x_charges_detail_rec.pricing_attribute8   := l_db_det_rec.pricing_attribute8;
    x_charges_detail_rec.pricing_attribute9   := l_db_det_rec.pricing_attribute9;
    x_charges_detail_rec.pricing_attribute10  := l_db_det_rec.pricing_attribute10;
    x_charges_detail_rec.pricing_attribute11  := l_db_det_rec.pricing_attribute11;
    x_charges_detail_rec.pricing_attribute12  := l_db_det_rec.pricing_attribute12;
    x_charges_detail_rec.pricing_attribute13  := l_db_det_rec.pricing_attribute13;
    x_charges_detail_rec.pricing_attribute14  := l_db_det_rec.pricing_attribute14;
    x_charges_detail_rec.pricing_attribute15  := l_db_det_rec.pricing_attribute15;
    x_charges_detail_rec.pricing_attribute16  := l_db_det_rec.pricing_attribute16;
    x_charges_detail_rec.pricing_attribute17  := l_db_det_rec.pricing_attribute17;
    x_charges_detail_rec.pricing_attribute18  := l_db_det_rec.pricing_attribute18;
    x_charges_detail_rec.pricing_attribute19  := l_db_det_rec.pricing_attribute19;
    x_charges_detail_rec.pricing_attribute20  := l_db_det_rec.pricing_attribute20;
    x_charges_detail_rec.pricing_attribute21  := l_db_det_rec.pricing_attribute21;
    x_charges_detail_rec.pricing_attribute22  := l_db_det_rec.pricing_attribute22;
    x_charges_detail_rec.pricing_attribute23  := l_db_det_rec.pricing_attribute23;
    x_charges_detail_rec.pricing_attribute24  := l_db_det_rec.pricing_attribute24;
    x_charges_detail_rec.pricing_attribute25  := l_db_det_rec.pricing_attribute25;
    x_charges_detail_rec.pricing_attribute26  := l_db_det_rec.pricing_attribute26;
    x_charges_detail_rec.pricing_attribute27  := l_db_det_rec.pricing_attribute27;
    x_charges_detail_rec.pricing_attribute28  := l_db_det_rec.pricing_attribute28;
    x_charges_detail_rec.pricing_attribute29  := l_db_det_rec.pricing_attribute29;
    x_charges_detail_rec.pricing_attribute30  := l_db_det_rec.pricing_attribute30;
    x_charges_detail_rec.pricing_attribute31  := l_db_det_rec.pricing_attribute31;
    x_charges_detail_rec.pricing_attribute32  := l_db_det_rec.pricing_attribute32;
    x_charges_detail_rec.pricing_attribute33  := l_db_det_rec.pricing_attribute33;
    x_charges_detail_rec.pricing_attribute34  := l_db_det_rec.pricing_attribute34;
    x_charges_detail_rec.pricing_attribute35  := l_db_det_rec.pricing_attribute35;
    x_charges_detail_rec.pricing_attribute36  := l_db_det_rec.pricing_attribute36;
    x_charges_detail_rec.pricing_attribute37  := l_db_det_rec.pricing_attribute37;
    x_charges_detail_rec.pricing_attribute38  := l_db_det_rec.pricing_attribute38;
    x_charges_detail_rec.pricing_attribute39  := l_db_det_rec.pricing_attribute39;
    x_charges_detail_rec.pricing_attribute40  := l_db_det_rec.pricing_attribute40;
    x_charges_detail_rec.pricing_attribute41  := l_db_det_rec.pricing_attribute41;
    x_charges_detail_rec.pricing_attribute42  := l_db_det_rec.pricing_attribute42;
    x_charges_detail_rec.pricing_attribute43  := l_db_det_rec.pricing_attribute43;
    x_charges_detail_rec.pricing_attribute44  := l_db_det_rec.pricing_attribute44;
    x_charges_detail_rec.pricing_attribute45  := l_db_det_rec.pricing_attribute45;
    x_charges_detail_rec.pricing_attribute46  := l_db_det_rec.pricing_attribute46;
    x_charges_detail_rec.pricing_attribute47  := l_db_det_rec.pricing_attribute47;
    x_charges_detail_rec.pricing_attribute48  := l_db_det_rec.pricing_attribute48;
    x_charges_detail_rec.pricing_attribute49  := l_db_det_rec.pricing_attribute49;
    x_charges_detail_rec.pricing_attribute50  := l_db_det_rec.pricing_attribute50;
    x_charges_detail_rec.pricing_attribute51  := l_db_det_rec.pricing_attribute51;
    x_charges_detail_rec.pricing_attribute52  := l_db_det_rec.pricing_attribute52;
    x_charges_detail_rec.pricing_attribute53  := l_db_det_rec.pricing_attribute53;
    x_charges_detail_rec.pricing_attribute54  := l_db_det_rec.pricing_attribute54;
    x_charges_detail_rec.pricing_attribute55  := l_db_det_rec.pricing_attribute55;
    x_charges_detail_rec.pricing_attribute56  := l_db_det_rec.pricing_attribute56;
    x_charges_detail_rec.pricing_attribute57  := l_db_det_rec.pricing_attribute57;
    x_charges_detail_rec.pricing_attribute58  := l_db_det_rec.pricing_attribute58;
    x_charges_detail_rec.pricing_attribute59  := l_db_det_rec.pricing_attribute59;
    x_charges_detail_rec.pricing_attribute60  := l_db_det_rec.pricing_attribute60;
    x_charges_detail_rec.pricing_attribute61  := l_db_det_rec.pricing_attribute61;
    x_charges_detail_rec.pricing_attribute62  := l_db_det_rec.pricing_attribute62;
    x_charges_detail_rec.pricing_attribute63  := l_db_det_rec.pricing_attribute63;
    x_charges_detail_rec.pricing_attribute64  := l_db_det_rec.pricing_attribute64;
    x_charges_detail_rec.pricing_attribute65  := l_db_det_rec.pricing_attribute65;
    x_charges_detail_rec.pricing_attribute66  := l_db_det_rec.pricing_attribute66;
    x_charges_detail_rec.pricing_attribute67  := l_db_det_rec.pricing_attribute67;
    x_charges_detail_rec.pricing_attribute68  := l_db_det_rec.pricing_attribute68;
    x_charges_detail_rec.pricing_attribute69  := l_db_det_rec.pricing_attribute69;
    x_charges_detail_rec.pricing_attribute70  := l_db_det_rec.pricing_attribute70;
    x_charges_detail_rec.pricing_attribute71  := l_db_det_rec.pricing_attribute71;
    x_charges_detail_rec.pricing_attribute72  := l_db_det_rec.pricing_attribute72;
    x_charges_detail_rec.pricing_attribute73  := l_db_det_rec.pricing_attribute73;
    x_charges_detail_rec.pricing_attribute74  := l_db_det_rec.pricing_attribute74;
    x_charges_detail_rec.pricing_attribute75  := l_db_det_rec.pricing_attribute75;
    x_charges_detail_rec.pricing_attribute76  := l_db_det_rec.pricing_attribute76;
    x_charges_detail_rec.pricing_attribute77  := l_db_det_rec.pricing_attribute77;
    x_charges_detail_rec.pricing_attribute78  := l_db_det_rec.pricing_attribute78;
    x_charges_detail_rec.pricing_attribute79  := l_db_det_rec.pricing_attribute79;
    x_charges_detail_rec.pricing_attribute80  := l_db_det_rec.pricing_attribute80;
    x_charges_detail_rec.pricing_attribute81  := l_db_det_rec.pricing_attribute81;
    x_charges_detail_rec.pricing_attribute82  := l_db_det_rec.pricing_attribute82;
    x_charges_detail_rec.pricing_attribute83  := l_db_det_rec.pricing_attribute83;
    x_charges_detail_rec.pricing_attribute84  := l_db_det_rec.pricing_attribute84;
    x_charges_detail_rec.pricing_attribute85  := l_db_det_rec.pricing_attribute85;
    x_charges_detail_rec.pricing_attribute86  := l_db_det_rec.pricing_attribute86;
    x_charges_detail_rec.pricing_attribute87  := l_db_det_rec.pricing_attribute87;
    x_charges_detail_rec.pricing_attribute88  := l_db_det_rec.pricing_attribute88;
    x_charges_detail_rec.pricing_attribute89  := l_db_det_rec.pricing_attribute89;
    x_charges_detail_rec.pricing_attribute90  := l_db_det_rec.pricing_attribute90;
    x_charges_detail_rec.pricing_attribute91  := l_db_det_rec.pricing_attribute91;
    x_charges_detail_rec.pricing_attribute92  := l_db_det_rec.pricing_attribute92;
    x_charges_detail_rec.pricing_attribute93  := l_db_det_rec.pricing_attribute93;
    x_charges_detail_rec.pricing_attribute94  := l_db_det_rec.pricing_attribute94;
    x_charges_detail_rec.pricing_attribute95  := l_db_det_rec.pricing_attribute95;
    x_charges_detail_rec.pricing_attribute96  := l_db_det_rec.pricing_attribute96;
    x_charges_detail_rec.pricing_attribute97  := l_db_det_rec.pricing_attribute97;
    x_charges_detail_rec.pricing_attribute98  := l_db_det_rec.pricing_attribute98;
    x_charges_detail_rec.pricing_attribute99  := l_db_det_rec.pricing_attribute99;
    x_charges_detail_rec.pricing_attribute100 := l_db_det_rec.pricing_attribute100;

 ELSIF p_charges_detail_rec.pricing_context IS NULL THEN

    --DBMS_OUTPUT.PUT_LINE('parameter context is null ');
    x_charges_detail_rec.pricing_context      := null ;
    x_charges_detail_rec.pricing_attribute1   := null ;
    x_charges_detail_rec.pricing_attribute2   := null ;
    x_charges_detail_rec.pricing_attribute3   := null ;
    x_charges_detail_rec.pricing_attribute4   := null ;
    x_charges_detail_rec.pricing_attribute5   := null ;
    x_charges_detail_rec.pricing_attribute6   := null ;
    x_charges_detail_rec.pricing_attribute7   := null ;
    x_charges_detail_rec.pricing_attribute8   := null ;
    x_charges_detail_rec.pricing_attribute9   := null ;
    x_charges_detail_rec.pricing_attribute10  := null ;
    x_charges_detail_rec.pricing_attribute11  := null ;
    x_charges_detail_rec.pricing_attribute12  := null ;
    x_charges_detail_rec.pricing_attribute13  := null ;
    x_charges_detail_rec.pricing_attribute14  := null ;
    x_charges_detail_rec.pricing_attribute15  := null ;
    x_charges_detail_rec.pricing_attribute16  := null ;
    x_charges_detail_rec.pricing_attribute17  := null ;
    x_charges_detail_rec.pricing_attribute18  := null ;
    x_charges_detail_rec.pricing_attribute19  := null ;
    x_charges_detail_rec.pricing_attribute20  := null ;
    x_charges_detail_rec.pricing_attribute21  := null ;
    x_charges_detail_rec.pricing_attribute22  := null ;
    x_charges_detail_rec.pricing_attribute23  := null ;
    x_charges_detail_rec.pricing_attribute24  := null ;
    x_charges_detail_rec.pricing_attribute25  := null ;
    x_charges_detail_rec.pricing_attribute26  := null ;
    x_charges_detail_rec.pricing_attribute27  := null ;
    x_charges_detail_rec.pricing_attribute28  := null ;
    x_charges_detail_rec.pricing_attribute29  := null ;
    x_charges_detail_rec.pricing_attribute30  := null ;
    x_charges_detail_rec.pricing_attribute31  := null ;
    x_charges_detail_rec.pricing_attribute32  := null ;
    x_charges_detail_rec.pricing_attribute33  := null ;
    x_charges_detail_rec.pricing_attribute34  := null ;
    x_charges_detail_rec.pricing_attribute35  := null ;
    x_charges_detail_rec.pricing_attribute36  := null ;
    x_charges_detail_rec.pricing_attribute37  := null ;
    x_charges_detail_rec.pricing_attribute38  := null ;
    x_charges_detail_rec.pricing_attribute39  := null ;
    x_charges_detail_rec.pricing_attribute40  := null ;
    x_charges_detail_rec.pricing_attribute41  := null ;
    x_charges_detail_rec.pricing_attribute42  := null ;
    x_charges_detail_rec.pricing_attribute43  := null ;
    x_charges_detail_rec.pricing_attribute44  := null ;
    x_charges_detail_rec.pricing_attribute45  := null ;
    x_charges_detail_rec.pricing_attribute46  := null ;
    x_charges_detail_rec.pricing_attribute47  := null ;
    x_charges_detail_rec.pricing_attribute48  := null ;
    x_charges_detail_rec.pricing_attribute49  := null ;
    x_charges_detail_rec.pricing_attribute50  := null ;
    x_charges_detail_rec.pricing_attribute51  := null ;
    x_charges_detail_rec.pricing_attribute52  := null ;
    x_charges_detail_rec.pricing_attribute53  := null ;
    x_charges_detail_rec.pricing_attribute54  := null ;
    x_charges_detail_rec.pricing_attribute55  := null ;
    x_charges_detail_rec.pricing_attribute56  := null ;
    x_charges_detail_rec.pricing_attribute57  := null ;
    x_charges_detail_rec.pricing_attribute58  := null ;
    x_charges_detail_rec.pricing_attribute59  := null ;
    x_charges_detail_rec.pricing_attribute59  := null ;
    x_charges_detail_rec.pricing_attribute60  := null ;
    x_charges_detail_rec.pricing_attribute61  := null ;
    x_charges_detail_rec.pricing_attribute62  := null ;
    x_charges_detail_rec.pricing_attribute63  := null ;
    x_charges_detail_rec.pricing_attribute64  := null ;
    x_charges_detail_rec.pricing_attribute65  := null ;
    x_charges_detail_rec.pricing_attribute66  := null ;
    x_charges_detail_rec.pricing_attribute67  := null ;
    x_charges_detail_rec.pricing_attribute68  := null ;
    x_charges_detail_rec.pricing_attribute69  := null ;
    x_charges_detail_rec.pricing_attribute70  := null ;
    x_charges_detail_rec.pricing_attribute71  := null ;
    x_charges_detail_rec.pricing_attribute72  := null ;
    x_charges_detail_rec.pricing_attribute73  := null ;
    x_charges_detail_rec.pricing_attribute74  := null ;
    x_charges_detail_rec.pricing_attribute75  := null ;
    x_charges_detail_rec.pricing_attribute76  := null ;
    x_charges_detail_rec.pricing_attribute77  := null ;
    x_charges_detail_rec.pricing_attribute78  := null ;
    x_charges_detail_rec.pricing_attribute79  := null ;
    x_charges_detail_rec.pricing_attribute80  := null ;
    x_charges_detail_rec.pricing_attribute81  := null ;
    x_charges_detail_rec.pricing_attribute82  := null ;
    x_charges_detail_rec.pricing_attribute83  := null ;
    x_charges_detail_rec.pricing_attribute84  := null ;
    x_charges_detail_rec.pricing_attribute85  := null ;
    x_charges_detail_rec.pricing_attribute86  := null ;
    x_charges_detail_rec.pricing_attribute87  := null ;
    x_charges_detail_rec.pricing_attribute88  := null ;
    x_charges_detail_rec.pricing_attribute89  := null ;
    x_charges_detail_rec.pricing_attribute90  := null ;
    x_charges_detail_rec.pricing_attribute91  := null ;
    x_charges_detail_rec.pricing_attribute92  := null ;
    x_charges_detail_rec.pricing_attribute93  := null ;
    x_charges_detail_rec.pricing_attribute94  := null ;
    x_charges_detail_rec.pricing_attribute95  := null ;
    x_charges_detail_rec.pricing_attribute96  := null ;
    x_charges_detail_rec.pricing_attribute97  := null ;
    x_charges_detail_rec.pricing_attribute98  := null ;
    x_charges_detail_rec.pricing_attribute99  := null ;
    x_charges_detail_rec.pricing_attribute100 := null ;

  ELSE

    -- the pricing context is not null
    -- copy the incoming parameters to the record structure
    -- --DBMS_OUTPUT.PUT_LINE('parameter context is not null ');

    x_charges_detail_rec.pricing_context     := p_charges_detail_rec.pricing_context ;

    IF p_charges_detail_rec.pricing_attribute1 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute1  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute1  := p_charges_detail_rec.pricing_attribute1;
    END IF;

    IF p_charges_detail_rec.pricing_attribute2 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute2  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute2  := p_charges_detail_rec.pricing_attribute2;
    END IF;

    IF p_charges_detail_rec.pricing_attribute3 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute3  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute3  := p_charges_detail_rec.pricing_attribute3;
    END IF;

    IF p_charges_detail_rec.pricing_attribute4 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute4  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute4  := p_charges_detail_rec.pricing_attribute4;
    END IF;

    IF p_charges_detail_rec.pricing_attribute5 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute5  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute5  := p_charges_detail_rec.pricing_attribute5;
    END IF;

     IF p_charges_detail_rec.pricing_attribute6 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute6  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute6  := p_charges_detail_rec.pricing_attribute6;
    END IF;

    IF p_charges_detail_rec.pricing_attribute7 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute7  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute7  := p_charges_detail_rec.pricing_attribute7;
    END IF;

    IF p_charges_detail_rec.pricing_attribute8 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute8  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute8  := p_charges_detail_rec.pricing_attribute8;
    END IF;

    IF p_charges_detail_rec.pricing_attribute9 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute9  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute9  := p_charges_detail_rec.pricing_attribute9;
    END IF;

    IF p_charges_detail_rec.pricing_attribute10 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute10  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute10 := p_charges_detail_rec.pricing_attribute10;
    END IF;

    IF p_charges_detail_rec.pricing_attribute11 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute11  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute11  := p_charges_detail_rec.pricing_attribute11;
    END IF;

    IF p_charges_detail_rec.pricing_attribute12 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute12  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute12  := p_charges_detail_rec.pricing_attribute12;
    END IF;

    IF p_charges_detail_rec.pricing_attribute13 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute13  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute13  := p_charges_detail_rec.pricing_attribute13;
    END IF;

    IF p_charges_detail_rec.pricing_attribute14 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute14  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute14  := p_charges_detail_rec.pricing_attribute14;
    END IF;

    IF p_charges_detail_rec.pricing_attribute15 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute15  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute15  := p_charges_detail_rec.pricing_attribute15;
    END IF;

    IF p_charges_detail_rec.pricing_attribute16 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute16  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute16  := p_charges_detail_rec.pricing_attribute16;
    END IF;

    IF p_charges_detail_rec.pricing_attribute17 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute17  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute17  := p_charges_detail_rec.pricing_attribute17;
    END IF;

    IF p_charges_detail_rec.pricing_attribute18 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute18  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute18  := p_charges_detail_rec.pricing_attribute18;
    END IF;

    IF p_charges_detail_rec.pricing_attribute19 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute19  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute19  := p_charges_detail_rec.pricing_attribute19;
    END IF;

    IF p_charges_detail_rec.pricing_attribute20 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute20  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute20  := p_charges_detail_rec.pricing_attribute20;
    END IF;

    IF p_charges_detail_rec.pricing_attribute21 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute21  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute21  := p_charges_detail_rec.pricing_attribute21;
    END IF;

    IF p_charges_detail_rec.pricing_attribute22 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute22  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute22  := p_charges_detail_rec.pricing_attribute22;
    END IF;


    IF p_charges_detail_rec.pricing_attribute23 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute23  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute23 := p_charges_detail_rec.pricing_attribute23;
    END IF;

    IF p_charges_detail_rec.pricing_attribute24 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute24  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute24  := p_charges_detail_rec.pricing_attribute24;
    END IF;

    IF p_charges_detail_rec.pricing_attribute25 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute25  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute25  := p_charges_detail_rec.pricing_attribute25;
    END IF;

    IF p_charges_detail_rec.pricing_attribute26 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute26  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute26  := p_charges_detail_rec.pricing_attribute26;
    END IF;

     IF p_charges_detail_rec.pricing_attribute27 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute27  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute27 := p_charges_detail_rec.pricing_attribute27;
    END IF;

    IF p_charges_detail_rec.pricing_attribute28 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute28 := null;
    ELSE
      x_charges_detail_rec.pricing_attribute28  := p_charges_detail_rec.pricing_attribute28;
    END IF;

    IF p_charges_detail_rec.pricing_attribute29 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute29  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute29  := p_charges_detail_rec.pricing_attribute29;
    END IF;

     IF p_charges_detail_rec.pricing_attribute30 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute30  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute30  := p_charges_detail_rec.pricing_attribute30;
    END IF;

    IF p_charges_detail_rec.pricing_attribute31 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute31  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute31  := p_charges_detail_rec.pricing_attribute31;
    END IF;

    IF p_charges_detail_rec.pricing_attribute32 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute32  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute32  := p_charges_detail_rec.pricing_attribute32;
    END IF;

    IF p_charges_detail_rec.pricing_attribute33 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute33  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute33  := p_charges_detail_rec.pricing_attribute33;
    END IF;

    IF p_charges_detail_rec.pricing_attribute34 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute34  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute34  := p_charges_detail_rec.pricing_attribute34;
    END IF;

    IF p_charges_detail_rec.pricing_attribute35 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute35  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute35  := p_charges_detail_rec.pricing_attribute35;
    END IF;

    IF p_charges_detail_rec.pricing_attribute36 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute36  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute36  := p_charges_detail_rec.pricing_attribute36;
    END IF;

    IF p_charges_detail_rec.pricing_attribute37 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute37  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute37  := p_charges_detail_rec.pricing_attribute37;
    END IF;

    IF p_charges_detail_rec.pricing_attribute38 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute38  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute38  := p_charges_detail_rec.pricing_attribute38;
    END IF;

    IF p_charges_detail_rec.pricing_attribute39 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute39  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute39  := p_charges_detail_rec.pricing_attribute39;
    END IF;

    IF p_charges_detail_rec.pricing_attribute40 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute40  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute40  := p_charges_detail_rec.pricing_attribute40;
    END IF;

    IF p_charges_detail_rec.pricing_attribute41 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute41  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute41 := p_charges_detail_rec.pricing_attribute41;
    END IF;

     IF p_charges_detail_rec.pricing_attribute42 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute42  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute42  := p_charges_detail_rec.pricing_attribute42;
    END IF;

    IF p_charges_detail_rec.pricing_attribute43 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute43  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute43  := p_charges_detail_rec.pricing_attribute43;
    END IF;

    IF p_charges_detail_rec.pricing_attribute44 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute44  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute44  := p_charges_detail_rec.pricing_attribute44;
    END IF;

     IF p_charges_detail_rec.pricing_attribute45 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute45  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute45  := p_charges_detail_rec.pricing_attribute45;
    END IF;

    IF p_charges_detail_rec.pricing_attribute46 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute46  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute46  := p_charges_detail_rec.pricing_attribute46;
    END IF;

    IF p_charges_detail_rec.pricing_attribute47 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute47  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute47  := p_charges_detail_rec.pricing_attribute47;
    END IF;

    IF p_charges_detail_rec.pricing_attribute48 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute48  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute48  := p_charges_detail_rec.pricing_attribute48;
    END IF;

    IF p_charges_detail_rec.pricing_attribute49 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute49 := null;
    ELSE
      x_charges_detail_rec.pricing_attribute49  := p_charges_detail_rec.pricing_attribute49;
    END IF;

    IF p_charges_detail_rec.pricing_attribute50 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute50  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute50  := p_charges_detail_rec.pricing_attribute50;
    END IF;

    IF p_charges_detail_rec.pricing_attribute51 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute51  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute51  := p_charges_detail_rec.pricing_attribute51;
    END IF;

     IF p_charges_detail_rec.pricing_attribute52 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute52  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute52  := p_charges_detail_rec.pricing_attribute52;
    END IF;

    IF p_charges_detail_rec.pricing_attribute53 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute53  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute53  := p_charges_detail_rec.pricing_attribute53;
    END IF;

    IF p_charges_detail_rec.pricing_attribute54 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute54  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute54  := p_charges_detail_rec.pricing_attribute54;
    END IF;

    IF p_charges_detail_rec.pricing_attribute55 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute55  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute55  := p_charges_detail_rec.pricing_attribute55;
    END IF;

    IF p_charges_detail_rec.pricing_attribute56 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute56  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute56  := p_charges_detail_rec.pricing_attribute56;
    END IF;

    IF p_charges_detail_rec.pricing_attribute57 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute57  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute57  := p_charges_detail_rec.pricing_attribute57;
    END IF;

    IF p_charges_detail_rec.pricing_attribute58 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute58  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute58  := p_charges_detail_rec.pricing_attribute58;
    END IF;

    IF p_charges_detail_rec.pricing_attribute59 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute59  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute59  := p_charges_detail_rec.pricing_attribute59;
    END IF;

    IF p_charges_detail_rec.pricing_attribute60 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute60  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute60  := p_charges_detail_rec.pricing_attribute60;
    END IF;

    IF p_charges_detail_rec.pricing_attribute61 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute61  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute61  := p_charges_detail_rec.pricing_attribute61;
    END IF;

    IF p_charges_detail_rec.pricing_attribute62 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute62  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute62  := p_charges_detail_rec.pricing_attribute62;
    END IF;

    IF p_charges_detail_rec.pricing_attribute63 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute63  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute63  := p_charges_detail_rec.pricing_attribute63;
    END IF;

    IF p_charges_detail_rec.pricing_attribute64 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute64  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute64  := p_charges_detail_rec.pricing_attribute64;
    END IF;

    IF p_charges_detail_rec.pricing_attribute65 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute65  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute65  := p_charges_detail_rec.pricing_attribute65;
    END IF;

    IF p_charges_detail_rec.pricing_attribute66 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute66  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute66  := p_charges_detail_rec.pricing_attribute66;
    END IF;

    IF p_charges_detail_rec.pricing_attribute67 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute67  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute67  := p_charges_detail_rec.pricing_attribute67;
    END IF;

    IF p_charges_detail_rec.pricing_attribute68 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute68  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute68  := p_charges_detail_rec.pricing_attribute68;
    END IF;

    IF p_charges_detail_rec.pricing_attribute69 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute69  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute69  := p_charges_detail_rec.pricing_attribute69;
    END IF;

    IF p_charges_detail_rec.pricing_attribute70 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute70  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute70  := p_charges_detail_rec.pricing_attribute70;
    END IF;

    IF p_charges_detail_rec.pricing_attribute71 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute71  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute71 := p_charges_detail_rec.pricing_attribute71;
    END IF;

    IF p_charges_detail_rec.pricing_attribute72 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute72  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute72  := p_charges_detail_rec.pricing_attribute72;
    END IF;

    IF p_charges_detail_rec.pricing_attribute73 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute73  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute73  := p_charges_detail_rec.pricing_attribute73;
    END IF;

    IF p_charges_detail_rec.pricing_attribute74 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute74  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute74  := p_charges_detail_rec.pricing_attribute74;
    END IF;

    IF p_charges_detail_rec.pricing_attribute75 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute75  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute75  := p_charges_detail_rec.pricing_attribute75;
    END IF;

    IF p_charges_detail_rec.pricing_attribute76 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute76  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute76  := p_charges_detail_rec.pricing_attribute76;
    END IF;

     IF p_charges_detail_rec.pricing_attribute77 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute77  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute77  := p_charges_detail_rec.pricing_attribute77;
    END IF;

    IF p_charges_detail_rec.pricing_attribute78 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute78  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute78  := p_charges_detail_rec.pricing_attribute78;
    END IF;

    IF p_charges_detail_rec.pricing_attribute79 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute79  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute79  := p_charges_detail_rec.pricing_attribute79;
    END IF;

      IF p_charges_detail_rec.pricing_attribute80 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute80  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute80  := p_charges_detail_rec.pricing_attribute80;
    END IF;

    IF p_charges_detail_rec.pricing_attribute81 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute81  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute81  := p_charges_detail_rec.pricing_attribute81;
    END IF;

    IF p_charges_detail_rec.pricing_attribute82 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute82  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute82  := p_charges_detail_rec.pricing_attribute82;
    END IF;

    IF p_charges_detail_rec.pricing_attribute83 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute83  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute83  := p_charges_detail_rec.pricing_attribute83;
    END IF;

    IF p_charges_detail_rec.pricing_attribute84 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute84  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute84  := p_charges_detail_rec.pricing_attribute84;
    END IF;

    IF p_charges_detail_rec.pricing_attribute85 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute85 := null;
    ELSE
      x_charges_detail_rec.pricing_attribute85  := p_charges_detail_rec.pricing_attribute85;
    END IF;

    IF p_charges_detail_rec.pricing_attribute86 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute86  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute86  := p_charges_detail_rec.pricing_attribute86;
    END IF;

    IF p_charges_detail_rec.pricing_attribute87 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute87  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute87  := p_charges_detail_rec.pricing_attribute87;
    END IF;

    IF p_charges_detail_rec.pricing_attribute88 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute88  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute88  := p_charges_detail_rec.pricing_attribute88;
    END IF;

    IF p_charges_detail_rec.pricing_attribute89 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute89  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute89  := p_charges_detail_rec.pricing_attribute89;
    END IF;

    IF p_charges_detail_rec.pricing_attribute90 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute90  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute90  := p_charges_detail_rec.pricing_attribute90;
    END IF;

    IF p_charges_detail_rec.pricing_attribute91 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute91  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute91  := p_charges_detail_rec.pricing_attribute91;
    END IF;

    IF p_charges_detail_rec.pricing_attribute92 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute92  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute92  := p_charges_detail_rec.pricing_attribute92;
    END IF;

    IF p_charges_detail_rec.pricing_attribute93 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute93  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute93  := p_charges_detail_rec.pricing_attribute93;
    END IF;

    IF p_charges_detail_rec.pricing_attribute94 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute94  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute94  := p_charges_detail_rec.pricing_attribute94;
    END IF;

    IF p_charges_detail_rec.pricing_attribute95 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute95  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute95  := p_charges_detail_rec.pricing_attribute95;
    END IF;

    IF p_charges_detail_rec.pricing_attribute96 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute96  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute96  := p_charges_detail_rec.pricing_attribute96;
    END IF;

    IF p_charges_detail_rec.pricing_attribute97 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute97  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute97  := p_charges_detail_rec.pricing_attribute97;
    END IF;

     IF p_charges_detail_rec.pricing_attribute98 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute98  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute98  := p_charges_detail_rec.pricing_attribute98;
    END IF;

    IF p_charges_detail_rec.pricing_attribute99 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute99  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute99  := p_charges_detail_rec.pricing_attribute99;
    END IF;

    IF p_charges_detail_rec.pricing_attribute100 = FND_API.G_MISS_CHAR THEN
      x_charges_detail_rec.pricing_attribute100  := null;
    ELSE
      x_charges_detail_rec.pricing_attribute100  := p_charges_detail_rec.pricing_attribute100;
    END IF;

  END IF;

END IF;
-- ========================================
-- Call the pricing API
-- ========================================
--DBMS_OUTPUT.PUT_LINE('Call the pricing API ...');
--DBMS_OUTPUT.PUT_LINE('Billing Flag '||x_charges_detail_rec.billing_flag);
--DBMS_OUTPUT.PUT_LINE('List Price '||p_charges_detail_rec.list_price);
--DBMS_OUTPUT.PUT_LINE('After Warranty_cost '||p_charges_detail_rec.after_warranty_cost);

IF p_validation_mode = 'I' THEN

  x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;

  IF x_charges_detail_rec.billing_flag = 'L' AND
     p_charges_detail_rec.list_price IS NOT NULL THEN

      -- no need to call the pricing api
      -- assign to out record
      x_charges_detail_rec.list_price    := p_charges_detail_rec.list_price;
      x_charges_detail_rec.selling_price := p_charges_detail_rec.list_price;

      --bug # 3056622 charge amount is zero for items with negative prices

      --derive the after_warranty_cost
      IF x_charges_detail_rec.no_charge_flag <> 'Y' AND
         x_charges_detail_rec.selling_price IS NOT NULL THEN

         --Fix for Bug # 3388373
         IF p_charges_detail_rec.after_warranty_cost IS NULL THEN
           x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.selling_price * x_charges_detail_rec.quantity_required;
         ELSE
           x_charges_detail_rec.after_warranty_cost := p_charges_detail_rec.after_warranty_cost;
         END IF;
      ELSE
        -- no charge flag = 'Y'
        x_charges_detail_rec.after_warranty_cost := 0;
      END IF;

      --check to see if contract discount needs to be applied
      IF x_charges_detail_rec.apply_contract_discount = 'Y' AND
         x_charges_detail_rec.contract_line_id IS NOT NULL AND
         x_charges_detail_rec.no_charge_flag <> 'Y' THEN

        --assign to out record
        x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;

        --call contracts dicounting API
        --DBMS_OUTPUT.PUT_LINE('Call Contracts API to Apply contracts 1');

        CS_Est_Apply_Contract_PKG.Apply_Contract(
          p_coverage_id           => x_charges_detail_rec.contract_line_id,
          p_coverage_txn_group_id => x_charges_detail_rec.coverage_txn_group_id,
          p_txn_billing_type_id   => x_charges_detail_rec.txn_billing_type_id,
          P_BUSINESS_PROCESS_ID   => x_charges_detail_rec.business_process_id,
          P_REQUEST_DATE          => l_request_date,
          p_amount                => x_charges_detail_rec.after_warranty_cost,
          p_discount_amount       => l_contract_discount,
          X_RETURN_STATUS         => l_return_status,
          X_MSG_COUNT             => l_msg_count,
          X_MSG_DATA              => l_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.Set_Name('CS', 'CS_CHG_APPLY_CONTRACT_WARNING');
          FND_MESSAGE.SET_TOKEN('REASON', l_msg_data);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --Bug Fix for Bug # 3088397
        IF l_contract_discount IS NOT NULL THEN
          --assign the contract discount to the out record
          x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.after_warranty_cost - l_contract_discount;

          --apply discount
          x_charges_detail_rec.after_warranty_cost :=  l_contract_discount;
        ELSE
          -- contract discount amt should be 0
          --x_charges_detail_rec.contract_discount_amount := 0;
          null;
        END IF;

       --DBMS_OUTPUT.PUT_LINE('Contract 1'||x_charges_detail_rec.contract_discount_amount);


      ELSE
        --Apply contract discount = 'N'
        --Fixed Bug # 3220253
        --passed p_charges_detail_rec.contract_discount_amount
        x_charges_detail_rec.apply_contract_discount  := p_charges_detail_rec.apply_contract_discount;
        x_charges_detail_rec.contract_discount_amount := p_charges_detail_rec.contract_discount_amount;
        IF x_charges_detail_rec.contract_discount_amount IS NULL THEN
          x_charges_detail_rec.contract_discount_amount := 0;
        ELSE
          x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.contract_discount_amount;
        END IF;
      END IF ;

  ELSIF
     --Fix # 3069583 unable to override charges for labor charge line

     --x_charges_detail_rec.billing_flag <> 'E' AND
     --x_charges_detail_rec.billing_flag <> 'M' OR
     x_charges_detail_rec.billing_flag IN ('E','M', 'L') AND
     p_charges_detail_rec.after_warranty_cost IS NULL AND
     p_charges_detail_rec.list_price IS NULL THEN


    IF ((((x_charges_detail_rec.inventory_item_id_in IS NOT NULL) AND
          (x_charges_detail_rec.unit_of_measure_code IS NOT NULL) AND
          (x_charges_detail_rec.price_list_id IS NOT NULL) AND
          (x_charges_detail_rec.quantity_required IS NOT NULL)))) THEN

      --DBMS_OUTPUT.PUT_LINE('Before calling CS_Pricing_Item_Pkg.Call_Pricing_Item ...');
      --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.inventory_item_id_in='||x_charges_detail_rec.inventory_item_id_in);
      --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.price_list_id='||x_charges_detail_rec.price_list_id);
      --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.unit_of_measure_code='||x_charges_detail_rec.unit_of_measure_code);
      --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.currency_code='||x_charges_detail_rec.currency_code);
      --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.quantity_required='||x_charges_detail_rec.quantity_required);

      -- Added to fix Bug # 3819167
      --
      /*
      IF ((l_line_order_category_code = 'RETURN') AND
          (sign(x_charges_detail_rec.quantity_required) = -1)) THEN
          l_absolute_quantity_required := x_charges_detail_rec.quantity_required * -1;
      ELSE
          l_absolute_quantity_required := x_charges_detail_rec.quantity_required;
      END IF;
      */
        -- Bug 7117553
      l_profile_value := fnd_profile.value('CS_SR_CHG_PRIC_DATE');
      If l_profile_value = 'CHG_INC_DATE' Then
        l_pricing_date := l_incident_date;
      Else
	l_pricing_date := sysdate;
      End if;
      -- Bug 7117553


      -- Calculate the selling price
      CS_Pricing_Item_Pkg.Call_Pricing_Item(
            P_Inventory_Item_Id          => x_charges_detail_rec.inventory_item_id_in,
            P_Price_List_Id              => x_charges_detail_rec.price_list_id,
            P_UOM_Code                   => x_charges_detail_rec.unit_of_measure_code,
            p_Currency_Code              => x_charges_detail_rec.currency_code,
            P_Quantity                   => abs(x_charges_detail_rec.quantity_required),
	    P_incident_date	         => l_pricing_date,   -- Bug 7117553
            P_Org_Id                     => x_charges_detail_rec.org_id,
            x_list_price                 => l_list_price,
            P_Pricing_Context            => x_charges_detail_rec.pricing_context,
            P_Pricing_Attribute1         => x_charges_detail_rec.pricing_attribute1,
            P_Pricing_Attribute2         => x_charges_detail_rec.pricing_attribute2,
            P_Pricing_Attribute3         => x_charges_detail_rec.pricing_attribute3,
            P_Pricing_Attribute4         => x_charges_detail_rec.pricing_attribute4,
            P_Pricing_Attribute5         => x_charges_detail_rec.pricing_attribute5,
            P_Pricing_Attribute6         => x_charges_detail_rec.pricing_attribute6,
            P_Pricing_Attribute7         => x_charges_detail_rec.pricing_attribute7,
            P_Pricing_Attribute8         => x_charges_detail_rec.pricing_attribute8,
            P_Pricing_Attribute9         => x_charges_detail_rec.pricing_attribute9,
            P_Pricing_Attribute10        => x_charges_detail_rec.pricing_attribute10,
            P_Pricing_Attribute11        => x_charges_detail_rec.pricing_attribute11,
            P_Pricing_Attribute12        => x_charges_detail_rec.pricing_attribute12,
            P_Pricing_Attribute13        => x_charges_detail_rec.pricing_attribute13,
            P_Pricing_Attribute14        => x_charges_detail_rec.pricing_attribute14,
            P_Pricing_Attribute15        => x_charges_detail_rec.pricing_attribute15,
            P_Pricing_Attribute16        => x_charges_detail_rec.pricing_attribute16,
            P_Pricing_Attribute17        => x_charges_detail_rec.pricing_attribute17,
            P_Pricing_Attribute18        => x_charges_detail_rec.pricing_attribute18,
            P_Pricing_Attribute19        => x_charges_detail_rec.pricing_attribute19,
            P_Pricing_Attribute20        => x_charges_detail_rec.pricing_attribute20,
            P_Pricing_Attribute21        => x_charges_detail_rec.pricing_attribute21,
            P_Pricing_Attribute22        => x_charges_detail_rec.pricing_attribute22,
            P_Pricing_Attribute23        => x_charges_detail_rec.pricing_attribute23,
            P_Pricing_Attribute24        => x_charges_detail_rec.pricing_attribute24,
            P_Pricing_Attribute25        => x_charges_detail_rec.pricing_attribute25,
            p_Pricing_Attribute26        => x_charges_detail_rec.pricing_attribute26,
            P_Pricing_Attribute27        => x_charges_detail_rec.pricing_attribute27,
            P_Pricing_Attribute28        => x_charges_detail_rec.pricing_attribute28,
            P_Pricing_Attribute29        => x_charges_detail_rec.pricing_attribute29,
            P_Pricing_Attribute30        => x_charges_detail_rec.pricing_attribute30,
            P_PRICING_ATTRIBUTE31        => x_charges_detail_rec.pricing_attribute31,
            P_PRICING_ATTRIBUTE32        => x_charges_detail_rec.pricing_attribute32,
            P_PRICING_ATTRIBUTE33        => x_charges_detail_rec.pricing_attribute33,
            P_PRICING_ATTRIBUTE34        => x_charges_detail_rec.pricing_attribute34,
            P_Pricing_Attribute35        => x_charges_detail_rec.pricing_attribute35,
            P_Pricing_Attribute36        => x_charges_detail_rec.pricing_attribute36,
            P_Pricing_Attribute37        => x_charges_detail_rec.pricing_attribute37,
            P_Pricing_Attribute38        => x_charges_detail_rec.pricing_attribute38,
            P_Pricing_Attribute39        => x_charges_detail_rec.pricing_attribute39,
            P_Pricing_Attribute40        => x_charges_detail_rec.pricing_attribute40,
            P_Pricing_Attribute41        => x_charges_detail_rec.pricing_attribute41,
            P_Pricing_Attribute42        => x_charges_detail_rec.pricing_attribute42,
            P_Pricing_Attribute43        => x_charges_detail_rec.pricing_attribute43,
            P_Pricing_Attribute44        => x_charges_detail_rec.pricing_attribute44,
            P_Pricing_Attribute45        => x_charges_detail_rec.pricing_attribute45,
            P_Pricing_Attribute46        => x_charges_detail_rec.pricing_attribute46,
            P_Pricing_Attribute47        => x_charges_detail_rec.pricing_attribute47,
            P_Pricing_Attribute48        => x_charges_detail_rec.pricing_attribute48,
            P_Pricing_Attribute49        => x_charges_detail_rec.pricing_attribute49,
            P_Pricing_Attribute50        => x_charges_detail_rec.pricing_attribute50,
            P_Pricing_Attribute51        => x_charges_detail_rec.pricing_attribute51,
            P_Pricing_Attribute52        => x_charges_detail_rec.pricing_attribute52,
            P_Pricing_Attribute53        => x_charges_detail_rec.pricing_attribute53,
            P_Pricing_Attribute54        => x_charges_detail_rec.pricing_attribute54,
            P_Pricing_Attribute55        => x_charges_detail_rec.pricing_attribute55,
            P_Pricing_Attribute56        => x_charges_detail_rec.pricing_attribute56,
            P_Pricing_Attribute57        => x_charges_detail_rec.pricing_attribute57,
            P_Pricing_Attribute58        => x_charges_detail_rec.pricing_attribute58,
            P_Pricing_Attribute59        => x_charges_detail_rec.pricing_attribute59,
            P_Pricing_Attribute60        => x_charges_detail_rec.pricing_attribute60,
            P_Pricing_Attribute61        => x_charges_detail_rec.pricing_attribute61,
            P_Pricing_Attribute62        => x_charges_detail_rec.pricing_attribute62,
            P_Pricing_Attribute63        => x_charges_detail_rec.pricing_attribute63,
            P_Pricing_Attribute64        => x_charges_detail_rec.pricing_attribute64,
            P_Pricing_Attribute65        => x_charges_detail_rec.pricing_attribute65,
            P_Pricing_Attribute66        => x_charges_detail_rec.pricing_attribute66,
            P_Pricing_Attribute67        => x_charges_detail_rec.pricing_attribute67,
            P_Pricing_Attribute68        => x_charges_detail_rec.pricing_attribute68,
            P_Pricing_Attribute69        => x_charges_detail_rec.pricing_attribute69,
            P_Pricing_Attribute70        => x_charges_detail_rec.pricing_attribute70,
            P_Pricing_Attribute71        => x_charges_detail_rec.pricing_attribute71,
            P_Pricing_Attribute72        => x_charges_detail_rec.pricing_attribute72,
            P_Pricing_Attribute73        => x_charges_detail_rec.pricing_attribute73,
            P_Pricing_Attribute74        => x_charges_detail_rec.pricing_attribute74,
            P_Pricing_Attribute75        => x_charges_detail_rec.pricing_attribute75,
            P_Pricing_Attribute76        => x_charges_detail_rec.pricing_attribute76,
            P_Pricing_Attribute77        => x_charges_detail_rec.pricing_attribute77,
            P_Pricing_Attribute78        => x_charges_detail_rec.pricing_attribute78,
            P_Pricing_Attribute79        => x_charges_detail_rec.pricing_attribute79,
            P_Pricing_Attribute80        => x_charges_detail_rec.pricing_attribute80,
            P_Pricing_Attribute81        => x_charges_detail_rec.pricing_attribute81,
            P_Pricing_Attribute82        => x_charges_detail_rec.pricing_attribute82,
            P_Pricing_Attribute83        => x_charges_detail_rec.pricing_attribute83,
            P_Pricing_Attribute84        => x_charges_detail_rec.pricing_attribute84,
            P_Pricing_Attribute85        => x_charges_detail_rec.pricing_attribute85,
            P_Pricing_Attribute86        => x_charges_detail_rec.pricing_attribute86,
            P_Pricing_Attribute87        => x_charges_detail_rec.pricing_attribute87,
            P_Pricing_Attribute88        => x_charges_detail_rec.pricing_attribute88,
            P_Pricing_Attribute89        => x_charges_detail_rec.pricing_attribute89,
            P_Pricing_Attribute90        => x_charges_detail_rec.pricing_attribute90,
            P_Pricing_Attribute91        => x_charges_detail_rec.pricing_attribute91,
            P_Pricing_Attribute92        => x_charges_detail_rec.pricing_attribute92,
            P_Pricing_Attribute93        => x_charges_detail_rec.pricing_attribute93,
            P_Pricing_Attribute94        => x_charges_detail_rec.pricing_attribute94,
            P_Pricing_Attribute95        => x_charges_detail_rec.pricing_attribute95,
            P_Pricing_Attribute96        => x_charges_detail_rec.pricing_attribute96,
            P_Pricing_Attribute97        => x_charges_detail_rec.pricing_attribute97,
            P_Pricing_Attribute98        => x_charges_detail_rec.pricing_attribute98,
            P_Pricing_Attribute99        => x_charges_detail_rec.pricing_attribute99,
            P_Pricing_Attribute100       => x_charges_detail_rec.pricing_attribute100,
            x_return_status              => l_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data);

      --DBMS_OUTPUT.PUT_LINE('After calling CS_Pricing_Item_Pkg.Call_Pricing_Item ...');
      --DBMS_OUTPUT.PUT_LINE('l_msg_data '||l_msg_data);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_API_PRICING_ITEM_ERROR');
        FND_MESSAGE.set_token('INV_ID', x_charges_detail_rec.inventory_item_id_in);
        FND_MESSAGE.set_token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
        FND_MESSAGE.set_token('UOM', x_charges_detail_rec.unit_of_measure_code);
        FND_MESSAGE.set_token('CURR_CODE', x_charges_detail_rec.currency_code);
        --FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data, TRUE);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --assign to out record
      x_charges_detail_rec.list_price    := l_list_price;

      --bug # 3056622 charge amount is zero for items with negative prices

      IF p_charges_detail_rec.selling_price IS NOT NULL THEN
        x_charges_detail_rec.selling_price :=  p_charges_detail_rec.selling_price;
      ELSE
        x_charges_detail_rec.selling_price := x_charges_detail_rec.list_price;
      END IF;


      IF x_charges_detail_rec.billing_flag = 'L' AND
         p_charges_detail_rec.con_pct_over_list_price IS NOT NULL THEN

         --get the new list price and selling price
         x_charges_detail_rec.list_price := x_charges_detail_rec.list_price +
                                               (x_charges_detail_rec.list_price *  p_charges_detail_rec.con_pct_over_list_price/100);

         x_charges_detail_rec.selling_price := x_charges_detail_rec.list_price;
      ELSE
         x_charges_detail_rec.list_price    := x_charges_detail_rec.list_price;
         x_charges_detail_rec.selling_price := x_charges_detail_rec.selling_price;
      END IF;


      --DBMS_OUTPUT.PUT_LINE('list_price '||x_charges_detail_rec.list_price);
      --DBMS_OUTPUT.PUT_LINE('Selling Price '||x_charges_detail_rec.selling_price);
      --DBMS_OUTPUT.PUT_LINE(' No Charge Flag is  '||x_charges_detail_rec.no_charge_flag);
      --DBMS_OUTPUT.PUT_LINE(' Conversion needed flag '||l_conversion_needed_flag);

      --bug # 3056622 charge amount is zero for items with negative prices

      IF x_charges_detail_rec.no_charge_flag <> 'Y' AND x_charges_detail_rec.selling_price IS NOT NULL THEN
        IF l_conversion_needed_flag = 'Y' THEN
          IF p_charges_detail_rec.selling_price IS NOT NULL THEN
            x_charges_detail_rec.selling_price := x_charges_detail_rec.selling_price * x_charges_detail_rec.conversion_rate;
            x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.selling_price * x_charges_detail_rec.quantity_required;
          ELSE
            x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.selling_price * x_charges_detail_rec.quantity_required * x_charges_detail_rec.conversion_rate;
          END IF;
        ELSE
          x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.selling_price * x_charges_detail_rec.quantity_required;
        END IF;
      ELSE
        -- no charge flag = 'Y'
        x_charges_detail_rec.after_warranty_cost := 0;
      END IF;

      --DBMS_OUTPUT.PUT_LINE(' after warr cost is '|| x_charges_detail_rec.after_warranty_cost);


      --check to see if contract discount needs to be applied

      --DBMS_OUTPUT.PUT_LINE('apply contract discount '|| x_charges_detail_rec.apply_contract_discount);
      --DBMS_OUTPUT.PUT_LINE('contract_id '||x_charges_detail_rec.contract_id);
      --DBMS_OUTPUT.PUT_LINE('coverage_id '||x_charges_detail_rec.coverage_id);

      IF x_charges_detail_rec.apply_contract_discount = 'Y' AND
         x_charges_detail_rec.no_charge_flag <> 'Y' AND
         x_charges_detail_rec.contract_line_id IS NOT NULL THEN

        --assign to out record
        x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;

        --DBMS_OUTPUT.PUT_LINE('calling get_contract_line_id');

        --DBMS_OUTPUT.PUT_LINE('after calling get_contract_line_id');
        --call contracts dicounting API
        --DBMS_OUTPUT.PUT_LINE('Call Contracts API to Apply contracts 2');

        CS_Est_Apply_Contract_PKG.Apply_Contract(
          p_coverage_id           => x_charges_detail_rec.contract_line_id,
          p_coverage_txn_group_id => x_charges_detail_rec.coverage_txn_group_id,
          p_txn_billing_type_id   => x_charges_detail_rec.txn_billing_type_id,
          P_BUSINESS_PROCESS_ID   => x_charges_detail_rec.business_process_id,
          P_REQUEST_DATE          => l_request_date,
          p_amount                => x_charges_detail_rec.after_warranty_cost,
          p_discount_amount       => l_contract_discount,
          X_RETURN_STATUS         => l_return_status,
          X_MSG_COUNT             => l_msg_count,
          X_MSG_DATA              => l_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.Set_Name('CS', 'CS_CHG_APPLY_CONTRACT_WARNING');
          FND_MESSAGE.SET_TOKEN('REASON', l_msg_data);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --Bug Fix for Bug # 3088397
        IF l_contract_discount IS NOT NULL THEN
          --assign the contract discount to the out record
          x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.after_warranty_cost - l_contract_discount;

          --apply discount
          x_charges_detail_rec.after_warranty_cost := l_contract_discount;

        ELSE
          -- contract discount amt should be 0
          --x_charges_detail_rec.contract_discount_amount := 0;
          null;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('l_contract_discount'||l_contract_discount);
        --DBMS_OUTPUT.PUT_LINE('Contract 2'||x_charges_detail_rec.contract_discount_amount);

      ELSE
        --Apply contract discount = 'N'
        --Fixed Bug # 3220253
        --passed p_charges_detail_rec.contract_discount_amount
        x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;
        x_charges_detail_rec.contract_discount_amount := p_charges_detail_rec.contract_discount_amount;

        IF x_charges_detail_rec.contract_discount_amount IS NULL THEN
          x_charges_detail_rec.contract_discount_amount := 0;
        ELSE
          x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.contract_discount_amount;
        END IF;

      END IF ;


    ELSE
      --x_charges_detail_rec.inventory_item_id_in IS NULL
      --x_charges_detail_rec.unit_of_measure_code IS NULL
      --x_charges_detail_rec.price_list_id IS NULL
      --x_charges_detail_rec.quantity_required IS NULL
      --the list price cannot be derived and the
      --after warranty cost cannot be computed
      --assign 0 to list_price and after_warranty_cost
      x_charges_detail_rec.list_price := 0;
      x_charges_detail_rec.selling_price := 0;
      x_charges_detail_rec.after_warranty_cost := 0;
      x_charges_detail_rec.contract_discount_amount := 0;

    END IF;

  --Added to fix bug # 3217757
  --debriefed expense line not displaying correct amount

  ELSIF x_charges_detail_rec.billing_flag = 'E' AND
        x_charges_detail_rec.source_code = 'SD' AND
        p_charges_detail_rec.after_warranty_cost IS NOT NULL THEN
        --DBMS_OUTPUT.PUT_LINE('Expense line with after warr cost ');
 /* Start Bug 6960562 */
    IF l_line_order_category_code = 'RETURN' THEN
        x_charges_detail_rec.after_warranty_cost := p_charges_detail_rec.after_warranty_cost * x_charges_detail_rec.quantity_required;
    ELSE
    -- Assign the after warranty that comes on the line
        x_charges_detail_rec.after_warranty_cost := p_charges_detail_rec.after_warranty_cost;
    END IF;
  /* End Bug 6960562 */

    x_charges_detail_rec.list_price := p_charges_detail_rec.after_warranty_cost;

    IF l_conversion_needed_flag = 'Y' THEN
      --assign coverted amt to after_list_price
      x_charges_detail_rec.list_price := x_charges_detail_rec.list_price * x_charges_detail_rec.conversion_rate;

      --bug # 3056600 charge amount is zero for items with negative prices

      IF p_charges_detail_rec.selling_price IS NOT NULL THEN
        x_charges_detail_rec.selling_price :=  p_charges_detail_rec.selling_price * x_charges_detail_rec.conversion_rate;
      ELSE
        x_charges_detail_rec.selling_price :=  x_charges_detail_rec.list_price;
      END IF;

      -- Fixed second issue in Bug 3468146
      -- If the line originates from SD and has a after_warranty_cost
      -- but the no_charge_flag = 'Y' then make after_warranty_cost = 0

      IF x_charges_detail_rec.no_charge_flag = 'Y' THEN
         x_charges_detail_rec.after_warranty_cost := 0;
      ELSE
         x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.after_warranty_cost * x_charges_detail_rec.conversion_rate;
      END IF;

    ELSE
      --l_conversion_needed_flag = 'N'
      --bug # 3056600 charge amount is zero for items with negative prices
      IF p_charges_detail_rec.selling_price IS NOT NULL THEN
        x_charges_detail_rec.selling_price :=  p_charges_detail_rec.selling_price;
      ELSE
        x_charges_detail_rec.selling_price :=  x_charges_detail_rec.list_price;
      END IF;

      -- Fixed second issue in Bug 3468146
      -- If the line originates from SD and has a after_warranty_cost
      -- but the no_charge_flag = 'Y' then make after_warranty_cost = 0
      IF x_charges_detail_rec.no_charge_flag = 'Y' THEN
         x_charges_detail_rec.after_warranty_cost := 0;
      END IF;
    END IF;

    --Fixed Bug # 3468146
    --need to do this here so that contract discounting is done correctly
    --re-set the no_charge_flag for Charge Lines
    --since the line has come with after warranty cost from upstream
    IF x_charges_detail_rec.after_warranty_cost <> 0 THEN
      x_charges_detail_rec.no_charge_flag := 'N';
    END IF;


    --DBMS_OUTPUT.PUT_LINE('re-setting the no_charge_flag' ||x_charges_detail_rec.no_charge_flag);

    IF x_charges_detail_rec.apply_contract_discount = 'Y' AND
       x_charges_detail_rec.no_charge_flag <> 'Y' AND
       x_charges_detail_rec.contract_line_id IS NOT NULL THEN

         --call contracts dicounting API
         CS_Est_Apply_Contract_PKG.Apply_Contract (
            p_coverage_id           => x_charges_detail_rec.contract_line_id,
            p_coverage_txn_group_id => x_charges_detail_rec.coverage_txn_group_id,
            p_business_process_id   => x_charges_detail_rec.business_process_id,
            p_request_date          => l_request_date,
            p_txn_billing_type_id   => x_charges_detail_rec.txn_billing_type_id,
            p_amount                => x_charges_detail_rec.after_warranty_cost,
            p_discount_amount       => l_contract_discount,
            X_RETURN_STATUS         => l_return_status,
            X_MSG_COUNT             => l_msg_count,
            X_MSG_DATA              => l_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.Set_Name('CS', 'CS_CHG_APPLY_CONTRACT_WARNING');
          FND_MESSAGE.SET_TOKEN('REASON', l_msg_data);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

         IF l_contract_discount IS NOT NULL THEN
          --assign the contract discount to the out record
          x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.after_warranty_cost - l_contract_discount;

          --apply discount
          x_charges_detail_rec.after_warranty_cost := l_contract_discount;

        ELSE
          -- contract discount amt should be 0
          --x_charges_detail_rec.contract_discount_amount := 0;
          null;
        END IF;

    ELSE
      --Apply contract discount = 'N'
      --Fixed Bug # 3220253
      --passed p_charges_detail_rec.contract_discount_amount
      x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;
      x_charges_detail_rec.contract_discount_amount := p_charges_detail_rec.contract_discount_amount;

      IF x_charges_detail_rec.contract_discount_amount IS NULL THEN
          x_charges_detail_rec.contract_discount_amount := 0;
      ELSE
          x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.contract_discount_amount;
      END IF;
    END IF ;


  ELSIF
        --Fix # 3069583 unable to override charges for labor charge line
        x_charges_detail_rec.billing_flag IN ('E', 'M', 'L') AND
        p_charges_detail_rec.after_warranty_cost IS NOT NULL THEN

        --DBMS_OUTPUT.PUT_LINE('Expense line with after warr cost ');
        --DBMS_OUTPUT.PUT_LINE('l_conversion_needed_flag '||l_conversion_needed_flag);
        --DBMS_OUTPUT.PUT_LINE('after_warranty_cost = '||p_charges_detail_rec.after_warranty_cost );

        -- Added to fix Bug # 3819167
        --
        /*
        IF ((l_line_order_category_code = 'RETURN') AND
          (sign(x_charges_detail_rec.quantity_required) = -1)) THEN
          l_absolute_quantity_required := x_charges_detail_rec.quantity_required * -1;
        ELSE
          l_absolute_quantity_required := x_charges_detail_rec.quantity_required;
        END IF;
        */

        -- Call the pricing API just to verify that the item is on the price list
        CS_Pricing_Item_Pkg.Call_Pricing_Item(
            P_Inventory_Item_Id          => x_charges_detail_rec.inventory_item_id_in,
            P_Price_List_Id              => x_charges_detail_rec.price_list_id,
            P_UOM_Code                   => x_charges_detail_rec.unit_of_measure_code,
            p_Currency_Code              => x_charges_detail_rec.currency_code,
            P_Quantity                   => abs(x_charges_detail_rec.quantity_required),
            P_Org_Id                     => x_charges_detail_rec.org_id,
            x_list_price                 => l_list_price,
            P_Pricing_Context            => x_charges_detail_rec.pricing_context,
            P_Pricing_Attribute1         => x_charges_detail_rec.pricing_attribute1,
            P_Pricing_Attribute2         => x_charges_detail_rec.pricing_attribute2,
            P_Pricing_Attribute3         => x_charges_detail_rec.pricing_attribute3,
            P_Pricing_Attribute4         => x_charges_detail_rec.pricing_attribute4,
            P_Pricing_Attribute5         => x_charges_detail_rec.pricing_attribute5,
            P_Pricing_Attribute6         => x_charges_detail_rec.pricing_attribute6,
            P_Pricing_Attribute7         => x_charges_detail_rec.pricing_attribute7,
            P_Pricing_Attribute8         => x_charges_detail_rec.pricing_attribute8,
            P_Pricing_Attribute9         => x_charges_detail_rec.pricing_attribute9,
            P_Pricing_Attribute10        => x_charges_detail_rec.pricing_attribute10,
            P_Pricing_Attribute11        => x_charges_detail_rec.pricing_attribute11,
            P_Pricing_Attribute12        => x_charges_detail_rec.pricing_attribute12,
            P_Pricing_Attribute13        => x_charges_detail_rec.pricing_attribute13,
            P_Pricing_Attribute14        => x_charges_detail_rec.pricing_attribute14,
            P_Pricing_Attribute15        => x_charges_detail_rec.pricing_attribute15,
            P_Pricing_Attribute16        => x_charges_detail_rec.pricing_attribute16,
            P_Pricing_Attribute17        => x_charges_detail_rec.pricing_attribute17,
            P_Pricing_Attribute18        => x_charges_detail_rec.pricing_attribute18,
            P_Pricing_Attribute19        => x_charges_detail_rec.pricing_attribute19,
            P_Pricing_Attribute20        => x_charges_detail_rec.pricing_attribute20,
            P_Pricing_Attribute21        => x_charges_detail_rec.pricing_attribute21,
            P_Pricing_Attribute22        => x_charges_detail_rec.pricing_attribute22,
            P_Pricing_Attribute23        => x_charges_detail_rec.pricing_attribute23,
            P_Pricing_Attribute24        => x_charges_detail_rec.pricing_attribute24,
            P_Pricing_Attribute25        => x_charges_detail_rec.pricing_attribute25,
            p_Pricing_Attribute26        => x_charges_detail_rec.pricing_attribute26,
            P_Pricing_Attribute27        => x_charges_detail_rec.pricing_attribute27,
            P_Pricing_Attribute28        => x_charges_detail_rec.pricing_attribute28,
            P_Pricing_Attribute29        => x_charges_detail_rec.pricing_attribute29,
            P_Pricing_Attribute30        => x_charges_detail_rec.pricing_attribute30,
            P_PRICING_ATTRIBUTE31        => x_charges_detail_rec.pricing_attribute31,
            P_PRICING_ATTRIBUTE32        => x_charges_detail_rec.pricing_attribute32,
            P_PRICING_ATTRIBUTE33        => x_charges_detail_rec.pricing_attribute33,
            P_PRICING_ATTRIBUTE34        => x_charges_detail_rec.pricing_attribute34,
            P_Pricing_Attribute35        => x_charges_detail_rec.pricing_attribute35,
            P_Pricing_Attribute36        => x_charges_detail_rec.pricing_attribute36,
            P_Pricing_Attribute37        => x_charges_detail_rec.pricing_attribute37,
            P_Pricing_Attribute38        => x_charges_detail_rec.pricing_attribute38,
            P_Pricing_Attribute39        => x_charges_detail_rec.pricing_attribute39,
            P_Pricing_Attribute40        => x_charges_detail_rec.pricing_attribute40,
            P_Pricing_Attribute41        => x_charges_detail_rec.pricing_attribute41,
            P_Pricing_Attribute42        => x_charges_detail_rec.pricing_attribute42,
            P_Pricing_Attribute43        => x_charges_detail_rec.pricing_attribute43,
            P_Pricing_Attribute44        => x_charges_detail_rec.pricing_attribute44,
            P_Pricing_Attribute45        => x_charges_detail_rec.pricing_attribute45,
            P_Pricing_Attribute46        => x_charges_detail_rec.pricing_attribute46,
            P_Pricing_Attribute47        => x_charges_detail_rec.pricing_attribute47,
            P_Pricing_Attribute48        => x_charges_detail_rec.pricing_attribute48,
            P_Pricing_Attribute49        => x_charges_detail_rec.pricing_attribute49,
            P_Pricing_Attribute50        => x_charges_detail_rec.pricing_attribute50,
            P_Pricing_Attribute51        => x_charges_detail_rec.pricing_attribute51,
            P_Pricing_Attribute52        => x_charges_detail_rec.pricing_attribute52,
            P_Pricing_Attribute53        => x_charges_detail_rec.pricing_attribute53,
            P_Pricing_Attribute54        => x_charges_detail_rec.pricing_attribute54,
            P_Pricing_Attribute55        => x_charges_detail_rec.pricing_attribute55,
            P_Pricing_Attribute56        => x_charges_detail_rec.pricing_attribute56,
            P_Pricing_Attribute57        => x_charges_detail_rec.pricing_attribute57,
            P_Pricing_Attribute58        => x_charges_detail_rec.pricing_attribute58,
            P_Pricing_Attribute59        => x_charges_detail_rec.pricing_attribute59,
            P_Pricing_Attribute60        => x_charges_detail_rec.pricing_attribute60,
            P_Pricing_Attribute61        => x_charges_detail_rec.pricing_attribute61,
            P_Pricing_Attribute62        => x_charges_detail_rec.pricing_attribute62,
            P_Pricing_Attribute63        => x_charges_detail_rec.pricing_attribute63,
            P_Pricing_Attribute64        => x_charges_detail_rec.pricing_attribute64,
            P_Pricing_Attribute65        => x_charges_detail_rec.pricing_attribute65,
            P_Pricing_Attribute66        => x_charges_detail_rec.pricing_attribute66,
            P_Pricing_Attribute67        => x_charges_detail_rec.pricing_attribute67,
            P_Pricing_Attribute68        => x_charges_detail_rec.pricing_attribute68,
            P_Pricing_Attribute69        => x_charges_detail_rec.pricing_attribute69,
            P_Pricing_Attribute70        => x_charges_detail_rec.pricing_attribute70,
            P_Pricing_Attribute71        => x_charges_detail_rec.pricing_attribute71,
            P_Pricing_Attribute72        => x_charges_detail_rec.pricing_attribute72,
            P_Pricing_Attribute73        => x_charges_detail_rec.pricing_attribute73,
            P_Pricing_Attribute74        => x_charges_detail_rec.pricing_attribute74,
            P_Pricing_Attribute75        => x_charges_detail_rec.pricing_attribute75,
            P_Pricing_Attribute76        => x_charges_detail_rec.pricing_attribute76,
            P_Pricing_Attribute77        => x_charges_detail_rec.pricing_attribute77,
            P_Pricing_Attribute78        => x_charges_detail_rec.pricing_attribute78,
            P_Pricing_Attribute79        => x_charges_detail_rec.pricing_attribute79,
            P_Pricing_Attribute80        => x_charges_detail_rec.pricing_attribute80,
            P_Pricing_Attribute81        => x_charges_detail_rec.pricing_attribute81,
            P_Pricing_Attribute82        => x_charges_detail_rec.pricing_attribute82,
            P_Pricing_Attribute83        => x_charges_detail_rec.pricing_attribute83,
            P_Pricing_Attribute84        => x_charges_detail_rec.pricing_attribute84,
            P_Pricing_Attribute85        => x_charges_detail_rec.pricing_attribute85,
            P_Pricing_Attribute86        => x_charges_detail_rec.pricing_attribute86,
            P_Pricing_Attribute87        => x_charges_detail_rec.pricing_attribute87,
            P_Pricing_Attribute88        => x_charges_detail_rec.pricing_attribute88,
            P_Pricing_Attribute89        => x_charges_detail_rec.pricing_attribute89,
            P_Pricing_Attribute90        => x_charges_detail_rec.pricing_attribute90,
            P_Pricing_Attribute91        => x_charges_detail_rec.pricing_attribute91,
            P_Pricing_Attribute92        => x_charges_detail_rec.pricing_attribute92,
            P_Pricing_Attribute93        => x_charges_detail_rec.pricing_attribute93,
            P_Pricing_Attribute94        => x_charges_detail_rec.pricing_attribute94,
            P_Pricing_Attribute95        => x_charges_detail_rec.pricing_attribute95,
            P_Pricing_Attribute96        => x_charges_detail_rec.pricing_attribute96,
            P_Pricing_Attribute97        => x_charges_detail_rec.pricing_attribute97,
            P_Pricing_Attribute98        => x_charges_detail_rec.pricing_attribute98,
            P_Pricing_Attribute99        => x_charges_detail_rec.pricing_attribute99,
            P_Pricing_Attribute100       => x_charges_detail_rec.pricing_attribute100,
            x_return_status              => l_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data);

      --DBMS_OUTPUT.PUT_LINE('After calling CS_Pricing_Item_Pkg.Call_Pricing_Item ...');
      --DBMS_OUTPUT.PUT_LINE('l_msg_data '||l_msg_data);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_API_PRICING_ITEM_ERROR');
        FND_MESSAGE.set_token('INV_ID', x_charges_detail_rec.inventory_item_id_in);
        FND_MESSAGE.set_token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
        FND_MESSAGE.set_token('UOM', x_charges_detail_rec.unit_of_measure_code);
        FND_MESSAGE.set_token('CURR_CODE', x_charges_detail_rec.currency_code);
        --FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data, TRUE);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;



      -- Assign the after warranty that comes on the line
        x_charges_detail_rec.after_warranty_cost := p_charges_detail_rec.after_warranty_cost;

    IF l_conversion_needed_flag = 'Y' THEN
      --assign coverted amt to after_warranty_cost
      x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.after_warranty_cost * x_charges_detail_rec.conversion_rate;
      x_charges_detail_rec.list_price := l_list_price;

      --bug # 3056622 charge amount is zero for items with negative prices

      IF p_charges_detail_rec.selling_price IS NOT NULL THEN
        x_charges_detail_rec.selling_price :=  p_charges_detail_rec.selling_price * x_charges_detail_rec.conversion_rate;
      ELSE
        x_charges_detail_rec.selling_price :=  x_charges_detail_rec.list_price;
      END IF;

    ELSE
      x_charges_detail_rec.after_warranty_cost := p_charges_detail_rec.after_warranty_cost;
      x_charges_detail_rec.list_price := l_list_price;

      --bug # 3056622 charge amount is zero for items with negative prices

      IF p_charges_detail_rec.selling_price IS NOT NULL THEN
        x_charges_detail_rec.selling_price :=  p_charges_detail_rec.selling_price;
      ELSE
        x_charges_detail_rec.selling_price :=  x_charges_detail_rec.list_price;
      END IF;

    END IF;

    --DBMS_OUTPUT.PUT_LINE(' after_warranty_cost '||x_charges_detail_rec.after_warranty_cost );

    --Fixed Bug # 3468146
    --need to do this here so that contract discounting is done correctly
    --re-set the no_charge_flag for Charge Lines
    --since the line has come with after warranty cost from upstream
    IF x_charges_detail_rec.after_warranty_cost <> 0 THEN
      x_charges_detail_rec.no_charge_flag := 'N';
    END IF;


    --DBMS_OUTPUT.PUT_LINE('re-setting the no_charge_flag' ||x_charges_detail_rec.no_charge_flag);


    IF x_charges_detail_rec.apply_contract_discount = 'Y' AND
       x_charges_detail_rec.no_charge_flag <> 'Y' AND
       x_charges_detail_rec.contract_line_id IS NOT NULL THEN

      --call contracts dicounting API
      CS_Est_Apply_Contract_PKG.Apply_Contract (
            p_coverage_id           => x_charges_detail_rec.contract_line_id,
            p_coverage_txn_group_id => x_charges_detail_rec.coverage_txn_group_id,
            p_business_process_id   => x_charges_detail_rec.business_process_id,
            p_request_date          => l_request_date,
            p_txn_billing_type_id   => x_charges_detail_rec.txn_billing_type_id,
            p_amount                => x_charges_detail_rec.after_warranty_cost,
            p_discount_amount       => l_contract_discount,
            X_RETURN_STATUS         => l_return_status,
            X_MSG_COUNT             => l_msg_count,
            X_MSG_DATA              => l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_APPLY_CONTRACT_WARNING');
        FND_MESSAGE.SET_TOKEN('REASON', l_msg_data);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --Bug Fix for Bug # 3088397
      IF l_contract_discount IS NOT NULL THEN
        --assign the contract discount to the out record
        x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.after_warranty_cost - l_contract_discount;

        --apply discount
        x_charges_detail_rec.after_warranty_cost := l_contract_discount;

       ELSE
          -- contract discount amt should be 0
          --x_charges_detail_rec.contract_discount_amount := 0;
          null;
      END IF;

    ELSE
      --Apply contract discount = 'N'
      --Fixed Bug # 3220253
      --passed p_charges_detail_rec.contract_discount_amount
      x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;
      x_charges_detail_rec.contract_discount_amount := p_charges_detail_rec.contract_discount_amount;

      IF x_charges_detail_rec.contract_discount_amount IS NULL THEN
          x_charges_detail_rec.contract_discount_amount := 0;
      ELSE
          x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.contract_discount_amount;
      END IF;
    END IF ;
  END IF;
  IF   l_line_order_category_code = 'ORDER' THEN      --Bug 6960562
      /* Start : 5705568 */
--      If x_charges_detail_rec.after_warranty_cost < 0  Then
-- Bug 8305664 removed the and condition in the if statement
      If x_charges_detail_rec.after_warranty_cost < 0  Then  -- bug 7459205
          x_charges_detail_rec.after_warranty_cost := 0;
      End If;
     /* End : 5705568 */
  End If;
ELSIF p_validation_mode = 'U' THEN

  --DBMS_OUTPUT.PUT_LINE('In Update of Pricing API');
  --DBMS_OUTPUT.PUT_LINE('Billing Flag '||x_charges_detail_rec.billing_flag);
  --DBMS_OUTPUT.PUT_LINE('AFter_warranty_cost '||p_charges_detail_rec.after_warranty_cost);
  --DBMS_OUTPUT.PUT_LINE('selling price '||p_charges_detail_rec.selling_price);

  IF x_charges_detail_rec.billing_flag = 'L' AND
     p_charges_detail_rec.list_price <> FND_API.G_MISS_NUM AND
     p_charges_detail_rec.list_price IS NOT NULL THEN

    IF p_charges_detail_rec.list_price <> l_db_det_rec.list_price THEN

       l_calc_sp := 'Y';


       -- no need to call the pricing api
       -- assign to out record
       x_charges_detail_rec.list_price    := p_charges_detail_rec.list_price;

       x_charges_detail_rec.selling_price := p_charges_detail_rec.list_price;

       --bug # 3056622 charge amount is zero for items with negative prices

       --derive the after_warranty_cost
       IF x_charges_detail_rec.no_charge_flag <> 'Y' AND
          x_charges_detail_rec.selling_price IS NOT NULL THEN

          --Fix for Bug # 3388373
          IF p_charges_detail_rec.after_warranty_cost IS NOT NULL THEN

            x_charges_detail_rec.after_warranty_cost := p_charges_detail_rec.after_warranty_cost;
            l_calc_sp := 'N';
          ELSIF p_charges_detail_rec.after_warranty_cost = FND_API.G_MISS_NUM THEN
            x_charges_detail_rec.after_warranty_cost := l_db_det_rec.after_warranty_cost;
            l_calc_sp := 'N';
          ELSE
            --after warr cost is null
            x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.selling_price * x_charges_detail_rec.quantity_required;
          END IF;

       ELSE
          -- no charge flag = 'Y'
          x_charges_detail_rec.after_warranty_cost := 0;
       END IF;

       --check to see if contract discount needs to be applied
       IF x_charges_detail_rec.apply_contract_discount = 'Y' AND
          x_charges_detail_rec.no_charge_flag <> 'Y' AND
          x_charges_detail_rec.contract_line_id IS NOT NULL THEN

          --assign to out record
          x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;

          --call contracts dicounting API
          --DBMS_OUTPUT.PUT_LINE('Call Contracts API to Apply contracts 3');

         CS_Est_Apply_Contract_PKG.Apply_Contract(
           p_coverage_id           => x_charges_detail_rec.contract_line_id,
           p_coverage_txn_group_id => x_charges_detail_rec.coverage_txn_group_id,
           p_txn_billing_type_id   => x_charges_detail_rec.txn_billing_type_id,
           P_BUSINESS_PROCESS_ID   => x_charges_detail_rec.business_process_id,
           P_REQUEST_DATE          => l_request_date,
           p_amount                => x_charges_detail_rec.after_warranty_cost,
           p_discount_amount       => l_contract_discount,
           X_RETURN_STATUS         => l_return_status,
           X_MSG_COUNT             => l_msg_count,
           X_MSG_DATA              => l_msg_data);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.Set_Name('CS', 'CS_CHG_APPLY_CONTRACT_WARNING');
            FND_MESSAGE.SET_TOKEN('REASON', l_msg_data);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          --Bug Fix for Bug # 3088397
          IF l_contract_discount IS NOT NULL THEN
            --assign the contract discount to the out record
            x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.after_warranty_cost - l_contract_discount;

            --apply discount
            x_charges_detail_rec.after_warranty_cost := l_contract_discount;
          ELSE
            -- contract discount amt should be 0
            --x_charges_detail_rec.contract_discount_amount := 0;
            null;
          END IF;

          --DBMS_OUTPUT.PUT_LINE('Contract 3'||x_charges_detail_rec.contract_discount_amount);

      ELSE
        --Apply contract discount = 'N'
        --Fixed Bug # 3220253
        --passed p_charges_detail_rec.contract_discount_amount
        x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;
        x_charges_detail_rec.contract_discount_amount := p_charges_detail_rec.contract_discount_amount;

        IF x_charges_detail_rec.contract_discount_amount IS NULL THEN
          x_charges_detail_rec.contract_discount_amount := 0;
        ELSE
          x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.contract_discount_amount;
        END IF;

      END IF ;
    ELSE
       --p_charges_detail_rec.list_price = l_db_det_rec.list_price

       -- no need to call the pricing api
       -- assign to out record what is the dbatabase
       x_charges_detail_rec.list_price    := l_db_det_rec.list_price;
       x_charges_detail_rec.selling_price := l_db_det_rec.list_price;

       --bug # 3056622 charge amount is zero for items with negative prices
        --derive the after_warranty_cost
       IF x_charges_detail_rec.no_charge_flag <> 'Y' THEN
          --Condition added to fix Bug # 3358531
          x_charges_detail_rec.after_warranty_cost := l_db_det_rec.after_warranty_cost;
       ELSE
          -- no charge flag = 'Y'
          x_charges_detail_rec.after_warranty_cost := 0;
       END IF;


      --check to see if contract discount needs to be applied
      IF x_charges_detail_rec.apply_contract_discount = 'Y' AND
         x_charges_detail_rec.contract_line_id IS NOT NULL AND
         x_charges_detail_rec.no_charge_flag <> 'Y' THEN

          --assign to out record
          x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;

          --call contracts dicounting API
          --DBMS_OUTPUT.PUT_LINE('Call Contracts API to Apply contracts 4');

          CS_Est_Apply_Contract_PKG.Apply_Contract(
            p_coverage_id           => x_charges_detail_rec.apply_contract_discount,
            p_coverage_txn_group_id => x_charges_detail_rec.coverage_txn_group_id,
            p_txn_billing_type_id   => x_charges_detail_rec.txn_billing_type_id,
            P_BUSINESS_PROCESS_ID   => x_charges_detail_rec.business_process_id,
            P_REQUEST_DATE          => l_request_date,
            p_amount                => x_charges_detail_rec.after_warranty_cost,
            p_discount_amount       => l_contract_discount,
            X_RETURN_STATUS         => l_return_status,
            X_MSG_COUNT             => l_msg_count,
            X_MSG_DATA              => l_msg_data);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.Set_Name('CS', 'CS_CHG_APPLY_CONTRACT_WARNING');
            FND_MESSAGE.SET_TOKEN('REASON', l_msg_data);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          --Bug Fix for Bug # 3088397
          IF l_contract_discount IS NOT NULL THEN
            --assign the contract discount to the out record
            x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.after_warranty_cost - l_contract_discount;

            --apply discount
            x_charges_detail_rec.after_warranty_cost := l_contract_discount;
          ELSE
            -- contract discount amt should be 0
            --x_charges_detail_rec.contract_discount_amount := 0;
            null;
          END IF;

          --DBMS_OUTPUT.PUT_LINE('Contract 4'||x_charges_detail_rec.contract_discount_amount);

      ELSE
        --Apply contract discount = 'N'
        --Fixed Bug # 3220253
        --passed p_charges_detail_rec.contract_discount_amount
        x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;

        IF p_charges_detail_rec.contract_discount_amount <> FND_API.G_MISS_NUM OR
           p_charges_detail_rec.contract_discount_amount IS NOT NULL THEN
           x_charges_detail_rec.contract_discount_amount := l_db_rec.contract_discount_amount;
        ELSIF p_charges_detail_rec.contract_discount_amount IS NULL THEN
           x_charges_detail_rec.contract_discount_amount := 0;
        ELSE
          x_charges_detail_rec.contract_discount_amount := p_charges_detail_rec.contract_discount_amount;
        END IF;

      END IF ;
    END IF;

  ELSIF

     --Fix # 3069583 unable to override charges for labor charge line
     --x_charges_detail_rec.billing_flag <> 'E' AND
     --x_charges_detail_rec.billing_flag <> 'M' OR
     (x_charges_detail_rec.billing_flag IN ('E','M', 'L') AND
     ((p_charges_detail_rec.after_warranty_cost = FND_API.G_MISS_NUM OR
     p_charges_detail_rec.after_warranty_cost IS NULL) AND
     (p_charges_detail_rec.list_price = FND_API.G_MISS_NUM OR
     p_charges_detail_rec.list_price IS NULL))) THEN


     IF l_calc_sp = 'Y' THEN
       IF ((((x_charges_detail_rec.inventory_item_id_in IS NOT NULL) AND
             (x_charges_detail_rec.unit_of_measure_code IS NOT NULL) AND
             (x_charges_detail_rec.price_list_id IS NOT NULL) AND
             (x_charges_detail_rec.quantity_required IS NOT NULL)))) THEN
          --DBMS_OUTPUT.PUT_LINE('Before calling CS_Pricing_Item_Pkg.Call_Pricing_Item ...');
          --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.inventory_item_id_in='||x_charges_detail_rec.inventory_item_id_in);
          --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.price_list_id='||x_charges_detail_rec.price_list_id);
          --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.unit_of_measure_code='||x_charges_detail_rec.unit_of_measure_code);
          --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.currency_code='||x_charges_detail_rec.currency_code);
          --DBMS_OUTPUT.PUT_LINE('x_charges_detail_rec.quantity_required='||x_charges_detail_rec.quantity_required);

          -- Added to fix Bug # 3819167
          --
          /*
          IF ((l_line_order_category_code = 'RETURN') AND
              (sign(x_charges_detail_rec.quantity_required) = -1)) THEN
             l_absolute_quantity_required := x_charges_detail_rec.quantity_required * -1;
          ELSE
             l_absolute_quantity_required := x_charges_detail_rec.quantity_required;
          END IF;
          */

          -- Calculate the selling price
          CS_Pricing_Item_Pkg.Call_Pricing_Item(
            P_Inventory_Item_Id          => x_charges_detail_rec.inventory_item_id_in,
            P_Price_List_Id              => x_charges_detail_rec.price_list_id,
            P_UOM_Code                   => x_charges_detail_rec.unit_of_measure_code,
            p_Currency_Code              => x_charges_detail_rec.currency_code,
            P_Quantity                   => abs(x_charges_detail_rec.quantity_required),
            P_Org_Id                     => x_charges_detail_rec.org_id,
            x_list_price                 => l_list_price,
            P_Pricing_Context            => x_charges_detail_rec.pricing_context,
            P_Pricing_Attribute1         => x_charges_detail_rec.pricing_attribute1,
            P_Pricing_Attribute2         => x_charges_detail_rec.pricing_attribute2,
            P_Pricing_Attribute3         => x_charges_detail_rec.pricing_attribute3,
            P_Pricing_Attribute4         => x_charges_detail_rec.pricing_attribute4,
            P_Pricing_Attribute5         => x_charges_detail_rec.pricing_attribute5,
            P_Pricing_Attribute6         => x_charges_detail_rec.pricing_attribute6,
            P_Pricing_Attribute7         => x_charges_detail_rec.pricing_attribute7,
            P_Pricing_Attribute8         => x_charges_detail_rec.pricing_attribute8,
            P_Pricing_Attribute9         => x_charges_detail_rec.pricing_attribute9,
            P_Pricing_Attribute10        => x_charges_detail_rec.pricing_attribute10,
            P_Pricing_Attribute11        => x_charges_detail_rec.pricing_attribute11,
            P_Pricing_Attribute12        => x_charges_detail_rec.pricing_attribute12,
            P_Pricing_Attribute13        => x_charges_detail_rec.pricing_attribute13,
            P_Pricing_Attribute14        => x_charges_detail_rec.pricing_attribute14,
            P_Pricing_Attribute15        => x_charges_detail_rec.pricing_attribute15,
            P_Pricing_Attribute16        => x_charges_detail_rec.pricing_attribute16,
            P_Pricing_Attribute17        => x_charges_detail_rec.pricing_attribute17,
            P_Pricing_Attribute18        => x_charges_detail_rec.pricing_attribute18,
            P_Pricing_Attribute19        => x_charges_detail_rec.pricing_attribute19,
            P_Pricing_Attribute20        => x_charges_detail_rec.pricing_attribute20,
            P_Pricing_Attribute21        => x_charges_detail_rec.pricing_attribute21,
            P_Pricing_Attribute22        => x_charges_detail_rec.pricing_attribute22,
            P_Pricing_Attribute23        => x_charges_detail_rec.pricing_attribute23,
            P_Pricing_Attribute24        => x_charges_detail_rec.pricing_attribute24,
            P_Pricing_Attribute25        => x_charges_detail_rec.pricing_attribute25,
            p_Pricing_Attribute26        => x_charges_detail_rec.pricing_attribute26,
            P_Pricing_Attribute27        => x_charges_detail_rec.pricing_attribute27,
            P_Pricing_Attribute28        => x_charges_detail_rec.pricing_attribute28,
            P_Pricing_Attribute29        => x_charges_detail_rec.pricing_attribute29,
            P_Pricing_Attribute30        => x_charges_detail_rec.pricing_attribute30,
            P_PRICING_ATTRIBUTE31        => x_charges_detail_rec.pricing_attribute31,
            P_PRICING_ATTRIBUTE32        => x_charges_detail_rec.pricing_attribute32,
            P_PRICING_ATTRIBUTE33        => x_charges_detail_rec.pricing_attribute33,
            P_PRICING_ATTRIBUTE34        => x_charges_detail_rec.pricing_attribute34,
            P_Pricing_Attribute35        => x_charges_detail_rec.pricing_attribute35,
            P_Pricing_Attribute36        => x_charges_detail_rec.pricing_attribute36,
            P_Pricing_Attribute37        => x_charges_detail_rec.pricing_attribute37,
            P_Pricing_Attribute38        => x_charges_detail_rec.pricing_attribute38,
            P_Pricing_Attribute39        => x_charges_detail_rec.pricing_attribute39,
            P_Pricing_Attribute40        => x_charges_detail_rec.pricing_attribute40,
            P_Pricing_Attribute41        => x_charges_detail_rec.pricing_attribute41,
            P_Pricing_Attribute42        => x_charges_detail_rec.pricing_attribute42,
            P_Pricing_Attribute43        => x_charges_detail_rec.pricing_attribute43,
            P_Pricing_Attribute44        => x_charges_detail_rec.pricing_attribute44,
            P_Pricing_Attribute45        => x_charges_detail_rec.pricing_attribute45,
            P_Pricing_Attribute46        => x_charges_detail_rec.pricing_attribute46,
            P_Pricing_Attribute47        => x_charges_detail_rec.pricing_attribute47,
            P_Pricing_Attribute48        => x_charges_detail_rec.pricing_attribute48,
            P_Pricing_Attribute49        => x_charges_detail_rec.pricing_attribute49,
            P_Pricing_Attribute50        => x_charges_detail_rec.pricing_attribute50,
            P_Pricing_Attribute51        => x_charges_detail_rec.pricing_attribute51,
            P_Pricing_Attribute52        => x_charges_detail_rec.pricing_attribute52,
            P_Pricing_Attribute53        => x_charges_detail_rec.pricing_attribute53,
            P_Pricing_Attribute54        => x_charges_detail_rec.pricing_attribute54,
            P_Pricing_Attribute55        => x_charges_detail_rec.pricing_attribute55,
            P_Pricing_Attribute56        => x_charges_detail_rec.pricing_attribute56,
            P_Pricing_Attribute57        => x_charges_detail_rec.pricing_attribute57,
            P_Pricing_Attribute58        => x_charges_detail_rec.pricing_attribute58,
            P_Pricing_Attribute59        => x_charges_detail_rec.pricing_attribute59,
            P_Pricing_Attribute60        => x_charges_detail_rec.pricing_attribute60,
            P_Pricing_Attribute61        => x_charges_detail_rec.pricing_attribute61,
            P_Pricing_Attribute62        => x_charges_detail_rec.pricing_attribute62,
            P_Pricing_Attribute63        => x_charges_detail_rec.pricing_attribute63,
            P_Pricing_Attribute64        => x_charges_detail_rec.pricing_attribute64,
            P_Pricing_Attribute65        => x_charges_detail_rec.pricing_attribute65,
            P_Pricing_Attribute66        => x_charges_detail_rec.pricing_attribute66,
            P_Pricing_Attribute67        => x_charges_detail_rec.pricing_attribute67,
            P_Pricing_Attribute68        => x_charges_detail_rec.pricing_attribute68,
            P_Pricing_Attribute69        => x_charges_detail_rec.pricing_attribute69,
            P_Pricing_Attribute70        => x_charges_detail_rec.pricing_attribute70,
            P_Pricing_Attribute71        => x_charges_detail_rec.pricing_attribute71,
            P_Pricing_Attribute72        => x_charges_detail_rec.pricing_attribute72,
            P_Pricing_Attribute73        => x_charges_detail_rec.pricing_attribute73,
            P_Pricing_Attribute74        => x_charges_detail_rec.pricing_attribute74,
            P_Pricing_Attribute75        => x_charges_detail_rec.pricing_attribute75,
            P_Pricing_Attribute76        => x_charges_detail_rec.pricing_attribute76,
            P_Pricing_Attribute77        => x_charges_detail_rec.pricing_attribute77,
            P_Pricing_Attribute78        => x_charges_detail_rec.pricing_attribute78,
            P_Pricing_Attribute79        => x_charges_detail_rec.pricing_attribute79,
            P_Pricing_Attribute80        => x_charges_detail_rec.pricing_attribute80,
            P_Pricing_Attribute81        => x_charges_detail_rec.pricing_attribute81,
            P_Pricing_Attribute82        => x_charges_detail_rec.pricing_attribute82,
            P_Pricing_Attribute83        => x_charges_detail_rec.pricing_attribute83,
            P_Pricing_Attribute84        => x_charges_detail_rec.pricing_attribute84,
            P_Pricing_Attribute85        => x_charges_detail_rec.pricing_attribute85,
            P_Pricing_Attribute86        => x_charges_detail_rec.pricing_attribute86,
            P_Pricing_Attribute87        => x_charges_detail_rec.pricing_attribute87,
            P_Pricing_Attribute88        => x_charges_detail_rec.pricing_attribute88,
            P_Pricing_Attribute89        => x_charges_detail_rec.pricing_attribute89,
            P_Pricing_Attribute90        => x_charges_detail_rec.pricing_attribute90,
            P_Pricing_Attribute91        => x_charges_detail_rec.pricing_attribute91,
            P_Pricing_Attribute92        => x_charges_detail_rec.pricing_attribute92,
            P_Pricing_Attribute93        => x_charges_detail_rec.pricing_attribute93,
            P_Pricing_Attribute94        => x_charges_detail_rec.pricing_attribute94,
            P_Pricing_Attribute95        => x_charges_detail_rec.pricing_attribute95,
            P_Pricing_Attribute96        => x_charges_detail_rec.pricing_attribute96,
            P_Pricing_Attribute97        => x_charges_detail_rec.pricing_attribute97,
            P_Pricing_Attribute98        => x_charges_detail_rec.pricing_attribute98,
            P_Pricing_Attribute99        => x_charges_detail_rec.pricing_attribute99,
            P_Pricing_Attribute100       => x_charges_detail_rec.pricing_attribute100,
            x_return_status              => l_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data);

          --DBMS_OUTPUT.PUT_LINE('After calling CS_Pricing_Item_Pkg.Call_Pricing_Item ...');
          --DBMS_OUTPUT.PUT_LINE('l_msg_data '||l_msg_data);

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            FND_MESSAGE.Set_Name('CS', 'CS_CHG_API_PRICING_ITEM_ERROR');
            FND_MESSAGE.set_token('INV_ID', x_charges_detail_rec.inventory_item_id_in);
            FND_MESSAGE.set_token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
            FND_MESSAGE.set_token('UOM', x_charges_detail_rec.unit_of_measure_code);
            FND_MESSAGE.set_token('CURR_CODE', x_charges_detail_rec.currency_code);
            --FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data, TRUE);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          --bug # 3056622 charge amount is zero for items with negative prices
          --assign to out record
          x_charges_detail_rec.list_price    := l_list_price;
          IF p_charges_detail_rec.selling_price <> FND_API.G_MISS_NUM AND
             p_charges_detail_rec.selling_price IS NOT NULL THEN
            x_charges_detail_rec.selling_price :=  p_charges_detail_rec.selling_price;
          ELSE
            x_charges_detail_rec.selling_price := x_charges_detail_rec.list_price;
          END IF;


          IF x_charges_detail_rec.billing_flag = 'L' AND
             x_charges_detail_rec.con_pct_over_list_price IS NOT NULL THEN

            --get the new list price and selling price
            x_charges_detail_rec.list_price := x_charges_detail_rec.list_price +
                                               (x_charges_detail_rec.list_price *  x_charges_detail_rec.con_pct_over_list_price/100);

            x_charges_detail_rec.selling_price := x_charges_detail_rec.list_price;
          ELSE
            x_charges_detail_rec.list_price    := x_charges_detail_rec.list_price;
            x_charges_detail_rec.selling_price := x_charges_detail_rec.selling_price;
          END IF;


          --DBMS_OUTPUT.PUT_LINE('list_price '||x_charges_detail_rec.list_price);
          --DBMS_OUTPUT.PUT_LINE('Selling Price '||x_charges_detail_rec.selling_price);
          --DBMS_OUTPUT.PUT_LINE(' No Charge Flag is  '||x_charges_detail_rec.no_charge_flag);
          --DBMS_OUTPUT.PUT_LINE(' Conversion needed flag '||l_conversion_needed_flag);


          --bug # 3056622 charge amount is zero for items with negative prices
          IF x_charges_detail_rec.no_charge_flag <> 'Y' AND x_charges_detail_rec.selling_price IS NOT NULL THEN
            IF l_conversion_needed_flag = 'Y' THEN
              IF p_charges_detail_rec.selling_price IS NOT NULL THEN
                x_charges_detail_rec.selling_price := x_charges_detail_rec.selling_price * x_charges_detail_rec.conversion_rate;
                x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.selling_price * x_charges_detail_rec.quantity_required;
              ELSE
                x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.selling_price * x_charges_detail_rec.quantity_required * x_charges_detail_rec.conversion_rate;
              END IF;
            ELSE
              x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.selling_price * x_charges_detail_rec.quantity_required;
            END IF;
          ELSE
            -- no charge flag = 'Y'
            x_charges_detail_rec.after_warranty_cost := 0;
          END IF;

          --DBMS_OUTPUT.PUT_LINE(' after warr cost is '|| x_charges_detail_rec.after_warranty_cost);


          --check to see if contract discount needs to be applied

          --DBMS_OUTPUT.PUT_LINE('apply contract discount '|| x_charges_detail_rec.apply_contract_discount);

          IF x_charges_detail_rec.apply_contract_discount = 'Y' AND
             x_charges_detail_rec.contract_line_id IS NOT NULL AND
             x_charges_detail_rec.no_charge_flag <> 'Y' THEN

            --assign to out record
            x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;

            --call contracts dicounting API
            --DBMS_OUTPUT.PUT_LINE('Call Contracts API to Apply contracts 5');

            CS_Est_Apply_Contract_PKG.Apply_Contract(
              p_coverage_id           => x_charges_detail_rec.contract_line_id,
              p_coverage_txn_group_id => x_charges_detail_rec.coverage_txn_group_id,
              p_txn_billing_type_id   => x_charges_detail_rec.txn_billing_type_id,
              P_BUSINESS_PROCESS_ID   => x_charges_detail_rec.business_process_id,
              P_REQUEST_DATE          => l_request_date,
              p_amount                => x_charges_detail_rec.after_warranty_cost,
              p_discount_amount       => l_contract_discount,
              X_RETURN_STATUS         => l_return_status,
              X_MSG_COUNT             => l_msg_count,
              X_MSG_DATA              => l_msg_data);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              FND_MESSAGE.Set_Name('CS', 'CS_CHG_APPLY_CONTRACT_WARNING');
              FND_MESSAGE.SET_TOKEN('REASON', l_msg_data);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            --Bug Fix for Bug # 3088397
            IF l_contract_discount IS NOT NULL THEN
              --assign the contract discount to the out record
              x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.after_warranty_cost - l_contract_discount;

              --apply discount
              x_charges_detail_rec.after_warranty_cost :=  l_contract_discount;

            ELSE
              -- contract discount amt should be 0
              --x_charges_detail_rec.contract_discount_amount := 0;
              null;
            END IF;
            --DBMS_OUTPUT.PUT_LINE('Contract 5'||x_charges_detail_rec.contract_discount_amount);

          ELSE
            --Apply contract discount = 'N'
            --Fixed Bug # 3220253
            --passed p_charges_detail_rec.contract_discount_amount
            x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;
            x_charges_detail_rec.contract_discount_amount := p_charges_detail_rec.contract_discount_amount;

            IF x_charges_detail_rec.contract_discount_amount IS NULL THEN
              x_charges_detail_rec.contract_discount_amount := 0;
            ELSE
              x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.contract_discount_amount;
            END IF;
          END IF ;

      ELSE
        --x_charges_detail_rec.inventory_item_id_in IS NULL
        --x_charges_detail_rec.unit_of_measure_code IS NULL
        --x_charges_detail_rec.price_list_id IS NULL
        --x_charges_detail_rec.quantity_required IS NULL
        --the list price cannot be derived and the
        --after warranty cost cannot be computed
        --assign 0 to list_price and after_warranty_cost
        x_charges_detail_rec.list_price := 0;
        x_charges_detail_rec.selling_price := 0;
        x_charges_detail_rec.after_warranty_cost := 0;
        x_charges_detail_rec.contract_discount_amount := 0;

      END IF;
    ELSE
      --l_calc_sp = 'N'
      x_charges_detail_rec.list_price := l_db_det_rec.list_price;
      x_charges_detail_rec.selling_price := l_db_det_rec.selling_price;


      --calculate the contract % over list price
      IF x_charges_detail_rec.billing_flag = 'L' AND
         x_charges_detail_rec.con_pct_over_list_price IS NOT NULL THEN

        --get the new list price and selling price
        x_charges_detail_rec.list_price := x_charges_detail_rec.list_price +
                                        (x_charges_detail_rec.list_price *  x_charges_detail_rec.con_pct_over_list_price/100);

        x_charges_detail_rec.selling_price := x_charges_detail_rec.list_price;
      ELSE
        x_charges_detail_rec.list_price    := l_db_det_rec.list_price;
        --x_charges_detail_rec.selling_price := l_db_det_rec.selling_price;
        -- Commented above and added below for Bug# 4689183
        IF (p_charges_detail_rec.selling_price <> FND_API.G_MISS_NUM AND
            p_charges_detail_rec.selling_price IS NOT NULL) THEN
          IF (p_charges_detail_rec.selling_price <> l_db_det_rec.selling_price) THEN
            x_charges_detail_rec.selling_price := p_charges_detail_rec.selling_price;
          ELSE
            x_charges_detail_rec.selling_price := l_db_det_rec.selling_price;
          END IF;
        END IF;
      END IF;

      --bug # 3056622 charge amount is zero for items with negative prices

      IF x_charges_detail_rec.no_charge_flag <> 'Y' AND x_charges_detail_rec.selling_price IS NOT NULL THEN
        IF l_conversion_needed_flag = 'Y' THEN
          x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.selling_price * x_charges_detail_rec.quantity_required * x_charges_detail_rec.conversion_rate;
        ELSE
          --Condition added to fix Bug # 3358531
          x_charges_detail_rec.after_warranty_cost := l_db_det_rec.after_warranty_cost;
        END IF;
      ELSE
        -- no charge flag = 'Y'
        x_charges_detail_rec.after_warranty_cost := 0;
      END IF;

       --DBMS_OUTPUT.PUT_LINE(' after warr cost is '|| x_charges_detail_rec.after_warranty_cost);


          --check to see if contract discount needs to be applied

          --DBMS_OUTPUT.PUT_LINE('apply contract discount '|| x_charges_detail_rec.apply_contract_discount);

          IF x_charges_detail_rec.apply_contract_discount = 'Y' AND
             x_charges_detail_rec.contract_line_id IS NOT NULL AND
             x_charges_detail_rec.no_charge_flag <> 'Y' THEN

            --assign to out record
            x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;


            --call contracts dicounting API
            --DBMS_OUTPUT.PUT_LINE('Call Contracts API to Apply contracts 6');

            CS_Est_Apply_Contract_PKG.Apply_Contract(
              p_coverage_id           => x_charges_detail_rec.coverage_id,
              p_coverage_txn_group_id => x_charges_detail_rec.coverage_txn_group_id,
              p_txn_billing_type_id   => x_charges_detail_rec.txn_billing_type_id,
              P_BUSINESS_PROCESS_ID   => x_charges_detail_rec.business_process_id,
              P_REQUEST_DATE          => l_request_date,
              p_amount                => x_charges_detail_rec.after_warranty_cost,
              p_discount_amount       => l_contract_discount,
              X_RETURN_STATUS         => l_return_status,
              X_MSG_COUNT             => l_msg_count,
              X_MSG_DATA              => l_msg_data);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              FND_MESSAGE.Set_Name('CS', 'CS_CHG_APPLY_CONTRACT_WARNING');
              FND_MESSAGE.SET_TOKEN('REASON', l_msg_data);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            --Bug Fix for Bug # 3088397
            IF l_contract_discount IS NOT NULL THEN
              --assign the contract discount to the out record
              x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.after_warranty_cost - l_contract_discount;

              --apply discount
              x_charges_detail_rec.after_warranty_cost := l_contract_discount;
            ELSE
              -- contract discount amt should be 0
              --x_charges_detail_rec.contract_discount_amount := 0;
              null;
            END IF;
            --DBMS_OUTPUT.PUT_LINE('Contract 6'||x_charges_detail_rec.contract_discount_amount);

          ELSE
            --Apply contract discount = 'N'
            --Fixed Bug # 3220253
            --passed p_charges_detail_rec.contract_discount_amount
            x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;
            IF p_charges_detail_rec.contract_discount_amount <> FND_API.G_MISS_NUM OR
              p_charges_detail_rec.contract_discount_amount IS NOT NULL THEN
              x_charges_detail_rec.contract_discount_amount := l_db_rec.contract_discount_amount;
            ELSIF p_charges_detail_rec.contract_discount_amount IS NULL THEN
              x_charges_detail_rec.contract_discount_amount := 0;
            ELSE
              x_charges_detail_rec.contract_discount_amount := p_charges_detail_rec.contract_discount_amount;
            END IF;
          END IF ;
    END IF;

  ELSIF
        --Fix # 3069583 unable to override charges for labor charge line
        x_charges_detail_rec.billing_flag IN ('E', 'M', 'L') AND
        p_charges_detail_rec.after_warranty_cost <> FND_API.G_MISS_NUM AND
        p_charges_detail_rec.after_warranty_cost IS NOT NULL THEN

        --DBMS_OUTPUT.PUT_LINE('Update Expense line with after warr cost ');
        --DBMS_OUTPUT.PUT_LINE('Update l_conversion_needed_flag '||l_conversion_needed_flag);
        --DBMS_OUTPUT.PUT_LINE('Update after_warranty_cost = '||p_charges_detail_rec.after_warranty_cost );
        --DBMS_OUTPUT.PUT_LINE('DB After warranty cost = '||l_db_det_rec.after_warranty_cost);

        IF p_charges_detail_rec.after_warranty_cost <> nvl(l_db_det_rec.after_warranty_cost, 0) THEN

          l_calc_sp := 'Y';

          --DBMS_OUTPUT.PUT_LINE(' In here ');

          -- Added to fix Bug # 3819167
          --
          /*
          IF ((l_line_order_category_code = 'RETURN') AND
              (sign(x_charges_detail_rec.quantity_required) = -1)) THEN
             l_absolute_quantity_required := x_charges_detail_rec.quantity_required * -1;
          ELSE
             l_absolute_quantity_required := x_charges_detail_rec.quantity_required;
          END IF;
          */

          -- Call the pricing API just to verify that the item is on the price list
          CS_Pricing_Item_Pkg.Call_Pricing_Item(
            P_Inventory_Item_Id          => x_charges_detail_rec.inventory_item_id_in,
            P_Price_List_Id              => x_charges_detail_rec.price_list_id,
            P_UOM_Code                   => x_charges_detail_rec.unit_of_measure_code,
            p_Currency_Code              => x_charges_detail_rec.currency_code,
            P_Quantity                   => abs(x_charges_detail_rec.quantity_required),
            P_Org_Id                     => x_charges_detail_rec.org_id,
            x_list_price                 => l_list_price,
            P_Pricing_Context            => x_charges_detail_rec.pricing_context,
            P_Pricing_Attribute1         => x_charges_detail_rec.pricing_attribute1,
            P_Pricing_Attribute2         => x_charges_detail_rec.pricing_attribute2,
            P_Pricing_Attribute3         => x_charges_detail_rec.pricing_attribute3,
            P_Pricing_Attribute4         => x_charges_detail_rec.pricing_attribute4,
            P_Pricing_Attribute5         => x_charges_detail_rec.pricing_attribute5,
            P_Pricing_Attribute6         => x_charges_detail_rec.pricing_attribute6,
            P_Pricing_Attribute7         => x_charges_detail_rec.pricing_attribute7,
            P_Pricing_Attribute8         => x_charges_detail_rec.pricing_attribute8,
            P_Pricing_Attribute9         => x_charges_detail_rec.pricing_attribute9,
            P_Pricing_Attribute10        => x_charges_detail_rec.pricing_attribute10,
            P_Pricing_Attribute11        => x_charges_detail_rec.pricing_attribute11,
            P_Pricing_Attribute12        => x_charges_detail_rec.pricing_attribute12,
            P_Pricing_Attribute13        => x_charges_detail_rec.pricing_attribute13,
            P_Pricing_Attribute14        => x_charges_detail_rec.pricing_attribute14,
            P_Pricing_Attribute15        => x_charges_detail_rec.pricing_attribute15,
            P_Pricing_Attribute16        => x_charges_detail_rec.pricing_attribute16,
            P_Pricing_Attribute17        => x_charges_detail_rec.pricing_attribute17,
            P_Pricing_Attribute18        => x_charges_detail_rec.pricing_attribute18,
            P_Pricing_Attribute19        => x_charges_detail_rec.pricing_attribute19,
            P_Pricing_Attribute20        => x_charges_detail_rec.pricing_attribute20,
            P_Pricing_Attribute21        => x_charges_detail_rec.pricing_attribute21,
            P_Pricing_Attribute22        => x_charges_detail_rec.pricing_attribute22,
            P_Pricing_Attribute23        => x_charges_detail_rec.pricing_attribute23,
            P_Pricing_Attribute24        => x_charges_detail_rec.pricing_attribute24,
            P_Pricing_Attribute25        => x_charges_detail_rec.pricing_attribute25,
            p_Pricing_Attribute26        => x_charges_detail_rec.pricing_attribute26,
            P_Pricing_Attribute27        => x_charges_detail_rec.pricing_attribute27,
            P_Pricing_Attribute28        => x_charges_detail_rec.pricing_attribute28,
            P_Pricing_Attribute29        => x_charges_detail_rec.pricing_attribute29,
            P_Pricing_Attribute30        => x_charges_detail_rec.pricing_attribute30,
            P_PRICING_ATTRIBUTE31        => x_charges_detail_rec.pricing_attribute31,
            P_PRICING_ATTRIBUTE32        => x_charges_detail_rec.pricing_attribute32,
            P_PRICING_ATTRIBUTE33        => x_charges_detail_rec.pricing_attribute33,
            P_PRICING_ATTRIBUTE34        => x_charges_detail_rec.pricing_attribute34,
            P_Pricing_Attribute35        => x_charges_detail_rec.pricing_attribute35,
            P_Pricing_Attribute36        => x_charges_detail_rec.pricing_attribute36,
            P_Pricing_Attribute37        => x_charges_detail_rec.pricing_attribute37,
            P_Pricing_Attribute38        => x_charges_detail_rec.pricing_attribute38,
            P_Pricing_Attribute39        => x_charges_detail_rec.pricing_attribute39,
            P_Pricing_Attribute40        => x_charges_detail_rec.pricing_attribute40,
            P_Pricing_Attribute41        => x_charges_detail_rec.pricing_attribute41,
            P_Pricing_Attribute42        => x_charges_detail_rec.pricing_attribute42,
            P_Pricing_Attribute43        => x_charges_detail_rec.pricing_attribute43,
            P_Pricing_Attribute44        => x_charges_detail_rec.pricing_attribute44,
            P_Pricing_Attribute45        => x_charges_detail_rec.pricing_attribute45,
            P_Pricing_Attribute46        => x_charges_detail_rec.pricing_attribute46,
            P_Pricing_Attribute47        => x_charges_detail_rec.pricing_attribute47,
            P_Pricing_Attribute48        => x_charges_detail_rec.pricing_attribute48,
            P_Pricing_Attribute49        => x_charges_detail_rec.pricing_attribute49,
            P_Pricing_Attribute50        => x_charges_detail_rec.pricing_attribute50,
            P_Pricing_Attribute51        => x_charges_detail_rec.pricing_attribute51,
            P_Pricing_Attribute52        => x_charges_detail_rec.pricing_attribute52,
            P_Pricing_Attribute53        => x_charges_detail_rec.pricing_attribute53,
            P_Pricing_Attribute54        => x_charges_detail_rec.pricing_attribute54,
            P_Pricing_Attribute55        => x_charges_detail_rec.pricing_attribute55,
            P_Pricing_Attribute56        => x_charges_detail_rec.pricing_attribute56,
            P_Pricing_Attribute57        => x_charges_detail_rec.pricing_attribute57,
            P_Pricing_Attribute58        => x_charges_detail_rec.pricing_attribute58,
            P_Pricing_Attribute59        => x_charges_detail_rec.pricing_attribute59,
            P_Pricing_Attribute60        => x_charges_detail_rec.pricing_attribute60,
            P_Pricing_Attribute61        => x_charges_detail_rec.pricing_attribute61,
            P_Pricing_Attribute62        => x_charges_detail_rec.pricing_attribute62,
            P_Pricing_Attribute63        => x_charges_detail_rec.pricing_attribute63,
            P_Pricing_Attribute64        => x_charges_detail_rec.pricing_attribute64,
            P_Pricing_Attribute65        => x_charges_detail_rec.pricing_attribute65,
            P_Pricing_Attribute66        => x_charges_detail_rec.pricing_attribute66,
            P_Pricing_Attribute67        => x_charges_detail_rec.pricing_attribute67,
            P_Pricing_Attribute68        => x_charges_detail_rec.pricing_attribute68,
            P_Pricing_Attribute69        => x_charges_detail_rec.pricing_attribute69,
            P_Pricing_Attribute70        => x_charges_detail_rec.pricing_attribute70,
            P_Pricing_Attribute71        => x_charges_detail_rec.pricing_attribute71,
            P_Pricing_Attribute72        => x_charges_detail_rec.pricing_attribute72,
            P_Pricing_Attribute73        => x_charges_detail_rec.pricing_attribute73,
            P_Pricing_Attribute74        => x_charges_detail_rec.pricing_attribute74,
            P_Pricing_Attribute75        => x_charges_detail_rec.pricing_attribute75,
            P_Pricing_Attribute76        => x_charges_detail_rec.pricing_attribute76,
            P_Pricing_Attribute77        => x_charges_detail_rec.pricing_attribute77,
            P_Pricing_Attribute78        => x_charges_detail_rec.pricing_attribute78,
            P_Pricing_Attribute79        => x_charges_detail_rec.pricing_attribute79,
            P_Pricing_Attribute80        => x_charges_detail_rec.pricing_attribute80,
            P_Pricing_Attribute81        => x_charges_detail_rec.pricing_attribute81,
            P_Pricing_Attribute82        => x_charges_detail_rec.pricing_attribute82,
            P_Pricing_Attribute83        => x_charges_detail_rec.pricing_attribute83,
            P_Pricing_Attribute84        => x_charges_detail_rec.pricing_attribute84,
            P_Pricing_Attribute85        => x_charges_detail_rec.pricing_attribute85,
            P_Pricing_Attribute86        => x_charges_detail_rec.pricing_attribute86,
            P_Pricing_Attribute87        => x_charges_detail_rec.pricing_attribute87,
            P_Pricing_Attribute88        => x_charges_detail_rec.pricing_attribute88,
            P_Pricing_Attribute89        => x_charges_detail_rec.pricing_attribute89,
            P_Pricing_Attribute90        => x_charges_detail_rec.pricing_attribute90,
            P_Pricing_Attribute91        => x_charges_detail_rec.pricing_attribute91,
            P_Pricing_Attribute92        => x_charges_detail_rec.pricing_attribute92,
            P_Pricing_Attribute93        => x_charges_detail_rec.pricing_attribute93,
            P_Pricing_Attribute94        => x_charges_detail_rec.pricing_attribute94,
            P_Pricing_Attribute95        => x_charges_detail_rec.pricing_attribute95,
            P_Pricing_Attribute96        => x_charges_detail_rec.pricing_attribute96,
            P_Pricing_Attribute97        => x_charges_detail_rec.pricing_attribute97,
            P_Pricing_Attribute98        => x_charges_detail_rec.pricing_attribute98,
            P_Pricing_Attribute99        => x_charges_detail_rec.pricing_attribute99,
            P_Pricing_Attribute100       => x_charges_detail_rec.pricing_attribute100,
            x_return_status              => l_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data);

        --DBMS_OUTPUT.PUT_LINE('After calling CS_Pricing_Item_Pkg.Call_Pricing_Item ...');
        --DBMS_OUTPUT.PUT_LINE('l_msg_data '||l_msg_data);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          FND_MESSAGE.Set_Name('CS', 'CS_CHG_API_PRICING_ITEM_ERROR');
          FND_MESSAGE.set_token('INV_ID', x_charges_detail_rec.inventory_item_id_in);
          FND_MESSAGE.set_token('PRICE_LIST_ID', x_charges_detail_rec.price_list_id);
          FND_MESSAGE.set_token('UOM', x_charges_detail_rec.unit_of_measure_code);
          FND_MESSAGE.set_token('CURR_CODE', x_charges_detail_rec.currency_code);
          --FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data, TRUE);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Assign the after warranty that comes on the line
        x_charges_detail_rec.after_warranty_cost := p_charges_detail_rec.after_warranty_cost;

        IF l_conversion_needed_flag = 'Y' THEN
         --assign coverted amt to after_warranty_cost
         x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.after_warranty_cost * x_charges_detail_rec.conversion_rate;
         x_charges_detail_rec.list_price := l_list_price;

         --bug # 3056622 charge amount is zero for items with negative prices

         IF p_charges_detail_rec.selling_price <> FND_API.G_MISS_NUM AND
            p_charges_detail_rec.selling_price IS NOT NULL THEN
           x_charges_detail_rec.selling_price :=  p_charges_detail_rec.selling_price * x_charges_detail_rec.conversion_rate;
         ELSE
           x_charges_detail_rec.selling_price :=  x_charges_detail_rec.list_price;
         END IF;

        ELSE
          x_charges_detail_rec.after_warranty_cost := p_charges_detail_rec.after_warranty_cost;
          x_charges_detail_rec.list_price := l_list_price;

          --bug # 3056622 charge amount is zero for items with negative prices

          IF p_charges_detail_rec.selling_price IS NOT NULL THEN
            x_charges_detail_rec.selling_price :=  p_charges_detail_rec.selling_price;
          ELSE
            x_charges_detail_rec.selling_price :=  x_charges_detail_rec.list_price;
          END IF;
        END IF;


        --DBMS_OUTPUT.PUT_LINE(' after_warranty_cost '||x_charges_detail_rec.after_warranty_cost );
        --DBMS_OUTPUT.PUT_LINE(' selling price is '|| x_charges_detail_rec.selling_price);
        --DBMS_OUTPUT.PUT_LINE(' list price is '|| x_charges_detail_rec.list_price);
        --DBMS_OUTPUT.PUT_LINE(' apply_contract_discount is '||x_charges_detail_rec.apply_contract_discount);
        --DBMS_OUTPUT.PUT_LINE(' no_charge_flag is '||x_charges_detail_rec.no_charge_flag);
        --DBMS_OUTPUT.PUT_LINE('l_request_date is '||l_request_date);

        --Fixed Bug # 3468146
        --need to do this here so that contract discounting is done correctly
        --re-set the no_charge_flag for Charge Lines
        --since the line has come with after warranty cost from upstream
        IF x_charges_detail_rec.after_warranty_cost <> 0 THEN
          x_charges_detail_rec.no_charge_flag := 'N';
        END IF;

        --DBMS_OUTPUT.PUT_LINE('re-setting the no_charge_flag' ||x_charges_detail_rec.no_charge_flag);


        IF x_charges_detail_rec.apply_contract_discount = 'Y' AND
          x_charges_detail_rec.contract_line_id IS NOT NULL AND
          x_charges_detail_rec.no_charge_flag <> 'Y' THEN


          --DBMS_OUTPUT.PUT_LINE('calling contract discount ');


          --call contracts dicounting API
         CS_Est_Apply_Contract_PKG.Apply_Contract(
           p_coverage_id           => x_charges_detail_rec.contract_line_id,
           p_coverage_txn_group_id => x_charges_detail_rec.coverage_txn_group_id,
           p_txn_billing_type_id   => x_charges_detail_rec.txn_billing_type_id,
           P_BUSINESS_PROCESS_ID   => x_charges_detail_rec.business_process_id,
           P_REQUEST_DATE          => l_request_date,
           p_amount                => x_charges_detail_rec.after_warranty_cost,
           p_discount_amount       => l_contract_discount,
           X_RETURN_STATUS         => l_return_status,
           X_MSG_COUNT             => l_msg_count,
           X_MSG_DATA              => l_msg_data);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.Set_Name('CS', 'CS_CHG_APPLY_CONTRACT_WARNING');
            FND_MESSAGE.SET_TOKEN('REASON', l_msg_data);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          --DBMS_OUTPUT.PUT_LINE('l_contract_discount '||l_contract_discount);

         --Bug Fix for Bug # 3088397
         IF l_contract_discount IS NOT NULL THEN
           --assign the contract discount to the out record
           x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.after_warranty_cost - l_contract_discount;

           --apply discount
           x_charges_detail_rec.after_warranty_cost := l_contract_discount;

           --DBMS_OUTPUT.PUT_LINE(' contract discount is : '||x_charges_detail_rec.contract_discount_amount);
           --DBMS_OUTPUT.PUT_LINE(' after_warranty_cost  : '||x_charges_detail_rec.after_warranty_cost );

         ELSE
           -- contract discount amt should be 0
           --x_charges_detail_rec.contract_discount_amount := 0;
           null;

         END IF;

           --DBMS_OUTPUT.PUT_LINE('Contract 7'||x_charges_detail_rec.contract_discount_amount);
           --DBMS_OUTPUT.PUT_LINE(' contract discount is : '||x_charges_detail_rec.contract_discount_amount);
           --DBMS_OUTPUT.PUT_LINE(' after_warranty_cost  : '||x_charges_detail_rec.after_warranty_cost );
      ELSE
        --Apply contract discount = 'N'
        --Fixed Bug # 3220253
        --passed p_charges_detail_rec.contract_discount_amount
        x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;
        x_charges_detail_rec.contract_discount_amount := p_charges_detail_rec.contract_discount_amount;

         IF x_charges_detail_rec.contract_discount_amount IS NULL THEN
            x_charges_detail_rec.contract_discount_amount := 0;
         ELSE
            x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.contract_discount_amount;
         END IF;
      END IF ;
   ELSE
     --l_calc_sp = 'N'
     -- Assign the after warranty that is in the databse
        x_charges_detail_rec.after_warranty_cost := l_db_det_rec.after_warranty_cost;

    IF l_conversion_needed_flag = 'Y' AND
       l_db_det_rec.conversion_rate IS NULL THEN
       --assign coverted amt to after_warranty_cost

      --bug # 3056622 charge amount is zero for items with negative prices

      IF p_charges_detail_rec.selling_price <> FND_API.G_MISS_NUM AND
         p_charges_detail_rec.selling_price IS NOT NULL THEN
        x_charges_detail_rec.selling_price :=  p_charges_detail_rec.selling_price * x_charges_detail_rec.conversion_rate;
        x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.after_warranty_cost * x_charges_detail_rec.conversion_rate;
        x_charges_detail_rec.list_price := l_db_det_rec.list_price * x_charges_detail_rec.conversion_rate;
      ELSE
        x_charges_detail_rec.selling_price :=  l_db_det_rec.selling_price * x_charges_detail_rec.conversion_rate  ;
        x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.after_warranty_cost * x_charges_detail_rec.conversion_rate;
        x_charges_detail_rec.list_price := l_db_det_rec.list_price * x_charges_detail_rec.conversion_rate;
      END IF;

    ELSE
       --bug # 3056622 charge amount is zero for items with negative prices
       IF p_charges_detail_rec.selling_price <> FND_API.G_MISS_NUM AND
          p_charges_detail_rec.selling_price IS NOT NULL THEN
         x_charges_detail_rec.selling_price :=  p_charges_detail_rec.selling_price;
         x_charges_detail_rec.after_warranty_cost := x_charges_detail_rec.after_warranty_cost;
         x_charges_detail_rec.list_price := l_db_det_rec.list_price;
       ELSE
         x_charges_detail_rec.after_warranty_cost := l_db_det_rec.after_warranty_cost;
         x_charges_detail_rec.list_price := l_db_det_rec.list_price;
         x_charges_detail_rec.selling_price := l_db_det_rec.selling_price;
       END IF;
    END IF;

    --DBMS_OUTPUT.PUT_LINE(' after_warranty_cost '||x_charges_detail_rec.after_warranty_cost );

    IF x_charges_detail_rec.apply_contract_discount = 'Y' AND
       x_charges_detail_rec.contract_line_id IS NOT NULL AND
       x_charges_detail_rec.no_charge_flag <> 'Y' THEN


      --call contracts dicounting API
     CS_Est_Apply_Contract_PKG.Apply_Contract(
          p_coverage_id           => x_charges_detail_rec.contract_line_id,
          p_coverage_txn_group_id => x_charges_detail_rec.coverage_txn_group_id,
          p_txn_billing_type_id   => x_charges_detail_rec.txn_billing_type_id,
          P_BUSINESS_PROCESS_ID   => x_charges_detail_rec.business_process_id,
          P_REQUEST_DATE          => l_request_date,
          p_amount                => x_charges_detail_rec.after_warranty_cost,
          p_discount_amount       => l_contract_discount,
          X_RETURN_STATUS         => l_return_status,
          X_MSG_COUNT             => l_msg_count,
          X_MSG_DATA              => l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_APPLY_CONTRACT_WARNING');
        FND_MESSAGE.SET_TOKEN('REASON', l_msg_data);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --Bug Fix for Bug # 3088397
      IF l_contract_discount IS NOT NULL THEN
        --assign the contract discount to the out record
        x_charges_detail_rec.contract_discount_amount := x_charges_detail_rec.after_warranty_cost - l_contract_discount;

        --apply discount
        x_charges_detail_rec.after_warranty_cost := l_contract_discount;

       ELSE
          -- contract discount amt should be 0
          --x_charges_detail_rec.contract_discount_amount := 0;
          null;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('Contract 8'||x_charges_detail_rec.contract_discount_amount);

      --DBMS_OUTPUT.PUT_LINE('Contract Amount '||x_charges_detail_rec.contract_discount_amount );

    ELSE
      --Apply contract discount = 'N'
      --Fixed Bug # 3220253
      --passed p_charges_detail_rec.contract_discount_amount
      x_charges_detail_rec.apply_contract_discount := p_charges_detail_rec.apply_contract_discount;
      IF p_charges_detail_rec.contract_discount_amount <> FND_API.G_MISS_NUM OR
         p_charges_detail_rec.contract_discount_amount IS NOT NULL THEN
        x_charges_detail_rec.contract_discount_amount := l_db_rec.contract_discount_amount;
      ELSIF p_charges_detail_rec.contract_discount_amount IS NULL THEN
        x_charges_detail_rec.contract_discount_amount := 0;
      ELSE
        x_charges_detail_rec.contract_discount_amount := p_charges_detail_rec.contract_discount_amount;
      END IF;
    END IF ;
   END IF;
  END IF;
  IF   l_line_order_category_code = 'ORDER' THEN      --Bug 6960562
  /* Start : 5705568 */
--    If x_charges_detail_rec.after_warranty_cost < 0  Then
-- Bug 8305664 Removed the and  condition in the if statement.
  If x_charges_detail_rec.after_warranty_cost < 0  Then  -- bug 7459205
     x_charges_detail_rec.after_warranty_cost := 0;
  End If;
  /* End : 5705568 */
  End If;
END IF;

--==================================
--final re-set of no_charge_flag
--if after_warranty_cost <> 0
--Fixed Bug # 3468146
--since the line has come with after warranty cost from upstream
IF x_charges_detail_rec.after_warranty_cost <> 0 THEN
  x_charges_detail_rec.no_charge_flag := 'N';
END IF;


--===================================
--Validate Transaction Inventory Org
--===================================
--DBMS_OUTPUT.PUT_LINE('Validate Transaction Inventory Org ...');
--DBMS_OUTPUT.PUT_LINE('p_charges_detail_rec.transaction_inventory_org = '||p_charges_detail_rec.transaction_inventory_org);
IF p_validation_mode = 'I' THEN
  IF p_charges_detail_rec.transaction_inventory_org IS NOT NULL THEN
    l_valid_check := IS_TXN_INV_ORG_VALID(p_txn_inv_org   => p_charges_detail_rec.transaction_inventory_org,
                            --p_org_id         => l_org_id,
                           -- p_org_id           => x_charges_detail_rec.org_id,
			      p_inv_id           => x_charges_detail_rec.inventory_item_id_in,
                              x_msg_data         => l_msg_data,
                              x_msg_count        => l_msg_count,
                              x_return_status    => l_return_status  ) ;

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_valid_check <> 'Y' THEN
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_TXN_INV_ORG');
        FND_MESSAGE.Set_Token('ORG_ID', p_charges_detail_rec.transaction_inventory_org);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

  END IF;
  x_charges_detail_rec.transaction_inventory_org := p_charges_detail_rec.transaction_inventory_org;

ELSIF p_validation_mode = 'U' THEN
  -- assign from db record
  -- need to find out if we can update the transaction_inventory_org
  --

  IF p_charges_detail_rec.transaction_inventory_org <> FND_API.G_MISS_NUM AND
     p_charges_detail_rec.transaction_inventory_org IS NOT NULL THEN

     l_valid_check := IS_TXN_INV_ORG_VALID
                           (p_txn_inv_org   => p_charges_detail_rec.transaction_inventory_org,
                           -- p_org_id           => x_charges_detail_rec.org_id,
			    p_inv_id           => x_charges_detail_rec.inventory_item_id_in,
                            x_msg_data         => l_msg_data,
                            x_msg_count        => l_msg_count,
                            x_return_status    => l_return_status  ) ;

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_valid_check <> 'Y' THEN
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_TXN_INV_ORG');
        FND_MESSAGE.Set_Token('ORG_ID', p_charges_detail_rec.transaction_inventory_org);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      x_charges_detail_rec.transaction_inventory_org := p_charges_detail_rec.transaction_inventory_org;

  ELSIF p_charges_detail_rec.transaction_inventory_org  = FND_API.G_MISS_NUM THEN
      x_charges_detail_rec.transaction_inventory_org := l_db_det_rec.transaction_inventory_org;
  ELSE
      x_charges_detail_rec.transaction_inventory_org := NULL;
  END IF;

END IF;

--DBMS_OUTPUT.PUT_LINE('Validate Transaction Inventory Org completed. x_charges_detail_rec.transaction_inventory_org = '|| x_charges_detail_rec.transaction_inventory_org);


--===================================
-- Validate Order Information
--===================================
--DBMS_OUTPUT.PUT_LINE('Validate Order Information ...');

IF p_validation_mode = 'I' THEN

  IF x_charges_detail_rec.add_to_order_flag = 'Y' AND
     x_charges_detail_rec.interface_to_oe_flag = 'Y' THEN

    IF p_charges_detail_rec.order_header_id IS NULL THEN

      --Charges needs a order number when interfaceing
      --to OM if add to order flag = 'Y'

      --RAISE FND_API.G_EXC_ERROR;
      --null;
      FND_MESSAGE.Set_Name('CS', 'CS_CHG_ORDER_NUMBER_REQUIRED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE

      -- If order number provided then validate the order

      Validate_Order(
        p_api_name           => p_api_name,
        p_order_header_id    => p_charges_detail_rec.order_header_id,
        --p_org_id           => l_org_id,
        p_org_id             => x_charges_detail_rec.org_id,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        --RAISE FND_API.G_EXC_ERROR ;
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_ORDER');
        FND_MESSAGE.SET_TOKEN('ORDER_HEADER_ID', p_charges_detail_rec.order_header_id);
        --FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data, TRUE);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE

        x_charges_detail_rec.order_header_id := p_charges_detail_rec.order_header_id;
        x_charges_detail_rec.order_line_id :=  p_charges_detail_rec.order_line_id;

      END IF;

    END IF;

   ELSE

   --If the add_to_order_flag = 'Y' and order is provided

    IF x_charges_detail_rec.add_to_order_flag = 'Y' AND
       p_charges_detail_rec.order_header_id IS NOT NULL THEN

      Validate_Order(
        p_api_name           => p_api_name,
        p_order_header_id    => p_charges_detail_rec.order_header_id,
        --p_org_id           => l_org_id,
        p_org_id             => x_charges_detail_rec.org_id,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        --RAISE FND_API.G_EXC_ERROR ;
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_ORDER');
        FND_MESSAGE.SET_TOKEN('ORDER_HEADER_ID', p_charges_detail_rec.order_header_id);
        --FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data, TRUE);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

      ELSE

         x_charges_detail_rec.order_header_id := p_charges_detail_rec.order_header_id;
        x_charges_detail_rec.order_line_id :=  p_charges_detail_rec.order_line_id;

      END IF;

    --In all other cases

    ELSE

      x_charges_detail_rec.order_line_id := NULL;
      x_charges_detail_rec.order_header_id := NULL;

    END IF;
 END IF;

ELSIF p_validation_mode = 'U' THEN

 IF l_db_det_rec.order_line_id IS NULL THEN

   IF x_charges_detail_rec.add_to_order_flag = 'Y' AND
      x_charges_detail_rec.interface_to_oe_flag = 'Y' THEN


     IF p_charges_detail_rec.order_header_id <> FND_API.G_MISS_NUM AND
        p_charges_detail_rec.order_header_id IS NOT NULL THEN

         Validate_Order(
               p_api_name           => p_api_name,
               p_order_header_id    => p_charges_detail_rec.order_header_id,
               p_org_id             => x_charges_detail_rec.org_id,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data);

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           --RAISE FND_API.G_EXC_ERROR ;
           FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_ORDER');
           FND_MESSAGE.SET_TOKEN('ORDER_HEADER_ID', p_charges_detail_rec.order_header_id);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         ELSE
            x_charges_detail_rec.order_header_id := p_charges_detail_rec.order_header_id;
         END IF;

     ELSIF p_charges_detail_rec.order_header_id = FND_API.G_MISS_NUM THEN
       IF  l_db_det_rec.order_header_id IS NOT NULL THEN
         x_charges_detail_rec.order_header_id := l_db_det_rec.order_header_id;
       ELSE
         --order number required
         FND_MESSAGE.Set_Name('CS', 'CS_CHG_ORDER_NUMBER_REQUIRED');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     ELSE
       --order number not passed
       --order number required
       FND_MESSAGE.Set_Name('CS', 'CS_CHG_ORDER_NUMBER_REQUIRED');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     END IF;


   ELSE
     --If the add_to_order_flag = 'Y' and order is provided
     IF x_charges_detail_rec.add_to_order_flag = 'Y' AND
        p_charges_detail_rec.order_header_id <> FND_API.G_MISS_NUM AND
        p_charges_detail_rec.order_header_id IS NOT NULL THEN

      Validate_Order(
        p_api_name           => p_api_name,
        p_order_header_id    => p_charges_detail_rec.order_header_id,
        --p_org_id           => l_org_id,
        p_org_id             => x_charges_detail_rec.org_id,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        --RAISE FND_API.G_EXC_ERROR ;
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_ORDER');
        FND_MESSAGE.SET_TOKEN('ORDER_HEADER_ID', p_charges_detail_rec.order_header_id);
        --FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data, TRUE);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

      ELSE

        x_charges_detail_rec.order_header_id := p_charges_detail_rec.order_header_id;
        x_charges_detail_rec.order_line_id :=  p_charges_detail_rec.order_line_id;

      END IF;

     --In all other cases

    ELSE

      x_charges_detail_rec.order_line_id := NULL;
      x_charges_detail_rec.order_header_id := NULL;

    END IF;
   END IF;
 ELSE

   --cannot add to order
   --line already interfaced to om
   --raise error
   FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CANNOT_ADD_CHG_TO_ORDER');
   FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
   FND_MSG_PUB.Add;
   RAISE FND_API.G_EXC_ERROR;
 END IF;
END IF;


--===================================
--Validate Purchase Order Information
--===================================
--DBMS_OUTPUT.PUT_LINE('Validate Purchase Order Information ...');

IF p_validation_mode = 'I' THEN
  IF p_charges_detail_rec.purchase_order_num IS NOT NULL THEN
    -- assign to out record
    x_charges_detail_rec.purchase_order_num := p_charges_detail_rec.purchase_order_num;
  ELSE
    IF l_cust_po_number IS NOT NULL THEN
      -- assign the customer po number from service
      x_charges_detail_rec.purchase_order_num := l_cust_po_number;
    ELSE
      -- get the po number from contracts of a contract exists
      IF l_po_number IS NOT NULL THEN
        x_charges_detail_rec.purchase_order_num := l_po_number;
      ELSE
        x_charges_detail_rec.purchase_order_num := null;
      END IF;
    END IF;
  END IF;
ELSIF p_validation_mode = 'U' THEN
  -- bug Fix for Bug # 3084256
  IF p_charges_detail_rec.purchase_order_num <> FND_API.G_MISS_CHAR AND
     p_charges_detail_rec.purchase_order_num IS NOT NULL THEN
     x_charges_detail_rec.purchase_order_num := p_charges_detail_rec.purchase_order_num;
  ELSIF
     p_charges_detail_rec.purchase_order_num = FND_API.G_MISS_CHAR THEN
     x_charges_detail_rec.purchase_order_num := l_db_det_rec.purchase_order_num;
  ELSE
     --null is passed
     x_charges_detail_rec.purchase_order_num := null;
  END IF;
END IF;


--====================================
--Validate Billing Engine Information
--====================================
--DBMS_OUTPUT.PUT_LINE('Validate Billing Engine Information ...');

IF p_validation_mode = 'I' THEN

  IF p_charges_detail_rec.generated_by_bca_engine IS NULL THEN
    x_charges_detail_rec.generated_by_bca_engine := 'N';
  ELSE
    x_charges_detail_rec.generated_by_bca_engine := p_charges_detail_rec.generated_by_bca_engine;
  END IF;

  x_charges_detail_rec.activity_start_time := p_charges_detail_rec.activity_start_time;
  x_charges_detail_rec.activity_end_time := p_charges_detail_rec.activity_end_time;

  --DBMS_OUTPUT.PUT_LINE('Customer Product Id '||x_charges_detail_rec.customer_product_id);

END IF;

/* Credit Card 9358401 */
    IF (p_validation_mode = 'I') THEN
      IF (p_charges_detail_rec.instrument_payment_use_id =FND_API.G_MISS_NUM)       THEN
        x_charges_detail_rec.instrument_payment_use_id := NULL;
      ELSE
        x_charges_detail_rec.instrument_payment_use_id :=
	                          p_charges_detail_rec.instrument_payment_use_id;
      END IF;
    ELSE /*Update mode */
      IF (p_charges_detail_rec.instrument_payment_use_id =FND_API.G_MISS_NUM)
	 THEN
        x_charges_detail_rec.instrument_payment_use_id :=
	                                  l_db_det_rec.instrument_payment_use_id;
      ELSE
        x_charges_detail_rec.instrument_payment_use_id :=
	                          p_charges_detail_rec.instrument_payment_use_id;
      END IF;
    END IF; /*p_validation_mode*/

     IF x_charges_detail_rec.instrument_payment_use_id is not null then
	  l_credit_status := FALSE;
       CS_ServiceRequest_UTIL.validate_credit_card(
            p_api_name             => l_api_name,
            p_parameter_name       => 'P_INSTRUMENT_PAYMENT_USE_ID',
            p_instrument_payment_use_id  =>
		                     x_charges_detail_rec.instrument_payment_use_id,
            p_bill_to_acct_id      => x_charges_detail_rec.bill_to_account_id,
		  p_called_from          => p_validation_mode,
            x_return_status        => l_return_status);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_charges_detail_rec.instrument_payment_use_id := NULL;
         END IF;
     END IF;

       IF (p_validation_mode = 'I' AND
            x_charges_detail_rec.instrument_payment_use_id is NULL AND
		  p_charges_detail_rec.instrument_payment_use_id is not null AND
            l_credit_status) THEN
            BEGIN
             SELECT instrument_payment_use_id
               INTO x_charges_detail_rec.instrument_payment_use_id
               FROM CS_INCIDENTS_ALL_B
             WHERE  incident_id = p_charges_detail_rec.incident_id;

            EXCEPTION
            WHEN OTHERS THEN
             NULL;
            END;
       END IF;

  --DBMS_OUTPUT.PUT_LINE('ORDER_LINE_ID IS '||x_charges_detail_rec.order_line_id);


--=================================
--Assign to out record --
--=================================

   -- Exception Block
   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Validate_Charge_Details_PUB;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count,
          p_data  => x_msg_data,
          p_encoded => FND_API.G_FALSE);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Validate_Charge_Details_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count,
          p_data  => x_msg_data,
          p_encoded => FND_API.G_FALSE);

      WHEN OTHERS THEN
        ROLLBACK TO Validate_Charge_Details_PUB;
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_UNEXPECTED_EXEC_ERRORS');
        FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name);
        FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm);
        FND_MSG_PUB.ADD;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
        END IF ;
        fnd_msg_pub.count_and_get(
           p_count => x_msg_count
          ,p_data  => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;

END VALIDATE_CHARGE_DETAILS;


--==================================
-- Get Defaults from Service Request
--==================================

PROCEDURE GET_SR_DEFAULTS(P_API_NAME               IN          VARCHAR2,
                          P_INCIDENT_ID            IN          NUMBER,
                          X_BUSINESS_PROCESS_ID    OUT NOCOPY  NUMBER,
                          X_CUSTOMER_ID            OUT NOCOPY  NUMBER,
                          X_CUSTOMER_SITE_ID       OUT NOCOPY  NUMBER,
                          X_CUST_PO_NUMBER         OUT NOCOPY  VARCHAR2,
                          X_CUSTOMER_PRODUCT_ID    OUT NOCOPY  NUMBER,
                          X_SYSTEM_ID              OUT NOCOPY  NUMBER, -- Fix bug
                          X_INVENTORY_ITEM_ID      OUT NOCOPY  NUMBER, -- Fix bug
                          X_ACCOUNT_ID             OUT NOCOPY  NUMBER,
                          X_BILL_TO_PARTY_ID       OUT NOCOPY  NUMBER,
                          X_BILL_TO_ACCOUNT_ID     OUT NOCOPY  NUMBER,
                          X_BILL_TO_CONTACT_ID     OUT NOCOPY  NUMBER,
                          X_BILL_TO_SITE_ID        OUT NOCOPY  NUMBER,
                          X_SHIP_TO_PARTY_ID       OUT NOCOPY  NUMBER,
                          X_SHIP_TO_ACCOUNT_ID     OUT NOCOPY  NUMBER,
                          X_SHIP_TO_CONTACT_ID     OUT NOCOPY  NUMBER,
                          X_SHIP_TO_SITE_ID        OUT NOCOPY  NUMBER,
                          X_CONTRACT_ID            OUT NOCOPY  NUMBER,
                          X_CONTRACT_SERVICE_ID    OUT NOCOPY  NUMBER,
                          X_INCIDENT_DATE          OUT NOCOPY  DATE,
                          X_CREATION_DATE          OUT NOCOPY  DATE,
                          X_MSG_DATA               OUT NOCOPY  VARCHAR2,
                          X_MSG_COUNT              OUT NOCOPY  NUMBER,
                          X_RETURN_STATUS          OUT NOCOPY  VARCHAR2) IS


CURSOR c_incidents_def(p_incident_id IN NUMBER) IS

  SELECT intp.business_process_id,
            inc.customer_id,
            inc.customer_site_id,
            inc.contract_id,
            inc.contract_service_id,
            inc.customer_po_number,
            inc.customer_product_id,
            inc.system_id,         -- Fix bug
            inc.inventory_item_id, -- Fix bug
            inc.account_id,
            inc.incident_date,
            inc.creation_date,
            substr(hza.account_name,1,30),
            NVL(inc.bill_to_party_id, -999)  bill_to_party_id,
            NVL(inc.ship_to_party_id, -999)  ship_to_party_id,
            NVL(inc.bill_to_site_id,-999),bill_to_site_id,
            NVL(inc.ship_to_site_id,-999)ship_to_site_id,
	    NVL(inc.bill_to_account_id,-999) bill_to_account_id,
	    NVL(inc.ship_to_account_id,-999) ship_to_account_id,
	    NVL(inc.bill_to_contact_id,-999) bill_to_contact_id,
	    NVL(inc.ship_to_contact_id,-999) ship_to_contact_id,
	    inc.caller_type
     FROM   cs_incidents_all_b inc,
            CS_INCIDENT_TYPES intp,
            CS_BUSINESS_PROCESSES bp,
            hz_parties hzp,
            hz_cust_accounts hza
     WHERE  inc.incident_id = p_incident_id
     AND    inc.incident_type_id = intp.incident_type_id
     AND    intp.business_process_id = bp.business_process_id
     AND    inc.customer_id = hzp.party_id
     AND    inc.account_id  = hza.cust_account_id(+);




BEGIN

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  FOR v_incidents_def IN c_incidents_def(p_incident_id) LOOP

    x_business_process_id    :=  v_incidents_def.business_process_id;
    x_customer_id            :=  v_incidents_def.customer_id;
    x_customer_site_id       :=  v_incidents_def.customer_site_id;
    x_cust_po_number         :=  v_incidents_def.customer_po_number;
    x_customer_product_id    :=  v_incidents_def.customer_product_id;
    x_system_id              :=  v_incidents_def.system_id;
    x_inventory_item_id      :=  v_incidents_def.inventory_item_id;
    x_account_id             :=  v_incidents_def.account_id;
    x_bill_to_party_id       :=  v_incidents_def.bill_to_party_id;
    x_bill_to_account_id     :=  v_incidents_def.bill_to_account_id;
    x_bill_to_contact_id     :=  v_incidents_def.bill_to_contact_id;
    x_bill_to_site_id        :=  v_incidents_def.bill_to_site_id;
    x_ship_to_party_id       :=  v_incidents_def.ship_to_party_id;
    x_ship_to_account_id     :=  v_incidents_def.ship_to_account_id;
    x_ship_to_contact_id     :=  v_incidents_def.ship_to_contact_id;
    x_ship_to_site_id        :=  v_incidents_def.ship_to_site_id;
    x_contract_id            :=  v_incidents_def.contract_id;
    x_contract_service_id    :=  v_incidents_def.contract_service_id;
    x_incident_date          :=  v_incidents_def.incident_date;
    x_creation_date          :=  v_incidents_def.creation_date;

  END LOOP;

  EXCEPTION

    WHEN OTHERS THEN
      x_return_status :=  FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(
        p_count => x_msg_count,
        p_data  => x_msg_data);

END GET_SR_DEFAULTS;

--================================
--Validate Transaction Type Id
--================================
PROCEDURE VALIDATE_TXN_TYPE(P_API_NAME                  IN         VARCHAR2,
                            P_BUSINESS_PROCESS_ID       IN         NUMBER,
                            P_TXN_TYPE_ID               IN         NUMBER,
                            P_SOURCE_CODE               IN         VARCHAR2,
                            X_LINE_ORDER_CATEGORY_CODE  OUT NOCOPY VARCHAR2,
                            X_NO_CHARGE_FLAG            OUT NOCOPY VARCHAR2,
                            X_INTERFACE_TO_OE_FLAG      OUT NOCOPY VARCHAR2,
                            X_UPDATE_IB_FLAG            OUT NOCOPY VARCHAR2,
                            X_SRC_REFERENCE_REQD_FLAG   OUT NOCOPY VARCHAR2,
                            X_SRC_RETURN_REQD_FLAG      OUT NOCOPY VARCHAR2,
                            X_NON_SRC_REFERENCE_REQD    OUT NOCOPY VARCHAR2,
                            X_NON_SRC_RETURN_REQD       OUT NOCOPY VARCHAR2,
                            X_MSG_DATA                  OUT NOCOPY VARCHAR2,
                            X_MSG_COUNT                 OUT NOCOPY NUMBER,
                            X_RETURN_STATUS             OUT NOCOPY VARCHAR2) IS

Cursor c_txn_type(p_txn_type_id         IN NUMBER,
                  p_business_process_id IN NUMBER) IS
SELECT  tt.transaction_type_id,
        NVL(citt.src_reference_reqd,'N') src_reference_reqd,
        NVL(citt.src_return_reqd,'N') src_return_reqd,
        citt.src_change_owner_to_code,
        NVL(citt.non_src_reference_reqd,'N') non_src_reference_reqd,
        NVL(citt.non_src_return_reqd,'N') non_src_return_reqd,
        citt.non_src_change_owner_to_code,
        NVL(csit.update_ib_flag,'N') update_ib_flag,
        nvl(tt.no_charge_flag, 'N') no_charge_flag,
        nvl(tt.interface_to_oe_flag, 'N')interface_to_oe_flag,
        tt.line_order_category_code,
        ol.meaning line_category_meaning
FROM    CS_TRANSACTION_TYPES_VL  tt,
        CS_BUS_PROCESS_TXNS  bt,
        csi_ib_txn_types citt,
        csi_source_ib_types csit,
        CSI_TXN_TYPES ctt,
        OE_LOOKUPS ol
WHERE  tt.transaction_type_id = p_txn_type_id
  and  bt.business_process_id = p_business_process_id
  and  bt.transaction_type_id = tt.transaction_type_id
  and  tt.line_order_category_code is not null
  and  ol.lookup_code = tt.line_order_category_code
  and  ol.lookup_type = 'LINE_CATEGORY'
  and  tt.transaction_type_id = citt.cs_transaction_type_id (+)
  and nvl(citt.parent_reference_reqd, 'N') = 'N'
  and nvl(ctt.source_transaction_type, 'OM_SHIPMENT') =
  decode(tt.line_order_category_code, 'ORDER', 'OM_SHIPMENT',
  nvl(ctt.source_transaction_type, 'OM_SHIPMENT'))
  and nvl(ctt.source_transaction_type, 'RMA_RECEIPT') =
  decode(tt.line_order_category_code, 'RETURN', 'RMA_RECEIPT',
  nvl(ctt.source_transaction_type, 'RMA_RECEIPT'))
  and citt.sub_type_id = csit.sub_type_id (+)
  and csit.transaction_type_id = ctt.transaction_type_id (+)
  and nvl(ctt.source_application_id, 660) = 660
  and trunc(sysdate) between trunc(nvl(bt.start_date_active, sysdate))
  and trunc(nvl(bt.end_date_active, sysdate));




Cursor c_txn_type_sd(p_txn_type_id         IN NUMBER,
                     p_business_process_id IN NUMBER) IS
SELECT  tt.transaction_type_id,
        nvl(tt.no_charge_flag, 'N') no_charge_flag,
        nvl(tt.interface_to_oe_flag, 'N')interface_to_oe_flag,
        tt.line_order_category_code,
        ol.meaning line_category_meaning
FROM    CS_TRANSACTION_TYPES_VL  tt,
        CS_BUS_PROCESS_TXNS  bt,
        OE_LOOKUPS ol
WHERE  tt.transaction_type_id = p_txn_type_id
  and  bt.business_process_id = p_business_process_id
  and  bt.transaction_type_id = tt.transaction_type_id
  and  tt.line_order_category_code is not null
  and  ol.lookup_code = tt.line_order_category_code
  and  ol.lookup_type = 'LINE_CATEGORY'
  and trunc(sysdate) between trunc(nvl(bt.start_date_active, sysdate))
  and trunc(nvl(bt.end_date_active, sysdate));

  lv_exists_flag VARCHAR2(1) := 'N';

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --DBMS_OUTPUT.PUT_LINE(' Source Code = :'||p_source_code);

  IF p_source_code <> 'SD' THEN

    FOR v_txn_type IN c_txn_type(p_txn_type_id, p_business_process_id) LOOP
      lv_exists_flag := 'Y';

      -- Check with Anu if this logic is OK here
      IF v_txn_type.line_order_category_code = 'RETURN' THEN
        IF v_txn_type.src_change_owner_to_code = 'E' THEN
          --RAISE FND_API.G_EXC_ERROR;
          --null;
          FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_TXN_TYPE_OWNER');
          FND_MESSAGE.SET_TOKEN('TXN_TYPE_ID', p_txn_type_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      ELSIF v_txn_type.line_order_category_code = 'ORDER' THEN
        IF v_txn_type.non_src_change_owner_to_code = 'E' THEN
          --RAISE FND_API.G_EXC_ERROR;
          --null;
          FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_TXN_TYPE_OWNER');
          FND_MESSAGE.SET_TOKEN('TXN_TYPE_ID', p_txn_type_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      x_line_order_category_code  := v_txn_type.line_order_category_code;
      x_no_charge_flag            := v_txn_type.no_charge_flag;
      x_interface_to_oe_flag      := v_txn_type.interface_to_oe_flag;
      x_update_ib_flag            := v_txn_type.update_ib_flag;
      x_src_reference_reqd_flag   := v_txn_type.src_reference_reqd;
      x_src_return_reqd_flag      := v_txn_type.src_return_reqd;
      x_non_src_reference_reqd    := v_txn_type.non_src_reference_reqd;
      x_non_src_return_reqd       := v_txn_type.non_src_return_reqd;

    END LOOP;

  ELSE

     FOR v_txn_type_sd IN c_txn_type_sd(p_txn_type_id, p_business_process_id) LOOP
      lv_exists_flag := 'Y';

      x_line_order_category_code  := v_txn_type_sd.line_order_category_code;
      x_no_charge_flag            := v_txn_type_sd.no_charge_flag;
      x_interface_to_oe_flag      := v_txn_type_sd.interface_to_oe_flag;
     END LOOP;
  END IF;



  IF lv_exists_flag = 'N' THEN
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_TXN_TYPE');
    FND_MESSAGE.SET_TOKEN('TXN_TYPE_ID', p_txn_type_id);
    FND_MESSAGE.SET_TOKEN('BUSINESS_PROCESS_ID', p_business_process_id);
    FND_MSG_PUB.Add;

    RAISE FND_API.G_EXC_ERROR;

  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);


    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_TXN_TYPE');
      FND_MESSAGE.SET_TOKEN('TXN_TYPE_ID', p_txn_type_id);
      FND_MESSAGE.SET_TOKEN('BUSINESS_PROCESS_ID', p_business_process_id);
      FND_MSG_PUB.Add;

      fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);




END VALIDATE_TXN_TYPE;


--=================================
-- Validate Inventory Item ID
--=================================
PROCEDURE VALIDATE_ITEM(P_API_NAME             IN         VARCHAR2,
                        P_INV_ID               IN         NUMBER,
                        P_UPDATE_IB_FLAG       IN         VARCHAR2,
                        X_COMMS_TRACKABLE_FLAG OUT NOCOPY VARCHAR2,
                        X_SERIAL_CONTROL_FLAG  OUT NOCOPY VARCHAR2,
                        X_REV_CONTROL_FLAG     OUT NOCOPY VARCHAR2,
                        X_MSG_DATA             OUT NOCOPY VARCHAR2,
                        X_MSG_COUNT            OUT NOCOPY NUMBER,
                        X_RETURN_STATUS        OUT NOCOPY VARCHAR2) IS

Cursor c_get_inv_item(p_inv_id NUMBER) IS
SELECT inventory_item_id,
       serial_number_control_code,
       revision_qty_control_code,
       nvl(comms_nl_trackable_flag, 'N') comms_nl_trackable_flag
       -- contract_item_type_code -- Fix for Bug # 3109160
 FROM MTL_SYSTEM_ITEMS_KFV
WHERE organization_id = cs_std.get_item_valdn_orgzn_id
  AND inventory_item_id = p_inv_id;



lv_exists_flag VARCHAR2(1) := 'N';

BEGIN


  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --DBMS_OUTPUT.PUT_LINE('cs_std.get_item_valdn_orgzn_id = ' || cs_std.get_item_valdn_orgzn_id);
  --DBMS_OUTPUT.PUT_LINE('p_inv_id = ' || p_inv_id);
  --DBMS_OUTPUT.PUT_LINE('p_update_ib_flag = ' || p_update_ib_flag);


  FOR v_get_inv_item IN c_get_inv_item(p_inv_id) LOOP

    x_comms_trackable_flag := v_get_inv_item.comms_nl_trackable_flag;

      --DBMS_OUTPUT.PUT_LINE('inside loop');
      --DBMS_OUTPUT.PUT_LINE('comms_nl_trackable '||v_get_inv_item.comms_nl_trackable_flag);

    --Comment this for bug # 3809160
    --

    -- IF NOT (NVL(v_get_inv_item.contract_item_type_code, 'N') = 'N') THEN
    -- lv_exists_flag := 'N';
    -- --RAISE FND_API.G_EXC_ERROR;
    -- FND_MESSAGE.Set_Name('CS', 'CS_CHG_CONTRACT_ITEM_ERROR');
    -- FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inv_id, TRUE);
    -- FND_MSG_PUB.Add;
    -- RAISE FND_API.G_EXC_ERROR;
    -- END IF;

    ------DBMS_OUTPUT.PUT_LINE('v_get_inv_item.contract_item_type_code '||v_get_inv_item.contract_item_type_code);

     -- Indicator If Serial Number Controlled or not
    IF v_get_inv_item.serial_number_control_code <> 1 THEN
      x_serial_control_flag := 'Y';
    ELSE
      x_serial_control_flag := 'N';
    END IF;

    --DBMS_OUTPUT.PUT_LINE('v_get_inv_item.serial_number_control_code '||v_get_inv_item.serial_number_control_code);


    -- Indicator If Item Revision Controlled or not
    IF v_get_inv_item.revision_qty_control_code <> 1 THEN
      x_rev_control_flag := 'Y';
    ELSE
      x_rev_control_flag := 'N';
    END IF;

    lv_exists_flag := 'Y';

  END LOOP;
  --DBMS_OUTPUT.PUT_LINE('lv_exists_flag '||lv_exists_flag);

  IF lv_exists_flag = 'N' THEN
   -- --DBMS_OUTPUT.PUT_LINE('lv_exists_flag = ' || 'N');
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_INVENTORY_ITEM');
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inv_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  EXCEPTION

  WHEN FND_API.G_EXC_ERROR  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_INVENTORY_ITEM');
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inv_id);
    FND_MSG_PUB.Add;
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

END VALIDATE_ITEM;

--==============================================
-- Get Item Billing Flag
--==============================================

PROCEDURE GET_BILLING_FLAG(
                 P_API_NAME            IN         VARCHAR2,
                 P_INV_ID              IN         NUMBER,
                 P_TXN_TYPE_ID         IN         NUMBER,
                 X_BILLING_FLAG        OUT NOCOPY VARCHAR2,
                 X_MSG_DATA            OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT           OUT NOCOPY NUMBER,
                 X_RETURN_STATUS       OUT NOCOPY VARCHAR2) IS

Cursor c_get_billing_flag(p_inv_id IN NUMBER,
                          p_txn_type_id IN NUMBER) IS
SELECT bc.billing_category
  FROM cs_billing_type_categories bc,
  cs_txn_billing_types bt
  WHERE sysdate between nvl(bc.start_date_active,sysdate)
    AND nvl(bc.end_date_active,sysdate)
    AND sysdate between nvl(bt.start_date_active,sysdate)
                            AND nvl(bt.end_date_active,sysdate)
                            AND bt.billing_type = bc.billing_type
                            AND bt.transaction_type_id = p_txn_type_id
                            AND bc.billing_type IN (SELECT material_billable_flag
                                                      FROM MTL_SYSTEM_ITEMS_KFV
                                                     WHERE organization_id = cs_std.get_item_valdn_orgzn_id
                                                       AND inventory_item_id = p_inv_id);


lv_exists_flag VARCHAR2(1) := 'N';

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- --DBMS_OUTPUT.PUT_LINE('p_inv_id = ' || p_inv_id);
 -- --DBMS_OUTPUT.PUT_LINE('p_txn_type_id = ' || p_txn_type_id);

  FOR v_get_billing_flag in c_get_billing_flag(p_inv_id, p_txn_type_id) LOOP

    lv_exists_flag := 'Y';
    x_billing_flag := v_get_billing_flag.billing_category;

  END LOOP;

  IF lv_exists_flag <> 'Y' THEN
    --RAISE FND_API.G_EXC_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_ITM_BILL_FLG_NOT_IN_TXN');
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inv_id);
    FND_MESSAGE.SET_TOKEN('TXN_TYPE_ID', p_txn_type_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --DBMS_OUTPUT.PUT_LINE('lv_exists_flag = ' || lv_exists_flag);
  --DBMS_OUTPUT.PUT_LINE('x_return_status = ' || x_return_status);

  EXCEPTION

  WHEN FND_API.G_EXC_ERROR  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_ITM_BILL_FLG_NOT_IN_TXN');
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inv_id);
    FND_MESSAGE.SET_TOKEN('TXN_TYPE_ID', p_txn_type_id);
    FND_MSG_PUB.Add;
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

END GET_BILLING_FLAG;


--=============================================
-- Get Txn Billing Type Id
--=============================================
PROCEDURE GET_TXN_BILLING_TYPE(
                 P_API_NAME            IN         VARCHAR2,
                 P_INV_ID              IN         NUMBER,
                 P_TXN_TYPE_ID         IN         NUMBER,
                 X_TXN_BILLING_TYPE_ID OUT NOCOPY NUMBER,
                 X_MSG_DATA            OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT           OUT NOCOPY NUMBER,
                 X_RETURN_STATUS       OUT NOCOPY VARCHAR2) IS

Cursor c_txn_billing_type(p_inventory_item_id   IN NUMBER,
                          p_txn_type_id         IN NUMBER) IS
  SELECT ctbt.txn_billing_type_id
    FROM mtl_system_items_kfv kfv,
         cs_txn_billing_types ctbt
   WHERE kfv.inventory_item_id = p_inventory_item_id
     AND organization_id = cs_std.get_item_valdn_orgzn_id   --
     AND ctbt.transaction_type_id = p_txn_type_id
     AND ctbt.billing_type = kfv.material_billable_flag;

  lv_exists_flag VARCHAR2(1) := 'N';


BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR v_txn_billing_type IN c_txn_billing_type(p_inv_id,
                p_txn_type_id) LOOP
    x_txn_billing_type_id := v_txn_billing_type.txn_billing_type_id;
    lv_exists_flag := 'Y';
  END LOOP;

  IF lv_exists_flag <> 'Y' THEN
    --RAISE FND_API.G_EXC_ERROR;
    --null;
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_ITM_BILL_TYP_NOT_IN_TXN');
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inv_id);
    FND_MESSAGE.SET_TOKEN('TXN_TYPE_ID', p_txn_type_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  EXCEPTION

  WHEN FND_API.G_EXC_ERROR  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_ITM_BILL_TYP_NOT_IN_TXN');
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inv_id);
    FND_MESSAGE.SET_TOKEN('TXN_TYPE_ID', p_txn_type_id);
    FND_MSG_PUB.Add;
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

END GET_TXN_BILLING_TYPE;


--==============================================
-- Get Unit Of Measure
--==============================================

PROCEDURE GET_UOM(P_INV_ID            IN NUMBER,
                  X_TBL_UOM           OUT NOCOPY TBL_UOM,
                  X_MSG_DATA          OUT NOCOPY VARCHAR2,
                  X_MSG_COUNT         OUT NOCOPY NUMBER,
                  X_RETURN_STATUS     OUT NOCOPY VARCHAR2) IS


Cursor c_uom(p_inv_id IN NUMBER) IS
SELECT   uom_code
  FROM   MTL_ITEM_UOMS_VIEW
  WHERE  inventory_item_id = P_INV_ID AND
         organization_id = cs_std.get_item_valdn_orgzn_id;

i NUMBER := 0;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR v_uom IN c_uom(p_inv_id) LOOP
    i := i + 1;
    X_TBL_UOM(i).unit_of_measure := v_uom.uom_code;
  END LOOP;

  EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_GET_UOM_FAILED');
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inv_id);
    FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', cs_std.get_item_valdn_orgzn_id);
    FND_MSG_PUB.Add;
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

END GET_UOM;


--================================================
-- Get Primary Unit of Measure
--================================================

PROCEDURE GET_PRIMARY_UOM(P_INV_ID            IN NUMBER,
                          X_PRIMARY_UOM       OUT NOCOPY VARCHAR2,
                          X_MSG_DATA          OUT NOCOPY VARCHAR2,
                          X_MSG_COUNT         OUT NOCOPY NUMBER,
                          X_RETURN_STATUS     OUT NOCOPY VARCHAR2)
IS

Cursor c_primary_uom(p_inv_id IN NUMBER) IS
 SELECT mum.uom_code
  FROM  mtl_system_items_b msi,
        MTL_UNITS_OF_MEASURE_TL mum
 WHERE msi.PRIMARY_UNIT_OF_MEASURE = mum.unit_of_measure
   AND msi.INVENTORY_ITEM_ID = P_INV_ID
   AND msi.organization_id = cs_std.get_item_valdn_orgzn_id;

lv_exists_flag VARCHAR2(1) := 'N';
BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR v_primary_uom IN c_primary_uom(p_inv_id) LOOP
    lv_exists_flag := 'Y';
    x_primary_uom := v_primary_uom.uom_code;
  END LOOP;

  IF lv_exists_flag = 'N' THEN
    --RAISE FND_API.G_EXC_ERROR;
    --null;
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_GET_UOM_FAILED');
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inv_id);
    FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', cs_std.get_item_valdn_orgzn_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_GET_UOM_FAILED');
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inv_id);
    FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', cs_std.get_item_valdn_orgzn_id);
    FND_MSG_PUB.Add;
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

END GET_PRIMARY_UOM;

--================================================
-- Validate Source Code and Source Id being passed
--===============================================
PROCEDURE VALIDATE_SOURCE(
                P_API_NAME          IN   VARCHAR2,
                P_SOURCE_CODE       IN   VARCHAR2,
                P_SOURCE_ID         IN   NUMBER,
                P_ORG_ID            IN   NUMBER,
                X_SOURCE_ID         OUT NOCOPY   NUMBER,
                X_MSG_DATA          OUT NOCOPY VARCHAR2,
                X_MSG_COUNT         OUT NOCOPY NUMBER,
                X_RETURN_STATUS     OUT NOCOPY   VARCHAR2)  IS

Cursor c_val_sr_source(p_source_id IN NUMBER) IS

-- Bug Fix for Bug # 3044488
SELECT incident_id
  FROM CS_INCIDENTS_ALL_b
 WHERE incident_id = p_source_id;
   --AND org_id = p_org_id;

Cursor c_val_dr_source(p_source_id IN NUMBER) IS
SELECT repair_line_id
  FROM CSD_REPAIRS
 WHERE repair_line_id = p_source_id;

Cursor c_val_sd_source(p_source_id IN NUMBER) IS
--SELECT debrief_header_id
--  FROM csf_debrief_headers
-- WHERE debrief_header_id = p_source_id ;
SELECT debrief_line_id
  FROM csf_debrief_lines
 WHERE debrief_line_id = p_source_id;

lv_exists_flag  VARCHAR2(1) := 'N';

--DEBUG
l_ERRM VARCHAR2(100);

BEGIN
-- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --DBMS_OUTPUT.PUT_LINE('p_source_code  = ' || p_source_code);
  --DBMS_OUTPUT.PUT_LINE('p_source_id  = ' || p_source_id);
  --DBMS_OUTPUT.PUT_LINE('p_org_id  = ' || p_org_id);

  IF p_source_code = 'SR' THEN

    IF  p_source_id IS NOT NULL THEN
      FOR v_val_sr_source IN c_val_sr_source(p_source_id) LOOP
        lv_exists_flag := 'Y';
        x_source_id := p_source_id;
      END LOOP;

      IF lv_exists_flag <> 'Y' THEN
        --RAISE FND_API.G_EXC_ERROR;
        --null;
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_SOURCE');
        FND_MESSAGE.SET_TOKEN('SOURCE_CODE', p_source_code);
        FND_MESSAGE.SET_TOKEN('SOURCE_ID', p_source_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSE
      -- source_id cannot be cannot be null
      Add_Null_Parameter_Msg(p_api_name, 'p_source_id');
      RAISE FND_API.G_EXC_ERROR;
    END IF ;

  ELSIF p_source_code = 'DR' THEN
    IF  p_source_id  IS NOT NULL  THEN
      FOR v_val_dr_source IN c_val_dr_source(p_source_id) LOOP
        lv_exists_flag := 'Y';
        x_source_id := p_source_id;
      END LOOP;

      IF lv_exists_flag <> 'Y' THEN
        --RAISE FND_API.G_EXC_ERROR;
        --null;
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_SOURCE');
        FND_MESSAGE.SET_TOKEN('SOURCE_CODE', p_source_code);
        FND_MESSAGE.SET_TOKEN('SOURCE_ID', p_source_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSE
      -- source_id cannot be cannot be null
      Add_Null_Parameter_Msg(p_api_name, 'p_source_id');
      RAISE FND_API.G_EXC_ERROR;
    END IF ;

  ELSIF p_source_code = 'SD' THEN
    IF  p_source_id  IS NOT NULL  THEN
      FOR v_val_dr_source IN c_val_sd_source(p_source_id) LOOP
        lv_exists_flag := 'Y';
        x_source_id := p_source_id;
      END LOOP;

      IF lv_exists_flag <> 'Y' THEN
        --RAISE FND_API.G_EXC_ERROR;
        --null;
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_SOURCE');
        FND_MESSAGE.SET_TOKEN('SOURCE_CODE', p_source_code);
        FND_MESSAGE.SET_TOKEN('SOURCE_ID', p_source_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSE
      -- raise error as source_id cannot be cannot be null
      Add_Null_Parameter_Msg(p_api_name, 'p_source_id');
      RAISE FND_API.G_EXC_ERROR;
    END IF ;

  ELSIF p_source_code = 'SD' THEN
    IF  p_source_id  IS NOT NULL  THEN
      FOR v_val_sd_source IN c_val_sd_source(p_source_id) LOOP

        lv_exists_flag := 'Y';
        x_source_id := p_source_id;
      END LOOP;

      IF lv_exists_flag <> 'Y' THEN
        --RAISE FND_API.G_EXC_ERROR;
        --null;
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_SOURCE');
        FND_MESSAGE.SET_TOKEN('SOURCE_CODE', p_source_code);
        FND_MESSAGE.SET_TOKEN('SOURCE_ID', p_source_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      -- cannot be null
      Add_Null_Parameter_Msg(p_api_name, 'p_source_id');
      RAISE FND_API.G_EXC_ERROR;
    END IF ;

  ELSE
    --Invalid source code passed. Raise an exception
    Add_Invalid_Argument_Msg(
      p_token_an => p_api_name,
      p_token_v  => p_source_code,
      p_token_p  => 'p_source_code');

    RAISE FND_API.G_EXC_ERROR;
  END IF ;

  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF  p_source_id IS NOT NULL THEN
      Add_Invalid_Argument_Msg(p_token_an => p_api_name,
        p_token_v  => p_source_id,
        p_token_p  => 'p_source_id');
    END IF ;

  WHEN OTHERS THEN
    --l_ERRM := SQLERRM;
    --DBMS_OUTPUT.PUT_LINE('Others Validate Source ' ||l_errm);
    --x_return_status := FND_API.G_RET_STS_ERROR ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_SOURCE');
    FND_MESSAGE.SET_TOKEN('SOURCE_CODE', p_source_code);
    FND_MESSAGE.SET_TOKEN('SOURCE_ID', p_source_id);
    FND_MSG_PUB.Add;
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

END  Validate_Source;

--===========================================================
-- Get Site Id
--==========================================================

PROCEDURE GET_SITE_FOR_PARTY(P_API_NAME          IN         VARCHAR2,
                             P_SITE_USE_ID       IN         NUMBER,
                             P_PARTY_ID          IN         NUMBER,
                             P_VAL_MODE          IN         VARCHAR2,
                             X_SITE_ID           OUT NOCOPY NUMBER,
                             X_RETURN_STATUS     OUT NOCOPY VARCHAR2) IS

CURSOR c_bill_to_party_site(P_SITE_USE_ID IN NUMBER,
                            P_PARTY_ID    IN NUMBER) IS
SELECT site_use.party_site_id
  FROM  HZ_PARTY_SITE_USES site_use,
        HZ_PARTY_SITES site,
        HZ_PARTIES party
 WHERE  site_use.party_site_use_id = p_site_use_id
   AND  party.party_id = p_party_id
   AND  nvl(site_use.status,'A') = 'A'
   AND  site_use.site_use_type = 'BILL_TO'
   AND  site_use.party_site_id = site.party_site_id
   AND  site.party_id   = party.party_id;

CURSOR c_ship_to_party_site(p_site_use_id IN NUMBER,
                            p_party_id    IN NUMBER) IS
SELECT site_use.party_site_id
  FROM  HZ_PARTY_SITE_USES site_use,
        HZ_PARTY_SITES site,
        HZ_PARTIES party
 WHERE  site_use.party_site_use_id = p_site_use_id
   AND  party.party_id = p_party_id
   AND  nvl(site_use.status,'A') = 'A'
   AND  site_use.site_use_type = 'SHIP_TO'
   AND  site_use.party_site_id = site.party_site_id
   AND  site.party_id   = party.party_id;

lv_exists_flag VARCHAR2(1) := 'N';
BEGIN

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
   IF p_val_mode = 'BILL_TO' THEN
     FOR v_bill_to_party_site IN c_bill_to_party_site(p_site_use_id, p_party_id) LOOP
       lv_exists_flag := 'Y';
       x_site_id := v_bill_to_party_site.party_site_id;
     END LOOP;
   ELSE
      --p_val_mode = 'SHIP_TO'
      FOR v_ship_to_party_site IN c_ship_to_party_site(p_site_use_id, p_party_id) LOOP
       lv_exists_flag := 'Y';
       x_site_id := v_ship_to_party_site.party_site_id;
     END LOOP;
   END IF;

   IF lv_exists_flag = 'N' THEN
     --RAISE FND_API.G_EXC_ERROR;
     --null;
     FND_MESSAGE.Set_Name('CS', 'CS_CHG_NO_SITE_FOUND');
     FND_MESSAGE.SET_TOKEN('PARTY_ID', p_party_id);
     FND_MESSAGE.SET_TOKEN('SITE_USE_ID', p_site_use_id);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_NO_SITE_FOUND');
    FND_MESSAGE.SET_TOKEN('PARTY_ID', p_party_id);
    FND_MESSAGE.SET_TOKEN('SITE_USE_ID', p_site_use_id);
    FND_MSG_PUB.Add;

END get_site_for_party;


--============================================================
-- Get Price List for Contract
--============================================================
PROCEDURE GET_CONTRACT_PRICE_LIST(
                p_api_name               IN         VARCHAR2,
                p_business_process_id    IN         NUMBER,
                p_request_date           IN         DATE,
                p_contract_line_id       IN         NUMBER,
                --p_coverage_id            IN         NUMBER,
                x_price_list_id          OUT NOCOPY NUMBER,
                x_currency_code          OUT NOCOPY VARCHAR2,
                x_msg_data               OUT NOCOPY VARCHAR2,
                x_msg_count              OUT NOCOPY NUMBER,
                x_return_status          OUT NOCOPY VARCHAR2) IS



--Added to get the currency_code for the price list header id
--Fixed Bug # 3546804
Cursor get_currency_code(p_price_list_id NUMBER) IS
  select currency_code
    from qp_price_lists_v
   where price_list_id = p_price_list_id;

--Added to get the currency_code for the price list header id
--Fixed Bug # 3546804
l_pricing_tbl      OKS_CON_COVERAGE_PUB.pricing_tbl_type ;
l_index           BINARY_INTEGER;



BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Changed the functionality to resolve bug # 3546804

  IF p_business_process_id IS NOT NULL AND
     p_request_date IS NOT NULL AND
     p_contract_line_id IS NOT NULL THEN


       --Call the OKC API
       OKS_CON_COVERAGE_PUB.get_bp_pricelist
                         (p_api_version         => 1.0
                         ,p_init_msg_list       => 'T'
                         ,p_Contract_line_id    => p_contract_line_id
                         ,p_business_process_id => p_business_process_id
                         ,p_request_date        => p_request_date
                         ,x_return_status       => x_return_status
                         ,x_msg_count           => x_msg_count
                         ,x_msg_data            => x_msg_data
                         ,x_pricing_tbl         => l_pricing_tbl);

        l_index := l_pricing_tbl.FIRST;

        FOR l_temp IN 1..l_pricing_tbl.COUNT LOOP
          --get the Business Process Price List ID
          x_price_list_id := l_pricing_tbl(l_index).BP_Price_list_id;

          --get the currency_code for the same
          OPEN get_currency_code(x_price_list_id);
          FETCH get_currency_code INTO x_currency_code;
          CLOSE get_currency_code;

          EXIT WHEN l_index = l_pricing_tbl.FIRST ;
        END LOOP;
  ELSE
    -- p_business_process_id or p_request_date is null
    -- default the contract price list and currency code to null
    -- as this cannot be derived
    x_price_list_id := null;
    x_currency_code := null;
  END IF;

  EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('CS', 'CS_CHG_UNEXPECTED_EXEC_ERRORS');
     FND_MESSAGE.SET_TOKEN('ROUTINE', p_api_name);
     FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm);
     FND_MSG_PUB.ADD;
     fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data  => x_msg_data);

END get_contract_price_list;

--===========================================================
-- Get Currency Code for Price List
--===========================================================

PROCEDURE  GET_CURRENCY_CODE(
                p_api_name        IN         VARCHAR2,
                p_price_list_id   IN         NUMBER ,
                x_currency_code   OUT NOCOPY VARCHAR2,
                x_msg_data        OUT NOCOPY VARCHAR2,
                x_msg_count       OUT NOCOPY NUMBER,
                x_return_status   OUT NOCOPY VARCHAR2)
IS

Cursor c_currency_code(p_price_list_id NUMBER) IS
SELECT currency_code
FROM   qp_price_lists_v
WHERE  price_list_id = p_price_list_id;

lv_exists_flag VARCHAR2(1) := 'N';
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_price_list_id IS NOT NULL THEN
    FOR v_currency_code IN c_currency_code(p_price_list_id) LOOP
      --assign currency_code to out record
      x_currency_code := v_currency_code.currency_code;
      lv_exists_flag := 'Y';
    END LOOP;

    IF lv_exists_flag <> 'Y' THEN
      --RAISE FND_API.G_EXC_ERROR;
      --null;
      FND_MESSAGE.Set_Name('CS', 'CS_CHG_GET_CURRENCY_FAILED');
      FND_MESSAGE.SET_TOKEN('PRICE_LIST_ID', p_price_list_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    --price list id is null
    -- this should never happen
    --RAISE FND_API.G_EXC_ERROR;
    --null;
    Add_Null_Parameter_Msg(p_api_name, 'p_price_list_id');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_GET_CURRENCY_FAILED');
    FND_MESSAGE.SET_TOKEN('PRICE_LIST_ID', p_price_list_id);
    FND_MSG_PUB.Add;
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

END get_currency_code;

--============================================================
-- Get_Conversion_Rate - To get the conversion rate
--=============================================================

 PROCEDURE  Get_Conversion_Rate
                   ( p_api_name       IN VARCHAR2,
                     p_from_currency  IN  VARCHAR2,
                     p_to_currency    IN  VARCHAR2,
                     x_denominator    OUT NOCOPY NUMBER,
                     x_numerator      OUT NOCOPY NUMBER,
                     x_rate           OUT NOCOPY NUMBER,
                     x_return_status  OUT NOCOPY VARCHAR) IS

  l_api_name  VARCHAR2(80)                   :=  'CS_Charge_Details_PVT.Get_Conversion_Rate';
  l_api_name_full  CONSTANT  VARCHAR2(61)    := G_PKG_NAME || '.' || l_api_name ;
  l_log_module     CONSTANT VARCHAR2(255)    := 'cs.plsql.' || l_api_name_full || '.';
  l_conversion_type VARCHAR2(30) :=   FND_PROFILE.VALUE('CS_CHG_DEFAULT_CONVERSION_TYPE');
  l_max_roll_days   NUMBER       :=   to_number(FND_PROFILE.VALUE('CS_CHG_MAX_ROLL_DAYS'));
  lx_numerator       NUMBER;
  lx_denominator     NUMBER;
  lx_rate            NUMBER;

  BEGIN

    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --DBMS_OUTPUT.PUT_LINE('Conversion Type is '||l_conversion_type);
    --DBMS_OUTPUT.PUT_LINE('l_max_roll_days '||l_max_roll_days);

      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
      THEN
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE || ''
	, 'The Value of profile CS_CHG_DEFAULT_CONVERSION_TYPE :' || l_conversion_type
	);
	FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE || ''
	, 'The Value of profile CS_CHG_MAX_ROLL_DAYS :' || l_max_roll_days
	);
      END IF;

   IF p_from_currency IS NULL THEN
     -- return error
     FND_MESSAGE.SET_NAME('CS', 'CS_CHG_UNDEFINED_CONV_CURRENCY');
     FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
     FND_MESSAGE.SET_TOKEN('FROM_CURRENCY', p_from_currency);
     FND_MESSAGE.SET_TOKEN('TO_CURRENCY', p_to_currency);
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_error;
   END IF;

   IF p_to_currency IS NULL THEN
     -- return error
     FND_MESSAGE.SET_NAME('CS', 'CS_CHG_UNDEFINED_CONV_CURRENCY');
     FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
     FND_MESSAGE.SET_TOKEN('FROM_CURRENCY', p_from_currency);
     FND_MESSAGE.SET_TOKEN('TO_CURRENCY', p_to_currency);
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_error;
   END IF;

   IF ((l_conversion_type IS NULL) OR
       (l_max_roll_days IS NULL)) THEN
     -- return error
     FND_MESSAGE.SET_NAME('CS', 'CS_CHG_UNDEFINED_CONV_PROFILES');
     FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
     FND_MESSAGE.SET_TOKEN('PROFILE1', 'CS_CHG_DEFAULT_CONVERSION_TYPE');
     FND_MESSAGE.SET_TOKEN('PROFILE2', 'CS_CHG_MAX_ROLL_DAYS');
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_error;
   END IF;


   IF  ((l_conversion_type IS NOT NULL) AND
        (l_max_roll_days IS NOT NULL)) THEN
            gl_currency_api.get_closest_triangulation_rate (
                x_from_currency      => p_from_currency,
                x_to_currency        => p_to_currency,
                x_conversion_date    => SYSDATE,
                x_conversion_type    => l_conversion_type,
                x_max_roll_days      => l_max_roll_days,
                x_denominator        => lx_denominator,
                x_numerator          => lx_numerator,
                x_rate               => lx_rate );

     IF lx_rate IS NULL THEN
       --RAISE FND_API.g_exc_error;
       FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CONV_RATE_NOT_FOUND');
       FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
       FND_MESSAGE.SET_TOKEN('FROM_CURRENCY', p_from_currency);
       FND_MESSAGE.SET_TOKEN('TO_CURRENCY', p_to_currency);
       FND_MESSAGE.SET_TOKEN('CONV_DATE', sysdate);
       FND_MSG_PUB.add;
       RAISE FND_API.g_exc_error;
     ELSE
       x_denominator := lx_denominator;
       x_numerator   := lx_numerator;
       x_rate        := lx_rate;
     END IF;
  END IF;

  EXCEPTION

    WHEN FND_API.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CONV_RATE_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
      FND_MESSAGE.SET_TOKEN('FROM_CURRENCY', p_from_currency);
      FND_MESSAGE.SET_TOKEN('TO_CURRENCY', p_to_currency);
      FND_MESSAGE.SET_TOKEN('CONV_DATE', sysdate);
      FND_MSG_PUB.add;

END Get_Conversion_Rate;

--============================================================
-- Get Contracts - Contracts information for Contract Service ID
--============================================================

PROCEDURE GET_CONTRACT(
                  p_api_name               IN VARCHAR2,
                  p_contract_SR_ID         IN NUMBER,
                  p_incident_date          IN DATE,
                  p_creation_date          IN DATE,
                  p_customer_id            IN NUMBER,
                  p_cust_account_id        IN NUMBER,
                  p_cust_product_id        IN NUMBER,
                  p_system_id              IN NUMBER DEFAULT NULL,   -- Fix bug
                  p_inventory_item_id      IN NUMBER DEFAULT NULL,   -- Fix bug
                  p_business_process_id    IN NUMBER,
                  x_contract_id            OUT NOCOPY NUMBER,
                  x_po_number              OUT NOCOPY VARCHAR2,
                  x_return_status          OUT NOCOPY VARCHAR2,
                  x_msg_count              OUT NOCOPY NUMBER,
                  x_msg_data               OUT NOCOPY VARCHAR2) IS

--Changed to Fix Bug # 3419211
Cursor Con_Coverage(p_service_line_id number,p_business_process_id number) IS
 SELECT     cov.contract_id
            --cov.coverage_line_id,
            --cov.coverage_name,
            --ent.txn_group_id
   FROM     oks_ent_line_details_v cov,
            oks_ent_txn_groups_v ent
  WHERE     cov.service_line_id = p_service_line_id
    AND     cov.coverage_line_id = ent.coverage_id
    AND     ent.business_process_id = p_business_process_id;

 TYPE T_CHCONCOVTAB IS TABLE OF Con_Coverage%rowtype
     INDEX BY BINARY_INTEGER;

 CHCONCOVTAB T_CHCONCOVTAB;



l_count          NUMBER := 0;
l_record_count   NUMBER := 0;
k                NUMBER := 0;
l_ent_contracts OKS_ENTITLEMENTS_PUB.GET_CONTOP_TBL;
l_request_date   DATE;

l_Service_PO_required VARCHAR2(30);
l_result  VARCHAR2(1);
l_return_status VARCHAR2(1);
l_service_po VARCHAR2(30);



BEGIN

 --Fixed Bug # 3480770
 -- Initiate contract value.
 x_contract_id := null;
 --x_coverage_id := null;
 --x_coverage_txn_group_id := null;
 x_po_number := null;

-- derive the request date which will be passed to the
-- CS_EST_APPLY_Contract_Pkg.Get_Contract_lines API
-- if p_incident_date is null then use p_creation_date

IF p_incident_date IS NOT NULL THEN
  l_request_date := p_incident_date;
ELSE
  l_request_date := p_creation_date;
END IF;


  --Changed to Fix Bug # 3419211
  IF p_contract_sr_id IS NOT NULL AND
     p_business_process_id IS NOT NULL THEN

      OPEN Con_Coverage(p_contract_sr_id, p_business_process_id);
      FETCH Con_Coverage
      INTO  CHCONCOVTAB(k);
      --Fixed Bug # 3480770
      IF Con_Coverage%FOUND THEN
        x_contract_id := CHCONCOVTAB(k).contract_id;
        --x_coverage_id := CHCONCOVTAB(k).coverage_line_id;
        --x_coverage_txn_group_id := CHCONCOVTAB(k).TXN_GROUP_ID;
      END IF;
      CLOSE Con_Coverage;


      --DBMS_OUTPUT.PUT_LINE('Calling PO Cursor');

      IF x_contract_id IS NOT NULL THEN
        -- call the Contracts API to get the PO NUmber
        OKS_ENTITLEMENTS_PVT.Get_Service_PO(
          P_Chr_Id               => x_contract_id,
          P_Set_ExcepionStack    => 'F',
          X_Service_PO           => l_service_po,
          X_Service_PO_required  => l_Service_po_required,
          X_Result               => l_result,
          X_Return_Status        => l_return_status);

        --DBMS_OUTPUT.PUT_LINE('l_return_status'||l_return_status);

        IF l_return_status  = 'S' THEN
          x_po_number := l_service_po;
        ELSIF l_return_status  IN ('E', 'U') THEN
          x_po_number := null;
        END IF;
      END IF;
  ELSE
    --RAISE FND_API.G_EXC_ERROR;
    --null;
    FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CONTRACT_ERROR');
    FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
    FND_MESSAGE.SET_TOKEN('CONTRACT_SERVICE_LINE_ID', p_contract_sr_id);
    FND_MESSAGE.SET_TOKEN('BUSINESS_PROCESS_ID', p_business_process_id);
    FND_MSG_PUB.add;
    RAISE FND_API.g_exc_error;
  END IF;

  EXCEPTION

    WHEN FND_API.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_count => x_msg_count
       ,p_data  => x_msg_data);

END get_contract;

--=============================================================
-- Get Charge Detail Record
--=============================================================

PROCEDURE GET_CHARGE_DETAIL_REC(
             P_API_NAME               IN         VARCHAR2,
             P_ESTIMATE_DETAIL_ID     IN         NUMBER,
             x_CHARGE_DETAIL_REC      OUT NOCOPY CS_ESTIMATE_DETAILS%ROWTYPE ,
             x_MSG_DATA               OUT NOCOPY VARCHAR2,
             x_MSG_COUNT              OUT NOCOPY NUMBER,
             x_RETURN_STATUS          OUT NOCOPY VARCHAR2) IS
BEGIN

  --DBMS_OUTPUT.PUT_LINE('In GET_CHARGE_DETAIL_REC .....');

  -- Initialize the  p_return_status  to TRUE
         --p_return_status :=  FND_API.G_RET_STS_SUCCESS ;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS ;

                 SELECT *
                 INTO x_charge_detail_rec
                 FROM CS_ESTIMATE_DETAILS
                 WHERE ESTIMATE_DETAIL_ID = p_estimate_detail_id
                 FOR UPDATE OF  ESTIMATE_DETAIL_ID NOWAIT ;

 EXCEPTION
        WHEN NO_DATA_FOUND THEN
         CS_Charge_Details_PVT.Add_Invalid_Argument_Msg(
                         p_token_an  =>  p_api_name,
                         p_token_v   =>  to_char(p_estimate_detail_id) ,
                         p_token_p   =>  'p_estimate_detail_id') ;
        fnd_msg_pub.count_and_get(
          p_count => x_msg_count
         ,p_data  => x_msg_data);

        WHEN RECORD_LOCK_EXCEPTION THEN
             --p_return_status := FND_API.G_RET_STS_ERROR ;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             CS_Charge_Details_PVT.Record_Is_Locked_Msg(
                             p_token_an => p_api_name);

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CHARGE_FAILED');
      FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
      FND_MESSAGE.SET_TOKEN('ESTIMATE_DETAIL_ID', p_estimate_detail_id);
      FND_MSG_PUB.add;
      fnd_msg_pub.count_and_get(
        p_count => x_msg_count
       ,p_data  => x_msg_data);

END;


--=============================================================
--Do_Txns_Exist -- Can This be a function instead of a procedure
--============================================================
PROCEDURE Do_Txns_Exist(
               p_api_name             IN          VARCHAR2,
               p_estimate_detail_id   IN          NUMBER ,
               x_order_line_id        OUT NOCOPY  NUMBER,
               x_gen_bca_flag         OUT NOCOPY  VARCHAR2,
               x_charge_line_type     OUT NOCOPY  VARCHAR2,
               x_return_status        OUT NOCOPY  VARCHAR2)  AS
BEGIN
      --p_return_status :=  FND_API.G_RET_STS_SUCCESS ;
      x_return_status :=  FND_API.G_RET_STS_SUCCESS;
        SELECT order_line_id,
               GENERATED_BY_BCA_ENGINE_FLAG,
               Charge_line_type
        INTO   x_order_line_id,
               x_gen_bca_flag,
               x_charge_line_type
        FROM   CS_ESTIMATE_DETAILS
        WHERE  estimate_detail_id = p_estimate_detail_id
        FOR UPDATE OF ESTIMATE_DETAIL_ID NOWAIT ;


EXCEPTION
        WHEN NO_DATA_FOUND THEN
             --p_return_status :=  FND_API.G_RET_STS_ERROR ;
             x_return_status :=  FND_API.G_RET_STS_ERROR ;
             Add_Invalid_Argument_Msg(p_token_an => p_api_name,
                  p_token_v => to_char(p_estimate_detail_id) ,
                  p_token_p => 'estimate_detail_id' ) ;

        WHEN RECORD_LOCK_EXCEPTION THEN
             --p_return_status := FND_API.G_RET_STS_ERROR ;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             Record_Is_Locked_Msg(p_token_an => p_api_name);

        WHEN OTHERS THEN
             --p_return_status :=  FND_API.G_RET_STS_ERROR ;
             x_return_status :=  FND_API.G_RET_STS_ERROR ;

END Do_Txns_Exist ;


--=================================
-- Validate Org Id
--================================

PROCEDURE VALIDATE_ORG_ID(
                  P_API_NAME       IN VARCHAR2,
                  P_ORG_ID         IN NUMBER,
                  X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
                  X_MSG_COUNT      OUT NOCOPY NUMBER,
                  X_MSG_DATA       OUT NOCOPY VARCHAR2)

IS

Cursor c_org_id IS
  SELECT organization_id
    FROM hr_operating_units
   WHERE organization_id = p_org_id;

lv_exists_flag VARCHAR2(1) := 'N';

BEGIN

  FOR v_org_id IN c_org_id
    LOOP
      lv_exists_flag := 'Y';
    END LOOP;

  IF lv_exists_flag = 'Y' THEN
    x_return_status :=  FND_API.G_RET_STS_SUCCESS ;
  ELSE
    raise NO_DATA_FOUND;
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
         CS_Charge_Details_PVT.Add_Invalid_Argument_Msg(
                         p_token_an  =>  p_api_name,
                         p_token_v   =>  to_char(p_org_id) ,
                         p_token_p   =>  'p_org_id') ;

         fnd_msg_pub.count_and_get(
           p_count => x_msg_count
          ,p_data  => x_msg_data);


  WHEN OTHERS THEN
         x_return_status :=  FND_API.G_RET_STS_ERROR ;

END VALIDATE_ORG_ID;


--==================================
-- Add_Invalid_Argument_Msg
--==================================

PROCEDURE Add_Invalid_Argument_Msg
( p_token_an	VARCHAR2,
  p_token_v	VARCHAR2,
  p_token_p	VARCHAR2
)
IS

BEGIN

  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('VALUE', p_token_v);
    FND_MESSAGE.Set_Token('PARAMETER', p_token_p);
    FND_MSG_PUB.Add;

  END IF;

END Add_Invalid_Argument_Msg;


--====================================
-- Add_Null_Parameter_Msg
--====================================

PROCEDURE Add_Null_Parameter_Msg
( p_token_an	VARCHAR2,
  p_token_np	VARCHAR2
)
IS

BEGIN

  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_NULL_PARAMETER');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('NULL_PARAM', p_token_np);
    FND_MSG_PUB.Add;

  END IF;

END Add_Null_Parameter_Msg;

--============================
--Cannot_Delete_Line_Msg
--============================
PROCEDURE Cannot_Delete_Line_Msg
( p_token_an    IN      VARCHAR2
)
IS
BEGIN
    FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_CANT_DELETE_DET');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MSG_PUB.Add;
END;


--============================
--
--============================
PROCEDURE Cant_Update_Detail_Param_Msg
( p_token_an            IN      VARCHAR2,
  p_token_cn            IN      VARCHAR2,
  p_token_v             IN      VARCHAR2
) IS
BEGIN
    FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_CANT_UPD_DET_PARAM');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('COLUMN_NAME', p_token_cn);
    FND_MESSAGE.Set_Token('VALUE', p_token_v);
    FND_MSG_PUB.Add;
END;



--=============================
-- Record_Is_Locked_msg
--=============================

PROCEDURE Record_Is_Locked_Msg
( p_token_an	VARCHAR2
)
IS

BEGIN

    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_CANT_LOCK_RECORD');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MSG_PUB.Add;
END Record_IS_Locked_Msg;


PROCEDURE Validate_Who_Info(
                 P_API_NAME                  IN            VARCHAR2,
                 P_USER_ID                   IN            NUMBER,
                 P_LOGIN_ID                  IN            NUMBER,
                 X_RETURN_STATUS             OUT NOCOPY    VARCHAR2) IS

  CURSOR c_user IS
  SELECT 1
  FROM   fnd_user
  WHERE  user_id = p_user_id
  AND    TRUNC(SYSDATE) <= start_date
  AND    NVL(end_date, SYSDATE) >= SYSDATE;

  CURSOR c_login IS
  SELECT 1
  FROM   fnd_logins
  WHERE  login_id = p_login_id
  AND    user_id = p_user_id;

  l_dummy  VARCHAR2(1);

BEGIN

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   BEGIN
      IF p_user_id = -1 then
         SELECT 'x' into l_dummy
         FROM    fnd_user
         WHERE   user_id = p_user_id;
      ELSE
         SELECT 'x' into l_dummy
         FROM    fnd_user
         WHERE   user_id = p_user_id
         AND trunc(sysdate) BETWEEN trunc(nvl(start_date, sysdate))
         AND trunc(nvl(end_date, sysdate));
      END IF;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg(p_token_an => p_api_name,
                                  p_token_v  => TO_CHAR(p_user_id),
                                  p_token_p  => 'p_user_id');
      return;
   END;

   IF p_login_id is not null then
   BEGIN
      SELECT 'x' into l_dummy
      FROM       fnd_logins
      WHERE   login_id = p_login_id
      AND        user_id  = p_user_id;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg(p_token_an => p_api_name,
                                  p_token_v  => TO_CHAR(p_login_id),
                                  p_token_p  => 'p_user_login');
   END;
   END IF;

END Validate_Who_Info;

-- Get line type id.
--Fixed Bug # 3325667 added p_org_id to procedure get_line_type
Procedure Get_Line_Type(p_api_name              IN VARCHAR2,
                        p_txn_billing_type_id   IN  NUMBER,
                        p_org_id                IN  NUMBER,
                        x_line_type_id          OUT NOCOPY  NUMBER,
                        x_return_status         OUT NOCOPY VARCHAR2,
                        x_msg_count             OUT NOCOPY NUMBER,
                        x_msg_data              OUT NOCOPY VARCHAR2) IS

--Fixed Bug # 3325667 added p_org_id to procedure get_line_type
CURSOR get_line_type_csr IS
   select tb.line_type_id
   from cs_txn_billing_oetxn_all tb, cs_txn_billing_types tt
   where tb.txn_billing_type_id = p_txn_billing_type_id
   and tb.txn_billing_type_id = tt.txn_billing_type_id and
   tb.org_id = p_org_id;

BEGIN
   --DBMS_OUTPUT.PUT_LINE('p_txn_billing_type_id = ' || p_txn_billing_type_id);

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
   x_line_type_id := null;

   OPEN get_line_type_csr;
   FETCH get_line_type_csr
   INTO x_line_type_id;
   IF get_line_type_csr%NOTFOUND THEN
      CLOSE get_line_type_csr;
      FND_MESSAGE.SET_NAME('CS', 'CS_CHG_LINE_TYPE_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID', p_txn_billing_type_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE get_line_type_csr;
   --DBMS_OUTPUT.PUT_LINE('x_return_status = ' || x_return_status);

   -- Exception Block
   EXCEPTION
      WHEN FND_API.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
          p_count => x_msg_count
         ,p_data  => x_msg_data);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         fnd_msg_pub.count_and_get(
            p_count   => x_msg_count
           ,p_data    => x_msg_data);
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('CS', 'CS_CHG_UNEXPECTED_EXEC_ERRORS');
         FND_MESSAGE.SET_TOKEN('ROUTINE', p_api_name);
         FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data  => x_msg_data);

END Get_Line_Type;

--==================================================
-- GET_CHARGE_FLAGS_FROM_SR
--==================================================

--Bug Fix for Bug # 3086455
PROCEDURE get_charge_flags_from_sr(p_api_name                IN          VARCHAR2,
                                   p_incident_id             IN          NUMBER,
                                   x_disallow_new_charge     OUT NOCOPY  VARCHAR2,
                                   x_disallow_charge_update  OUT NOCOPY  VARCHAR2,
                                   x_msg_data                OUT NOCOPY  VARCHAR2,
                                   x_msg_count               OUT NOCOPY  NUMBER,
                                   x_return_status           OUT NOCOPY  NUMBER
                                   )IS

cursor c_charge_flags(p_incident_id IN NUMBER)IS
select nvl(csinst.disallow_new_charge, 'N'),
       nvl(csinst.disallow_charge_update, 'N')
 from cs_incident_statuses csinst,
      cs_incidents_all csinall
 where csinst.incident_status_id = csinall.incident_status_id
 and   csinall.incident_id = p_incident_id;


BEGIN

  OPEN c_charge_flags(p_incident_id);
   FETCH c_charge_flags
   INTO x_disallow_new_charge, x_disallow_charge_update;
   IF c_charge_flags%NOTFOUND THEN
      CLOSE c_charge_flags;
        --Add null argument error
        Add_Invalid_Argument_Msg(p_token_an => p_api_name,
                                  p_token_v  => TO_CHAR(p_incident_id),
                                  p_token_p  => 'p_incident_id');
        RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE c_charge_flags;
 END;


--========================
--CHARGE FLAG
--========================

--added by bkanimoz on 15-dec-2007

PROCEDURE  get_charge_flag_from_sac
                            (p_api_name                IN  VARCHAR2,
                             p_txn_type_id             IN  NUMBER,
                             x_create_charge_flag      OUT NOCOPY  VARCHAR2,
			     x_msg_data                OUT NOCOPY  VARCHAR2,
                             x_msg_count               OUT NOCOPY  NUMBER,
                             x_return_status           OUT NOCOPY  NUMBER
                             )IS

cursor c_create_charge_flag ( p_txn_type_id IN NUMBER)IS
select nvl(ctt.create_charge_flag, 'Y')
from   cs_transaction_types_b  ctt
where transaction_type_id= p_txn_type_id ;


BEGIN

  OPEN c_create_charge_flag(p_txn_type_id);
   FETCH c_create_charge_flag
   INTO x_create_charge_flag;
   IF c_create_charge_flag%NOTFOUND THEN
      CLOSE c_create_charge_flag;
        --Add null argument error
        Add_Invalid_Argument_Msg(p_token_an => p_api_name,
                                  p_token_v  => TO_CHAR(p_txn_type_id),
                                  p_token_p  => 'p_txn_type_id');
        RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE c_create_charge_flag;

END;




--========================
-- VALIDATE_ORDER
--========================

PROCEDURE Validate_Order(p_api_name              IN VARCHAR2,
                         p_order_header_id       IN NUMBER,
                         p_org_id                IN NUMBER,
                         x_return_status         OUT NOCOPY VARCHAR2,
                         x_msg_count             OUT NOCOPY NUMBER,
                         x_msg_data              OUT NOCOPY VARCHAR2) IS

CURSOR order_csr IS
   SELECT header_id,
          open_flag
     FROM OE_ORDER_HEADERS_ALL ooha,
          HZ_CUST_ACCOUNTS acct,
          HZ_PARTIES hp
    WHERE ooha.sold_to_org_id = acct.cust_account_id
    AND   acct.party_id       = hp.party_id
    AND   ooha.header_id      = p_order_header_id
    AND   ooha.org_id         = p_org_id;

l_order_header_id   NUMBER;
l_open_flag       VARCHAR2(1);

BEGIN
   -- Initialize Return Status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN order_csr;
   FETCH order_csr
   INTO l_order_header_id, l_open_flag;
   IF order_csr%NOTFOUND THEN
      CLOSE order_csr;
        FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_ORDER');
        FND_MESSAGE.SET_TOKEN('ORDER_HEADER_ID', p_order_header_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE order_csr;

   --Bug Fix for Bug # 3085106

   IF l_open_flag = 'N' THEN
     FND_MESSAGE.Set_Name('CS', 'CS_CHG_CANNOT_ADD_TO_ORDER');
     FND_MESSAGE.Set_token('API_NAME', p_api_name);
     FND_MESSAGE.SET_TOKEN('ORDER_HEADER_ID', p_order_header_id);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- Exception Block
   EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get(
            p_count   => x_msg_count
           ,p_data    => x_msg_data);

      WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('CS', 'CS_CHG_UNEXPECTED_EXEC_ERRORS');
         FND_MESSAGE.SET_TOKEN('ROUTINE', p_api_name);
         FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data  => x_msg_data);
         x_return_status := FND_API.G_RET_STS_ERROR;

END Validate_Order;

--------------------------------------------------------------------------------
--  Procedure Name            :   PURGE_CHG_VALIDATIONS
--
--  Parameters (other than standard ones)
--  IN
--      p_object_type         :   Type of object for which this procedure is
--                                being called. (Here it will be 'SR')
--      p_processing_set_id   :   Id that helps the API in identifying the
--                                set of SRs for which the child objects have
--                                to be deleted.
--
--  Description
--      This procedure identifies the charge lines that are related to an SR
--      and verifies if they can be deleted. The conditions checked during the
--      varification are: if the charge line is 'ACTUAL' and if it does not have
--      an order line id, the line cannot be deleted. In this case, the global
--      temp table is updated with a purge_status as E against that SR which
--      contains such a charge line.
--
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  4-Aug-2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
PROCEDURE Purge_Chg_Validations
(
  p_api_version_number IN  NUMBER := 1.0
, p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
, p_commit             IN  VARCHAR2 := FND_API.G_FALSE
, p_object_type        IN  VARCHAR2
, p_processing_set_id  IN  NUMBER
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
)
IS
--------------------------------------------------------------------------------

L_API_VERSION   CONSTANT NUMBER        := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30)  := 'PURGE_CHG_VALIDATIONS';
L_API_NAME_FULL CONSTANT VARCHAR2(61)  := G_PKG_NAME || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

l_row_count     NUMBER := 0;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL
      || ', called with parameters below:'
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_api_version_number:' || p_api_version_number
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_object_type:' || p_object_type
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_processing_set_id:' || p_processing_set_id
    );
  END IF ;

  IF NOT FND_API.Compatible_API_Call
  (
    L_API_VERSION
  , p_api_version_number
  , L_API_NAME
  , G_PKG_NAME
  )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ------------------------------------------------------------------------------
  -- Parameter Validations:
  ------------------------------------------------------------------------------

  IF NVL(p_object_type, 'X') <> 'SR'
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'object_type_invalid'
      , 'p_object_type has to be SR.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_object_type');
    FND_MESSAGE.Set_Token('CURRVAL', p_object_type);
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ---

  IF p_processing_set_id IS NULL
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'proc_set_id_invalid'
      , 'p_processing_set_id should not be NULL.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_processing_set_id');
    FND_MESSAGE.Set_Token('CURRVAL', NVL(to_char(p_processing_set_id),'NULL'));
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ------------------------------------------------------------------------------
  -- Actual Logic starts below:
  ------------------------------------------------------------------------------

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'valid_chg_line_start'
    , 'validating charge lines against SRs in the global temp table'
    );
  END IF ;

  -- validate the SRs that are submitted for purge
  -- against the charge lines created for them.
  -- if the charge lines are ACTUAL and do not have
  -- a line id attached to them, then the corresponding
  -- SRs cannot be purged.

  UPDATE jtf_object_purge_param_tmp
  SET
    purge_status        = 'E'
  , purge_error_message = 'CS:CS_CHG_LINE_VAL_ERR'
  WHERE
      object_id IN
      (
      SELECT
          t.object_id
      FROM
        cs_estimate_details        e
      , jtf_object_purge_param_tmp t
      WHERE
          e.incident_id            = t.object_id
      AND e.charge_line_type       = 'ACTUAL'
      AND e.order_line_id          IS NULL
      AND t.object_type            = 'SR'
      AND t.processing_set_id      = p_processing_set_id
      AND nvl(t.purge_status, 'S') = 'S'
      )
  AND nvl(purge_status, 'S') = 'S'
  AND object_type            = 'SR'
  AND processing_set_id      = p_processing_set_id;

  l_row_count := SQL%ROWCOUNT;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'valid_chg_line_end'
    , 'after validating charge lines against SRs in the global temp table '
      || l_row_count || ' rows failed validation'
    );
  END IF ;

  ---

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' successfully'
    );
  END IF ;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );
    END IF ;

	WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_LINE_VAL_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;
END Purge_Chg_Validations;

--------------------------------------------------------------------------------
--  Procedure Name            :   PURGE_CHARGES
--
--  Parameters (other than standard ones)
--  IN
--      p_object_type         :   Type of object for which this procedure is
--                                being called. (Here it will be 'SR')
--      p_processing_set_id   :   Id that helps the API in identifying the
--                                set of SRs for which the child objects have
--                                to be deleted.
--
--  Description
--      This procedure physically deletes all the charge lines attached to
--      a service request. It reads the list of SRs for which the charge lines
--      have to be deleted from the global temp table, looking only for rows
--      having the purge_status as NULL. Using Set processing, the procedure
--      deletes all the charge lines attached to such SRs.
--
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  4-Aug-2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
PROCEDURE Purge_Charges
(
  p_api_version_number IN  NUMBER := 1.0
, p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
, p_commit             IN  VARCHAR2 := FND_API.G_FALSE
, p_object_type        IN  VARCHAR2
, p_processing_set_id  IN  NUMBER
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
)
IS
--------------------------------------------------------------------------------

L_API_VERSION   CONSTANT NUMBER       := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30) := 'PURGE_CHARGES';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := G_PKG_NAME || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

l_row_count     NUMBER := 0;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_api_version_number:' || p_api_version_number
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_object_type:' || p_object_type
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_processing_set_id:' || p_processing_set_id
    );
  END IF ;

  IF NOT FND_API.Compatible_API_Call
  (
    L_API_VERSION
  , p_api_version_number
  , L_API_NAME
  , G_PKG_NAME
  )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ------------------------------------------------------------------------------
  -- Parameter Validations:
  ------------------------------------------------------------------------------

  IF NVL(p_object_type, 'X') <> 'SR'
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'object_type_invalid'
      , 'p_object_type has to be SR.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_object_type');
    FND_MESSAGE.Set_Token('CURRVAL', p_object_type);
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ---

  IF p_processing_set_id IS NULL
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'proc_set_id_invalid'
      , 'p_processing_set_id should not be NULL.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_processing_set_id');
    FND_MESSAGE.Set_Token('CURRVAL', NVL(to_char(p_processing_set_id),'NULL'));
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ------------------------------------------------------------------------------
  -- Actual Logic starts below:
  ------------------------------------------------------------------------------

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'del_chg_line_start'
    , 'deleting charge lines against SRs in the global temp table'
    );
  END IF ;

  -- Delete all the estimate lines that correspond to the
  -- SRs that are available for purge after validations.

  DELETE /*+ index(e) */ cs_estimate_details e
  WHERE
    incident_id IN
    (
    SELECT /*+ no_unnest no_semijoin cardinality(10) */
        object_id
    FROM
        jtf_object_purge_param_tmp
    WHERE
        processing_set_id = p_processing_set_id
    AND object_type = 'SR'
    AND NVL(purge_status, 'S') = 'S'
    );

  l_row_count := SQL%ROWCOUNT;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'del_chg_line_end'
    , 'after deleting charge lines against SRs in the global temp table'
      || l_row_count || ' rows deleted.'
    );
  END IF ;

  ---

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' successfully'
    );
  END IF ;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );
    END IF ;

	WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_LINE_DEL_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;
END Purge_Charges;
--------------------------------------------------------------------------------

END CS_Charge_Details_PVT;

/
