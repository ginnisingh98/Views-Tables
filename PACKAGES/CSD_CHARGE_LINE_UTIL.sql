--------------------------------------------------------
--  DDL for Package CSD_CHARGE_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_CHARGE_LINE_UTIL" AUTHID CURRENT_USER AS
/* $Header: csdvclus.pls 120.1.12000000.2 2007/04/18 22:53:58 takwong ship $ */


TYPE MLE_LINES_REC_TYPE IS RECORD
(
    INVENTORY_ITEM_ID       NUMBER,
    UOM                     VARCHAR2(3),
    QUANTITY                NUMBER,
    SELLING_PRICE           NUMBER,
    ITEM_NAME               VARCHAR2(100),
    COMMS_NL_TRACKABLE_FLAG VARCHAR2(1),
    TXN_BILLING_TYPE_ID     NUMBER,
    TRANSACTION_TYPE_ID     NUMBER,
    SOURCE_CODE             VARCHAR2(30),
    SOURCE_ID1              NUMBER,
    SOURCE_ID2              NUMBER,
    ITEM_COST               NUMBER,
    RESOURCE_ID             NUMBER, -- ER 3607765, vkjain.
    OVERRIDE_CHARGE_FLAG    VARCHAR2(1)
);

TYPE MLE_LINES_TBL_TYPE IS TABLE OF MLE_LINES_REC_TYPE INDEX BY BINARY_INTEGER;

-- A table of charge records
TYPE CHARGE_LINES_TBL_TYPE IS TABLE OF
   CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE INDEX BY BINARY_INTEGER;


/*----------------------------------------------------------------*/
/* function name: Get_PLCurrCode                                  */
/* description  : Gets the currency for a price list              */
/*                                                                */
/* p_price_list_id                Price List ID to get currency   */
/*                                                                */
/*----------------------------------------------------------------*/
FUNCTION Get_PLCurrCode
(
   p_price_list_id   IN   NUMBER
)
RETURN VARCHAR2;

/*----------------------------------------------------------------*/
/* procedure name: Get_DefaultPriceList                           */
/* description  : Gets the price list from contract (default      */
/*                contract if null), if not, default price list   */
/*                from profile option.                            */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_repair_type_id             Repair Type ID                    */
/* p_repair_line_id             Repair Line ID                    */
/* p_contract_line_id           Contract Line ID                  */
/* p_currency_code              RO Currency                       */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_DefaultPriceList
(
  p_api_version            IN  NUMBER,
  p_init_msg_list          IN  VARCHAR2,
  p_repair_line_id         IN  NUMBER,
  p_repair_type_id         IN  NUMBER,
  p_contract_line_id       IN  NUMBER,
  p_currency_code         IN  VARCHAR2,
  x_contract_validated        OUT NOCOPY BOOLEAN,
  x_default_pl_id          OUT NOCOPY NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2
);

/*----------------------------------------------------------------*/
/* function name: Get_RO_PriceList                                */
/* description  : Gets the price list header id for a repair order*/
/*                                                                */
/* p_repair_line_id            Repair Line ID to get Price List   */
/*                                                                */
/*----------------------------------------------------------------*/
FUNCTION Get_RO_PriceList
(
   p_repair_line_id   IN   NUMBER
)
RETURN NUMBER;


/* bug#3875036 */
/*----------------------------------------------------------------*/
/* function name: Get_SR_AccountId                                */
/* description  : Gets the SR Customer Account Id for a repair order */
/*                                                                */
/* p_repair_line_id            Repair Line ID to get SR Customer Account Id  */
/*                                                                */
/*----------------------------------------------------------------*/
FUNCTION Get_SR_AccountId
(
   p_repair_line_id   IN   NUMBER
)
RETURN NUMBER;


/*----------------------------------------------------------------*/
/* function name: Get_DefaultContract                             */
/* description  : Gets the default contract set in Product        */
/*                Coverage.                                       */
/*                                                                */
/* p_repair_line_id           Repair Line ID to get contract      */
/*                                                                */
/*----------------------------------------------------------------*/
FUNCTION Get_DefaultContract
(
    p_repair_line_id IN NUMBER
)
RETURN NUMBER;

/*----------------------------------------------------------------*/
/* procedure name: Get_ContractPriceList                          */
/* description   : procedure used to get ets the price list       */
/*                 specified by the contract                      */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_contract_line_id           Contract Line ID                  */
/* p_repair_type_id             Repair Type ID                    */
/* p_currency_code              RO Currency                       */
/* x_contract_validated         Whether the contract can be used  */
/* x_contract_pl_id             Contract Price List ID            */
/* x_billing_pl_id              Billing Price List ID             */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_ContractPriceList
(
  p_api_version            IN  NUMBER,
  p_init_msg_list          IN  VARCHAR2,
  p_contract_line_id       IN  NUMBER,
  p_repair_type_id         IN  NUMBER,
  p_currency_code    IN  VARCHAR2,
  x_contract_validated        OUT NOCOPY BOOLEAN,
  x_contract_pl_id         OUT NOCOPY NUMBER,
  x_billing_pl_id          OUT NOCOPY NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2
);

/*----------------------------------------------------------------*/
/* procedure name: Validate_Contract                              */
/* description  : Checks the currency of the contract to see if   */
/*                it matches the one for repair order             */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_contract_line_id           Contract Line ID to check currency*/
/* p_repair_type_id             Repair Type ID to get contract PL */
/* p_ro_currency_code           RO currency code                  */
/* x_contract_currency_code     Contract PriceList Currency       */
/* x_contract_validated         Whether the contract can be used  */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/

PROCEDURE Validate_Contract
(
  p_api_version            IN  NUMBER,
  p_init_msg_list          IN  VARCHAR2,
  p_contract_line_id       IN  NUMBER,
  p_repair_type_id      IN  NUMBER,
  p_ro_currency_code         IN  VARCHAR2,
  x_contract_currency_code      OUT NOCOPY VARCHAR2,
  x_contract_validated        OUT NOCOPY BOOLEAN,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2
);


/*----------------------------------------------------------------*/
/* function name: Validate_PriceList                              */
/* description  : Checks the currency the price list to see if it */
/*                matches the one for repair order                */
/*                                                                */
/* p_price_list_id            Price List ID to get currency       */
/* p_currency_code            RO currency                         */
/*                                                                */
/*----------------------------------------------------------------*/
FUNCTION Validate_PriceList (
   p_price_list_id      IN  NUMBER,
   p_currency_code   IN  VARCHAR2
)
RETURN BOOLEAN;


/*----------------------------------------------------------------*/
/* procedure name: Get_DiscountedPrice                            */
/* description   : procedure used to get the discounted price     */
/*                 for applying a contract                        */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_contract_line_id           Contract Line ID                  */
/* p_repair_type_id             Repair Type ID                    */
/* p_txn_billing_type_id        Transaction Billing Type ID       */
/* p_coverage_txn_grp_id        Coverage Transaction Group ID     */
/* p_extended_price             Extended Price                    */
/* p_no_charge_flag             No Charge Flag                    */
/* x_discounted_price           Discounted Price                  */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_DiscountedPrice
(
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2,
   p_contract_line_id     IN  NUMBER,
   p_repair_type_id       IN  NUMBER,
   p_txn_billing_type_id  IN  NUMBER,
   p_coverage_txn_grp_id  IN  NUMBER,
   p_extended_price       IN  NUMBER,
   p_no_charge_flag    IN  VARCHAR2,
   x_discounted_price     OUT NOCOPY NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
);

/*----------------------------------------------------------------*/
/* procedure name: Get_CoverageInfo                               */
/* description   : procedure used to get the converage information*/
/*                 for a given contract line and business process */
/*                                                                */
/* p_contract_line_id           Contract Line ID                  */
/* p_business_process_id        Business process ID               */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/* x_contract_id                Contract ID                       */
/* x_contract_number            Contract Number                   */
/* x_coverage_id                Coverage ID                       */
/* x_coverage_txn_grp_id        Coverage Transaction Group ID     */
/*                                                                */
/*----------------------------------------------------------------*/

PROCEDURE  Get_CoverageInfo (p_contract_line_id      IN         NUMBER,
                             p_business_process_id   IN         NUMBER,
                             x_return_status         OUT NOCOPY VARCHAR2,
                             x_msg_count             OUT NOCOPY NUMBER,
                             x_msg_data              OUT NOCOPY VARCHAR2,
                             x_contract_id           OUT NOCOPY NUMBER,
                             x_contract_number       OUT NOCOPY VARCHAR2, -- swai bug fix 4770958
                             -- x_contract_number    OUT NOCOPY NUMBER,   -- swai bug fix 4770958
                             x_coverage_id           OUT NOCOPY NUMBER,
                             x_coverage_txn_group_id OUT NOCOPY NUMBER
                             );

/*----------------------------------------------------------------*/
/* procedure name: Convert_To_Charge_Lines                        */
/* description   : The procedure takes in a set of generic MLE    */
/*                 records and sorts out 'good' records that are  */
/*                 eligible for creating charge lines. It also    */
/*                 logs warning messages for 'bad' records        */
/*                 indicating the reason.                         */
/*                                                                */
/*----------------------------------------------------------------*/

PROCEDURE Convert_To_Charge_Lines (
    p_api_version           IN     NUMBER,
    p_commit                IN     VARCHAR2,
    p_init_msg_list         IN     VARCHAR2,
    p_validation_level      IN     NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2,
    p_est_act_module_code   IN   VARCHAR2,
    p_est_act_msg_entity    IN   VARCHAR2,
    p_charge_line_type      IN   VARCHAR2,
    p_repair_line_id        IN   NUMBER,
    p_repair_actual_id      IN   NUMBER,
    p_repair_type_id        IN   NUMBER,
    p_business_process_id   IN   NUMBER,
    p_currency_code         IN   VARCHAR2,
    p_incident_id           IN   NUMBER,
    p_organization_id       IN   NUMBER,
    p_price_list_id         IN   NUMBER,
    p_contract_line_id      IN   NUMBER,
    p_MLE_lines_tbl         IN   MLE_LINES_TBL_TYPE,
    px_valid_MLE_lines_tbl  IN OUT NOCOPY  MLE_LINES_TBL_TYPE,
    px_charge_lines_tbl     IN OUT NOCOPY  CHARGE_LINES_TBL_TYPE,
    x_warning_flag             OUT NOCOPY  VARCHAR2
);



END CSD_CHARGE_LINE_UTIL;
 

/
