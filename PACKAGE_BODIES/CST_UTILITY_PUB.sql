--------------------------------------------------------
--  DDL for Package Body CST_UTILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_UTILITY_PUB" AS
/* $Header: CSTUTILB.pls 120.6.12010000.2 2008/10/31 11:05:27 prashkum ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CST_Utility_PUB';

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   writeLogMessages                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API loops through the message stack and writes the messages to  --
-- log file                                                               --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.4                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    10/12/00     Anitha B       Created                                 --
----------------------------------------------------------------------------
PROCEDURE writeLogMessages (p_api_version       IN   NUMBER,

                            p_msg_count   	IN   NUMBER,
                            p_msg_data          IN   VARCHAR2,

                            x_return_status     OUT NOCOPY  VARCHAR2) IS

    l_api_name    CONSTANT       VARCHAR2(30) := 'writeLogMessages';
    l_api_version CONSTANT       NUMBER       := 1.0;

    l_msg_count   NUMBER;
    l_msg_data    VARCHAR2(8000);

    l_stmt_num    NUMBER := 0;

BEGIN
    -- standard start of API savepoint
    SAVEPOINT writeLogMessages_PUB;

    -- standard call to check for call compatibility
    if not fnd_api.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then
         raise fnd_api.g_exc_unexpected_error;
    end if;

    -- initialize api return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- assign to local variables
    l_msg_count := p_msg_count;
    l_msg_data := p_msg_data;

    /* obtain messages from the message list */
    l_stmt_num := 20;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => l_msg_count,
            p_data    => l_msg_data
    );

    /* write all messages in the concurrent manager log */
    l_stmt_num := 20;
    IF(l_msg_count > 0) THEN
            FOR i in 1 ..l_msg_count
            LOOP
               l_msg_data := FND_MSG_PUB.get(i, FND_API.g_false);
               FND_FILE.PUT_LINE(FND_FILE.LOG, i ||'-'||l_msg_data);
            END LOOP;
    END IF;

 EXCEPTION
    when fnd_api.g_exc_error then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_file.put_line(fnd_file.log,'CST_Utility_PUB.writeLogMessages(' || l_stmt_num || '): ' || x_return_status || substr(SQLERRM,1,200));
    when fnd_api.g_exc_unexpected_error then
       x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_file.put_line(fnd_file.log,'CST_Utility_PUB.writeLogMessages(' || l_stmt_num || '): ' || x_return_status || substr(SQLERRM,1,200));
    when others then
       x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_file.put_line(fnd_file.log,'CST_Utility_PUB.writeLogMessages(' || l_stmt_num || '): ' || x_return_status || substr(SQLERRM,1,200));

END writeLogMessages;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   getTxnCategoryId                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API loops through the message stack and writes the messages to  --
-- log file                                                               --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.4                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    11/03/00     Hemant G       Created                                 --
----------------------------------------------------------------------------
PROCEDURE getTxnCategoryId (p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2
                                                  := FND_API.G_FALSE,
                            p_commit             IN   VARCHAR2
                                                  := FND_API.G_FALSE,
                            p_validation_level   IN   NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,


                            p_txn_id		 IN   NUMBER,
                            p_txn_action_id      IN   NUMBER,
                            p_txn_source_type_id IN   NUMBER,
                            p_txn_source_id      IN   NUMBER,
                            p_item_id            IN   NUMBER,
                            p_organization_id    IN   NUMBER,

                            x_category_id        OUT NOCOPY  NUMBER,
                            x_return_status      OUT NOCOPY  VARCHAR2,
                            x_msg_count          OUT NOCOPY  NUMBER,
                            x_msg_data           OUT NOCOPY  VARCHAR2 ) IS

    l_api_name        CONSTANT       VARCHAR2(30) := 'getTxnCategoryId';
    l_api_version     CONSTANT       NUMBER       := 1.0;

    l_item_id         NUMBER := 0;
    l_category_set_id NUMBER := 0;
    l_category_id     NUMBER := 0;
    l_statement       NUMBER := 0;

BEGIN

    -------------------------------------------------------------------------
    -- standard start of API savepoint
    -------------------------------------------------------------------------
    SAVEPOINT getTxnCategoryId;

    -------------------------------------------------------------------------
    -- standard call to check for call compatibility
    -------------------------------------------------------------------------
    IF NOT fnd_api.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then

         RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    -------------------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;


    -------------------------------------------------------------------------
    -- initialize api return status to success
    -------------------------------------------------------------------------
    x_return_status := fnd_api.g_ret_sts_success;

    -- assign to local variables
    l_statement := 10;
    l_item_id   := p_item_id;

    IF (p_txn_source_type_id = 5 AND p_txn_action_id IN (1,27,33,34)) THEN

      l_statement := 20;


      SELECT MAX(primary_item_id)
      INTO   l_item_id
      FROM   wip_entities we
      WHERE  we.wip_entity_id = p_txn_source_id;

      -----------------------------------------------------------------------
      -- Primary item id may be NULL for non-standard jobs
      -- In this situation we should return the category id
      -- of the component and not the assembly
      -----------------------------------------------------------------------

      IF l_item_id IS NULL THEN

        l_item_id := p_item_id;

      END IF;

    END IF; -- check for comp txns

    l_statement := 30;

    SELECT  category_set_id
    INTO    l_category_set_id
    FROM    mtl_default_category_sets mdcs
    WHERE   functional_area_id = 5;

    -------------------------------------------------------------------------
    -- If an item is assigned to multiple categries in the default
    -- category set of costing functional area
    -- get the max category id.
    -- For costing functional area's default category set, recommendation
    -- is to assign item to only one category.
    -------------------------------------------------------------------------

    l_statement := 40;

    SELECT  MAX(category_id)
    INTO    l_category_id
    FROM    mtl_item_categories mic
    WHERE   mic.inventory_item_id = l_item_id
    AND     mic.organization_id   = p_organization_id
    AND     mic.category_set_id   = l_category_set_id;

    IF l_category_id IS NULL THEN
      x_category_id := -1;
    ELSE
      x_category_id := l_category_id;
    END IF;

    ---------------------------------------------------------------------------
    -- Standard check of p_commit
    ---------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    ---------------------------------------------------------------------------
    -- Standard Call to get message count and if count = 1, get message info
    ---------------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );



 EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_Utility_Pub'
              , 'getTxnCategoryId : Statement - '||to_char(l_statement)
              );

        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );

END getTxnCategoryId;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   get_Std_CG_Acct_Flag                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API determines if the standard costing organization follows     --
-- cost group accounting. If yes, then it has PJM support. If the         --
-- organization ID provided is not standard costing organization, the     --
-- API will always return 0                                               --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.6                                        --
-- PJM support for Standard Costing Organizations                         --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    11/03/00     Anitha Dixit      Created                              --
----------------------------------------------------------------------------
PROCEDURE get_Std_CG_Acct_Flag (
                            p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2
                                                := FND_API.G_FALSE,
                            p_commit             IN   VARCHAR2
                                                := FND_API.G_FALSE,
                            p_validation_level   IN   NUMBER
                                                := FND_API.G_VALID_LEVEL_FULL,

                            p_organization_id    IN   NUMBER,
                            p_organization_code  IN   VARCHAR2,

                            x_cg_acct_flag       OUT NOCOPY  NUMBER,
                            x_return_status      OUT NOCOPY  VARCHAR2,
                            x_msg_count          OUT NOCOPY  NUMBER,
                            x_msg_data           OUT NOCOPY  VARCHAR2 ) IS

          l_api_name 	CONSTANT	VARCHAR2(30) := 'get_Std_CG_Acct_Flag';
          l_api_version CONSTANT	NUMBER       := 1.0;

          l_api_message			VARCHAR2(240);

          l_statement   		NUMBER := 0;
          l_cost_method 		NUMBER := 0;
          l_cg_acct_flag 		NUMBER := 0;



BEGIN
      ---------------------------------------------
      --  Standard start of API savepoint
      ---------------------------------------------
      SAVEPOINT get_Std_CG_Acct_Flag;

      ------------------------------------------------
      --  Standard call to check for API compatibility
      ------------------------------------------------
      l_statement := 10;
      IF not fnd_api.compatible_api_call (
                                  l_api_version,
                                  p_api_version,
                                  l_api_name,
                                  G_PKG_NAME ) then
            RAISE fnd_api.G_exc_unexpected_error;
      END IF;

      ------------------------------------------------------------
      -- Initialize message list if p_init_msg_list is set to TRUE
      -------------------------------------------------------------
      l_statement := 20;
      IF fnd_api.to_Boolean(p_init_msg_list) then
          fnd_msg_pub.initialize;
      end if;

      -------------------------------------------------------------
      --  Initialize API return status to Success
      -------------------------------------------------------------
      l_statement := 30;
      x_return_status := fnd_api.g_ret_sts_success;


      -------------------------------------------------
      --  Validate input parameters
      -------------------------------------------------
      l_statement := 40;
      if ((p_organization_id is null) and (p_organization_code is null)) then
            l_api_message := 'Please specify an organization';
            FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
            FND_MESSAGE.set_token('TEXT', l_api_message);
            FND_MSG_PUB.add;

            RAISE fnd_api.g_exc_error;
      end if;

      ---------------------------------------------
      --  Obtain organization parameters
      ---------------------------------------------
      if (p_organization_code is not null) then
           l_statement := 50;
           select primary_cost_method,nvl(cost_group_accounting,0)
           into l_cost_method,l_cg_acct_flag
           from mtl_parameters
           where organization_code = p_organization_code;
      else
           l_statement := 60;
           select primary_cost_method,nvl(cost_group_accounting,0)
           into l_cost_method,l_cg_acct_flag
           from mtl_parameters
           where organization_id = p_organization_id;
      end if;

      ---------------------------------------------
      --  Validate cost method
      ---------------------------------------------
      if (l_cost_method = 1) then
           l_statement := 70;
           x_cg_acct_flag := l_cg_acct_flag;
      else
        l_statement := 80;
        l_api_message := 'This function is not valid for non-standard costing organizations';
        FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
        FND_MESSAGE.set_token('TEXT', l_api_message);
        FND_MSG_PUB.add;

        x_cg_acct_flag := 0;
      end if;

EXCEPTION
    WHEN fnd_api.g_exc_error then
       x_return_status := fnd_api.g_ret_sts_error;

       fnd_msg_pub.count_and_get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN fnd_api.g_exc_unexpected_error then
       x_return_status := fnd_api.g_ret_sts_unexp_error;

       fnd_msg_pub.count_and_get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      If fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
           fnd_msg_pub.add_exc_msg
              ( 'CST_Utility_PUB','get_Std_CG_Acct_Flag : Statement - ' || to_char(l_statement));
      end if;

      fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data );
END get_Std_CG_Acct_Flag;



-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  insert_MTA      Function to ensure correct insertion of data into MTA  --
--                  Can be called from user code including the             --
--                  cst_dist_hook functions.  It derives the values for    --
--                  populating the table from what the user provides.      --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--  P_ORG_ID           Organization ID - REQUIRED                          --
--  P_TXN_ID           Transaction ID - REQUIRED: should exist in MMT      --
--  P_USER_ID          User ID - REQUIRED                                  --
--  P_LOGIN_ID         Login ID                                            --
--  P_REQ_ID           Request ID                                          --
--  P_PRG_APPL_ID      Program Application ID                              --
--  P_PRG_ID           Program ID                                          --
--  P_ACCOUNT          Reference account - should correspond to            --
--                     gl_code_combinations.code_combination_id            --
--  P_DBT_CRDT         Debit / Credit flag - enter 1 for debit             --
--                                                -1 for credit            --
--                     will be used to set the sign for both base_txn_value--
--                     and primary_quantity in MTA                         --
--  P_LINE_TYP         Accounting line type - should correspond to a       --
--                     lookup for CST_ACCOUNTING_LINE_TYPE                 --
--  P_BS_TXN_VAL       Total txn value in base currency - Enter a positive --
--                     value, the sign will be determined by the value of  --
--                     P_DBT_CRDT                                          --
--  P_CST_ELEMENT      Cost element ID (1-5) - 1=material, 2=MOH, ...      --
--  P_RESOURCE_ID      Resource ID from BOM_RESOURCES - should correspond  --
--                     to bom_resources.resource_id                        --
--  P_ENCUMBR_ID       Encumbrance type ID - should correspond to          --
--                     gl_encumbrance_types.encumbrance_type_id            --
--                                                                         --
-- HISTORY:                                                                --
--    09/25/02     Bryan Kuntz      Created                                --
-- End of comments
-----------------------------------------------------------------------------
procedure insert_MTA (
  P_API_VERSION    IN          NUMBER,
  P_INIT_MSG_LIST  IN          VARCHAR2,
  P_COMMIT         IN          VARCHAR2,
  X_RETURN_STATUS  OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT      OUT NOCOPY  NUMBER,
  X_MSG_DATA       OUT NOCOPY  VARCHAR2,
  P_ORG_ID         IN          NUMBER,
  P_TXN_ID         IN          NUMBER,
  P_USER_ID        IN          NUMBER,
  P_LOGIN_ID       IN          NUMBER,
  P_REQ_ID         IN          NUMBER,
  P_PRG_APPL_ID    IN          NUMBER,
  P_PRG_ID         IN          NUMBER,
  P_ACCOUNT        IN          NUMBER,
  P_DBT_CRDT       IN          NUMBER,
  P_LINE_TYP       IN          NUMBER,
  P_BS_TXN_VAL     IN          NUMBER,
  P_CST_ELEMENT    IN          NUMBER,
  P_RESOURCE_ID    IN          NUMBER,
  P_ENCUMBR_ID     IN          NUMBER
) IS

  /* local control variables */
  l_api_name            CONSTANT VARCHAR2(30) := 'insert_MTA';
  l_api_version         CONSTANT NUMBER       := 1.0;
  l_debug               VARCHAR2(1);
  l_stmt_num            number := 0;

  /* local data variables */
  l_sob_id              number;
  l_pri_curr            gl_sets_of_books.currency_code%TYPE;     -- varchar2(15);
  l_min_acct_unit       fnd_currencies.minimum_accountable_unit%TYPE;
  l_precision           fnd_currencies.precision%TYPE;
  l_num                 number;

  l_api_message varchar2(150);

BEGIN

  SAVEPOINT Insert_MTA_PUB;
  -- Initialize message list if p_init_msg_list is set to TRUE
  if FND_API.to_Boolean(P_INIT_MSG_LIST) then
    FND_MSG_PUB.initialize;
  end if;
  FND_MESSAGE.set_name('BOM', 'CST_API_MESSAGE');

  -- Standard check for compatibility
  IF NOT FND_API.Compatible_API_Call (
                      l_api_version,
                      P_API_VERSION,
                      l_api_name,
                      G_PKG_NAME ) -- line 90
  THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize API return status to success
  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  -- API body

  l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
  if (l_debug = 'Y') then
    l_api_message := 'insert_MTA API: Txn ID = '||to_char(P_TXN_ID);
    FND_FILE.PUT_LINE(fnd_file.log,l_api_message);
  end if;

  -- Check that required parameters are not null
  if (P_ORG_ID is null OR P_TXN_ID is null OR P_USER_ID is null OR P_DBT_CRDT is null
      OR P_LINE_TYP is null OR P_BS_TXN_VAL is null) then
    l_api_message := 'Required parameters P_ORG_ID, P_TXN_ID, P_USER_ID, P_DBT_CRDT, P_LINE_TYP, and P_BS_TXN_VAL must not be NULL';
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Check P_ACCOUNT
  l_stmt_num := 10;
  l_api_message := 'P_ACCOUNT';
  if P_ACCOUNT IS NOT NULL then
    select 1
    into l_num
    from gl_code_combinations
    where code_combination_id = P_ACCOUNT;
  end if;

  -- Check P_DBT_CRDT
  l_stmt_num := 20;
  if (P_DBT_CRDT <> -1 AND P_DBT_CRDT <> 1) then
    l_api_message := 'Invalid P_DBT_CRDT: should be 1 or -1';
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Check that P_LINE_TYP exists
  l_stmt_num := 30;
  l_api_message := 'P_LINE_TYP';
  select 1
  into l_num
  from mfg_lookups
  where lookup_type = 'CST_ACCOUNTING_LINE_TYPE'
  and lookup_code = P_LINE_TYP;

  -- Check P_CST_ELEMENT
  l_stmt_num := 40;
  if P_CST_ELEMENT IS NOT NULL then
    l_api_message := 'P_CST_ELEMENT';
    select 1
    into l_num
    from cst_cost_elements
    where cost_element_id = P_CST_ELEMENT;
  end if;

  -- Check P_RESOURCE_ID
  l_stmt_num := 50;
  if P_RESOURCE_ID IS NOT NULL then
    l_api_message := 'P_RESOURCE_ID';
    select 1
    into l_num
    from bom_resources
    where resource_id = P_RESOURCE_ID;
  end if;

  -- Check P_ENCUMBR_ID
  l_stmt_num := 60;
  if P_ENCUMBR_ID IS NOT NULL then
    l_api_message := 'P_ENCUMBR_ID';
    select 1
    into l_num
    from gl_encumbrance_types
    where encumbrance_type_id = P_ENCUMBR_ID;
  end if;

  -- Get Set of Books ID
  l_stmt_num := 70;
  l_api_message := 'P_ORG_ID';
  select ledger_id
  into l_sob_id
  from cst_acct_info_v
  where organization_id = P_ORG_ID;

  if (l_debug = 'Y') then
    l_api_message := 'Got Set_Of_Books_ID = '||to_char(l_sob_id);
    FND_FILE.PUT_LINE (fnd_file.log, l_api_message);
  end if;

  -- Get primary currency
  l_stmt_num := 80;
  select currency_code
  into l_pri_curr
  from gl_sets_of_books
  where set_of_books_id = l_sob_id;

  -- Get precision and minimum_accountable_unit for the primary currency
  l_stmt_num := 90;
  select precision, minimum_accountable_unit
  into l_precision, l_min_acct_unit
  from fnd_currencies
  where currency_code = l_pri_curr;

  if (l_debug = 'Y') then
    l_api_message := 'Got currency code = '||l_pri_curr;
    FND_FILE.PUT_LINE (fnd_file.log,l_api_message);
  end if;

  l_stmt_num := 100;
  insert into mtl_transaction_accounts     -- line 95
	(ORGANIZATION_ID,
	TRANSACTION_ID,
	REFERENCE_ACCOUNT,
	INVENTORY_ITEM_ID,
	BASE_TRANSACTION_VALUE,
	PRIMARY_QUANTITY,
	ACCOUNTING_LINE_TYPE,
	COST_ELEMENT_ID,
	TRANSACTION_DATE,
	TRANSACTION_SOURCE_ID,
	TRANSACTION_SOURCE_TYPE_ID,
	TRANSACTION_VALUE,
	RATE_OR_AMOUNT,
	BASIS_TYPE,
	RESOURCE_ID,
	ACTIVITY_ID,
	CURRENCY_CODE,
	CURRENCY_CONVERSION_DATE,
	CURRENCY_CONVERSION_TYPE,
	CURRENCY_CONVERSION_RATE,
	ENCUMBRANCE_TYPE_ID,
	GL_BATCH_ID,
	CONTRA_SET_ID,
	REPETITIVE_SCHEDULE_ID,
	GL_SL_LINK_ID,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN)
  select  P_ORG_ID,
	P_TXN_ID,
	P_ACCOUNT,
	mmt.inventory_item_id,
	decode(l_min_acct_unit, NULL, decode(l_precision, NULL, ABS(P_BS_TXN_VAL) * sign(P_DBT_CRDT),
                                      ROUND(ABS(P_BS_TXN_VAL) * sign(P_DBT_CRDT), l_precision)),
	    ROUND(ABS(P_BS_TXN_VAL) * sign(P_DBT_CRDT) / l_min_acct_unit) * l_min_acct_unit),
	ABS(
          DECODE(
            mmt.transaction_action_id,
            24,
            mmt.quantity_adjusted,
            mmt.primary_quantity
          )
        ) * sign(P_DBT_CRDT),
	P_LINE_TYP,
	P_CST_ELEMENT,
	mmt.transaction_date,
	decode(mmt.transaction_source_type_id, 16, -1, nvl(mmt.transaction_source_id, -1)),
	mmt.transaction_source_type_id,
	decode(mmt.currency_code, NULL, NULL, l_pri_curr, NULL,
	  decode(mmt.currency_conversion_rate, NULL, NULL, 0, NULL,
	    decode(fc.minimum_accountable_unit, NULL,
	      decode(fc.precision, NULL, sign(P_DBT_CRDT) * ABS(P_BS_TXN_VAL) / mmt.currency_conversion_rate,
	        ROUND(sign(P_DBT_CRDT) * ABS(P_BS_TXN_VAL) / mmt.currency_conversion_rate, fc.precision)),
	      ROUND(sign(P_DBT_CRDT) * ABS(P_BS_TXN_VAL) / mmt.currency_conversion_rate / fc.minimum_accountable_unit) * fc.minimum_accountable_unit))),
	decode(mmt.primary_quantity, 0, 0, sign(P_DBT_CRDT) * ABS(P_BS_TXN_VAL) / mmt.primary_quantity),
	1,
	P_RESOURCE_ID,
	NULL,
	decode(mmt.currency_code, l_pri_curr, NULL, mmt.currency_code),
	decode(mmt.currency_code, l_pri_curr, NULL, NULL, NULL, nvl(mmt.currency_conversion_date, mmt.transaction_date)),
	decode(mmt.currency_code, l_pri_curr, NULL, NULL, NULL, mmt.currency_conversion_type),
	decode(mmt.currency_code, l_pri_curr, NULL, NULL, NULL, nvl(mmt.currency_conversion_rate, -1)),
	P_ENCUMBR_ID,
	-1,
	1,
	NULL,
	NULL,
	P_REQ_ID,
	P_PRG_APPL_ID,
	-1*P_PRG_ID,
	sysdate,
	sysdate,
	P_USER_ID,
	sysdate,
	P_USER_ID,
	P_LOGIN_ID
  from mtl_material_transactions mmt, fnd_currencies fc
  where mmt.transaction_id = P_TXN_ID
  and (mmt.organization_id = P_ORG_ID or
       mmt.transfer_organization_id = P_ORG_ID)
  and fc.currency_code = nvl(mmt.currency_code, l_pri_curr);

  if SQL%FOUND then -- insert succeeded
    l_api_message := 'INSERT succeeded';
  else
    l_api_message := 'Insert Failed for txn_id '||to_char(P_TXN_ID)||'. Check that it exists in MMT and that P_ORG_ID is correct.';
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if (l_debug = 'Y') then
    FND_FILE.PUT_LINE (fnd_file.log,l_api_message);
  end if;

  FND_MESSAGE.set_token('TEXT', l_api_message);
  FND_MSG_PUB.ADD;

  -- End of API body

  FND_MSG_PUB.Count_And_Get (
         p_encoded   => FND_API.G_FALSE,
         p_count     => X_MSG_COUNT,
         p_data      => X_MSG_DATA );

  -- Standard check of P_COMMIT
  IF FND_API.to_Boolean(P_COMMIT) THEN
     COMMIT WORK;
  END IF;

EXCEPTION

  when NO_DATA_FOUND then
    l_api_message := 'Error at statement '||to_char(l_stmt_num)||'. Invalid '||l_api_message;
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get (
         p_encoded   => FND_API.G_FALSE,
         p_count     => X_MSG_COUNT,
         p_data      => X_MSG_DATA );
    X_RETURN_STATUS := fnd_api.g_ret_sts_error;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get (
         p_encoded   => FND_API.G_FALSE,
         p_count     => X_MSG_COUNT,
         p_data      => X_MSG_DATA );
    X_RETURN_STATUS := fnd_api.g_ret_sts_unexp_error;
  when FND_API.G_EXC_ERROR then
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get (
         p_encoded   => FND_API.G_FALSE,
         p_count     => X_MSG_COUNT,
         p_data      => X_MSG_DATA );
    X_RETURN_STATUS := fnd_api.g_ret_sts_error;
  when OTHERS then
    l_api_message := 'Error after statement '||to_char(l_stmt_num)||'. SQLCODE '||to_char(SQLCODE)||': '|| substrb(SQLERRM,1,100);
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get (
         p_encoded   => FND_API.G_FALSE,
         p_count     => X_MSG_COUNT,
         p_data      => X_MSG_DATA );
    X_RETURN_STATUS := fnd_api.g_ret_sts_unexp_error;

END insert_MTA;

FUNCTION get_ret_sts_success return varchar2
IS
BEGIN
  return fnd_api.g_ret_sts_success;
END get_ret_sts_success;

FUNCTION get_ret_sts_error return varchar2
IS
BEGIN
  return fnd_api.g_ret_sts_error;
END get_ret_sts_error;

FUNCTION get_ret_sts_unexp_error return varchar2
IS
BEGIN
  return fnd_api.g_ret_sts_unexp_error;
END get_ret_sts_unexp_error;

FUNCTION get_true return varchar2
IS
BEGIN
  return fnd_api.g_true;
END get_true;

FUNCTION get_false return varchar2
IS
BEGIN
  return fnd_api.g_false;
END get_false;

FUNCTION get_log return number
IS
BEGIN
  return fnd_file.log;
END get_log;

-----------------------------------------------------------------------------
-- PROCEDURE                                                               --
--  get_ZeroCost_Flag							   --
--                                                                         --
-- DESCRIPTION								   --
--  Transaction ID and organization ID are passed in to this procedure.	   --
--  With this information, check to see if:				   --
--    organization_id is EAM-enabled,					   --
--    transaction_source_type = 5,					   --
--    transaction_action_id = 1, 27, 33, 34				   --
--    subinventory_code is an expense subinventory			   --
--    inventory item is an asset item					   --
--    entity_type of wip_entity_id = 6, 7				   --
--  If any of these conditions are not passed, then return 0		   --
--  After checking that all these conditions pass, then check the	   --
--    issue_zero_cost_flag in wip_discrete_jobs of the work order;	   --
--    return the value of the flag					   --
--									   --
-- PARAMETERS                                                              --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--  P_TXN_ID           Transaction ID - REQUIRED: should exist in MMT      --
--  P_ORG_ID           Organization ID - REQUIRED                          --
--  X_ZERO_COST_FLAG   Return 0 if none of the above conditions are met;   --
--		       Otherwise return the value of issue_zero_cost_flag  --
--		       of the work order				   --
--                                                                         --
-- HISTORY:                                                                --
--    07/01/03	Linda Soo	Created					   --
-----------------------------------------------------------------------------
PROCEDURE get_ZeroCostIssue_Flag (
  P_API_VERSION    IN         NUMBER,
  P_INIT_MSG_LIST  IN         VARCHAR2 default FND_API.G_FALSE,
  X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
  X_MSG_COUNT      OUT NOCOPY NUMBER,
  X_MSG_DATA       OUT NOCOPY VARCHAR2,
  P_TXN_ID         IN         NUMBER,
  X_ZERO_COST_FLAG OUT NOCOPY NUMBER
)
IS
  l_api_name		CONSTANT	VARCHAR2(30) := 'get_ZeroCostIssue_Flag';
  l_api_version		CONSTANT	NUMBER := 1.0;

  l_api_message				VARCHAR2(240);
  l_statement				NUMBER := 0;
  l_debug		VARCHAR2(80);

  l_count				NUMBER;
  l_eam_enabled				NUMBER;
  l_txn_act_id				NUMBER;
  l_txn_src_type_id			NUMBER;
  l_item_id				NUMBER;
  l_org_id              NUMBER;
  l_wip_entity_id			NUMBER;
  l_sub_inventory			VARCHAR2(30);
  l_exp_item				NUMBER;
  l_rebuild_item			NUMBER;
  l_exp_sub				NUMBER;
  l_entity_type				NUMBER;
  l_zero_cost_flag			NUMBER := 0;

BEGIN

  -----------------------------------
  -- Standard start of API savepoint
  -----------------------------------
  SAVEPOINT get_ZeroCost_Flag;

  l_debug := FND_PROFILE.VALUE('MRP_DEBUG');

  /*if (l_debug = 'Y') then
    fnd_file.put_line(fnd_file.log,'get_ZeroCostIssue_Flag');
  end if;*/

  ------------------------------------------------
  -- Standard call to check for API compatibility
  ------------------------------------------------
  l_statement := 10;
  IF not fnd_api.compatible_api_call( l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME ) then
    RAISE fnd_api.G_exc_unexpected_error;
  END IF;

  -------------------------------------------------------------
  -- Initialize message list if p_init_msg_list is set to TRUE
  -------------------------------------------------------------
  l_statement := 20;
  IF fnd_api.to_Boolean(p_init_msg_list) then
    fnd_msg_pub.initialize;
  end if;

  -------------------------------------------
  -- Initialize API return status to Success
  -------------------------------------------
  l_statement := 30;
  x_return_status := fnd_api.g_ret_sts_success;

  -----------------------------
  -- Validate input parameters
  -----------------------------
  l_statement := 40;
  if (p_txn_id is null) then
    l_api_message := 'p_txn_id is null';
    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_PUB.add;
    RAISE fnd_api.g_exc_error;
  end if;

  -----------------------------------
  --  Obtain data for transaction ID
  -----------------------------------
  l_statement := 50;
  begin
    select mmt.transaction_action_id,
      mmt.transaction_source_type_id,
      nvl(mmt.transaction_source_id, -1),
      mmt.inventory_item_id,
      mmt.subinventory_code,
      mmt.organization_id
    into l_txn_act_id,
      l_txn_src_type_id,
      l_wip_entity_id,
      l_item_id,
      l_sub_inventory,
      l_org_id
    from mtl_material_transactions mmt
      where mmt.transaction_id = p_txn_id;
  exception
    when no_data_found then
      l_api_message := 'Transaction ID does not exist in MTL_MATERIAL_TRANSACTIONS table. ';
      FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
      FND_MESSAGE.set_token('TEXT', l_api_message);
      FND_MSG_PUB.add;
      RAISE fnd_api.g_exc_error;
  end;

  -------------------------------------
  --  Check transaction source type ID
  -------------------------------------
  l_statement := 60;
  if (l_txn_src_type_id <> 5) then
    x_zero_cost_flag := l_zero_cost_flag;
    return;
  end if;

  ----------------------
  --  Check entity type
  ----------------------
  l_statement := 70;
  select entity_type
  into l_entity_type
  from wip_entities
  where wip_entity_id = l_wip_entity_id;

  if (l_entity_type not in (6,7)) then
    x_zero_cost_flag := l_zero_cost_flag;
    return;
  end if;

  ----------------------------------
  --  Check transaction action type
  ----------------------------------
  l_statement := 80;
  if (l_txn_act_id not in (1, 27, 33, 34)) then
    x_zero_cost_flag := l_zero_cost_flag;
    return;
  end if;

  -----------------------------------------------------
  --  Check if item is asset or expense; or if rebuild
  -----------------------------------------------------
  l_statement := 90;
  select decode(inventory_asset_flag,'Y', 0, 1), nvl(eam_item_type,-1)
  into l_exp_item, l_rebuild_item
  from mtl_system_items_b
  where inventory_item_id = l_item_id
    and organization_id = l_org_id;

  -- Item is rebuildable item or not
  if (l_rebuild_item <> 3) then
    x_zero_cost_flag := l_zero_cost_flag;
    return;
  end if;

  -- Item is Asset or Expense
  if (l_exp_item = 1) then
    x_zero_cost_flag := l_zero_cost_flag;
    return;
  end if;

  -------------------------------------------
  --  Check subinventory is asset or expense
  -------------------------------------------
  l_statement := 100;
  select decode(asset_inventory, 1, 0, 1)
  into l_exp_sub
  from mtl_secondary_inventories
  where secondary_inventory_name = l_sub_inventory
    and organization_id = l_org_id;

  if (l_exp_sub = 0) then
    x_zero_cost_flag := l_zero_cost_flag;
    return;
  end if;

  ---------------------------------------------
  --  Get zero cost flag
  ---------------------------------------------
  l_statement := 110;
  select decode(nvl(issue_zero_cost_flag, 'N'), 'Y', 1, 0)
  into l_zero_cost_flag
  from wip_discrete_jobs
  where wip_entity_id = l_wip_entity_id;

  x_zero_cost_flag := l_zero_cost_flag;

  -- Standard Call to get message count and if count = 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count	=> x_msg_count,
    p_data	=> x_msg_data );

EXCEPTION

  WHEN fnd_api.g_exc_error then
    x_return_status := fnd_api.g_ret_sts_error;
    x_zero_cost_flag:= -1;

    fnd_msg_pub.count_and_get(
      p_count => x_msg_count,
      p_data  => x_msg_data );

  WHEN fnd_api.g_exc_unexpected_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    x_zero_cost_flag:= -1;

    fnd_msg_pub.count_and_get(
      p_count => x_msg_count,
      p_data  => x_msg_data );

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    x_zero_cost_flag:= -1;
    if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
      fnd_msg_pub.add_exc_msg ( 'CST_Utility_PUB',
	' get_ZeroCostIssue_Flag: Statement - ' || to_char(l_statement));
    end if;

    fnd_msg_pub.count_and_get(
      p_count => x_msg_count,
      p_data  => x_msg_data );

END get_ZeroCostIssue_Flag;


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   get_Direct_Item_Charge_Acct                                          --
--                                                                        --
-- DESCRIPTION                                                            --
--  This API is from CST_eamCost_PUB package.  Added this API to this
--  package to minimize the dependencies PO would have on the API.
--  Changes starting from J should be made to this API.
--
--  This API returns the account number given a EAM job
--  (entity type = 6,7) and purchasing category.  If the wip identity
--  doesn't refer to an EAM job type then -1 is returned, -1 is also
--  returned if no account is defined for that particular wip entity.
--
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.6                                        --
--   Costing Support for EAM                                              --
--   Called by the PO account generator
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    08/28/03		Linda Soo		Created
--	Dummy API for pre-req for PO to minimize dependencies
----------------------------------------------------------------------------

PROCEDURE get_Direct_Item_Charge_Acct (
                            p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2
                                                := FND_API.G_FALSE,
                            p_commit             IN   VARCHAR2
                                                := FND_API.G_FALSE,
                            p_validation_level   IN   NUMBER
                                                := FND_API.G_VALID_LEVEL_FULL,
                            p_wip_entity_id      IN   NUMBER := NULL,
			    x_material_acct      OUT NOCOPY  NUMBER,
                            x_return_status      OUT NOCOPY  VARCHAR2,
                            x_msg_count          OUT NOCOPY  NUMBER,
                            x_msg_data           OUT NOCOPY  VARCHAR2,
			    p_category_id	 IN   NUMBER := -1
) IS

          l_api_name 	CONSTANT	VARCHAR2(30) := 'get_Direct_Item_Charge_Acct';
          l_api_version CONSTANT	NUMBER       := 1.0;

          l_api_message			VARCHAR2(240);
	  l_statement   		NUMBER := 0;
          l_account	   		NUMBER := -1;
          l_entity_type			NUMBER;
	  l_cst_element_id		NUMBER := 1;

BEGIN
      ---------------------------------------------
      --  Standard start of API savepoint
      ---------------------------------------------
      SAVEPOINT  get_Direct_Item_Charge_Acct;

      ------------------------------------------------
      --  Standard call to check for API compatibility
      ------------------------------------------------
      l_statement := 10;
      IF not fnd_api.compatible_api_call (
                                  l_api_version,
                                  p_api_version,
                                  l_api_name,
                                  G_PKG_NAME ) then
            RAISE fnd_api.G_exc_unexpected_error;
      END IF;

      ------------------------------------------------------------
      -- Initialize message list if p_init_msg_list is set to TRUE
      -------------------------------------------------------------
      l_statement := 20;
      IF fnd_api.to_Boolean(p_init_msg_list) then
          fnd_msg_pub.initialize;
      end if;

      -------------------------------------------------------------
      --  Initialize API return status to Success
      -------------------------------------------------------------
      l_statement := 30;
      x_return_status := fnd_api.g_ret_sts_success;

      -------------------------------------------------
      --  Validate input parameters
      -------------------------------------------------
      l_statement := 40;
      if (p_wip_entity_id is null) then
            l_api_message := 'Please specify a wip entity id';
            FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
            FND_MESSAGE.set_token('TEXT', l_api_message);
            FND_MSG_PUB.add;

            RAISE fnd_api.g_exc_error;
      end if;

      ---------------------------------------------
      --  Verify if EAM job
      ---------------------------------------------
      l_statement := 50;
      select entity_type
      into l_entity_type
      from wip_entities
      where wip_entity_id = p_wip_entity_id;

      if (l_entity_type in (6,7)) then
      ---------------------------------------------
      --  Obtain cost element based on category_id
      ---------------------------------------------
	l_statement := 60;
	begin
	  select cceea.mfg_cost_element_id
	  into l_cst_element_id
	  from cst_cat_ele_exp_assocs cceea
	  where cceea.category_id = p_category_id
	    and sysdate >= cceea.start_date
	    and sysdate <= (nvl(cceea.end_date, sysdate) + 1);
	exception
	  when no_data_found then
	    l_cst_element_id := 1;
	end;

	l_statement := 70;
	select decode(l_cst_element_id, 1, nvl(material_account,-1),
					3, nvl(resource_account, -1),
					4, nvl(outside_processing_account, -1))
	into l_account
	from wip_discrete_jobs
	where wip_entity_id = p_wip_entity_id;
      end if;

      x_material_acct := l_account;

EXCEPTION
    WHEN fnd_api.g_exc_error then
       x_return_status := fnd_api.g_ret_sts_error;
       x_material_acct := -1;

       fnd_msg_pub.count_and_get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN fnd_api.g_exc_unexpected_error then
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       x_material_acct := -1;

       fnd_msg_pub.count_and_get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      x_material_acct := -1;
      If fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
           fnd_msg_pub.add_exc_msg
              ( 'CST_Utility_PUB',' get_Direct_Item_Charge_Acct : Statement - ' || to_char(l_statement));
      end if;

      fnd_msg_pub.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data );
  END  get_Direct_Item_Charge_Acct;

FUNCTION check_Db_Version
(
  p_api_version      IN	        NUMBER,
  p_init_msg_list    IN	        VARCHAR2,
  x_return_status    OUT NOCOPY	VARCHAR2,
  x_msg_count	     OUT NOCOPY NUMBER,
  x_msg_data	     OUT NOCOPY VARCHAR2
) return NUMBER
IS
  l_db_version                  NUMBER;
  l_api_name    CONSTANT        VARCHAR2(30) := 'check_Db_Version';
  l_api_version CONSTANT        NUMBER       := 1.0;
  l_statement                   NUMBER := 0;
BEGIN
  ------------------------------------------------
  --  Standard call to check for API compatibility
  ------------------------------------------------
  l_statement := 10;
  IF NOT fnd_api.compatible_api_call (
           l_api_version,
           p_api_version,
           l_api_name,
           G_PKG_NAME )
  THEN RAISE fnd_api.G_exc_unexpected_error;
  END IF;

  ------------------------------------------------------------
  -- Initialize message list if p_init_msg_list is set to TRUE
  -------------------------------------------------------------
  l_statement := 20;
  IF fnd_api.to_Boolean(p_init_msg_list)
  THEN fnd_msg_pub.initialize;
  END IF;

  -------------------------------------------------------------
  --  Initialize API return status to Success
  -------------------------------------------------------------
  l_statement := 30;
  x_return_status := fnd_api.g_ret_sts_success;

  SELECT replace(substr(version,1,instr(version,'.',1,2)-1),'.')
  INTO   l_db_version
  FROM   v$instance;

  IF (l_db_version < 90)
  THEN return 0;
  ELSE return 1;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
    THEN fnd_msg_pub.add_exc_msg
           ( 'CST_Utility_PUB',' check_Db_Version : Statement - ' || to_char(l_statement));
    END IF;
    fnd_msg_pub.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data );
END check_Db_Version;

Procedure Get_Context_Value (
 p_api_version       IN         NUMBER,
 p_init_msg_list     IN         VARCHAR2 ,
 p_commit            IN         VARCHAR2 ,
 p_validation_level  IN         NUMBER ,
 x_return_status     OUT NOCOPY VARCHAR2,
 x_msg_count         OUT NOCOPY NUMBER,
 x_msg_data          OUT NOCOPY VARCHAR2,
 p_org_id            IN         NUMBER,
 p_ledger_id         OUT NOCOPY NUMBER,
 p_le_id             OUT NOCOPY NUMBER,
 p_ou_id             OUT NOCOPY NUMBER)
IS
l_api_version  CONSTANT NUMBER            :=1.0;
l_api_name     CONSTANT VARCHAR2(30)      :='Get Context Value';

BEGIN

----------------------------------------------------------
-- Standard Begin of API Savepoint
----------------------------------------------------------
SAVEPOINT GET_CONTEXT_PUB;

----------------------------------------------------------
-- Standard call to check for call compatibility
----------------------------------------------------------
IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                   p_api_version,
                                   l_api_name,
                                   G_PKG_NAME)
THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

----------------------------------------------------------
--Check p_init_msg_list
----------------------------------------------------------
IF FND_API.to_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.initialize;
END IF;

---------------------------------------------------------
--Initialize API return Status to Success
--------------------------------------------------------
 x_return_status := FND_API.G_RET_STS_SUCCESS;

SELECT
     ledger_id,
     legal_entity,
     operating_unit
INTO
     p_ledger_id,
     p_le_id,
     p_ou_id
FROM
     cst_acct_info_v
WHERE
   organization_id = p_org_id;

IF FND_API.To_Boolean(p_commit) THEN
 COMMIT;
END IF;

FND_MSG_PUB.Count_And_Get
 ( p_count     =>      x_msg_count,
   p_data      =>      x_msg_data
 );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
 ROLLBACK TO GET_CONTEXT_PUB;
 x_return_status := FND_API.G_RET_STS_ERROR;
 FND_MSG_PUB.Count_And_Get
 ( p_count =>  x_msg_count,
   p_data  =>  x_msg_data
 );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 ROLLBACK TO GET_CONTEXT_PUB;
 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.Count_And_Get
 ( p_count =>  x_msg_count,
   p_data  =>  x_msg_data
 );

WHEN OTHERS THEN
 ROLLBACK TO GET_CONTEXT_PUB;
 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
  FND_MSG_PUB.Add_Exc_Msg
  ( G_PKG_NAME,
    l_api_name
  );
 END IF;
 FND_MSG_PUB.Count_And_Get
 ( p_count =>  x_msg_count,
   p_data  =>  x_msg_data
 );

end Get_Context_Value;

----------------------------------------------------------------------------
--
-- PROCEDURE
-- Get_Receipt_Event_Info:
-- API provides the name of the event class and entity code for a
-- receiving transaction type
-- PARAMETERS
-- p_api_version       API version Required
-- p_transaction_type  Receiving Transaction Type (from RCV_TRANSACTIONS)
-- p_entity_code       XLA Entity Code (RCV_ACCOUNTING_EVENTS)
-- p_application_id    Application Identifier for Cost Management
-- p_event_class_code  XLA Event Class Code
--------------------------------------------------------------------------

Procedure Get_Receipt_Event_Info (
  p_api_version      IN NUMBER,
  p_transaction_type IN VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  p_entity_code      OUT NOCOPY VARCHAR2,
  p_application_id   OUT NOCOPY NUMBER,
  p_event_class_code OUT NOCOPY VARCHAR2
) IS

  l_api_name            CONSTANT VARCHAR2(30)  := 'Get_Receipt_Event_Info';
  l_api_version         CONSTANT NUMBER        := 1.0;
  l_stmt_num            NUMBER      := 0;

BEGIN
  SAVEPOINT Get_Receipt_Event_Info;
  IF NOT FND_API.COMPATIBLE_API_CALL ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status   := FND_API.G_RET_STS_SUCCESS;
  p_entity_code     := 'RCV_ACCOUNTING_EVENTS';
  p_application_id  := 707; /* Application ID for Cost Management */

  IF p_transaction_type IN ( 'RECEIVE', 'MATCH', 'RETURN TO VENDOR' ) THEN
    l_stmt_num := 10;
    SELECT EVENT_CLASS_CODE
    INTO   p_event_class_code
    FROM   CST_XLA_RCV_EVENT_MAP
    WHERE  TRANSACTION_TYPE_ID = 1;
  ELSE
    p_event_class_code := NULL;
    x_return_status := fnd_api.g_ret_sts_error;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    p_event_class_code := NULL;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    p_event_class_code := NULL;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Get_Receipt_Event_Info;

END CST_Utility_PUB;

/
