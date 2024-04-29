--------------------------------------------------------
--  DDL for Package Body CSD_COST_ANALYSIS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_COST_ANALYSIS_PVT" AS
/* $Header: csdvanab.pls 120.1 2005/06/06 16:14:40 appldev  $ */

  G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_COST_ANALYSIS_PVT';
  G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvanab.pls';


  -- Global variable for storing the debug level

  G_debug_level          number       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  /*----------------------------------------------------------------*/

  /* procedure name: Get_TotalEstCosts                              */

  /* description   : procedure used to get total estimated costs    */

  /*                                                                */

  /* p_api_version                Standard IN param                 */

  /* p_commit                     Standard IN param                 */

  /* p_init_msg_list              Standard IN param                 */

  /* p_validation_level           Standard IN param                 */

  /* p_repair_estimate_id         Required Estimate ID to get	  */
  /*                                est costs                       */

  /* p_organization_id            Required Organization Id          */

  /* p_ro_currency_code           Required Repair Order Currency Code*/

  /* x_costs                      Total MLE costs for repair line   */

  /* x_return_status              Standard OUT param                */

  /* x_msg_count                  Standard OUT param                */

  /* x_msg_data                   Standard OUT param                */

  /*                                                                */

  /*----------------------------------------------------------------*/

  PROCEDURE Get_TotalEstCosts(p_api_version IN NUMBER, p_commit IN VARCHAR2,
                              p_init_msg_list IN VARCHAR2,
                              p_validation_level IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2,
                              p_repair_estimate_id IN NUMBER,
                              p_organization_id IN NUMBER,
                              p_ro_currency_code IN VARCHAR2,
                              x_costs OUT NOCOPY CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE)

  IS

    --Cursor to get total cost for an estimate line, group by MLE.

    CURSOR cur_getTotalCost(p_repair_estimate_id NUMBER)
    IS
        SELECT btc.billing_category,
               sum(rel.item_Cost * ed.quantity_required) TotalCost  -- sangita
          FROM CSD_REPAIR_ESTIMATE_LINES rel, CS_ESTIMATE_DETAILS ed,
               CS_BILLING_TYPE_CATEGORIES btc, CS_TXN_BILLING_TYPES btt
         WHERE rel.repair_estimate_id = p_repair_estimate_id
           AND rel.estimate_detail_id = ed.estimate_detail_id
           AND ed.txn_billing_type_id = btt.txn_billing_type_id
           AND btc.billing_type = btt.billing_type
      GROUP BY btc.billing_category;

    --Cursor to get the number of rows with null item cost for an estimate line.

    CURSOR cur_getNullCostRows(p_repair_estimate_id NUMBER)
    IS
      SELECT count(rel.estimate_detail_id)
        FROM CSD_REPAIR_ESTIMATE_LINES rel
       WHERE rel.repair_estimate_id = p_repair_estimate_id
         AND rel.item_cost IS NULL
	 AND rownum = 1;

    --Cursor to determine the count of estimate lines for an estimate header.

    CURSOR cur_getEstLineCount(p_repair_Estimate_id NUMBER)
    IS
       SELECT count(repair_estimate_line_id)
       FROM CSD_REPAIR_ESTIMATE_LINES
       WHERE repair_estimate_id = p_repair_estimate_id
       ANd rownum=1;
    l_api_name     CONSTANT VARCHAR2(30)   := 'Get_TotalEstCosts';
    l_api_version  CONSTANT NUMBER         := 1.0;
    l_nullCostRows         NUMBER;
    l_count                 NUMBER;

    -- Variable used in FND log

    l_stat_level            number         := FND_LOG.LEVEL_STATEMENT;
    l_proc_level            number         := FND_LOG.LEVEL_PROCEDURE;
    l_event_level           number         := FND_LOG.LEVEL_EVENT;
    l_excep_level           number         := FND_LOG.LEVEL_EXCEPTION;
    l_error_level           number         := FND_LOG.LEVEL_ERROR;
    l_unexp_level           number         := FND_LOG.LEVEL_UNEXPECTED;
    l_mod_name              varchar2(2000) := 'csd.plsql.csd_cost_analysis_pvt.get_totalestcosts';

  BEGIN

    -- Standard Start of API savepoint
    -- No need to create savepoints because no updates/inserts are being done.
    --  SAVEPOINT Get_TotalEstCosts_Pvt;

    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.

    IF FND_API.to_Boolean(p_init_msg_list)
      THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    -- Debug messages

    IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
      THEN
        FND_LOG.STRING(Fnd_Log.Level_Procedure,
                       'csd.plsql.csd_cost_analysis_pvt.get_totalestcosts.BEGIN',
                       'Entered Get_TotalEstCosts');
    END IF;

    -- IF not costing enabled then throw exception

    IF NOT (CSD_COST_ANALYSIS_UTIL.Validate_CostingEnabled(p_organization_id))
      THEN

        -- Throw error

        FND_MESSAGE.SET_NAME('CSD', 'CSD_CST_COSTING_NOT_ENABLED');
        IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.MESSAGE(Fnd_Log.Level_Error, l_mod_name, FALSE);
		  END IF;
       -- ELSE
          FND_MSG_PUB.ADD;
        --END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Raise warning if no estimate lines are found.

    OPEN cur_getEstLineCount(p_repair_estimate_id);
    FETCH cur_getEstLineCount INTO l_count;
    IF (l_count = 0)
      THEN
        CLOSE cur_getEstLineCount;

        -- Throw error

        FND_MESSAGE.SET_NAME('CSD', 'CSD_CST_NO_CHG_ROWS_SELECTED');
        IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.MESSAGE(Fnd_Log.Level_Error, l_mod_name, FALSE);
		  END IF;
       -- ELSE
          FND_MSG_PUB.ADD;
        --END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE cur_getEstLineCount;

    -- Raise warning if any item cost is null

    OPEN cur_getNullCostRows(p_repair_estimate_id);
    FETCH cur_getNullCostRows INTO l_nullCostRows;
    IF l_nullCostRows > 0
      THEN
        CLOSE cur_getNullCostRows;
        FND_MESSAGE.SET_NAME('CSD', 'CSD_CST_NULL_ITEM_COST');
        IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.MESSAGE(Fnd_Log.Level_Error, l_mod_name, FALSE);
		  END IF;
       -- ELSE
          FND_MSG_PUB.ADD;
        --END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE cur_getNullCostRows;

    -- Loop through the cursor and get the MLE lines cost.

    FOR data IN cur_getTotalCost(p_repair_Estimate_id) LOOP
      IF data.billing_Category = 'M'
        THEN
          x_costs.materials := data.TotalCost;
      ELSIF data.billing_category = 'L'
        THEN
          x_costs.labor := data.TotalCost;
      ELSIF data.billing_category = 'E'
        THEN
          x_costs.expenses := data.TotalCost;
      END IF;
      x_costs.currency_code := p_ro_currency_code;
    END LOOP;

    --close the cursor if open.

    IF cur_getTotalCost%ISOPEN
      THEN
        CLOSE cur_getTotalCost;
    END IF;

    --Caluculate MLE_TOTAL

    x_costs.MLE_TOTAL := nvl(x_costs.materials, 0) + nvl(x_costs.labor,
                                                         0) + nvl(x_costs.expenses,
                                                                  0);

    -- Debug messages

    IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
      THEN
        FND_LOG.STRING(Fnd_Log.Level_Procedure,
                       'csd.plsql.csd_cost_analysis_pvt.get_totalestcosts.END',
                       'Leaving Get_TotalEstCosts');
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.

    IF FND_API.To_Boolean(p_commit)
      THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN

        --ROLLBACK TO Get_TotalEstCosts_Pvt;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Get_TotalEstCosts',
                           'EXC_ERROR['
                           || x_msg_data
                           || ']');
        END IF;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        --ROLLBACK TO Get_TotalEstCosts_Pvt;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Get_TotalEstCosts',
                           'EXC_ERROR['
                           || x_msg_data
                           || ']');
        END IF;
      WHEN OTHERS THEN

        --ROLLBACK TO Get_TotalEstCosts_Pvt;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Get_TotalEstCosts',
                           'SQL Message['
                           || sqlerrm
                           || ']');
        END IF;
  END Get_TotalEstCosts;
  /*----------------------------------------------------------------*/

  /* procedure name: Get_TotalEstCharges                            */

  /* description   : procedure used to get total estimated charges  */

  /*                                                                */

  /* p_api_version                Standard IN param                 */

  /* p_commit                     Standard IN param                 */

  /* p_init_msg_list              Standard IN param                 */

  /* p_validation_level           Standard IN param                 */

  /* p_repair_estimate_id         Required Estimate ID to get est charges */

  /* p_ro_currency_code           Required Repair Order Currency Code*/

  /* x_charges                    Total MLE charges for repair line */

  /* x_return_status              Standard OUT param                */

  /* x_msg_count                  Standard OUT param                */

  /* x_msg_data                   Standard OUT param                */

  /*                                                                */

  /*----------------------------------------------------------------*/

  PROCEDURE Get_TotalEstCharges(p_api_version IN NUMBER,
                                p_commit IN VARCHAR2,
                                p_init_msg_list IN VARCHAR2,
                                p_validation_level IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2,
                                p_repair_estimate_id IN NUMBER,
                                p_ro_currency_code IN VARCHAR2,
                                x_charges OUT NOCOPY CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE)
  IS
    --Cursor to get teh line count for an estimate header.
    CURSOR cur_getEstLineCount(p_repair_Estimate_id NUMBER)
    IS
      SELECT count(repair_estimate_line_id)
        FROM CSD_REPAIR_ESTIMATE_LINES
       WHERE repair_estimate_id = p_repair_estimate_id;

    --Cursor to get the charges, group by MLE.
    CURSOR cur_getTotalCharges(p_repair_estimate_id NUMBER)
    IS
        SELECT btc.billing_category,
               sum(nvl(ed.after_warranty_cost, 0)) TotalCharges
          FROM CSD_REPAIR_ESTIMATE_LINES rel, CS_ESTIMATE_DETAILS ed,
               CS_BILLING_TYPE_CATEGORIES btc, CS_TXN_BILLING_TYPES btt
         WHERE rel.repair_estimate_id = p_repair_estimate_id
           AND rel.estimate_detail_id = ed.estimate_detail_id
           AND ed.txn_billing_type_id = btt.txn_billing_type_id
           AND btc.billing_type = btt.billing_type
      GROUP BY btc.billing_category;

    l_api_name     CONSTANT VARCHAR2(30)   := 'Get_TotalEstCharges';
    l_api_version  CONSTANT NUMBER         := 1.0;
    l_nullCostRows          NUMBER;
    l_count                 NUMBER;

    -- Variable used in FND log

    l_stat_level            number         := FND_LOG.LEVEL_STATEMENT;
    l_proc_level            number         := FND_LOG.LEVEL_PROCEDURE;
    l_event_level           number         := FND_LOG.LEVEL_EVENT;
    l_excep_level           number         := FND_LOG.LEVEL_EXCEPTION;
    l_error_level           number         := FND_LOG.LEVEL_ERROR;
    l_unexp_level           number         := FND_LOG.LEVEL_UNEXPECTED;
    l_mod_name              varchar2(2000) := 'csd.plsql.csd_cost_analysis_pvt.get_totalestcharges';

  BEGIN

    -- Standard Start of API savepoint
    --SAVEPOINT Get_TotalEstCharges_Pvt;

    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.

    IF FND_API.to_Boolean(p_init_msg_list)
      THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    -- Debug messages

    IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
      THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                       'csd.plsql.csd_cost_analysis_pvt.get_totalestcosts.BEGIN',
                       'Entered Get_TotalEstCharges');
    END IF;

    -- No need to check if costing enabled because these are charges.

    OPEN cur_getEstLineCount(p_repair_estimate_id);
    FETCH cur_getEstLineCount INTO l_count;
    IF (l_count = 0)
      THEN
        CLOSE cur_getEstLineCount;

        -- Throw error

        FND_MESSAGE.SET_NAME('CSD', 'CSD_CST_NO_CHG_ROWS_SELECTED');
        IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.MESSAGE(Fnd_Log.Level_Error, l_mod_name, FALSE);
		  END IF;
        --ELSE
          FND_MSG_PUB.ADD;
       -- END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE cur_getEstLineCount;

    --Get MLE charge amount

    FOR x IN cur_getTotalCharges(p_repair_Estimate_id) LOOP
      IF x.billing_Category = 'M'
        THEN
          x_charges.materials := x.TotalCharges;
      ELSIF x.billing_category = 'L'
        THEN
          x_charges.labor := x.TotalCharges;
      ELSIF x.billing_category = 'E'
        THEN
          x_charges.expenses := x.TotalCharges;
      END IF;
      x_charges.currency_code := p_ro_currency_code;
    END LOOP;
    IF cur_getTotalCharges%ISOPEN
      THEN
        CLOSE cur_getTotalCharges;
    END IF;

    --CLOSE cur_getTotalCharges;

    x_charges.MLE_TOTAL := nvl(x_charges.materials, 0) + nvl(x_charges.labor,
                                                             0) + nvl(x_charges.expenses,
                                                                      0);

    -- Debug messages

    IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
      THEN
        FND_LOG.STRING(Fnd_Log.Level_Procedure,
                       'csd.plsql.csd_cost_analysis_pvt.get_totalestcharges.END',
                       ' Exiting Get_TotalEstCharges');
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.

    IF FND_API.To_Boolean(p_commit)
      THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN

        --  ROLLBACK TO Get_TotalEstCharges_Pvt;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Get_TotalEstCharges',
                           'EXC_ERROR['
                           || x_msg_data
                           || ']');
        END IF;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        --ROLLBACK TO Get_TotalEstCharges_Pvt;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Get_TotalEstCharges',
                           'EXC_ERROR['
                           || x_msg_data
                           || ']');
        END IF;
      WHEN OTHERS THEN

        --ROLLBACK TO Get_TotalEstCharges_Pvt;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Get_TotalEstCharges',
                           'SQL Message['
                           || sqlerrm
                           || ']');
        END IF;
  END Get_TotalEstCharges;
  /*----------------------------------------------------------------*/

  /* procedure name: Compare_EstChargesAndCosts                     */

  /* description   : procedure used to compare estimated charges to */

  /*                 estimated costs                                */

  /*                                                                */

  /* p_api_version                Standard IN param                 */

  /* p_commit                     Standard IN param                 */

  /* p_init_msg_list              Standard IN param                 */

  /* p_validation_level           Standard IN param                 */

  /* p_repair_estimate_id         Required Estimate ID to get est charges */

  /* p_organization_id           Required Organization Id           */

  /* p_ro_currency_code           Required Repair Order Currency Code */

  /* x_charges                    Total MLE charges for estimate    */

  /* x_costs                      MLE Costs for estimate            */

  /* x_profit                     MLE Profit                        */

  /* x_profit_margin              MLE Profit Margin (%)             */

  /* x_return_status              Standard OUT param                */

  /* x_msg_count                  Standard OUT param                */

  /* x_msg_data                   Standard OUT param                */

  /*                                                                */

  /*----------------------------------------------------------------*/

  PROCEDURE Compare_EstChargesAndCosts(p_api_version IN NUMBER,
                                       p_commit IN VARCHAR2,
                                       p_init_msg_list IN VARCHAR2,
                                       p_validation_level IN NUMBER,
                                       x_return_status OUT NOCOPY VARCHAR2,
                                       x_msg_count OUT NOCOPY NUMBER,
                                       x_msg_data OUT NOCOPY VARCHAR2,
                                       p_repair_estimate_id IN NUMBER,
                                       p_organization_id IN NUMBER,
                                       p_ro_currency_code IN VARCHAR2,
                                       x_charges OUT NOCOPY CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
                                       x_costs OUT NOCOPY CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
                                       x_profit OUT NOCOPY CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
                                       x_profit_margin OUT NOCOPY CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE)
  IS
    l_api_name    CONSTANT VARCHAR2(30)   := 'Compare_EstChargesAndCosts';
    l_api_version CONSTANT NUMBER         := 1.0;

    -- Variable used in FND log

    l_stat_level           number         := FND_LOG.LEVEL_STATEMENT;
    l_proc_level           number         := FND_LOG.LEVEL_PROCEDURE;
    l_event_level          number         := FND_LOG.LEVEL_EVENT;
    l_excep_level          number         := FND_LOG.LEVEL_EXCEPTION;
    l_error_level          number         := FND_LOG.LEVEL_ERROR;
    l_unexp_level          number         := FND_LOG.LEVEL_UNEXPECTED;
    l_mod_name             varchar2(2000) := 'csd.plsql.csd_cost_analysis_pvt.Compare_EstChargesAndCosts';

  BEGIN

    -- Standard Start of API savepoint to the database
    --- No need to have savepoint because no update

    -- SAVEPOINT Compare_EstChargesAndCosts_Pvt;

    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.

    IF FND_API.to_Boolean(p_init_msg_list)
      THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    -- Debug messages

    IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
      THEN
        FND_LOG.STRING(Fnd_Log.Level_Procedure,
                       l_mod_name
                       || 'BEGIN',
                       'Entered Compare_EstChargesAndCosts');
    END IF;

    -- Get charges for the estimate lines

    Get_TotalEstCharges(p_api_version        => p_api_version,
                        p_commit             => p_commit,
                        p_init_msg_list      => p_init_msg_list,
                        p_validation_level   => p_validation_level,
                        p_repair_estimate_id => p_repair_estimate_id,
                        p_ro_currency_code   => p_ro_currency_code,
                        x_charges            => x_charges,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data);

    -- Throw exception if API fails.

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Get Costs for the estimate line

    Get_TotalEstCosts(p_api_version        => p_api_version,
                      p_commit             => p_commit,
                      p_init_msg_list      => p_init_msg_list,
                      p_validation_level   => p_validation_level,
                      p_repair_estimate_id => p_repair_estimate_id,
                      p_organization_id    => p_organization_id,
                      p_ro_currency_code   => p_ro_currency_code,
                      x_costs              => x_costs,
                      x_return_status      => x_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data);

    -- Throw exception if API fails.

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Throw exception if charge and cost currency codes are different.

    IF x_charges.currency_code <> x_costs.currency_code
      THEN
        FND_MESSAGE.SET_NAME('CSD', 'CSD_CST_CURR_CODE_DIFF');
        IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.MESSAGE(Fnd_Log.Level_Error, l_mod_name, FALSE);
		 END IF;
        --ELSE
          FND_MSG_PUB.ADD;
       -- END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Compare charges and costs amount and return the profit and percent profit.

    CSD_COST_ANALYSIS_UTIL.Compare_MLETotals(p_api_version        => p_api_version,
                                             p_commit             => p_commit,
                                             p_init_msg_list      => p_init_msg_list,
                                             p_validation_level   => p_validation_level,
                                             p_mle_totals_basis   => x_costs,
                                             p_mle_totals_compare => x_charges,
                                             x_diff               => x_profit,
                                             x_pct_diff           => x_profit_margin,
                                             x_return_status      => x_return_status,
                                             x_msg_count          => x_msg_count,
                                             x_msg_data           => x_msg_data);

    --Throw exception if API fails.

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= Fnd_Log.G_Current_Runtime_Level)
      THEN
        FND_LOG.STRING(Fnd_Log.Level_Procedure,
                       'csd.plsql.csd_cost_analysis_pvt.Compare_EstChargesAndCosts.END',
                       'Exiting Compare_EstChargesAndCosts');
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.

    IF FND_API.To_Boolean(p_commit)
      THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN

        --ROLLBACK TO Compare_EstChargesAndCosts_Pvt;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Compare_EstChargesAndCosts',
                           'EXC_ERROR['
                           || x_msg_data
                           || ']');
        END IF;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        -- ROLLBACK TO Compare_EstChargesAndCosts_Pvt;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Compare_EstChargesAndCosts',
                           'EXC_ERROR['
                           || x_msg_data
                           || ']');
        END IF;
      WHEN OTHERS THEN

        --ROLLBACK TO Compare_EstChargesAndCosts_Pvt;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt. Compare_EstChargesAndCosts',
                           'SQL Message['
                           || sqlerrm
                           || ']');
        END IF;
  END Compare_EstChargesAndCosts;
  /*----------------------------------------------------------------*/

  /* procedure name: Get_InvItemCost                                */

  /* description   : procedure used get item cost for an            */

  /*                 inventory item in the charges curency. CSD_REPAIR_ESTIMATE_LINES */
  /*                 table will be populated with the converted item_cost.  */

  /*                                                                */

  /*                                                                */

  /* p_api_version                Standard IN param                 */

  /* p_commit                     Standard IN param                 */

  /* p_init_msg_list              Standard IN param                 */

  /* p_validation_level           Standard IN param                 */

  /* p_inventory_item_id          Inventory Item ID                 */

  /* p_quantity                   Quantity of Inventory Items       */

  /* p_organization_id            Inventory Organization ID         */

  /* p_charge_amt                 Total Charge Amt to compare to    */

  /* p_currency_code              Currency of Charge Amt            */

  /* x_item_cost                  Item cost of Inv Item             */

  /* x_return_status              Standard OUT param                */

  /* x_msg_count                  Standard OUT param                */

  /* x_msg_data                   Standard OUT param                */

  /*                                                                */

  /*----------------------------------------------------------------*/

  PROCEDURE Get_InvItemCost(p_api_version IN NUMBER, p_commit IN VARCHAR2,
                            p_init_msg_list IN VARCHAR2,
                            p_validation_level IN NUMBER,
		            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_inventory_item_id IN NUMBER,
                            p_organization_id IN NUMBER,
                            p_charge_date IN DATE,
                            p_currency_code IN VARCHAR2,
			    p_chg_line_uom_code IN VARCHAR2, --
                            x_item_cost OUT NOCOPY NUMBER
                           )
  IS
    --Curcor to get item cost for an item. We only cosider standard/frozen costing type.
    CURSOR cur_getItemCost(p_inventory_item_id NUMBER,
                           p_organization_id NUMBER)
    IS
      SELECT CIC.item_cost
        FROM CST_ITEM_COSTS CIC
       WHERE CIC.inventory_item_id = p_inventory_item_id
         AND CIC.organization_id = p_organization_id
         AND CIC.cost_type_id = 1; -- standard/frozen cost

	 --Cursor to get primary_uom_code (item cost uom) for a given item
	 CURSOR cur_getPrimaryUomCode(p_inventory_item_id NUMBER,
	                              p_organization_id NUMBER)
         IS
	   SELECT primary_uom_code
	   FROM mtl_system_items MSI
	   WHERE MSI.inventory_item_id = p_inventory_item_id
           AND MSI.organization_id = p_organization_id;


    l_api_name           CONSTANT VARCHAR2(30)   := 'Get_InvItemCost';
    l_api_version        CONSTANT NUMBER         := 1.0;
    l_cost_currency_code          VARCHAR2(30);
    l_item_cost                   NUMBER;
    l_primary_uom_code 		  VARCHAR2(30);


    -- Variable used in FND log

    l_stat_level                  number         := FND_LOG.LEVEL_STATEMENT;
    l_proc_level                  number         := FND_LOG.LEVEL_PROCEDURE;
    l_event_level                 number         := FND_LOG.LEVEL_EVENT;
    l_excep_level                 number         := FND_LOG.LEVEL_EXCEPTION;
    l_error_level                 number         := FND_LOG.LEVEL_ERROR;
    l_unexp_level                 number         := FND_LOG.LEVEL_UNEXPECTED;
    l_mod_name                    varchar2(2000) := 'csd.plsql.csd_cost_analysis_pvt.Get_InvItemCost';

  BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT Get_InvItemCostAnalysis_Pvt;

    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.

    IF FND_API.to_Boolean(p_init_msg_list)
      THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
      THEN
        FND_LOG.STRING(Fnd_Log.Level_Procedure,
                       'csd.plsql.csd_cost_analysis_pvt.Get_InvItemCost.BEGIN',
                       'Entering Get_InvItemCost');
    END IF;

    --Check if costing enabled

    IF (CSD_COST_ANALYSIS_UTIL.Validate_CostingEnabled(p_organization_id))
      THEN

        -- Get item cost

        OPEN cur_getItemCost(p_inventory_item_id, p_organization_id);
        FETCH cur_getItemCost INTO l_item_cost;
        IF cur_getItemCost%NOTFOUND
          THEN
            CLOSE cur_getItemCost;
            FND_MESSAGE.SET_NAME('CSD', 'CSD_CST_NO_ITEM_COST_AVAIL');
            IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level)
              THEN
                FND_LOG.MESSAGE(Fnd_Log.Level_Error, l_mod_name, FALSE);
			END IF;
           -- ELSE
              FND_MSG_PUB.ADD;
            --END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE cur_getItemCost;

	-- Get primary uom code from inventory for the item.

        OPEN cur_getPrimaryUomCode(p_inventory_item_id, p_organization_id);
        FETCH cur_getPrimaryUomCode INTO l_primary_uom_code;
        IF cur_getPrimaryUomCode%NOTFOUND
          THEN
            CLOSE cur_getPrimaryUomCode;
            FND_MESSAGE.SET_NAME('CSD', 'CSD_CST_NO_PRIMARY_UOM_CODE'); --new message
            IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level)
              THEN
                FND_LOG.MESSAGE(Fnd_Log.Level_Error, l_mod_name, FALSE);
			END IF;
           -- ELSE
              FND_MSG_PUB.ADD;
            --END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE cur_getPrimaryUomCode;

	--Raise exception if the charge line UOM is different from item primary uom
	--Cannot do cost analysis if the UUOMs are different
        IF ( l_primary_uom_code <> p_chg_line_uom_code) THEN
        FND_MESSAGE.SET_NAME('CSD', 'CSD_CST_DIFF_UOM_CODE'); --new message
            IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level)
              THEN
                FND_LOG.MESSAGE(Fnd_Log.Level_Error, l_mod_name, FALSE);
			END IF;
           -- ELSE
              FND_MSG_PUB.ADD;
            --END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        l_cost_currency_code := CSD_COST_ANALYSIS_UTIL.get_GLCurrencyCode(p_organization_id);

        --do the conversion if currency codes differ.

        IF (p_currency_code <> l_cost_currency_code)
          THEN
            CSD_COST_ANALYSIS_UTIL.Convert_CurrencyAmount(p_api_version      => p_api_version,
                                                          p_commit           => p_commit,
                                                          p_init_msg_list    => p_init_msg_list,
                                                          p_validation_level => p_validation_level,
                                                          p_from_currency    => l_cost_currency_code,
                                                          p_to_currency      => p_currency_code,
                                                          p_eff_date         => p_charge_date,
                                                          p_amount           => l_item_cost,
                                                          x_conv_amount      => x_item_cost,
                                                          x_return_status    => x_return_status,
                                                          x_msg_count        => x_msg_count,
                                                          x_msg_data         => x_msg_data);
        ELSE

          -- no need to convert becuase currency is same. Just set the variable.

          x_item_cost := l_item_cost;
        END IF;

        -- Throw exception if API fails.

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
          THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
    IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
      THEN
        FND_LOG.STRING(Fnd_Log.Level_Procedure,
                       'csd.plsql.csd_cost_analysis_pvt.Get_InvItemCost.END',
                       'Exiting Get_InvItemCost');
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.

    IF FND_API.To_Boolean(p_commit)
      THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Get_InvItemCostAnalysis_Pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_item_cost := NULL;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Get_InvItemCost',
                           'EXC_ERROR['
                           || x_msg_data
                           || ']');
        END IF;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Get_InvItemCostAnalysis_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_item_cost := NULL;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Get_InvItemCost',
                           'EXC_ERROR['
                           || x_msg_data
                           || ']');
        END IF;
      WHEN OTHERS THEN
        ROLLBACK TO Get_InvItemCostAnalysis_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_item_cost := NULL;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Get_InvItemCost',
                           'SQL Message['
                           || sqlerrm
                           || ']');
        END IF;
  END Get_InvItemCost;
  /*----------------------------------------------------------------*/

/* procedure name: Get_ResItemCost                                */

/* description   : procedure used get resource item cost          */

/*                 for a bom resource                             */
/* This will be called to obtain labor item cost. If a resource id is */
/* passed, then resource cost will be returned in x_item_Cost     */
/* If resource_id is not passed then cost is obtained from the labor */
/* inventory item. */

/* This is a new API. During code review it was suggested that    */

/* since it will never be called independently, there is no need  */
/* to use standard input parameters. Hence I am removing them in  */
/* the new API.                                                   */

/* x_return_status              Standard OUT param                */

/* x_msg_count                  Standard OUT param                */

/* x_msg_data                   Standard OUT param                */

/* p_inventory_item_id		Inventory item id for the labor item */
/* p_organization_id            Inventory Organization ID (Service validation org) */

/* p_bom_resource_id            BOM Resource ID                   */
/*p_charge_date			Charge date                       */

/* p_currency_code              Currency of Charge Amt            */

/* x_item_cost                  Resource rate of BOM resource     */


/*                                                                */

/*----------------------------------------------------------------*/


   PROCEDURE Get_ResItemCost
   (
		x_return_status OUT NOCOPY VARCHAR2,
                x_msg_count OUT NOCOPY NUMBER,
                x_msg_data OUT NOCOPY VARCHAR2,
                p_inventory_item_id IN NUMBER,
                p_organization_id IN NUMBER,
		p_bom_resource_id IN NUMBER,
                p_charge_date IN DATE,
                p_currency_code IN VARCHAR2,
		p_chg_line_uom_code IN VARCHAR2,
                x_item_cost OUT NOCOPY NUMBER
   )
   IS
   --Cursor to get item cost for an item. We only cosider standard/frozen costing type.
    CURSOR cur_getItemCost(p_inventory_item_id NUMBER,
                           p_organization_id NUMBER)
    IS
      SELECT CIC.item_cost
        FROM CST_ITEM_COSTS CIC
       WHERE CIC.inventory_item_id = p_inventory_item_id
         AND CIC.organization_id = p_organization_id
         AND CIC.cost_type_id = 1; -- standard/frozen cost

   --Cursor to get resource cost for a resource id. We only consider standard/frozen costing type.
   CURSOR cur_getResCost(p_bom_resorce_id NUMBER,
   			 p_organization_id NUMBER)
   IS
     SELECT CRC.resource_rate
       FROM   cst_resource_costs CRC
       WHERE  CRC.resource_id = p_bom_resource_id
       AND CRC.organization_id   = p_organization_id
       AND CRC.cost_type_id      = 1; -- standard/frozen cost

       --Cursor to get resource UOM code for the given resource id
       CURSOR cur_getResUOMCode (p_bom_resource_id NUMBER)
       IS
         SELECT BR.unit_of_measure
         FROM BOM_RESOURCES BR
         WHERE BR.resource_id = p_bom_resource_id;


    l_api_name           CONSTANT VARCHAR2(30)   := 'Get_ResItemCost';
    l_api_version        CONSTANT NUMBER         := 1.0;
    l_cost_currency_code          VARCHAR2(30);
    l_item_cost                   NUMBER;
    l_res_uom_code 		VARCHAR2(30);
    p_api_version  CONSTANT NUMBER    := 1.0;
    p_commit  CONSTANT VARCHAR2(1)    := 'F';
    p_init_msg_list CONSTANT VARCHAR2(1)  := 'T';
    p_validation_level CONSTANT NUMBER :=fnd_api.g_valid_level_full;
    -- Variable used in FND log

    l_stat_level                  number         := FND_LOG.LEVEL_STATEMENT;
    l_proc_level                  number         := FND_LOG.LEVEL_PROCEDURE;
    l_event_level                 number         := FND_LOG.LEVEL_EVENT;
    l_excep_level                 number         := FND_LOG.LEVEL_EXCEPTION;
    l_error_level                 number         := FND_LOG.LEVEL_ERROR;
    l_unexp_level                 number         := FND_LOG.LEVEL_UNEXPECTED;
    l_mod_name                    varchar2(2000) := 'csd.plsql.csd_cost_analysis_pvt.Get_InvItemCost';

    BEGIN
    -- Initialize API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
      THEN
        FND_LOG.STRING(Fnd_Log.Level_Procedure,
                       'csd.plsql.csd_cost_analysis_pvt.Get_ResItemCost.BEGIN',
                       'Entering Get_ResItemCost');
    END IF;

    --Check if costing enabled

    IF (CSD_COST_ANALYSIS_UTIL.Validate_CostingEnabled(p_organization_id))
      THEN

      --Check if the resource id was passed. If so, then get the resource cost
      If p_bom_resource_id is not null THEN
        IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
        THEN
          FND_LOG.STRING(Fnd_Log.Level_Statement,
                       'csd.plsql.csd_cost_analysis_pvt.Get_ResItemCost',
                       'Resource id :'|| p_bom_resource_id);
       END IF;

       -- Check if the resource UOM is different from Charge line UOM.
       -- If it is, then null out the item cost and exit. User will get here intentionally
       -- because when user is selecting a resource and UOM does not match,
       -- he is warned about it.
       OPEN cur_getResUOMCode(p_bom_resource_id);
       FETCH cur_getResUOMCode into l_Res_uom_code;
       CLOSE cur_getResUOMCode;
--codes are different, let the user know before nulling out the item cost
       IF (l_res_uom_code <> p_chg_line_uom_code ) THEN
 	FND_MESSAGE.SET_NAME('CSD', 'CSD_CST_DIFF_UOM_CODE'); --new message
            IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level)
              THEN
                FND_LOG.MESSAGE(Fnd_Log.Level_Error, l_mod_name, FALSE);
			END IF;

              FND_MSG_PUB.ADD;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

      OPEN cur_getResCost(p_bom_resource_id, p_organization_id);
      FETCH cur_getResCost INTO l_item_cost;
--        IF cur_getResCost%NOTFOUND
 --         THEN
  --          CLOSE cur_getResCost;
   --     END IF;
        CLOSE cur_getResCost;
	   END IF; --if p_bom_resource_id

	--no resource id was passed or item cost
	-- based on resource id was null, derive the labor item cost instead.
        -- Get item cost
	   IF ( p_bom_resource_id is null OR l_item_cost is null ) then
 IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
        THEN
          FND_LOG.STRING(Fnd_Log.Level_Statement,
                       'csd.plsql.csd_cost_analysis_pvt.Get_ResItemCost',
                       'No resource information. Deriving Labor item cost');
       END IF;
        OPEN cur_getItemCost(p_inventory_item_id, p_organization_id);
        FETCH cur_getItemCost INTO l_item_cost;
        IF cur_getItemCost%NOTFOUND
          THEN
            CLOSE cur_getItemCost;
            FND_MESSAGE.SET_NAME('CSD', 'CSD_CST_NO_ITEM_COST_AVAIL');
            IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level)
              THEN
                FND_LOG.MESSAGE(Fnd_Log.Level_Error, l_mod_name, FALSE);
			END IF;
           -- ELSE
              FND_MSG_PUB.ADD;
            --END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE cur_getItemCost;
	END IF;
        l_cost_currency_code := CSD_COST_ANALYSIS_UTIL.get_GLCurrencyCode(p_organization_id);

        --do the conversion if currency codes differ.

        IF (p_currency_code <> l_cost_currency_code)
          THEN
            CSD_COST_ANALYSIS_UTIL.Convert_CurrencyAmount(p_api_version      => p_api_version,
                                                          p_commit           => p_commit,
                                                          p_init_msg_list    => p_init_msg_list,
                                                          p_validation_level => p_validation_level,
                                                          p_from_currency    => l_cost_currency_code,
                                                          p_to_currency      => p_currency_code,
                                                          p_eff_date         => p_charge_date,
                                                          p_amount           => l_item_cost,
                                                          x_conv_amount      => x_item_cost,
                                                          x_return_status    => x_return_status,
                                                          x_msg_count        => x_msg_count,
                                                          x_msg_data         => x_msg_data);
        ELSE

          -- no need to convert becuase currency is same. Just set the variable.

          x_item_cost := l_item_cost;
        END IF;

        -- Throw exception if API fails.

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
          THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
    IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
      THEN
        FND_LOG.STRING(Fnd_Log.Level_Procedure,
                       'csd.plsql.csd_cost_analysis_pvt.Get_ResItemCost.END',
                       'Exiting Get_InvItemCost');
    END IF;

    --
    -- End API Body
    --

    -- Standard call to get message count and IF count is  get message info.

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_item_cost := NULL;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Get_ResItemCost',
                           'EXC_ERROR['
                           || x_msg_data
                           || ']');
        END IF;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_item_cost := NULL;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Get_ResItemCost',
                           'EXC_ERROR['
                           || x_msg_data
                           || ']');
        END IF;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_item_cost := NULL;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Get_ResItemCost',
                           'SQL Message['
                           || sqlerrm
                           || ']');
        END IF;
END get_ResItemCost;


END CSD_COST_ANALYSIS_PVT;

/
