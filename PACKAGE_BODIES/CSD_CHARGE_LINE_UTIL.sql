--------------------------------------------------------
--  DDL for Package Body CSD_CHARGE_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_CHARGE_LINE_UTIL" AS
/* $Header: csdvclub.pls 120.5 2008/03/11 22:26:24 rfieldma ship $ */
--
-- Package name     : CSD_CHARGE_LINE_UTIL
-- Purpose          : This package contains the utilities for handling
--                    price list and contract for charge lines.
-- History          :
-- Version       Date       Name        Description
-- 115.9         10/24/02   glam        Created.


G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_CHARGE_LINE_UTIL';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvclub.pls';
g_debug NUMBER := csd_gen_utility_pvt.g_debug_level;

/*----------------------------------------------------------------*/
/* function name: Get_PLCurrCode                                  */
/* description  : Gets the currency for a price list              */
/*                                                                */
/* p_price_list_id                Price List ID to get currency   */
/*                                                                */
/*----------------------------------------------------------------*/
FUNCTION Get_PLCurrCode (
   p_price_list_id   IN   NUMBER
)
RETURN VARCHAR2
IS
  l_curr_code  VARCHAR2(15) := NULL;

BEGIN

  -- get currency code from price list
  SELECT currency_code
  INTO l_curr_code
  FROM qp_list_headers_b
  WHERE list_header_id = p_price_list_id;

  IF (l_curr_code IS NOT NULL) THEN
    RETURN l_curr_code;
  ELSE
    RAISE no_data_found;
  END IF;

EXCEPTION
  WHEN no_data_found THEN
    FND_MESSAGE.SET_NAME('CSD','CSD_API_PL_CURR_CODE');
    FND_MESSAGE.SET_TOKEN('PRICE_LIST_ID',p_price_list_id);
    FND_MSG_PUB.Add;
    -- saupadhy 2826127
    RETURN NULL ;  -- RETURN -1

  WHEN others THEN
    FND_MESSAGE.SET_NAME('CSD','CSD_API_PL_CURR_CODE');
    FND_MESSAGE.SET_TOKEN('PRICE_LIST_ID',p_price_list_id);
    FND_MSG_PUB.Add;
    -- saupadhy 2826127
    RETURN NULL ;  -- RETURN -1

END Get_PLCurrCode;

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
)

IS
  l_api_name                  CONSTANT VARCHAR2(30) := 'Get_DefaultPriceList';
  l_api_version                  CONSTANT NUMBER := 1.0;

  l_default_contract       NUMBER := NULL;
  l_contract_line_id    NUMBER := NULL;
  l_contract_pl_id      NUMBER := NULL;
  l_billing_pl_id       NUMBER := NULL;
  l_contract_validated     BOOLEAN;
  l_default_pl_id       NUMBER := NULL;

  -- gilam: bug 3542319 - added flag to indicate if contract is used
  l_use_contract_pl     BOOLEAN;

  -- gilam: bug 3542319 - added cursor to get repair type price list
  CURSOR c_rt_pl_id(p_repair_type_id number) IS
        SELECT price_list_header_id
          FROM csd_repair_types_b
         WHERE repair_type_id = p_repair_type_id;

BEGIN

  --debug msg
  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.ADD ('Get_DefaultPriceList Begin: p_repair_line_id ='|| p_repair_line_id);
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT Get_DefaultPriceList;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Begin API Body
  --

  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                     p_api_name  => l_api_name );
  END IF;

  --debug msg
  IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.ADD ('Check required parameters and validate them');
  END IF;

  -- Check the required parameters
  CSD_PROCESS_UTIL.Check_Reqd_Param
  ( p_param_value => p_repair_line_id,
    p_param_name  => 'REPAIR_LINE_ID',
    p_api_name    => l_api_name);

  CSD_PROCESS_UTIL.Check_Reqd_Param
  ( p_param_value => p_repair_type_id,
    p_param_name  => 'REPAIR_TYPE_ID',
    p_api_name    => l_api_name);

  CSD_PROCESS_UTIL.Check_Reqd_Param
  ( p_param_value => p_currency_code,
    p_param_name  => 'CURRENCY_CODE',
    p_api_name    => l_api_name);

  -- Validate the repair type ID
  IF NOT( CSD_PROCESS_UTIL.Validate_repair_type_id ( p_repair_type_id  => p_repair_type_id )) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate the repair line ID
  IF NOT( CSD_PROCESS_UTIL.Validate_rep_line_id ( p_repair_line_id  => p_repair_line_id )) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  --debug msg
  IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.ADD ('Check required parameters and validation complete');
  END IF;

   -- If contract is passed in, get price list from contract and verify currency
   -- If no contract is passed, get price list from default contract and verify currency
   -- If currency is different from RO currency, contract price list will not be used
   -- If contract does not have price list, get default price list set in profile option
   -- If currency of default price list is different from RO currency, default price list will not be used
   -- gilam: bug 3542319 - add repair type price list option
   -- If default price list cannot be used or if user did not set default price list, get repair type price list
   -- If repair type price list is not set or repair type price list has different currency from RO's, null will be returned

   --debug msg
  IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.ADD ('Get price list from contract');
  END IF;

   -- no contract is passed in, get default contract
   IF (p_contract_line_id IS NULL) THEN

     l_contract_line_id := Get_DefaultContract(p_repair_line_id);
     IF (l_contract_line_id = -1) THEN
       -- gilam: bug 3542319 - remove raising the exception and set flag to false
       --RAISE FND_API.G_EXC_ERROR;
       l_use_contract_pl := FALSE;
       --
     END IF;

   -- contract is passed in
   ELSE

     l_contract_line_id := p_contract_line_id;

   END IF;

   -- get contract price list
   -- gilam: bug 3542319 - added check for -1 condition
   IF (l_contract_line_id IS NOT NULL and l_contract_line_id <> -1) THEN

     --debug msg
     IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.ADD ('Call Get_ContractPriceList API: l_contract_line_id ='|| l_contract_line_id);
     END IF;

     Get_ContractPriceList
     (
   p_api_version           => l_api_version,
      p_init_msg_list         => 'T',
      p_contract_line_id   => l_contract_line_id,
      p_repair_type_id     => p_repair_type_id,
      p_currency_code      => p_currency_code,
      x_contract_validated    => l_contract_validated,
      x_contract_pl_id     => l_contract_pl_id,
      x_billing_pl_id      => l_billing_pl_id,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data
     );

     -- gilam: bug 3542319 - changed logic for contract price list
     -- set it to false first, then change it to yes if contract price list is used
     l_use_contract_pl := FALSE;

     IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       x_contract_validated := l_contract_validated;

       IF (l_contract_validated) THEN
         IF (l_contract_pl_id IS NOT NULL) THEN
           l_use_contract_pl := TRUE;
           x_default_pl_id :=  l_contract_pl_id;
         ELSIF (l_billing_pl_id IS NOT NULL) THEN
           l_use_contract_pl := TRUE;
           x_default_pl_id :=  l_billing_pl_id;
         END IF;
       END IF;

     END IF;
     -- gilam: bug 3542319

   END IF;

   -- if no contract has passed in, or if there is contract and contract is valid and contract has no price list
   -- or if there is error on the contract, then get default price list from profile option
   -- if currency of default price list is different from RO currency, default price list will not be used

   -- gilam: bug 3542319 - changed IF condition
   --IF ((l_contract_line_id IS NULL) OR
   --    (l_contract_validated AND l_contract_line_id IS NOT NULL AND l_contract_pl_id IS NULL)) THEN

   IF NOT l_use_contract_pl THEN

     --debug msg
     IF (g_debug > 0 ) THEN
      csd_gen_utility_pvt.ADD ('Get default price list from profile option');
     END IF;

     l_default_pl_id := Fnd_Profile.value('CSD_Default_Price_List');

     IF (l_default_pl_id IS NOT NULL) THEN
       IF (Validate_PriceList(l_default_pl_id, p_currency_code)) THEN
         x_default_pl_id := l_default_pl_id;
       END IF;
     END IF;

     -- gilam: bug 3542319 - added repair type price list default option
     IF (x_default_pl_id IS NULL) THEN

        open c_rt_pl_id(p_repair_type_id);
        fetch c_rt_pl_id into l_default_pl_id;

          -- if repair type price list is set
          IF (c_rt_pl_id%FOUND) THEN
             IF (Validate_PriceList(l_default_pl_id, p_currency_code)) THEN
             x_default_pl_id := l_default_pl_id;
             END IF;
          END IF;

          close c_rt_pl_id;

      END IF;

   END IF;
   -- gilam; end bug 3542319


-- API body ends here

  -- Standard call to get message count and IF count is  get message info.
  FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                             p_data   =>  x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Get_DefaultPriceList;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Get_DefaultPriceList;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );

  WHEN OTHERS THEN
    ROLLBACK TO Get_DefaultPriceList;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                               l_api_name  );
    END IF;
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );

END Get_DefaultPriceList;


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
RETURN NUMBER
IS
    l_price_list_id NUMBER;
BEGIN
    SELECT price_list_header_id
    INTO l_price_list_id
    FROM csd_repairs
    WHERE repair_line_id = p_repair_line_id;

    IF (l_price_list_id is NOT NULL) THEN
        return l_price_list_id;
    ELSE
        return null;
    END IF;

EXCEPTION
   WHEN others THEN
    RETURN NULL;
END Get_RO_PriceList;

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
RETURN NUMBER
IS
    l_account_id NUMBER;

BEGIN

	SELECT account_id
	INTO l_account_id
	FROM cs_incidents_all_b ciab, csd_repairs cr
	WHERE cr.repair_line_id = p_repair_line_id and cr.incident_id  = ciab.incident_id;

    IF (l_account_id is NOT NULL) THEN
        return l_account_id;
    ELSE
        return null;
    END IF;

EXCEPTION
   WHEN others THEN
    RETURN NULL;
END Get_SR_AccountId;


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
RETURN NUMBER
IS

  l_contract_line_id NUMBER := NULL;

BEGIN

  -- get default contract using repair order number
  SELECT contract_line_id
  INTO l_contract_line_id
  FROM csd_repairs
  WHERE repair_line_id = p_repair_line_id;

  IF (l_contract_line_id IS NOT NULL) THEN
    RETURN l_contract_line_id;
  ELSE
    RETURN NULL;
  END IF;

EXCEPTION

   WHEN others THEN
    FND_MESSAGE.SET_NAME('CSD','CSD_API_DEFAULT_CONTRACT');
    FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',p_repair_line_id);
    FND_MSG_PUB.Add;
    RETURN -1;

END Get_DefaultContract;

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
  x_billing_pl_id    OUT NOCOPY NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_api_name               CONSTANT VARCHAR2(30) := 'Get_ContractPriceList';
  l_api_version               CONSTANT NUMBER := 1.0;

  l_contract_pl_id      NUMBER := NULL;
  l_bus_process_id      NUMBER;
  l_use_pl        BOOLEAN;
  l_date       DATE := sysdate;
  l_pl_out_tbl       OKS_CON_COVERAGE_PUB.pricing_tbl_type;
  i            NUMBER := 1;

  -- gilam: bug 3542319 - added flag for checking contract bp price list and variable for billing pl
  l_use_contract_bp_pl     BOOLEAN;
  l_billing_pl_id    NUMBER := NULL;
  --

BEGIN

  --debug msg
  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.ADD ('Get_ContractPriceList procedure: p_contract_line_id ='|| p_contract_line_id);
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT Get_ContractPriceList;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Begin API Body
  --

  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                     p_api_name  => l_api_name );
  END IF;

  --debug msg
  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.ADD ('Check required param and validate them');
  END IF;


  -- Check the required parameters
  CSD_PROCESS_UTIL.Check_Reqd_Param
  ( p_param_value => p_contract_line_id,
    p_param_name  => 'CONTRACT_LINE_ID',
    p_api_name    => l_api_name);

  CSD_PROCESS_UTIL.Check_Reqd_Param
  ( p_param_value => p_repair_type_id,
    p_param_name  => 'REPAIR_TYPE_ID',
    p_api_name    => l_api_name);


  -- Validate the repair line ID
  IF NOT( CSD_PROCESS_UTIL.Validate_repair_type_id ( p_repair_type_id  => p_repair_type_id )) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  BEGIN

    SELECT business_process_id
    INTO l_bus_process_id
    FROM csd_repair_types_b
    WHERE repair_type_id = p_repair_type_id;

  EXCEPTION

    WHEN others THEN
      FND_MESSAGE.SET_NAME('CSD','CSD_API_CONTRACT_PL');
      FND_MESSAGE.SET_TOKEN('REPAIR_TYPE_ID', p_repair_type_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

  END;

  --debug msg
  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.ADD ('Call OKS_Con_Coverage_PUB.Get_BP_PriceList API: p_contract_line_id ='|| p_contract_line_id);
  END IF;

  -- gilam: bug 3542319 - changed the logic to handle contract price lists
  BEGIN

    -- Call OKS_Con_Coverage_PUB.Get_BP_PriceList API
    OKS_CON_COVERAGE_PUB.GET_BP_PRICELIST
    (
      p_api_version        => l_api_version,
   p_init_msg_list      => 'T',
      p_contract_line_id   => p_contract_line_id,
        p_business_process_id   => l_bus_process_id,
        p_request_date     => l_date,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        x_pricing_tbl      => l_pl_out_tbl
    );


    IF (g_debug > 0 ) THEN

      csd_gen_utility_pvt.ADD ('Call OKS API to get price list: return status ='|| x_return_status);
      csd_gen_utility_pvt.ADD ('l_pl_out_tbl(i).bp_price_list_id: '|| l_pl_out_tbl(i).bp_price_list_id);

    END IF;


  EXCEPTION

    WHEN no_data_found THEN

      l_use_contract_bp_pl := FALSE;

  END;

  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

      -- only 1 row should be returned
      IF (l_pl_out_tbl.COUNT = 1) THEN

        -- contract has bp price list
        IF (l_pl_out_tbl(i).bp_price_list_id IS NOT NULL) THEN

            l_use_contract_bp_pl := TRUE;

        -- contract does not have bp price list
        ELSE

            l_use_contract_bp_pl := FALSE;

            IF (l_pl_out_tbl(i).contract_price_list_id IS NOT NULL) THEN

               l_billing_pl_id := l_pl_out_tbl(i).contract_price_list_id;

            END IF;

        END IF;

      ELSE

        -- contract does not have any price list or has errors, set flag to false
        l_use_contract_bp_pl := FALSE;

      END IF;

  ELSIF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

      -- contract has errors, set flag to false
      l_use_contract_bp_pl := FALSE;

  END IF;

  -- setting contract validated to true since no validation is required now
  x_contract_validated := TRUE;

  -- 1) if contract business process price list should be used
  IF (l_use_contract_bp_pl) THEN

      IF (l_pl_out_tbl(i).bp_price_list_id IS NOT NULL) THEN
        l_contract_pl_id := l_pl_out_tbl(i).bp_price_list_id;
        l_use_pl := Validate_PriceList(l_contract_pl_id, p_currency_code);

        -- contract bp price list has currency same as RO
        IF (l_use_pl) THEN
          x_contract_pl_id := l_contract_pl_id;

        -- contract price list has currency different from RO
        ELSIF (NOT l_use_pl) THEN
          x_contract_pl_id := NULL;

        END IF;

      END IF;

  ELSE

      -- 2) else if contract price list exists
      IF (l_billing_pl_id IS NOT NULL) then

        l_use_pl := Validate_PriceList(l_billing_pl_id, p_currency_code);
        x_contract_pl_id := NULL;

        -- contract billing price list has currency same as RO
        IF (l_use_pl) THEN
          x_billing_pl_id := l_billing_pl_id;

        -- contract billing price list has currency different from RO
        ELSIF (NOT l_use_pl) THEN
          x_billing_pl_id := NULL;

        END IF;

      END IF;

  END IF;
  -- gilam: end bug 3542319 - changed the logic to handle contract price lists


  --
  -- End API Body
  --

  -- Standard call to get message count and IF count is  get message info.
  FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                             p_data   =>  x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Get_ContractPriceList;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Get_ContractPriceList;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );

  WHEN OTHERS THEN
    ROLLBACK TO Get_ContractPriceList;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                               l_api_name  );
    END IF;

    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                 p_data   =>  x_msg_data );

END Get_ContractPriceList;

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
)
IS

  l_api_name         CONSTANT VARCHAR2(30) := 'Validate_contract';
  l_api_version            CONSTANT NUMBER := 1.0;

  l_contract_validated     BOOLEAN;
  l_contract_pl_id      NUMBER;
  l_billing_pl_id    NUMBER;

BEGIN

  --debug msg
 IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.ADD ('Validate Contract function: p_contract_line_id ='|| p_contract_line_id);
 END IF;

  -- Standard Start of API savepoint
  SAVEPOINT Validate_Contract;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Begin API Body
  --

 IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                     p_api_name  => l_api_name );
 END IF;

  --debug msg
 IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.ADD ('Check required parameters and validate them');
 END IF;

  CSD_PROCESS_UTIL.Check_Reqd_Param
  ( p_param_value => p_repair_type_id,
    p_param_name  => 'REPAIR_TYPE_ID',
    p_api_name    => l_api_name);

  CSD_PROCESS_UTIL.Check_Reqd_Param
  ( p_param_value => p_ro_currency_code,
    p_param_name  => 'RO_CURRENCY_CODE',
    p_api_name    => l_api_name);

  -- Validate the repair type ID
  IF NOT( CSD_PROCESS_UTIL.Validate_repair_type_id ( p_repair_type_id  => p_repair_type_id )) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  --debug msg
  IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.ADD ('Call Get_ContractPriceList procedure: p_contract_line_id ='|| p_contract_line_id);
  END IF;

  IF (p_contract_line_id IS NOT NULL) THEN
     Get_ContractPriceList
     (
   p_api_version           => l_api_version,
      p_init_msg_list         => 'T',
      p_contract_line_id   => p_contract_line_id,
      p_repair_type_id     => p_repair_type_id,
      p_currency_code      => p_ro_currency_code,
      x_contract_validated    => l_contract_validated,
      x_contract_pl_id     => l_contract_pl_id,
      x_billing_pl_id      => l_billing_pl_id,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data
     );

  ELSE

    --debug msg
    IF (g_debug > 0 ) THEN
      csd_gen_utility_pvt.ADD ('p_contract_line_id is null');
    END IF;

    RAISE FND_API.G_EXC_ERROR;

  END IF;

   --debug msg
   IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.ADD ('Call Get_ContractPriceList procedure: return status ='|| x_return_status);
   END IF;

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

     x_contract_validated := l_contract_validated;

     IF (l_contract_pl_id IS NOT NULL) THEN
       x_contract_currency_code := Get_PLCurrCode (l_contract_pl_id);
     ELSE
       x_contract_currency_code := Get_PLCurrCode (l_billing_pl_id);
     END IF;

   ELSIF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

     --debug msg
     IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.ADD ('Get_ContractPL procedure failed');
     END IF;

     RAISE FND_API.G_EXC_ERROR;

   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Validate_Contract;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Validate_Contract;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );

  WHEN OTHERS THEN
    ROLLBACK TO Validate_Contract;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                               l_api_name  );
    END IF;

    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                 p_data   =>  x_msg_data );

 END Validate_Contract;


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
RETURN BOOLEAN
IS
  l_pl_curr_code  VARCHAR2(15) := NULL;
  l_result     VARCHAR2(10);

  reqd_param_failed     EXCEPTION;

BEGIN

  -- get currency of price list and verify with RO currency
  IF (p_price_list_id IS NOT NULL AND p_currency_code IS NOT NULL) THEN
    l_pl_curr_code := Get_PLCurrCode(p_price_list_id);
    IF (l_pl_curr_code = p_currency_code) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSE
    Raise reqd_param_failed;
  END IF;

EXCEPTION

 WHEN reqd_param_failed THEN
    FND_MESSAGE.SET_NAME('CSD','CSD_API_VALIDATE_PL');
    FND_MESSAGE.SET_TOKEN('MISSING PARAM: PRICE_LIST_ID', p_price_list_id);
    FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',p_currency_code);
    FND_MSG_PUB.Add;
    RETURN NULL;

  WHEN others THEN
    FND_MESSAGE.SET_NAME('CSD','CSD_API_VALIDATE_PL');
    FND_MESSAGE.SET_TOKEN('PRICE_LIST_ID',p_price_list_id);
    FND_MSG_PUB.Add;
    RETURN NULL;

END Validate_PriceList;


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
)
IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Apply_contract';
  l_api_version         CONSTANT NUMBER := 1.0;

  l_bus_process_id   NUMBER;
  l_request_date  DATE := sysdate;
  l_contract_in_tbl     OKS_CON_COVERAGE_PUB.ser_tbl_type;
  l_contract_out_tbl    OKS_CON_COVERAGE_PUB.cov_tbl_type;
  i         NUMBER := 1;

BEGIN

  --debug msg
 IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.ADD ('Get_DiscountedPrice procedure: p_contract_line_id ='|| p_contract_line_id);
 END IF;

  -- Standard Start of API savepoint
  SAVEPOINT Get_DiscountedPrice;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Begin API Body
  --

 IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                     p_api_name  => l_api_name );
 END IF;

  --debug msg
 IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.ADD ('Check required parameters and validate them');
 END IF;

  -- Check the required parameters
  CSD_PROCESS_UTIL.Check_Reqd_Param
  ( p_param_value => p_contract_line_id,
    p_param_name  => 'CONTRACT_LINE_ID',
    p_api_name    => l_api_name);

  CSD_PROCESS_UTIL.Check_Reqd_Param
  ( p_param_value => p_repair_type_id,
    p_param_name  => 'REPAIR_TYPE_ID',
    p_api_name    => l_api_name);

  CSD_PROCESS_UTIL.Check_Reqd_Param
  ( p_param_value => p_txn_billing_type_id,
    p_param_name  => 'TRANSACTION_BILLING_TYPE_ID',
    p_api_name    => l_api_name);

  CSD_PROCESS_UTIL.Check_Reqd_Param
  ( p_param_value => p_extended_price,
    p_param_name  => 'EXTENDED_PRICE',
    p_api_name    => l_api_name);


  -- Validate the repair type ID
  IF NOT( CSD_PROCESS_UTIL.Validate_repair_type_id ( p_repair_type_id  => p_repair_type_id )) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  BEGIN

    -- get business process id for repair type
    SELECT business_process_id
    INTO l_bus_process_id
    FROM csd_repair_types_b
    WHERE repair_type_id = p_repair_type_id;

  EXCEPTION

    WHEN others THEN
      FND_MESSAGE.SET_NAME('CSD','CSD_API_DISCOUNTED_PRICE');
      FND_MESSAGE.SET_TOKEN('REPAIR_TYPE_ID', p_repair_type_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

  END;

  -- Set l_contract_in_tbl attributes
  -- only passing 1 row, so i = 1

  l_contract_in_tbl(i).contract_line_id := p_contract_line_id;
  --l_contract_in_tbl(i).txn_group_id := p_coverage_txn_grp_id;
  -- contract rearch changes for R12
  l_contract_in_tbl(i).txn_group_id := null;
  l_contract_in_tbl(i).business_process_id := l_bus_process_id;
  l_contract_in_tbl(i).billing_type_id := p_txn_billing_type_id;
  l_contract_in_tbl(i).request_date := l_request_date;

  IF (p_no_charge_flag = 'Y') THEN
    l_contract_in_tbl(i).charge_amount := 0;
  ELSE
    l_contract_in_tbl(i).charge_amount := p_extended_price;
  END IF;

  --debug msg
 IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.ADD ('Call OKS_Con_Coverage_PUB.Apply_Contract_Coverage API: p_contract_line_id ='|| p_contract_line_id);
 END IF;


  -- Call OKS_Con_Coverage_PUB.Apply_Contract_Coverage API
  OKS_CON_COVERAGE_PUB.APPLY_CONTRACT_COVERAGE
  (
    p_api_version          => l_api_version,
    p_init_msg_list        => p_init_msg_list, -- 'T' Changed by vkjain.
    p_est_amt_tbl          => l_contract_in_tbl,
    x_return_status     => x_return_status,
    x_msg_count            => x_msg_count,
    x_msg_data             => x_msg_data,
    x_est_discounted_amt_tbl     => l_contract_out_tbl
  );


  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

    -- only 1 row should be returned
    IF (l_contract_out_tbl.COUNT > 1) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE

      IF (l_contract_out_tbl(i).discounted_amount IS NULL) THEN
        x_discounted_price := l_contract_in_tbl(i).charge_amount;
      ELSE
        x_discounted_price := l_contract_out_tbl(i).discounted_amount;
      END IF;
    END IF;

  ELSIF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- API body ends here

  -- Standard call to get message count and IF count is  get message info.
  FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                             p_data   =>  x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Get_DiscountedPrice;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Get_DiscountedPrice;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );

  WHEN OTHERS THEN
    ROLLBACK TO Get_DiscountedPrice;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                               l_api_name  );
    END IF;
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );


END Get_DiscountedPrice;

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
                                x_contract_number       OUT NOCOPY VARCHAR2, -- swai: bug fix 4770958
                                -- x_contract_number    OUT NOCOPY NUMBER,   -- swai: bug fix 4770958
                                x_coverage_id           OUT NOCOPY NUMBER,
                                x_coverage_txn_group_id OUT NOCOPY NUMBER
                                ) IS

    l_api_name    CONSTANT VARCHAR2(30) := 'Get_CoverageInfo';

    -- Selects coverage information for charge line record
    --Contract re arch changes for R12
    /**
    cursor c_coverage_info IS
       SELECT cov.contract_id,
              cov.contract_number,
              cov.actual_coverage_id,
              ent.txn_group_id
       FROM   oks_ent_coverages_v cov,
              oks_ent_txn_groups_v ent
       WHERE  cov.actual_coverage_id  = ent.coverage_id
         AND  cov.contract_line_id    = p_contract_line_id
         AND  ent.business_process_id = p_business_process_id;
       */
    cursor c_coverage_info IS
       SELECT cov.contract_id,
              cov.contract_number,
              cov.actual_coverage_id
       FROM   oks_ent_coverages_v cov
       WHERE  cov.contract_line_id    = p_contract_line_id;

   BEGIN

       --debug msg
      IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.ADD ('Get_CoverageInfo procedure: p_contract_line_id ='|| p_contract_line_id);
         csd_gen_utility_pvt.ADD ('Get_CoverageInfo procedure: p_business_process_id='|| p_business_process_id);
      END IF;

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                      p_api_name  => l_api_name );
      END IF;

       --debug msg
      IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.ADD ('Check required parameters and validate them');
      END IF;

      -- Check the required parameters
      CSD_PROCESS_UTIL.Check_Reqd_Param
      ( p_param_value   => p_contract_line_id,
        p_param_name => 'CONTRACT_LINE_ID',
        p_api_name      => l_api_name);

      CSD_PROCESS_UTIL.Check_Reqd_Param
      ( p_param_value   => p_business_process_id,
        p_param_name => 'BUSINESS_PROCESS_ID',
        p_api_name      => l_api_name);

      x_coverage_txn_group_id := NULL;

      IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.ADD ('Get_CoverageInfo: Opening cursor');
      END IF;

      x_coverage_txn_group_id := NULL;

      -- Open the cursor and fetch the values.
      OPEN  c_coverage_info;
      FETCH c_coverage_info
      INTO  x_contract_id,
            x_contract_number,
            x_coverage_id;
        -- contracts re arch changes for R12
            --x_coverage_txn_group_id;

      CLOSE c_coverage_info;

      -- Checking only for x_coverage_txn_group_id as
      -- we use it for determining discounts.
  -- contracts re arch changes for R12
  /****
      IF (x_coverage_txn_group_id IS NULL) THEN
         -- put a debug message.
         IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD ('Get_CoverageInfo: No coverage information found.');
         END IF;

         -- Log an error message.
         FND_MESSAGE.SET_NAME('CSD', 'CSD_CHRG_UTIL_NO_COVG');
       -- No coverage information found for contract and business process.
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
 ******/
    x_coverage_txn_group_id := null;

   EXCEPTION
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                        p_data   =>  x_msg_data );
       WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                          l_api_name  );
             END IF;
             FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                        p_data   =>  x_msg_data );
   END Get_CoverageInfo;

/*----------------------------------------------------------------*/
/* procedure name: Convert_To_Charge_Lines                        */
/* description   : The procedure takes in a set of generic MLE    */
/*                 records and sorts out 'good' records that are  */
/*                 eligible for creating charge lines. It also    */
/*                 logs warning messages for 'bad' records        */
/*                 indicating the reason.                         */
/*                                                                */
/*----------------------------------------------------------------*/

  PROCEDURE Convert_To_Charge_Lines( p_api_version IN NUMBER,
                                     p_commit IN VARCHAR2,
                                     p_init_msg_list IN VARCHAR2,
                                     p_validation_level IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_msg_count OUT NOCOPY NUMBER,
                                     x_msg_data OUT NOCOPY VARCHAR2,
                                     p_est_act_module_code IN VARCHAR2,
                                     p_est_act_msg_entity IN VARCHAR2,
                                     p_charge_line_type IN VARCHAR2,
                                     p_repair_line_id IN NUMBER,
                                     p_repair_actual_id IN NUMBER,
                                     p_repair_type_id IN NUMBER,
                                     p_business_process_id IN NUMBER,
                                     p_currency_code IN VARCHAR2,
                                     p_incident_id IN NUMBER,
                                     p_organization_id IN NUMBER,
                                     p_price_list_id IN NUMBER,
                                     p_contract_line_id IN NUMBER,
                                     p_MLE_lines_tbl IN MLE_LINES_TBL_TYPE,
                                     px_valid_MLE_lines_tbl IN OUT NOCOPY MLE_LINES_TBL_TYPE,
                                     px_charge_lines_tbl IN OUT NOCOPY CHARGE_LINES_TBL_TYPE,
                                     x_warning_flag OUT NOCOPY VARCHAR2 ) IS

-- CONSTANTS --
    -- API constants
    lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
    lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
    lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
    lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
    lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
    lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
    lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_charge_line_util.convert_to_charge_lines';
    lc_api_name              CONSTANT VARCHAR2(30)   := 'CONVERT_TO_CHARGE_LINES';
    lc_api_version           CONSTANT NUMBER         := 1.0;

   -- Pricing attributes
    l_pricing_rec        csd_process_util.pricing_attr_rec;

	--bug#3875036
	l_account_id						NUMBER        := NULL;

    -- Generic constants definitions
    G_CHARGES_SOURCE_CODE_DR   CONSTANT VARCHAR2(30)   := 'DR';
    G_LINE_CATEGORY_CODE_ORDER CONSTANT VARCHAR2(30)   := 'ORDER';

-- VARIABLES --
    -- Stores the ID for the last and current item in the loop.
    l_curr_inv_item                     NUMBER         := NULL;
    l_last_inv_item                     NUMBER         := NULL;

    -- Used only to log warning message
    l_price_list_name                   VARCHAR2(240)  := NULL;

    -- Stores the count of install base subtypes that are
    -- defined for the given transaction type.
    l_num_subtypes                      NUMBER         := NULL;

    -- Stores 'after warranty cost', unit selling price and the
    -- discounted price for the item.
    l_extended_price                    NUMBER;
    l_unit_selling_price                NUMBER         := NULL;
    l_discounted_price                  NUMBER         := NULL;

    -- Stores the flag value for the current item in the loop.
    l_no_charge_flag                    VARCHAR2(1)    := NULL;

    -- Stores the contract information that is applicable to all lines.
    l_contract_id                       NUMBER         := NULL;
    l_contract_number                   VARCHAR2(120)  := NULL; -- swai bug fix 4770958
    -- l_contract_number                NUMBER         := NULL; -- swai bug fix 4770958
    l_coverage_id                       NUMBER         := NULL;
    l_coverage_txn_group_id             NUMBER         := NULL;

    -- Stores the ORG ID that is applicable to all lines.
    l_org_id                            NUMBER         := NULL;

    -- The derived line type and category code for each line based
    -- on the set up for transaction billing type.
    l_line_type_id                      NUMBER         := NULL;
    l_line_category_code                VARCHAR2(30)   := NULL;

    -- Indicates whether or not to skip the current record
    -- while putting in the valid list of values.
    -- If the value is TRUE then it means that the current
    -- record is ineligible for further processing.
    l_skip_curr_rec                     BOOLEAN;

    l_numRows                           NUMBER;
    l_curRow                            NUMBER;

    l_return_status                     VARCHAR2(1);
    l_msg_count                         NUMBER;
    l_msg_data                          VARCHAR2(2000);

    -- cursors --

    -- number of txn subtypes for a given txn billing type
    CURSOR count_csi_txn_subtypes( p_txn_billing_type_id NUMBER ) IS
      SELECT COUNT( * )
        FROM csi_txn_sub_types ib,
         cs_txn_billing_types cs,
         CSI_TXN_TYPES ctt
       WHERE cs.txn_billing_type_id = p_txn_billing_type_id
         AND ib.cs_transaction_type_id = cs.transaction_type_id
         AND ib.non_src_reference_reqd = 'Y'
       AND ib.update_ib_flag = 'Y'
         AND ctt.transaction_type_id = ib.transaction_type_id
         AND nvl(ctt.source_application_id, 660) = 660 -- For Order Management 'ONT'
       AND nvl(ctt.source_transaction_type, 'OM_SHIPMENT') = 'OM_SHIPMENT';

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Convert_To_Actual_Lines;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( lc_api_version,
                                        p_api_version,
                                        lc_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- logging
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.BEGIN',
                       'Entering CSD_CHARGE_LINE_UTIL.convert_to_charge_lines');
    end if;

    -- log parameters
    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_api_version: ' || p_api_version);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_commit: ' || p_commit);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_init_msg_list: ' || p_init_msg_list);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_validation_level: ' || p_validation_level);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_est_act_module_code: ' || p_est_act_module_code);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_est_act_msg_entity: ' || p_est_act_msg_entity);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_charge_line_type: ' || p_charge_line_type);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_repair_line_id: ' || p_repair_line_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_repair_actual_id: ' || p_repair_actual_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_repair_type_id: ' || p_repair_type_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_business_process_id: ' || p_business_process_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_currency_code: ' || p_currency_code);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_incident_id: ' || p_incident_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_organization_id: ' || p_organization_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_price_list_id: ' || p_price_list_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_contract_line_id: ' || p_contract_line_id);
    end if;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    --DBMS_OUTPUT.put_line( 'NEW: before the api begin' );

    -- Get the org id. It will be used later to derive
    -- line type id.
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name,
                     'Calling CSD_PROCESS_UTIL.get_org_id with p_incident_id = ' || p_incident_id);
    end if;

    l_org_id := CSD_PROCESS_UTIL.get_org_id( p_incident_id );

/* bug#3875036 */
	l_account_id := Get_SR_AccountId(p_repair_line_id);

    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name,
                     'Returned from CSD_PROCESS_UTIL.get_org_id.'
                     || ' l_org_id = ' || l_org_id);
    end if;

   --DBMS_OUTPUT.put_line( 'NEW: The org id was got '
   --                       || l_org_id );

    IF ( l_org_id IS NULL ) THEN
      if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                         'Could not determine the operating unit for'
                         || ' p_incident_id = ' || p_incident_id);
      end if;
      FND_MESSAGE.SET_NAME( 'CSD', 'CSD_CHRG_NO_OPER_UNIT');
    -- Could not determine the operating unit. Operating unit is required to derive line types.
      FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_ERROR_MSG );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Get the coverage details for the business process and
    -- Contract line id.
    -- This is placed outside the loop as the API output
    -- is applicable to all lines.
    IF ( p_contract_line_id IS NOT NULL
         AND p_business_process_id IS NOT NULL ) THEN
      if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                         'Calling CSD_CHARGE_LINE_UTIL.Get_CoverageInfo with '
                         || 'p_contract_line_id = ' || p_contract_line_id
                         || ' and p_business_process_id = ' || p_business_process_id);
      end if;
     --DBMS_OUTPUT.put_line( 'NEW: inside to get coverage info' );
      CSD_CHARGE_LINE_UTIL.Get_CoverageInfo( p_contract_line_id      => p_contract_line_id,
                                             p_business_process_id   => p_business_process_id,
                                             x_return_status         => x_return_status,
                                             x_msg_count             => x_msg_count,
                                             x_msg_data              => x_msg_data,
                                             x_contract_id           => l_contract_id,
                                             x_contract_number       => l_contract_number,
                                             x_coverage_id           => l_coverage_id,
                                             x_coverage_txn_group_id => l_coverage_txn_group_id );

      if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                         'Returned from CSD_CHARGE_LINE_UTIL.Get_CoverageInfo with '
                         || 'l_coverage_txn_group_id = ' || l_coverage_txn_group_id);
      end if;

      -- swai: bug fix 4770958 (FP of 4499468)
      -- due to rearch of contracts for r12,
      -- no need to check for null coverage txn group anymore
      -- IF ( l_coverage_txn_group_id IS NULL
      --      OR x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        if (lc_proc_level >= lc_debug_level) then
            FND_LOG.STRING(lc_proc_level, lc_mod_name,
                           'Coverage information could not be determined for the contract and business process.');
        end if;
        FND_MESSAGE.SET_NAME( 'CSD', 'CSD_CHRG_UTIL_NO_COVG');
        -- Coverage information could not be determined for the contract and business process.
        FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_ERROR_MSG );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    l_numRows := p_MLE_lines_tbl.COUNT;

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                       'Begin LOOP through p_MLE_lines_tbl table');
    end if;

    FOR i IN 1..l_numRows LOOP
     --DBMS_OUTPUT.put_line( 'NEW: Inside the main loop' );

      -- Reset the values for the current record.
      l_skip_curr_rec := FALSE;
      l_curr_inv_item := p_MLE_lines_tbl( i ).inventory_item_id;

      if (lc_stat_level >= lc_debug_level) then
          FND_LOG.STRING(lc_stat_level, lc_mod_name,
                         'Processing item - id = ' || l_curr_inv_item
                         || ' name = ' || p_MLE_lines_tbl( i ).item_name
                         || ', for count = ' || i);
      end if;

      -- If a line happens to be -ve then we should ignore the line.
      -- This may happen when we use SUM(qty) for material transactions
      -- as more material can be returned than issued.
      IF ( p_MLE_lines_tbl( i ).quantity IS NULL
             OR p_MLE_lines_tbl( i ).quantity <= 0 ) THEN
         l_skip_curr_rec := TRUE;
         if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
                           'The transaction quantity value is either NULL or 0. '
                           || 'p_MLE_lines_tbl( i ).quantity = ' || p_MLE_lines_tbl( i ).quantity);
         end if;
         FND_MESSAGE.SET_NAME( 'CSD', 'CSD_CHRG_NEG_QTY');
       -- The net transactable quantity for the item $ITEM was found to be negative.
       -- The lines for the item will be ignored.
         FND_MESSAGE.SET_TOKEN( 'ITEM', p_MLE_lines_tbl( i ).item_name );
         FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_WARNING_MSG );
      END IF;

      -- We derive/validate lots of values that depend just on the item.
      -- Hence, for each subsequent record we need not do the entire processing
      -- again if the item is same. We utilize the values from the previous
      -- processing for the current record.
      IF ((l_last_inv_item IS NULL
           OR ( l_last_inv_item <> l_curr_inv_item )) AND NOT l_skip_curr_rec) THEN

        if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
                           'Current item being processed - id = ' || l_curr_inv_item
                           || ' name = ' || p_MLE_lines_tbl( i ).item_name
                           || ', for count = ' || i);
        end if;

        --DBMS_OUTPUT.put_line( 'NEW: Inside the item loop again' );

        -- get the selling price of the item
        -- if no selling price, then we cannot determine charge, so
        -- log a warning.
        -- The reason we put the following code in a plsql block
        -- is because the API throws an excetion when there is no success.
        BEGIN
          if (lc_proc_level >= lc_debug_level) then
             FND_LOG.STRING(lc_proc_level, lc_mod_name,
                            'Calling CSD_PROCESS_UTIL.GET_CHARGE_SELLING_PRICE with'
                            || ' p_inventory_item_id = ' || p_MLE_lines_tbl( i ).inventory_item_id
                            || ' p_price_list_header_id = ' || p_price_list_id
                            || ' p_unit_of_measure_code = ' || p_MLE_lines_tbl( i ).uom
                            || ' p_currency_code = ' || p_currency_code
                            || ' p_quantity_required = ' || p_MLE_lines_tbl( i ).quantity);
          end if;
          l_unit_selling_price := NULL;

/*bug#3875036 */
          CSD_PROCESS_UTIL.GET_CHARGE_SELLING_PRICE( p_inventory_item_id    => p_MLE_lines_tbl( i ).inventory_item_id,
                                                     p_price_list_header_id => p_price_list_id,
                                                     p_unit_of_measure_code => p_MLE_lines_tbl( i ).uom,
                                                     p_currency_code        => p_currency_code,
                                                     p_quantity_required    => p_MLE_lines_tbl( i ).quantity,
													 p_account_id			=> l_account_id, --bug#3875036
													 p_org_id               => l_org_id, -- Added for R12
                                                     p_pricing_rec          => l_pricing_rec,
                                                     x_selling_price        => l_unit_selling_price,
                                                     x_return_status        => l_return_status,
                                                     x_msg_count            => l_msg_count,
                                                     x_msg_data             => l_msg_data );

          if (lc_proc_level >= lc_debug_level) then
             FND_LOG.STRING(lc_proc_level, lc_mod_name,
                            'Returned form CSD_PROCESS_UTIL.GET_CHARGE_SELLING_PRICE with'
                            || ' l_unit_selling_price = ' || l_unit_selling_price);
          end if;

          -- If API returned NULL value for the selling price
          -- we consider it's an error.
          IF l_unit_selling_price IS NULL THEN
            RAISE FND_API.G_eXC_ERROR;
          END IF;

          EXCEPTION
            -- The reason we only handle 'FND_API.G_EXC_ERROR' exception
            -- is because the above API throws only one type of exception.
            -- If there is any other exception then it should be caught
            -- outside the loop in the main EXCEPTION block of the procedure.
            WHEN FND_API.G_EXC_ERROR THEN
             --DBMS_OUTPUT.put_line( 'NEW: The unit price is '
             --                       || l_unit_selling_price );
             --DBMS_OUTPUT.put_line( 'NEW: The status is '
             --                       || l_return_status );

              if (lc_proc_level >= lc_debug_level) then
                 FND_LOG.STRING(lc_proc_level, lc_mod_name,
                                'Inside EXC ERROR for the block calling CSD_PROCESS_UTIL.GET_CHARGE_SELLING_PRICE.');
              end if;

              l_skip_curr_rec := TRUE;
              -- Get the price list name if the it's NULL
              -- and then use it to log message.
              IF ( l_price_list_name IS NULL ) THEN
               --DBMS_OUTPUT.put_line( 'NEW: price list is NULL' );
                BEGIN
                  SELECT name
                    INTO l_price_list_name
                    FROM qp_list_headers_vl
                   WHERE list_header_id = p_price_list_id;
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                     if (lc_stat_level >= lc_debug_level) then
                         FND_LOG.STRING(lc_stat_level, lc_mod_name,
                                        'Could not determine the price list name for p_price_list_id = ' || p_price_list_id);
                     end if;
                     --DBMS_OUTPUT.put_line( 'NEW: no data found' );
                     l_price_list_name := p_price_list_id;
                END;
              END IF;
              FND_MESSAGE.SET_NAME( 'CSD', 'CSD_CHRG_NOPRICE_ITEM_UOM' );
          -- Unable to determine selling price for the item $ITEM and unit of measure $UOM for the price list $PRICE_LIST.
              FND_MESSAGE.SET_TOKEN( 'ITEM',
                                     p_MLE_lines_tbl( i ).item_name );
              FND_MESSAGE.SET_TOKEN( 'PRICE_LIST', l_price_list_name );
              FND_MESSAGE.SET_TOKEN( 'UOM', p_MLE_lines_tbl( i ).uom );
             --DBMS_OUTPUT.put_line( 'NEW: before the message was added' );
              FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_WARNING_MSG );
             --DBMS_OUTPUT.put_line( 'NEW: after the message was added' );
        END;

       --DBMS_OUTPUT.put_line( 'NEW: after getting the selling price' );

        if (lc_stat_level >= lc_debug_level) then
           FND_LOG.STRING(lc_stat_level, lc_mod_name,
                          'Checking if the Transaction Billing Type is null. '
                          || 'p_MLE_lines_tbl(' || i || ').txn_billing_type_id = ' || p_MLE_lines_tbl( i ).txn_billing_type_id);
        end if;

        -- Txn Billing type is required. Log a warning if it is missing.
        -- Else we derive 'No Charge Flag' and 'Line Type/Category Code'.
        IF ( p_MLE_lines_tbl( i ).txn_billing_type_id IS NULL ) THEN
         --DBMS_OUTPUT.put_line( 'NEW: txn bill type null' );

          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                             'Transaction billing type found to be NULL');
          end if;

          l_skip_curr_rec := TRUE;
          FND_MESSAGE.SET_NAME( 'CSD', 'CSD_CHRG_NO_ITEM_SAR' );
      -- Unable to determine service activity billing type for the item $ITEM.
          FND_MESSAGE.SET_TOKEN( 'ITEM', p_MLE_lines_tbl( i ).item_name );
          FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_WARNING_MSG );
        ELSE
         --DBMS_OUTPUT.put_line( 'NEW: txn bill type is NOT NULL' );

          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                             'Transaction billing type is NOT NULL');
          end if;

          if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                             'Calling procedure CSD_PROCESS_UTIL.Get_No_Chg_Flag with '
                             || 'p_MLE_lines_tbl( i ).txn_billing_type_id = ' || p_MLE_lines_tbl( i ).txn_billing_type_id);
          end if;

          -- Check if the 'No Charge Flag' is checked for the txn billing type.
          l_no_charge_flag := CSD_PROCESS_UTIL.Get_No_Chg_Flag( p_MLE_lines_tbl( i ).txn_billing_type_id );

          if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                             'Returned from procedure CSD_PROCESS_UTIL.Get_No_Chg_Flag with '
                             || 'l_no_charge_flag = ' || l_no_charge_flag);
          end if;

          /*
      The extended price is set to 0 in the later part of the code.

          IF ( NVL( l_no_charge_flag, 'N' ) = 'Y' ) THEN
            l_unit_selling_price := 0;
          END IF;
      */

         --DBMS_OUTPUT.put_line( 'NEW: Before calling get line type' );

          -- Initialize the variables.
          l_line_type_id := NULL;
          l_line_category_code := NULL;

          if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                             'Calling procedure CSD_PROCESS_UTIL.get_line_type with '
                             || 'p_txn_billing_type_id = ' || p_MLE_lines_tbl( i ).txn_billing_type_id
                             || ' and p_org_id = ' || l_org_id);
          end if;

          -- Get the line type for the txn billing type.
          CSD_PROCESS_UTIL.get_line_type( p_txn_billing_type_id => p_MLE_lines_tbl( i ).txn_billing_type_id,
                                          p_org_id              => l_org_id,
                                          x_line_type_id        => l_line_type_id,
                                          x_line_category_code  => l_line_category_code,
                                          x_return_status       => l_return_status );

          if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                             'Returned from procedure CSD_PROCESS_UTIL.get_line_type with '
                             || 'x_line_type_id = ' || l_line_type_id
                             || ', x_line_category_code = ' || l_line_category_code
                             || ', x_return_status = ' || l_return_status);
          end if;

         --DBMS_OUTPUT.put_line( 'NEW: after get line type' );

          -- Line type id is a required field. If the value is NULL then
          -- the current record is ineligible for further processing.
          IF ( l_line_type_id IS NULL
               OR l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
           --DBMS_OUTPUT.put_line( 'NEW: inside the line_typeId NULL check.' );
            l_skip_curr_rec := TRUE;
            FND_MESSAGE.SET_NAME( 'CSD', 'CSD_CHRG_LINE_TYPE_MISS');
        -- Line type, for the current organization, has not been set for the item $ITEM. Check the service activity billing types set up.
            FND_MESSAGE.SET_TOKEN( 'ITEM', p_MLE_lines_tbl( i ).item_name );
            FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_WARNING_MSG );
          END IF;

         --DBMS_OUTPUT.put_line( 'NEW: after line type id null check' );

          IF ( l_line_category_code IS NULL
               OR l_line_category_code <> G_LINE_CATEGORY_CODE_ORDER ) THEN
           --DBMS_OUTPUT.put_line( 'NEW: inside line cat code null check' );
            l_skip_curr_rec := TRUE;
            FND_MESSAGE.SET_NAME( 'CSD', 'CSD_CHRG_LINE_CAT_MISS');
        -- Line category code, for the current organization, is either incorrect or not set for the item $ITEM. Check the service activity billing types set up.
            FND_MESSAGE.SET_TOKEN( 'ITEM', p_MLE_lines_tbl( i ).item_name );
            FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_WARNING_MSG );
          END IF;
        END IF;

       --DBMS_OUTPUT.put_line( 'NEW: after line cat null check' );

        -- We ignore the record if instance number is required
        -- for the item, as we are unable to determine the instance number.
        -- Charges require Instance number on a line if the txn billing
        -- type is defined as an IB subtype and item is IB trackable.
      --

        -- vkjain 01/20/2004
      -- The following comment does not apply as Charges DO validate for
      -- instance num even for ORDER/SHIP lines. The code has been uncommented
      -- and the validation is reinstated.
      /**************************************************************************
        -- Shiv Ragunathan, 11/07/03, Commenting out this as based on the discussion
     -- with Vivek, Charges requires Instance Number for the above case
        -- only for RMA lines, Since actual lines are considered as Order lines,
        -- not RMA lines, commenting this out, Later the owner of the code can remove
        -- this piece of code and obsolete the message, if not used
      **************************************************************************/

         IF ( p_MLE_lines_tbl( i ).txn_billing_type_id IS NOT NULL AND
          p_MLE_lines_tbl( i ).comms_nl_trackable_flag = 'Y') THEN
         --DBMS_OUTPUT.put_line( 'NEW: Inside the IB check' );
          l_num_subtypes := 0;

          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                             'Opening cursor count_csi_txn_subtypes using '
                             || 'txn_billing_type_id = ' || p_MLE_lines_tbl( i ).txn_billing_type_id);
          end if;

          -- check if any csi txn subtypes exist. if at least one does, then throw an error
          OPEN count_csi_txn_subtypes( p_MLE_lines_tbl( i ).txn_billing_type_id );
          FETCH count_csi_txn_subtypes INTO l_num_subtypes;
          CLOSE count_csi_txn_subtypes;

          if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                             'Closed cursor count_csi_txn_subtypes. Value returned '
                             || 'l_num_subtypes = ' || l_num_subtypes);
          end if;

         --DBMS_OUTPUT.put_line( 'NEW: l_num_subtypes is ' || l_num_subtypes );
         --DBMS_OUTPUT.put_line( 'NEW: item is ' || p_MLE_lines_tbl( i ).inventory_item_id );
          IF ( l_num_subtypes > 0 ) THEN
            l_skip_curr_rec := TRUE;
            FND_MESSAGE.SET_NAME( 'CSD', 'CSD_CHRG_IB_REQ' );
        -- Instance number for the item $ITEM is required, based on it's service activity billing type set up.
            FND_MESSAGE.SET_TOKEN( 'ITEM',
                                   p_MLE_lines_tbl( i ).item_name );
            FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_WARNING_MSG );
          END IF;
        END IF;

       --DBMS_OUTPUT.put_line( 'NEW: outside IB check' );

        -- Defaulting the discount price to be same as the extended price.
        -- This is useful in the event no contract or discount
        -- is deteremined. In that case, the discounted price should be
        -- same as the extended price.
      l_extended_price := l_unit_selling_price * nvl(p_MLE_lines_tbl( i ).quantity,0);
        l_discounted_price := l_extended_price;

        -- We would like to derive the discount only if the current line had
        -- no prior errors and the selling price is not zero.
        -- Assuming no discount can be applied if the price is zero.
        IF ( NOT l_skip_curr_rec
             AND l_unit_selling_price > 0
             AND ( p_contract_line_id IS NOT NULL )
             AND ( p_business_process_id IS NOT NULL ))
           /*AND ( l_coverage_txn_group_id IS NOT NULL )*/ -- 6882951, rfieldma
                                                           -- FP of 6823603
                                                           -- r12 re-arch, l_coverage_txn_group_id is allowed
                                                           -- to be null.
		 THEN
         --DBMS_OUTPUT.put_line( 'NEW: To get the discouted price.' );

          if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                             'Calling procedure CSD_CHARGE_LINE_UTIL.GET_DISCOUNTEDPRICE with values - '
                             || 'p_contract_line_id = ' || p_contract_line_id
                             || ', p_repair_type_id = ' || p_repair_type_id
                             || ', p_txn_billing_type_id = ' || p_MLE_lines_tbl( i ).txn_billing_type_id
                             || ', p_coverage_txn_grp_id = ' || l_coverage_txn_group_id
                             || ', p_extended_price = ' || l_extended_price
                             || ', p_no_charge_flag = ' || l_no_charge_flag);
          end if;

          CSD_CHARGE_LINE_UTIL.GET_DISCOUNTEDPRICE( p_api_version         => 1.0,
                                                    p_init_msg_list       => 'F',
                                                    p_contract_line_id    => p_contract_line_id,
                                                    p_repair_type_id      => p_repair_type_id,
                                                    p_txn_billing_type_id => p_MLE_lines_tbl( i ).txn_billing_type_id,
                                                    p_coverage_txn_grp_id => l_coverage_txn_group_id,
                                                    p_extended_price      => l_extended_price,
                                                    p_no_charge_flag      => 'N', --l_no_charge_flag, as we always
                                                              -- want to know the discount amount.
                                                    x_discounted_price    => l_discounted_price,
                                                    x_return_status       => l_return_status,
                                                    x_msg_count           => l_msg_count,
                                                    x_msg_data            => l_msg_data );

          if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                             'Returned from procedure CSD_CHARGE_LINE_UTIL.GET_DISCOUNTEDPRICE with values - '
                             || 'x_discounted_price = ' || l_discounted_price
                             || ', x_return_status = ' || l_return_status);
          end if;

          IF (( l_return_status <> FND_API.G_RET_STS_SUCCESS )
               OR ( l_discounted_price IS NULL )) THEN
            l_skip_curr_rec := TRUE;
            FND_MESSAGE.SET_NAME( 'CSD', 'CSD_CHRG_DISCOUNT_PRICE');
        -- There was an error while trying to get discount price for the item $ITEM using the contract $CONTRACT_NUMBER.
            FND_MESSAGE.SET_TOKEN( 'ITEM', p_MLE_lines_tbl( i ).item_name);
            FND_MESSAGE.SET_TOKEN( 'CONTRACT_NUMBER', l_contract_number );
            FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_ERROR_MSG );
          END IF;
        END IF;

        -- We do not do Actuals costing.
        /*
           CSD_COST_ANALYSIS_PVT.Get_InvItemCost(
           p_api_version           =>     1.0,
           p_commit                =>     fnd_api.g_false,
           p_init_msg_list         =>     fnd_api.g_false,
           p_validation_level      =>     fnd_api.g_valid_level_full,
           x_return_status         =>     x_return_status,
           x_msg_count             =>     x_msg_count,
           x_msg_data              =>     x_msg_data,
           p_inventory_item_id     =>     p_MLE_lines_tbl(i).inventory_item_id,
           p_quantity              =>     p_MLE_lines_tbl(i).quantity,
           p_organization_id       =>     p_organization_id,
           p_charge_date           =>     sysdate,
           p_currency_code         =>     p_currency_code,
           x_item_cost             =>     px_charge_lines_tbl(l_curRow).item_cost
           );
           if(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
           px_charge_lines_tbl(l_curRow).item_cost := null;
           --
           -- give warning message that cost could not be determined?
           -- x_warning_flag  := FND_API.G_TRUE;
           -- x_return_status := FND_API.G_RET_STS_ERROR;
           --FND_MESSAGE.SET_NAME('CSD','CSD_EST_ESTIMATED_CHARGE_ERR');
           --FND_MESSAGE.SET_TOKEN('CONTRACT_NUMBER',px_charge_lines_tbl(l_curRow).contract_number);
           --FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_WARNING_MSG );
           -- l_skip_curr_rec := TRUE;
           end if;
           */

        l_last_inv_item := l_curr_inv_item;
      END IF;

      IF ( NOT l_skip_curr_rec ) THEN
        -- This ensures that we always add a record for a new index.
        l_curRow := px_valid_MLE_lines_tbl.COUNT + 1;

        if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
                           'Current record# ' || l_curRow || ' is not skipped');
        end if;

       --DBMS_OUTPUT.put_line( 'NEW: Inside the valid loop '
       --                       || l_curRow );

        -- Populate the 'valid' MLE table.
        px_valid_MLE_lines_tbl( l_curRow ).inventory_item_id := p_MLE_lines_tbl( i ).inventory_item_id;
        px_valid_MLE_lines_tbl( l_curRow ).uom := p_MLE_lines_tbl( i ).uom;
        px_valid_MLE_lines_tbl( l_curRow ).quantity := p_MLE_lines_tbl( i ).quantity;
        px_valid_MLE_lines_tbl( l_curRow ).item_name := p_MLE_lines_tbl( i ).item_name;
        px_valid_MLE_lines_tbl( l_curRow ).comms_nl_trackable_flag := p_MLE_lines_tbl( i ).comms_nl_trackable_flag;
        px_valid_MLE_lines_tbl( l_curRow ).txn_billing_type_id := p_MLE_lines_tbl( i ).txn_billing_type_id;
        px_valid_MLE_lines_tbl( l_curRow ).transaction_type_id := p_MLE_lines_tbl( i ).transaction_type_id;
        px_valid_MLE_lines_tbl( l_curRow ).source_code := p_MLE_lines_tbl( i ).source_code;
        px_valid_MLE_lines_tbl( l_curRow ).source_id1 := p_MLE_lines_tbl( i ).source_id1;
        px_valid_MLE_lines_tbl( l_curRow ).source_id2 := p_MLE_lines_tbl( i ).source_id2;
        px_valid_MLE_lines_tbl( l_curRow ).item_cost := p_MLE_lines_tbl( i ).item_cost;
        px_valid_MLE_lines_tbl( l_curRow ).override_charge_flag := NVL( l_no_charge_flag,
                                                                        'N' );

        -- Added for ER 3607765, vkjain.
        px_valid_MLE_lines_tbl( l_curRow ).resource_id := p_MLE_lines_tbl( i ).resource_id;

        -- values from individual params
        px_charge_lines_tbl( l_curRow ).incident_id := p_incident_id;-- derived value, do we need this?
        px_charge_lines_tbl( l_curRow ).business_process_id := p_business_process_id;-- optional value?, used if derived value not available
        px_charge_lines_tbl( l_curRow ).currency_code := p_currency_code;-- derived value, do we need this?
        px_charge_lines_tbl( l_curRow ).price_list_id := p_price_list_id;-- required param

        -- values from MLE_LINES
        px_charge_lines_tbl( l_curRow ).txn_billing_type_id := p_MLE_lines_tbl( i ).txn_billing_type_id;-- required param
        px_charge_lines_tbl( l_curRow ).transaction_type_id := p_MLE_lines_tbl( i ).transaction_type_id;
        px_charge_lines_tbl( l_curRow ).inventory_item_id_in := p_MLE_lines_tbl( i ).inventory_item_id;-- required param
        px_charge_lines_tbl( l_curRow ).unit_of_measure_code := p_MLE_lines_tbl( i ).uom;-- required param
        px_charge_lines_tbl( l_curRow ).quantity_required := p_MLE_lines_tbl( i ).quantity;-- required param
        px_charge_lines_tbl( l_curRow ).selling_price := l_unit_selling_price;
      IF (l_no_charge_flag = 'Y') THEN
           px_charge_lines_tbl( l_curRow ).after_warranty_cost := 0;
      ELSE
           px_charge_lines_tbl( l_curRow ).after_warranty_cost := l_discounted_price;
      END IF;

        -- null items
        px_charge_lines_tbl( l_curRow ).source_number := NULL;
        px_charge_lines_tbl( l_curRow ).original_source_number := NULL;
        --px_charge_lines_tbl(l_curRow).reference_number          := null;
        --px_charge_lines_tbl(l_curRow).order_number              := null;
        --px_charge_lines_tbl(l_curRow).original_system_reference := null;
        --px_charge_lines_tbl(l_curRow).lot_number                := null;
        --px_charge_lines_tbl(l_curRow).instance_id               := null;
        --px_charge_lines_tbl(l_curRow).instance_number           := null;
        --px_charge_lines_tbl(l_curRow).coverage_bill_rate_id     := null;
        --px_charge_lines_tbl(l_curRow).sub_inventory             := null;
        --px_charge_lines_tbl(l_curRow).return_reason             := null;
        --px_charge_lines_tbl(l_curRow).last_update_date          := null;
        --px_charge_lines_tbl(l_curRow).last_updated_by           := null;
        --px_charge_lines_tbl(l_curRow).created_by                := null;
        --px_charge_lines_tbl(l_curRow).last_update_login         := null;
        --px_charge_lines_tbl(l_curRow).security_group_id         := null;

        -- non-null items
        --px_charge_lines_tbl(l_curRow).return_by_date            := sysdate;
        --px_charge_lines_tbl(l_curRow).creation_date             := sysdate;
        -- px_charge_lines_tbl(l_curRow).charge_line_type          := G_CHARGE_LINE_TYPE_ACTUAL;
        px_charge_lines_tbl( l_curRow ).line_type_id := l_line_type_id;
        px_charge_lines_tbl( l_curRow ).line_category_code := l_line_category_code;
        px_charge_lines_tbl( l_curRow ).original_source_code := G_CHARGES_SOURCE_CODE_DR;
        px_charge_lines_tbl( l_curRow ).original_source_id := p_repair_line_id;
        px_charge_lines_tbl( l_curRow ).source_code := G_CHARGES_SOURCE_CODE_DR;
        px_charge_lines_tbl( l_curRow ).source_id := p_repair_line_id;
        px_charge_lines_tbl( l_curRow ).charge_line_type := p_charge_line_type;
        px_charge_lines_tbl( l_curRow ).no_charge_flag := l_no_charge_flag;
        px_charge_lines_tbl( l_curRow ).interface_to_oe_flag := 'N';
        px_charge_lines_tbl( l_curRow ).contract_id := l_contract_id;
      --Contract re arch changes for R12
        px_charge_lines_tbl( l_curRow ).contract_line_id := p_contract_line_id;
        px_charge_lines_tbl( l_curRow ).coverage_id := l_coverage_id;
        px_charge_lines_tbl( l_curRow ).coverage_txn_group_id := l_coverage_txn_group_id;
        px_charge_lines_tbl( l_curRow ).apply_contract_discount := 'N';
/*      IF l_coverage_txn_group_id IS NOT NULL THEN */ -- 6823603, rfieldma, due to r12 re-arch
                                                       -- there is not restriction on txn_grp_id
           px_charge_lines_tbl( l_curRow ).contract_discount_amount := l_extended_price - l_discounted_price;
/*      END IF;*/

      ELSE
        -- If the current row is not valid then set the OUT flag.
        x_warning_flag := FND_API.G_TRUE;
       --DBMS_OUTPUT.put_line( 'NEW: Inside the warnings ..'
       --                       || x_warning_flag );

      END IF;

    END LOOP;

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                       'End LOOP through p_MLE_lines_tbl table');
    end if;

    --
    -- End API Body
    --

    --IF ( x_warning_flag = FND_API.G_TRUE ) THEN
     --DBMS_OUTPUT.put_line( 'NEW: TRUE WARNING' );
    --END IF;

    -- Standard check of p_commit.

    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;-- Standard call to get message count and IF count is  get message info.

    -- logging
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.END',
                       'Leaving CSD_CHARGE_LINE_UTIL.convert_to_charge_lines');
    end if;

    /*
       FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
       p_data   =>  x_msg_data );
       */

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Convert_To_Actual_Lines;
       --DBMS_OUTPUT.put_line( 'NEW: Inside EXC ERROR' );
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                   p_data  => x_msg_data );

        -- save message in debug log
        IF (lc_excep_level >= lc_debug_level) THEN
           FND_LOG.STRING(lc_excep_level, lc_mod_name,
                          'EXC_ERROR['||x_msg_data||']');
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Convert_To_Actual_Lines;
       --DBMS_OUTPUT.put_line( 'NEW: Inside UNEXP ERROR' );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                   p_data  => x_msg_data );

        -- save message in debug log
        IF (lc_excep_level >= lc_debug_level) THEN
           FND_LOG.STRING(lc_excep_level, lc_mod_name,
                          'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
        END IF;

      WHEN OTHERS THEN
        ROLLBACK TO Convert_To_Actual_Lines;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --DBMS_OUTPUT.put_line( 'SQLCODE= '
       --                       || SQLCODE );
       --DBMS_OUTPUT.put_line( 'SQLERRM= '
       --                       || SQLERRM );

        IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, lc_api_name );
        END IF;

        -- save message in debug log
        IF (lc_excep_level >= lc_debug_level) THEN
           FND_LOG.STRING(lc_excep_level, lc_mod_name,
                          'WHEN OTHERS THEN. SQL Message['||SQLERRM||']');
        END IF;

        FND_MESSAGE.SET_NAME( 'CSD', 'CSD_CHRG_MLE_CHRG_FORMAT_ERR');
        -- Encountered an error while converting MLE lines into charge line format. SQLCODE = $SQLCODE, SQLERRM = $SQLERRM.
        FND_MESSAGE.set_token('SQLCODE' , SQLCODE);
        FND_MESSAGE.set_token('SQLERRM' , SQLERRM);
        FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_ERROR_MSG );
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                   p_data  => x_msg_data );
  END Convert_To_Charge_Lines;



END CSD_CHARGE_LINE_UTIL;

/
