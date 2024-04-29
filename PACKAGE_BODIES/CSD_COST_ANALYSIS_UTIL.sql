--------------------------------------------------------
--  DDL for Package Body CSD_COST_ANALYSIS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_COST_ANALYSIS_UTIL" AS
/* $Header: csdvanub.pls 120.0 2005/05/24 17:40:33 appldev noship $ */

  G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_COST_ANALYSIS_UTIL';
  G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvanub.pls';
  l_debug                NUMBER       := fnd_profile.value('CSD_DEBUG_LEVEL');
--hello
  -- Global variable for storing the debug level

  G_debug_level          number       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

 /*----------------------------------------------------------------*/

  /* procedure name: Convert_CurrencyAmount                         */

  /* description   : Converts an amount from one currency to        */

  /*                 another currency                               */

  /*                                                                */

  /* p_api_version                Standard IN param                 */

  /* p_commit                     Standard IN param                 */

  /* p_init_msg_list              Standard IN param                 */

  /* p_validation_level           Standard IN param                 */

  /* p_from_currency              Required Currency code to convert from   */

  /* p_to_currency                Required Currency code to convert to       */

  /* p_eff_date                  Required Conversion Date                   */

  /* p_amount                     Required Amount to convert                 */

  /* x_conv_amount                Converted amount                  */

  /* x_return_status              Standard OUT param                */

  /* x_msg_count                  Standard OUT param                */

  /* x_msg_data                   Standard OUT param                */

  /*                                                                */

  /*----------------------------------------------------------------*/


  PROCEDURE Convert_CurrencyAmount(p_api_version IN NUMBER,
                                   p_commit IN VARCHAR2,
                                   p_init_msg_list IN VARCHAR2,
                                   p_validation_level IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count OUT NOCOPY NUMBER,
                                   x_msg_data OUT NOCOPY VARCHAR2,
                                   p_from_currency IN VARCHAR2,
                                   p_to_currency IN VARCHAR2,
                                   p_eff_date IN DATE,
							p_amount IN NUMBER,
                                   x_conv_amount OUT NOCOPY NUMBER)
  IS
    l_api_name        CONSTANT VARCHAR2(30)   := 'Convert_CurrencyAmount';
    l_api_version     CONSTANT NUMBER         := 1.0;
    l_conversion_type          VARCHAR2(30);
    l_max_roll_days            NUMBER;
    l_denominator              NUMBER         := NULL;
    l_numerator                NUMBER         := NULL;
    l_rate                     NUMBER         := NULL;
    l_user_rate                NUMBER         := NULL;

    -- Variable used in FND log

    l_stat_level               number         := FND_LOG.LEVEL_STATEMENT;
    l_proc_level               number         := FND_LOG.LEVEL_PROCEDURE;
    l_event_level              number         := FND_LOG.LEVEL_EVENT;
    l_excep_level              number         := FND_LOG.LEVEL_EXCEPTION;
    l_error_level              number         := FND_LOG.LEVEL_ERROR;
    l_unexp_level              number         := FND_LOG.LEVEL_UNEXPECTED;
    l_mod_name                 varchar2(2000) := 'csd.plsql.csd_cost_analysis_util.Convert_CurrencyAmount';

  BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT Convert_CurrencyAmount_Utl;

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
                       'csd.plsql.csd_cost_analysis_util.Convert_CurrencyAmount.BEGIN',
                       'Entered Convert_CurrencyAmount');
    END IF;

    -- Check if conversion type profile is set. If not then raise error.

    l_conversion_type := FND_PROFILE.value('CSD_CURRENCY_CONVERSION_TYPE');
    IF (l_conversion_type IS NULL)
      THEN
        FND_MESSAGE.SET_NAME('CSD', 'CSD_CST_CURR_CONV_TYPE_NOT_SET');
        IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.MESSAGE(Fnd_Log.Level_Error, l_mod_name, FALSE);
       END IF;
       -- ELSE
          FND_MSG_PUB.ADD;
        --END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Get the max roll days from the profile.

    l_max_roll_days := FND_PROFILE.value('CSD_CURRENCY_MAX_ROLL');

    -- Initialize x_converted_amount to the in parameter p_amount

    x_conv_amount := p_amount;
    IF (p_amount IS NULL)
      THEN
        x_conv_amount := 0;
    ELSE

      --Call GL API to convert the amount.
   -- This is an impure API. It raises exceptions - NO_RATE and INVALID_CURRENCY. If so, it gets caught in others exception.
      GL_CURRENCY_API.CONVERT_CLOSEST_AMOUNT(x_from_currency    => p_from_currency,
                                             x_to_currency      => p_to_currency,
                                             x_conversion_date  => p_eff_date,
                                             x_conversion_type  => l_conversion_type,
                                             x_user_rate        => l_user_rate,
                                             x_amount           => p_amount,
                                             x_max_roll_days    => l_max_roll_days,
                                             x_converted_amount => x_conv_amount,
                                             x_denominator      => l_denominator,
                                             x_numerator        => l_numerator,
                                             x_rate             => l_rate);
    END IF;

    -- Debug messages

    IF (FND_LOG.LEVEL_PROCEDURE >= Fnd_Log.G_Current_Runtime_Level)
      THEN
        FND_LOG.STRING(Fnd_Log.Level_Procedure,
                       'csd.plsql.csd_cost_analysis_util.Convert_CurrencyAmount.END',
                       'LeavingConvert_CurrencyAmount');
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

        --ROLLBACK TO Convert_CurrencyAmount_Utl;

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_conv_amount := NULL;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
	     THEN

            FND_LOG.STRING(Fnd_Log.Level_Exception,
		     'csd.plsql.csd_cost_analysis_pvt.Convert_CurrencyAmount',
                           'EXC_ERROR['
                           || x_msg_data
                           || ']');
        END IF;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        -- ROLLBACK TO Convert_CurrencyAmount_Utl;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_conv_amount := NULL;
        FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => 'F');
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Convert_CurrencyAmount',
                           'EXC_ERROR['
                           || x_msg_data
                           || ']');
        END IF;
      WHEN OTHERS THEN

        --  ROLLBACK TO Convert_CurrencyAmount_Utl;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_conv_amount := NULL;
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
                           'csd.plsql.csd_cost_analysis_pvt.Convert_CurrencyAmount',
                           'SQL Message['
                           || sqlerrm
                           || ']');
        END IF;
  END Convert_CurrencyAmount;
  /*----------------------------------------------------------------*/

  /* procedure name: Compare_MLETotals                              */

  /* description   : Compares any two records of                    */

  /*                 MLE_total_record_type by amount and percent.   */

  /*                 Difference is calculated by basis - compare.   */

  /*                 Percent is determined by dividing difference   */

  /*                 by the basis.                                  */
  /* bugfix 3795221- Percent is now determined by dividing difference by compare */
  /*  If currencies are different,                                  */

  /*                 Difference will be in currency of compare amts */

  /*                                                                */

  /* p_api_version                Standard IN param                 */

  /* p_commit                     Standard IN param                 */

  /* p_init_msg_list              Standard IN param                 */

  /* p_validation_level           Standard IN param                 */

  /* p_mle_totals_basis           required Totals to use as basis            */

  /* p_mle_totals_compare         required Totals to compare to basis        */

  /* x_diff                       Basis - Compare                   */

  /* x_pct_diff                   (Basis - Compare)*100/Basis       */

  /* x_return_status              Standard OUT param                */

  /* x_msg_count                  Standard OUT param                */

  /* x_msg_data                   Standard OUT param                */

  /*                                                                */

  /*----------------------------------------------------------------*/

  PROCEDURE Compare_MLETotals(p_api_version IN NUMBER, p_commit IN VARCHAR2,
                              p_init_msg_list IN VARCHAR2,
                              p_validation_level IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2,
                              p_mle_totals_basis IN MLE_TOTALS_REC_TYPE,
                              p_mle_totals_compare IN MLE_TOTALS_REC_TYPE,
                              x_diff OUT NOCOPY MLE_TOTALS_REC_TYPE,
                              x_pct_diff OUT NOCOPY MLE_TOTALS_REC_TYPE)
  IS
    l_api_name         CONSTANT VARCHAR2(30)        := 'Compare_MLETotals';
    l_api_version      CONSTANT NUMBER              := 1.0;
    l_mle_totals_basis          MLE_TOTALS_REC_TYPE := p_mle_totals_basis;

    -- Variable used in FND log

    l_stat_level                number              := FND_LOG.LEVEL_STATEMENT;
    l_proc_level                number              := FND_LOG.LEVEL_PROCEDURE;
    l_event_level               number              := FND_LOG.LEVEL_EVENT;
    l_excep_level               number              := FND_LOG.LEVEL_EXCEPTION;
    l_error_level               number              := FND_LOG.LEVEL_ERROR;
    l_unexp_level               number              := FND_LOG.LEVEL_UNEXPECTED;
    l_mod_name                  varchar2(2000)      := 'csd.plsql.csd_cost_analysis_util.Compare_MLETotals';

  BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT Compare_MLETotals_Utl;

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
                       'csd.plsql.csd_cost_analysis_util.Compare_MLETotals.BEGIN',
                       'Entered Convert_CurrencyAmount');
    END IF;

    --Error if currency codes are differnt. While populating the databse, conversion must have happened.
    -- This is an additional precautionary check.

    IF p_mle_totals_basis.currency_code <> p_mle_totals_compare.currency_code
      THEN

        -- Throw error

        FND_MESSAGE.SET_NAME('CSD', 'CSD_CST_CURR_CODE_DIFF');
        IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.MESSAGE(Fnd_Log.Level_Error, l_mod_name, FALSE);
		 END IF;
       -- ELSE
          FND_MSG_PUB.ADD;
        --END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Populate difference between basis and compare data

    x_diff.materials := p_mle_totals_compare.materials - p_mle_totals_basis.materials;
    x_diff.labor := p_mle_totals_compare.labor - p_mle_totals_basis.labor;
    x_diff.expenses := p_mle_totals_compare.expenses - p_mle_totals_basis.expenses;

    -- total differnece will be null only when all 3 are null else it will be a normal sum.

    IF (x_diff.materials = NULL
        AND x_diff.labor = NULL
        AND x_diff.expenses = NULL)
      THEN
        x_diff.mle_total := NULL;
    ELSE
      x_diff.mle_total := nvl(x_diff.materials, 0) + nvl(x_diff.labor, 0) + nvl(x_diff.expenses,
                                                                                0);
    END IF;
    x_diff.currency_code := p_mle_totals_compare.currency_code;

    --Return null if any of the billing category amount is 0.

    IF p_mle_totals_compare.materials = 0
      THEN
        x_pct_diff.materials := NULL;
    ELSE
     --3795221- sangigup  x_pct_diff.materials := round(x_diff.materials * 100 / p_mle_totals_basis.materials, 2);
      x_pct_diff.materials := round(x_diff.materials * 100 / p_mle_totals_compare.materials, 2);
    END IF;
    IF p_mle_totals_compare.labor = 0
      THEN
        x_pct_diff.labor := NULL;
    ELSE
       --3795221- sangigup  x_pct_diff.labor := round(x_diff.labor * 100 / p_mle_totals_basis.labor, 2);
	x_pct_diff.labor := round(x_diff.labor * 100 / p_mle_totals_compare.labor, 2);
    END IF;
    IF p_mle_totals_compare.expenses = 0
      THEN
        x_pct_diff.expenses := NULL;
    ELSE
      x_pct_diff.expenses := round(x_diff.expenses * 100 / p_mle_totals_basis.expenses, 2);
    END IF;
    IF p_mle_totals_compare.mle_total = 0
      THEN
        x_pct_diff.mle_total := NULL;
    ELSE
     --3795221 sangigup x_pct_diff.mle_total := round(x_diff.mle_total * 100 / p_mle_totals_basis.mle_total, 2);
     x_pct_diff.mle_total := round(x_diff.mle_total * 100 / p_mle_totals_compare.mle_total, 2);
    END IF;
    x_pct_diff.currency_code := NULL;
    IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
      THEN
        FND_LOG.STRING(Fnd_Log.Level_Procedure,
                       'csd.plsql.csd_cost_analysis_util.Compare_MLETotals.END',
                       'LEaving Convert_CurrencyAmount');
    END IF;

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
        ROLLBACK TO Compare_MLETotals_Utl;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Compare_MLETotals',
                           'EXC_ERROR['
                           || x_msg_data
                           || ']');
        END IF;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Compare_MLETotals_Utl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Compare_MLETotals',
                           'EXC_ERROR['
                           || x_msg_data
                           || ']');
        END IF;
      WHEN OTHERS THEN
        ROLLBACK TO Compare_MLETotals_Utl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
          THEN
            FND_LOG.STRING(Fnd_Log.Level_Exception,
                           'csd.plsql.csd_cost_analysis_pvt.Compare_MLETotals',
                           'SQL Message['
                           || sqlerrm
                           || ']');
        END IF;
  END Compare_MLETotals;
  /*----------------------------------------------------------------*/

  /* function  name: get_GLCurrencyCode                             */

  /* description   : Given an organization_id,returns currency code */

  /*                  for the Organization                          */

  /* p_organization_id     IN        NUMBER                         */

  /*                                                                */

  /*----------------------------------------------------------------*/

  FUNCTION get_GLCurrencyCode(p_organization_id IN NUMBER) RETURN VARCHAR2
  IS
    --Curcor to get GL Currency Code defined in GL set of books.
    CURSOR cur_getGLCode(p_org_id NUMBER)
    IS
      SELECT gl.currency_code
        FROM gl_sets_of_books gl, hr_operating_units hr
       WHERE hr.set_of_books_id = gl.set_of_books_id
         AND hr.organization_id = p_org_id;
    l_currency_code VARCHAR2(15);

  BEGIN
    OPEN cur_getGLCOde(p_organization_id);
    FETCH cur_getGLCode INTO l_currency_code;
    CLOSE cur_getGLCode;
    RETURN l_currency_code;
    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        l_currency_code := NULL;
        FND_MESSAGE.SET_NAME('CSD', 'CSD_CST_TOO_MANY_ROWS_CURR');
        FND_MSG_PUB.ADD;
        /*
           FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
           p_data   =>  x_msg_data
           );*/

        RETURN l_currency_code;
      WHEN NO_DATA_FOUND THEN
        l_currency_code := NULL;
        FND_MESSAGE.SET_NAME('CSD', 'CSD_CST_NO_DATA_CURR');
        FND_MSG_PUB.ADD;
        /*
           FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
           p_data   =>  x_msg_data
           );*/

        RETURN l_currency_code;
      WHEN OTHERS THEN
        l_currency_code := NULL;
        RETURN l_currency_code;
  END Get_GLCurrencyCode;
  /*----------------------------------------------------------------*/

  /* function  name: Validate_CostingEnabled                        */

  /* description   : Given an organization_id, returns TRUE if the  */

  /*                  Organization is costing enabled.              */

  /* p_organization_id     IN        NUMBER                         */

  /*                                                                */

  /*----------------------------------------------------------------*/

  FUNCTION Validate_CostingEnabled(p_organization_id IN NUMBER) RETURN BOOLEAN
  IS
    l_cost_enabled      BOOLEAN;
    l_PrimaryCostMethod NUMBER;
    l_costing           vARCHAR2(4);

--Curcor to get the primary cost method for the organization.
    CURSOR cur_getPrimaryCostMethod(p_organization_id NUMBER)
    IS
      SELECT primary_cost_method
        FROM mtl_parameters
       WHERE organization_id = p_organization_id;
  BEGIN
    l_cost_enabled := TRUE;

    -- get the profile value of CSD_ENABLE_COSTING

    IF nvl(fnd_profile.value('CSD_ENABLE_COSTING'), 'N') <> 'Y'
      THEN
        l_cost_enabled := FALSE;
    END IF;
    IF l_cost_enabled
      THEN

        --  get the primary cost method for the organization

        OPEN cur_getPrimaryCostMethod(p_organization_id);
        FETCH cur_getPrimaryCostMethod INTO l_PrimaryCostMethod;
        IF cur_getPrimaryCostMethod%NOTFOUND
          THEN
            l_cost_enabled := FALSE;
        END IF;
        IF l_PrimaryCostMethod <> 1
          THEN
            l_cost_enabled := FALSE;
        END IF;
        CLOSE cur_getPrimaryCostMethod;
    END IF;
    RETURN l_cost_enabled;
    EXCEPTION
      WHEN OTHERS THEN
        l_cost_enabled := FALSE;
        RETURN l_cost_enabled;
  END Validate_CostingEnabled;

END CSD_COST_ANALYSIS_UTIL;

/
