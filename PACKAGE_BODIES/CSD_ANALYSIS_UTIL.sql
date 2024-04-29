--------------------------------------------------------
--  DDL for Package Body CSD_ANALYSIS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_ANALYSIS_UTIL" AS
/* $Header: csdvanub.pls 115.0 2002/11/19 22:28:58 swai noship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_ANALYSIS_UTIL';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvanub.pls';
l_debug       NUMBER := fnd_profile.value('CSD_DEBUG_LEVEL');

/*----------------------------------------------------------------*/
/* function name: Get_CurrencyCode                                */
/* description  : Gets the currency from GL_SETS_OF_BOOKS for an  */
/*                organization                                    */
/*                                                                */
/* p_organization_id            Organization ID to get currency   */
/*                                                                */
/*----------------------------------------------------------------*/
FUNCTION Get_CurrencyCode (
   p_organization_id   IN   NUMBER
)
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END Get_CurrencyCode;

/*----------------------------------------------------------------*/
/* procedure name: Convert_CurrencyAmount                         */
/* description   : Converts an amount from one currency to        */
/*                 another currency                               */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_from_currency              Currency code to convert from     */
/* p_to_currency                Currency code to convert to       */
/* p_eff_date                   Conversion Date                   */
/* p_amount                     Amount to convert                 */
/* p_conv_type                  Conversion type                   */
/* x_conv_amount                Converted amount                  */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Convert_CurrencyAmount (
   p_api_version           IN     NUMBER,
   p_commit                IN     VARCHAR2,
   p_init_msg_list         IN     VARCHAR2,
   p_validation_level      IN     NUMBER,
   p_from_currency         IN     VARCHAR2,
   p_to_currency           IN     VARCHAR2,
   p_eff_date              IN     DATE,
   p_amount                IN     NUMBER,
   p_conv_type             IN     VARCHAR2,
   x_conv_amount           OUT NOCOPY    NUMBER,
   x_return_status         OUT NOCOPY    VARCHAR2,
   x_msg_count             OUT NOCOPY    NUMBER,
   x_msg_data              OUT NOCOPY    VARCHAR2
)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Convert_CurrencyAmount';
   l_api_version             CONSTANT NUMBER := 1.0;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Convert_CurrencyAmount_Utl;

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

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Convert_CurrencyAmount_Utl;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Convert_CurrencyAmount_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Convert_CurrencyAmount_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Convert_CurrencyAmount;

/*----------------------------------------------------------------*/
/* procedure name: Get_TotalActCosts                              */
/* description   : Given a repair line id, gets the total MLE     */
/*                 actual costs.                                  */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_repair_line_id             Repair Line ID to get actual costs*/
/* p_currency_code              Currency to convert costs to      */
/* x_costs                      Total MLE costs for repair line   */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_TotalActCosts
(
   p_api_version           IN     NUMBER,
   p_commit                IN     VARCHAR2,
   p_init_msg_list         IN     VARCHAR2,
   p_validation_level      IN     NUMBER,
   p_repair_line_id        IN     NUMBER,
   p_currency_code         IN     VARCHAR2,  --currency to convert costs to
   x_costs                 OUT NOCOPY    MLE_TOTALS_REC_TYPE,
   x_return_status         OUT NOCOPY    VARCHAR2,
   x_msg_count             OUT NOCOPY    NUMBER,
   x_msg_data              OUT NOCOPY    VARCHAR2
)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Get_TotalActCosts';
   l_api_version             CONSTANT NUMBER := 1.0;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Get_TotalActCosts_Utl;

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

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Get_TotalActCosts_Utl;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Get_TotalActCosts_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Get_TotalActCosts_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Get_TotalActCosts;


/*----------------------------------------------------------------*/
/* procedure name: Get_TotalEstCosts                              */
/* description   : Given an estimate header, gets the total MLE   */
/*                 estimated costs.                               */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_estimate_header_id         Est header ID to get est costs for*/
/* p_currency_code              Currency to convert costs to      */
/* x_costs                      Total MLE costs for repair line   */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_TotalEstCosts (
   p_api_version           IN     NUMBER,
   p_commit                IN     VARCHAR2,
   p_init_msg_list         IN     VARCHAR2,
   p_validation_level      IN     NUMBER,
   p_estimate_header_id    IN     NUMBER,
   x_costs                 OUT NOCOPY    MLE_TOTALS_REC_TYPE,
   x_return_status         OUT NOCOPY    VARCHAR2,
   x_msg_count             OUT NOCOPY    NUMBER,
   x_msg_data              OUT NOCOPY    VARCHAR2
)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Get_TotalEstCosts';
   l_api_version             CONSTANT NUMBER := 1.0;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Get_TotalEstCosts_Utl;

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

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Get_TotalEstCosts_Utl;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Get_TotalEstCosts_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Get_TotalEstCosts_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Get_TotalEstCosts;

/*----------------------------------------------------------------*/
/* procedure name: Compare_MLETotals                              */
/* description   : Compares any two records of                    */
/*                 MLE_total_record_type by amount and percent.   */
/*                 Difference is calculated by basis - compare.   */
/*                 Percent is determined by dividing difference   */
/*                 by the basis. If currencies are different,     */
/*                 Difference will be in currency of compare amts */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_mle_totals_basis           Totals to use as basis            */
/* p_mle_totals_compare         Totals to compare to basis        */
/* x_diff                       Basis - Compare                   */
/* x_pct_diff                   (Basis - Compare)*100/Basis       */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Compare_MLETotals (
   p_api_version           IN     NUMBER,
   p_commit                IN     VARCHAR2,
   p_init_msg_list         IN     VARCHAR2,
   p_validation_level      IN     NUMBER,
   p_mle_totals_basis      IN     MLE_TOTALS_REC_TYPE,
   p_mle_totals_compare    IN     MLE_TOTALS_REC_TYPE,
   x_diff                  OUT NOCOPY    MLE_TOTALS_REC_TYPE,
   x_pct_diff              OUT NOCOPY    MLE_TOTALS_REC_TYPE,
   x_return_status         OUT NOCOPY    VARCHAR2,
   x_msg_count             OUT NOCOPY    NUMBER,
   x_msg_data              OUT NOCOPY    VARCHAR2
)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Compare_MLETotals';
   l_api_version             CONSTANT NUMBER := 1.0;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Compare_MLETotals_Utl;

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

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Compare_MLETotals_Utl;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Compare_MLETotals_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Compare_MLETotals_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Compare_MLETotals;

END CSD_ANALYSIS_UTIL ;

/
