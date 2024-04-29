--------------------------------------------------------
--  DDL for Package Body PA_MULTI_CURRENCY_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MULTI_CURRENCY_BILLING" AS
--$Header: PAXMULTB.pls 120.5 2007/12/28 12:01:11 hkansal ship $

/*----------------------------------------------------------------------------------------+
|   Procedure  :   get_imp_defaults                                                       |
|   Purpose    :   To get implementation level defaults related to  multi_currency_billing|
|                  setup                                                                  |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                             Mode    Description                                |
|     ==================================================================================  |
|     x_multi_currency_billing_flag    OUT     Indicates multi_currency_billing_flag      |
|                                              is allowed for this OU                     |
|     x_share_bill_rates_across_ou     OUT     Indicates sharing Bill rates schedules     |
|                                              across OU is allowed for this OU           |
|     x_allow_funding_across_ou        OUT     Indicates funding across OU is allowed for |
|                                              this OU                                    |
|     x_default_exchange_rate_type     OUT     Default value for rate type                |
|     x_functional_currency            OUT     Functional currency of OU                  |
|     x_return_status                  OUT     Return status of this procedure            |
|     x_msg_count                      OUT     Error message count                        |
|     x_msg_data                       OUT     Error message                              |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/

   PROCEDURE get_imp_defaults (
            x_multi_currency_billing_flag    OUT NOCOPY     VARCHAR2,
            x_share_bill_rates_across_OU     OUT NOCOPY     VARCHAR2,
            x_allow_funding_across_OU        OUT NOCOPY     VARCHAR2,
            x_default_exchange_rate_type     OUT NOCOPY     VARCHAR2,
            x_functional_currency            OUT NOCOPY     VARCHAR2,
            x_competence_match_wt            OUT NOCOPY     NUMBER,
            x_availability_match_wt          OUT NOCOPY     NUMBER,
            x_job_level_match_wt             OUT NOCOPY     NUMBER,
            x_return_status                  OUT NOCOPY     VARCHAR2,
            x_msg_count                      OUT NOCOPY     NUMBER,
            x_msg_data                       OUT NOCOPY     VARCHAR2) IS


   BEGIN

        SELECT multi_currency_billing_flag,
               share_across_ou_br_sch_flag,
               allow_funding_across_ou_flag,
               default_rate_type,
               pa_currency.get_currency_code,
               competence_match_wt,
               availability_match_wt,
               job_level_match_wt
        INTO   x_multi_currency_billing_flag,
               x_share_bill_rates_across_OU,
               x_allow_funding_across_OU,
               x_default_exchange_rate_type,
               x_functional_currency,
               x_competence_match_wt,
               x_availability_match_wt,
               x_job_level_match_wt
        FROM   pa_implementations;

   EXCEPTION

        WHEN others THEN
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         /* Aded the below for NOCOPY Mandate */
             x_multi_currency_billing_flag := NULL;
             x_share_bill_rates_across_OU := NULL;
             x_allow_funding_across_OU := NULL;
             x_default_exchange_rate_type := NULL;
             x_functional_currency := NULL;
             x_competence_match_wt := NULL;
             x_availability_match_wt := NULL;
             x_job_level_match_wt := NULL;
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_MULTI_CURRENCY_BILLING',
                    p_procedure_name   => 'get_imp_defaults');

             RAISE ;

   END get_imp_defaults;

/*----------------------------------------------------------------------------------------+
|   Procedure  :   get_project_defaults                                                   |
|   Purpose    :   To get project level defaults related to  multi_currency_billing setup |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                             Mode    Description                                |
|     ==================================================================================  |
|     p_project_id                     IN      Project ID                                 |
|     x_multi_currency_billing_flag    OUT     Indicates multi_currency_billing_flag      |
|                                              is allowed for the project                 |
|     x_baseline_funding_flag          OUT     Indicates baselining is allowed from       |
|                                              funding inquiry form (without any existing)|
|                                              budgets for the project                    |
|     x_revproc_currency_code          OUT     Revenue processing currency code of the    |
|                                              project                                    |
|     x_invproc_currency_type          OUT     Invoice processing currency type of the    |
|                                              project                                    |
|     x_invproc_currency_code          OUT     Invoice processing currency code of the    |
|                                              project                                    |
|     x_project_currency_code          OUT     Project currency code of the project       |
|     x_project_bil_rate_date_code     OUT     Exchange rate date type for determining the|
|                                              date to use for conversion between  bill   |
|                                              transaction currency/funding currency to   |
|                                              project currency for customer billing      |
|     x_project_bil_rate_type          OUT     Exchange rate type to use for conversion   |
|                                              between  bill transaction currency/funding |
|                                              currency to project currency for customer  |
|                                              billing                                    |
|     x_project_bil_rate_date          OUT     Exchange rate date to use for conversion   |
|                                              between  bill transaction currency/funding |
|                                              currency to project currency               |
|     x_project_bil_exchange_rate      OUT     Exchange rate to use for conversion        |
|                                              between  bill transaction currency/funding |
|                                              currency to project currency if            |
|                                              bil_rate_type is user                      |
|     x_projfunc_currency_code         OUT     Project functional currency code of the    |
|                                              project                                    |
|     x_projfunc_bil_rate_date_code    OUT     Exchange rate date type for determining the|
|                                              date to use for conversion between  bill   |
|                                              transaction currency/funding currency to   |
|                                              project functional currency                |
|     x_projfunc_bil_rate_type         OUT     Exchange rate type to use for conversion   |
|                                              between  bill transaction currency/funding |
|                                              currency to project functional currency    |
|     x_projfunc_bil_rate_date         OUT     Exchange rate date to use for conversion   |
|                                              between  bill transaction currency/funding |
|                                              currency to project functional currency r  |
|     x_projfunc_bil_exchange_rate     OUT     Exchange rate to use for conversion        |
|                                              between  bill transaction currency/funding |
|                                              currency to project functional currency if |
|                                              bil_rate_type is user                      |
|     x_funding_rate_date_code         OUT     Exchange rate date type for determining the|
|                                              date to use for conversion between  bill   |
|                                              transaction currency to funding currency   |
|     x_funding_rate_type              OUT     Exchange rate type to use for conversion   |
|                                              between  bill transaction currency to      |
|                                              funding currency                           |
|     x_funding_rate_date              OUT     Exchange rate date to use for conversion   |
|                                              between  bill transaction currency to      |
|                                              funding currency                           |
|     x_funding_exchange_rate          OUT     Exchange rate to use for conversion        |
|                                              between  bill transaction currency to      |
|                                              funding currency if bil_rate_type is user  |
|     x_return_status                  OUT     Return status of this procedure            |
|     x_msg_count                      OUT     Error message count                        |
|     x_msg_data                       OUT     Error message                              |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/
   PROCEDURE get_project_defaults (
            p_project_id                  IN      NUMBER,
            x_multi_currency_billing_flag OUT NOCOPY     VARCHAR2,
            x_baseline_funding_flag       OUT NOCOPY     VARCHAR2,
            x_revproc_currency_code       OUT NOCOPY     VARCHAR2,
            x_invproc_currency_type       OUT NOCOPY     VARCHAR2,
            x_invproc_currency_code       OUT NOCOPY     VARCHAR2,
            x_project_currency_code       OUT NOCOPY     VARCHAR2,
            x_project_bil_rate_date_code  OUT NOCOPY     VARCHAR2,
            x_project_bil_rate_type       OUT NOCOPY     VARCHAR2,
            x_project_bil_rate_date       OUT NOCOPY     DATE,
            x_project_bil_exchange_rate   OUT NOCOPY     NUMBER,
            x_projfunc_currency_code      OUT NOCOPY     VARCHAR2,
            x_projfunc_bil_rate_date_code OUT NOCOPY     VARCHAR2,
            x_projfunc_bil_rate_type      OUT NOCOPY     VARCHAR2,
            x_projfunc_bil_rate_date      OUT NOCOPY     DATE,
            x_projfunc_bil_exchange_rate  OUT NOCOPY     NUMBER,
            x_funding_rate_date_code      OUT NOCOPY     VARCHAR2,
            x_funding_rate_type           OUT NOCOPY     VARCHAR2,
            x_funding_rate_date           OUT NOCOPY     DATE,
            x_funding_exchange_rate       OUT NOCOPY     NUMBER,
            x_return_status               OUT NOCOPY     VARCHAR2,
            x_msg_count                   OUT NOCOPY     NUMBER,
            x_msg_data                    OUT NOCOPY     VARCHAR2) IS


   BEGIN
        SELECT    invproc_currency_type, revproc_currency_code,
                  project_currency_code, project_bil_rate_date_code,
                  project_bil_rate_type, project_bil_rate_date,
                  project_bil_exchange_rate,
                  projfunc_currency_code, projfunc_bil_rate_date_code,
                  projfunc_bil_rate_type, projfunc_bil_rate_date,
                  projfunc_bil_exchange_rate,
                  funding_rate_date_code, funding_rate_type,
                  funding_rate_date, funding_exchange_rate,
                  baseline_funding_flag, multi_currency_billing_flag
       INTO       x_invproc_currency_type, x_revproc_currency_code,
                  x_project_currency_code, x_project_bil_rate_date_code,
                  x_project_bil_rate_type, x_project_bil_rate_date,
                  x_project_bil_exchange_rate,
                  x_projfunc_currency_code, x_projfunc_bil_rate_date_code,
                  x_projfunc_bil_rate_type, x_projfunc_bil_rate_date,
                  x_projfunc_bil_exchange_rate,
                  x_funding_rate_date_code, x_funding_rate_type,
                  x_funding_rate_date, x_funding_exchange_rate,
                  x_baseline_funding_flag, x_multi_currency_billing_flag
       FROM       pa_projects_all
       WHERE      project_id = p_project_id;


       IF x_invproc_currency_type = 'PROJECT_CURRENCY'  THEN

          x_invproc_currency_code := x_project_currency_code;

       ELSIF x_invproc_currency_type = 'PROJFUNC_CURRENCY'  THEN

          x_invproc_currency_code := x_projfunc_currency_code;

       ELSIF x_invproc_currency_type = 'FUNDING_CURRENCY'  THEN

          BEGIN

              SELECT funding_currency_code
              INTO   x_invproc_currency_code
              FROM   pa_summary_project_fundings
              WHERE  project_id = p_project_id
              AND    rownum = 1
	      AND    NVL(total_baselined_amount,0) > 0;  /* Added for bug 2834362 */
	      /*
              GROUP BY funding_currency_code
              HAVING    sum(nvl(total_baselined_amount,0)) > 0; Commented for bug 2834362*/

          EXCEPTION

              WHEN NO_DATA_FOUND THEN

                  x_invproc_currency_code := null;

                  /*
                   x_msg_count     := 1;
                   x_msg_data      := 'PA_NO_FUNDING_EXISTS';
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   FND_MSG_PUB.add_Exc_msg(
                          p_pkg_name         => 'PA_MULTI_CURRENCY_BILLING',
                          p_procedure_name   => 'get_project_defaults');

                   RAISE ;
                 */

          END;


       END IF;


   EXCEPTION

        WHEN others THEN

             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            /* Added the belog for NOCOPY mandate */
             x_multi_currency_billing_flag     := NULL;
             x_baseline_funding_flag      := NULL;
             x_revproc_currency_code      := NULL;
             x_invproc_currency_type     := NULL;
             x_invproc_currency_code     := NULL;
             x_project_currency_code      := NULL;
             x_project_bil_rate_date_code     := NULL;
             x_project_bil_rate_type     := NULL;
             x_project_bil_rate_date     := NULL;
             x_project_bil_exchange_rate     := NULL;
             x_projfunc_currency_code     := NULL;
             x_projfunc_bil_rate_date_code     := NULL;
             x_projfunc_bil_rate_type      := NULL;
             x_projfunc_bil_rate_date     := NULL;
             x_projfunc_bil_exchange_rate     := NULL;
             x_funding_rate_date_code     := NULL;
             x_funding_rate_type      := NULL;
             x_funding_rate_date     := NULL;
             x_funding_exchange_rate      := NULL;

             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_MULTI_CURRENCY_BILLING',
                    p_procedure_name   => 'get_project_defaults');

             RAISE ;

   END get_project_defaults;

/*----------------------------------------------------------------------------------------+
|   Function   :   is_project_mcb_enabled                                                 |
|   Purpose    :   To return if multi currency billing is enabled for a project           |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                             Mode    Description                                |
|     ==================================================================================  |
|     p_project_id                     IN      Project ID                                 |
|     ==================================================================================  |
|   Returns    : VARCHAR2                                                                 |
+----------------------------------------------------------------------------------------*/

   FUNCTION is_project_mcb_enabled ( p_project_id    IN NUMBER)
   RETURN VARCHAR2 IS

       l_multi_currency_billing_flag   VARCHAR2(15);

   BEGIN

       SELECT  multi_currency_billing_flag
       INTO    l_multi_currency_billing_flag
       FROM    pa_projects_all
       WHERE   project_id = p_project_id;

       RETURN  l_multi_currency_billing_flag;

   EXCEPTION

        WHEN others THEN
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_MULTI_CURRENCY_BILLING',
                    p_procedure_name   => 'is_project_mcb_enabled');

             RAISE ;

   END is_project_mcb_enabled;


/*----------------------------------------------------------------------------------------+
|   Function   :   is_ou_mcb_enabled                                                      |
|   Purpose    :   To return if multi currency billing is enabled for the OU              |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                             Mode    Description                                |
|     ==================================================================================  |
|     p_org_id                         IN      Operatin Unit Identifier                   |
|     ==================================================================================  |
|   Returns    : VARCHAR2                                                                 |
+----------------------------------------------------------------------------------------*/

   FUNCTION is_OU_mcb_enabled ( p_org_id    IN NUMBER)
   RETURN VARCHAR2 IS

       l_multi_currency_billing_flag   VARCHAR2(15);

   BEGIN

       SELECT  multi_currency_billing_flag
       INTO    l_multi_currency_billing_flag
       FROM    pa_implementations_all
       WHERE   org_id = p_org_id; /*Bug 5368089*/

       RETURN  l_multi_currency_billing_flag;

   EXCEPTION

        WHEN others THEN
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_MULTI_CURRENCY_BILLING',
                    p_procedure_name   => 'is_OU_mcb_enabled');

             RAISE ;

   END is_OU_mcb_enabled;


/*----------------------------------------------------------------------------------------+
|   Function   :   is_sharing_bill_rates_allowed                                          |
|   Purpose    :   To return if sharing bill rate schedules across OU is allowed          |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                             Mode    Description                                |
|     ==================================================================================  |
|     p_org_id                         IN      Operatin Unit Identifier                   |
|     ==================================================================================  |
|   Returns    : VARCHAR2                                                                 |
+----------------------------------------------------------------------------------------*/
   FUNCTION is_sharing_bill_rates_allowed ( p_org_id    IN NUMBER)
   RETURN VARCHAR2 IS

       l_share_across_ou_br_sch_flag   VARCHAR2(15);

   BEGIN

       SELECT  share_across_ou_br_sch_flag
       INTO    l_share_across_ou_br_sch_flag
       FROM    pa_implementations_all
       WHERE   org_id = p_org_id; /*Bug 5368089*/

       RETURN  l_share_across_ou_br_sch_flag;

   EXCEPTION

        WHEN others THEN
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_MULTI_CURRENCY_BILLING',
                    p_procedure_name   => 'is_sharing_bill_rates_allowed');

             RAISE ;

   END is_sharing_bill_rates_allowed;


/*----------------------------------------------------------------------------------------+
|   Function   :   is_funding_across_ou_allowed                                           |
|   Purpose    :   To return if funding across OU is allowed                              |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                             Mode    Description                                |
|     ==================================================================================  |
|     p_org_id                         IN      Operatin Unit Identifier                   |
|     ==================================================================================  |
|   Returns    : VARCHAR2                                                                 |
+----------------------------------------------------------------------------------------*/

   FUNCTION is_funding_across_ou_allowed
   RETURN VARCHAR2 IS

       l_allow_funding_across_ou_flag   VARCHAR2(15);

   BEGIN

       SELECT  allow_funding_across_ou_flag
       INTO    l_allow_funding_across_ou_flag
       FROM    pa_implementations;

       RETURN  l_allow_funding_across_ou_flag;

   EXCEPTION

        WHEN others THEN
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_MULTI_CURRENCY_BILLING',
                    p_procedure_name   => 'is_funding_across_ou_allowed');

             RAISE ;

   END is_funding_across_ou_allowed;

/*----------------------------------------------------------------------------------------+
|   Function   :   get_invoice_processing_cur                                             |
|   Purpose    :   To return invoice processing currency code of  a project               |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                             Mode    Description                                |
|     ==================================================================================  |
|     p_project_id                     IN      Project ID                                 |
|     ==================================================================================  |
|   Returns    : VARCHAR2                                                                 |
+----------------------------------------------------------------------------------------*/
   FUNCTION get_invoice_processing_cur ( p_project_id    IN NUMBER)
   RETURN VARCHAR2 IS

       l_invproc_currency_type pa_projects_all.invproc_currency_type%TYPE;
       l_invproc_currency_code pa_projects_all.project_currency_code%TYPE;
       l_project_currency_code   pa_projects_all.project_currency_code%TYPE;
       l_projfunc_currency_code  pa_projects_all.projfunc_currency_code%TYPE;

   BEGIN

        SELECT    invproc_currency_type, project_currency_code,
                  projfunc_currency_code
        INTO      l_invproc_currency_type, l_project_currency_code,
                  l_projfunc_currency_code
        FROM      pa_projects_all
        WHERE     project_id = p_project_id;


       IF l_invproc_currency_type = 'PROJECT_CURRENCY'  THEN

          l_invproc_currency_code := l_project_currency_code;

       ELSIF l_invproc_currency_type = 'PROJFUNC_CURRENCY'  THEN

          l_invproc_currency_code := l_projfunc_currency_code;

       ELSIF l_invproc_currency_type = 'FUNDING_CURRENCY'  THEN

          BEGIN

               SELECT funding_currency_code
               INTO   l_invproc_currency_code
               FROM   pa_summary_project_fundings
               WHERE  project_id = p_project_id
               AND    rownum = 1;

          EXCEPTION

               WHEN NO_DATA_FOUND THEN
                   FND_MSG_PUB.add_Exc_msg(
                          p_pkg_name         => 'PA_MULTI_CURRENCY_BILLING',
                          p_procedure_name   => 'get_invoice_processing_cur');

                   RAISE ;

          END;

       END IF;

       RETURN l_invproc_currency_code;

   EXCEPTION

        WHEN others THEN
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_MULTI_CURRENCY_BILLING',
                    p_procedure_name   => 'get_invoice_processing_cur');

             RAISE ;

   END get_invoice_processing_cur;

/*----------------------------------------------------------------------------------------+
|   Procedure  :   convert_amount_bulk                                                    |
|   Purpose    :   Converts amount from one currency to another based on the currency     |
|                  attributes. Also returns the exchange rate/error messages. This will   |
|                  handle bulk conversion amounts.                                        |
|                  Error message will be returned in x_status_tab. Input p_conversion_between will be|
|                  appended to the end of the error_messages, The possible expected       |
|                  error messages are 1)PA_USR_RATE_NOT_ALLOWED                           |
|                                     2)PA_NO_EXCH_RATE_EXISTS                            |
|                                     3)PA_CURR_NOT_VALID                                 |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                             Mode    Description                                |
|     ==================================================================================  |
|     p_from_currency_tab              IN      Source Currency code(s) of the amount(s) to|
|                                              be converted                               |
|     p_to_currency_tab                IN      Destination Currency code(s) of the        |
|                                              amount(s) to be converted                  |
|     p_conversion_date_tab            IN OUT  Conversion Date(s) to use for conversion   |
|     p_conversion_type_tab            IN OUT  Conversion type(s) to use for conversion   |
|     p_amount_tab                     IN      Amount to be converted                     |
|     p_user_validate_flag_tab         IN      For coversion type  'user', this flag      |
|                                              indicates if validation is to be done to   |
|                                              check if 'user' rate type is allowed for   |
|                                              the currency conversion                    |
|                                              'Y' : yes; 'N : No                         |
|     p_converted_amount_tab           IN OUT  Converted amount                           |
|     p_denominator_tab                IN OUT  Denominator value                          |
|     p_numerator_tab                  IN OUT  Numerator value                            |
|     p_rate_tab                       IN OUT  Rate used for coversion                    |
|     p_conversion_between                        IN      Error string denoting which conversion has |
|                                              failed. Ex : PC_PF indicates project to    |
|                                              project functional has failed              |
|     p_cache_flag                     IN      if attributes are to cached                |
|                                                                                         |
|        Brief desc : During EI conversion, it is assumed that the conversion attributes  |
|        will be same. So the attribures are cached into a plsql table and used for       |
|        further computations which would help in performance                             |
|     x_status_tab                     OUT     Return status of each conversion           |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/
   PROCEDURE convert_amount_bulk (
          p_from_currency_tab         IN       PA_PLSQL_DATATYPES.Char30TabTyp,
          p_to_currency_tab           IN       PA_PLSQL_DATATYPES.Char30TabTyp,
          p_conversion_date_tab       IN OUT  NOCOPY   PA_PLSQL_DATATYPES.DateTabTyp ,
          p_conversion_type_tab       IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
          p_amount_tab                IN       PA_PLSQL_DATATYPES.NumTabTyp,
          p_user_validate_flag_tab    IN       PA_PLSQL_DATATYPES.Char30TabTyp ,
          p_converted_amount_tab      IN OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
          p_denominator_tab           IN OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
          p_numerator_tab             IN OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
          p_rate_tab                  IN OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
          p_conversion_between        IN       VARCHAR2,
          p_cache_flag                IN       VARCHAR2,
          x_status_tab                OUT     NOCOPY   PA_PLSQL_DATATYPES.Char30TabTyp)  IS

        l_allow_user_rate_type   VARCHAR2(1) ;
        l_converted_amount       NUMBER ;
        l_numerator	         NUMBER ;
        l_denominator            NUMBER ;
        l_rate			 NUMBER ;

        l_tab_count              NUMBER;
        l_done_flag              VARCHAR2(1);

        l_AttrTab_count          NUMBER;
	l_debug_mode             VARCHAR2(1); /* added for bug 6322049 */

   BEGIN

         l_tab_count := p_from_currency_tab.COUNT;
         l_AttrTab_count := CurrAttrTab.COUNT;
	 l_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');  /* added for bug 6322049 */

         IF l_tab_count = 0 then

            RETURN;

         END IF;

         FOR i in p_from_currency_tab.first..p_from_currency_tab.last LOOP

             x_status_tab(i) := 'N';
             l_done_flag := 'N';

             IF (p_from_currency_tab(i) = p_to_currency_tab(i)) THEN

                 p_conversion_date_tab(i) := null;
                 p_conversion_type_tab(i) := null;
                 p_rate_tab(i)            := null;
                 p_converted_amount_tab(i):= p_amount_tab(i);

             ELSE

                IF p_cache_flag = 'Y' then

                   --PA_MCB_REVENUE_PKG.log_message('MCB... Inside Convert amount bulk ');


                   IF nvl(CurrAttrTab.count,0) <> 0 THEN

                      --PA_MCB_REVENUE_PKG.log_message('UTL... in if');

                      For j in CurrAttrTab.First..CurrAttrTab.Last LOOP

                      IF l_debug_mode = 'Y' THEN  /* added IF for bug 6322049 */
                          PA_MCB_REVENUE_PKG.log_message('UTL' || CurrAttrTab(j).from_currency);
                          PA_MCB_REVENUE_PKG.log_message('UTL' || CurrAttrTab(j).from_currency);
		      END IF;

                          If CurrAttrTab(j).from_currency = p_from_currency_tab(i) and
                                     CurrAttrTab(j).to_currency = p_to_currency_tab(i) and
				     CurrAttrTab(j).conv_date = p_conversion_date_tab(i) and /* Condition added for bug 5907315 */
                                 CurrAttrTab(j).conv_between = p_conversion_between then

                                 --PA_MCB_REVENUE_PKG.log_message('UTL in if 2' || to_char(CurrAttrTab(j).rate));
                             p_rate_tab(i) := CurrAttrTab(j).rate;
                             p_numerator_tab(i) := CurrAttrTab(j).numerator ;
                             p_denominator_tab(i) := CurrAttrTab(j).denominator ;
/*
                             p_converted_amount_tab(i) :=  round_trans_currency_amt(
                                            p_amount_tab(i) * p_rate_tab(i), p_to_currency_tab(i)) ;
*/
                             p_converted_amount_tab(i) :=  round_trans_currency_amt(
                                            p_amount_tab(i) * p_numerator_tab(i)/p_denominator_tab(i), p_to_currency_tab(i)) ;
                             l_done_flag := 'Y';

                             exit;

                          end if;

                      End loop;

                   end if ;

                END IF;

                IF l_done_flag = 'N' then

                   IF ( p_conversion_type_tab(i) = 'User') THEN

                       IF ( p_user_validate_flag_tab(i) = 'Y') THEN

                           l_allow_user_rate_type := pa_multi_currency.is_user_rate_type_allowed (
                                                p_from_currency_tab(i),
                                                p_to_currency_tab(i) ,
                                                NVL(p_conversion_date_tab(i),sysdate))  ;

                           IF ( l_allow_user_rate_type = 'Y')  then

                              p_converted_amount_tab(i) := round_trans_currency_amt
                                                           (p_amount_tab(i) * NVL(p_rate_tab(i),1),
                                                               p_to_currency_tab(i)) ;
                              p_denominator_tab(i) := 1 ;
                              p_numerator_tab(i)   := NVL(p_rate_tab(i),1) ;

                              IF p_cache_flag = 'Y' then

                                 l_AttrTab_count := l_AttrTab_Count + 1;
                                 CurrAttrTab(l_AttrTab_Count).conv_between :=  p_conversion_between;
                                 CurrAttrTab(l_AttrTab_Count).from_currency :=  p_from_currency_tab(i);
                                 CurrAttrTab(l_AttrTab_Count).to_currency :=  p_to_currency_tab(i);
                                 CurrAttrTab(l_AttrTab_Count).rate :=  nvl(p_rate_tab(i),1);
                                 CurrAttrTab(l_AttrTab_Count).numerator := p_numerator_tab(i);
				 CurrAttrTab(l_AttrTab_Count).conv_date := p_conversion_date_tab(i); /* Code added for bug 5907315 */
                                 CurrAttrTab(l_AttrTab_Count).denominator := 1 ;

                              END IF;

                           ELSE

                               x_status_tab(i) := 'PA_USR_RATE_NOT_ALLOWED_' || p_conversion_between;


                           END IF;

                       ELSE

                          p_converted_amount_tab(i) := round_trans_currency_amt
                              (p_amount_tab(i) * p_rate_tab(i), p_to_currency_tab(i)) ;
                          p_denominator_tab(i) := 1 ;
                          p_numerator_tab(i) := p_rate_tab(i) ;

                          IF p_cache_flag = 'Y' then

                                 l_AttrTab_count := l_AttrTab_Count + 1;
                                 CurrAttrTab(l_AttrTab_Count).conv_between :=  p_conversion_between;
                                 CurrAttrTab(l_AttrTab_Count).from_currency :=  p_from_currency_tab(i);
                                 CurrAttrTab(l_AttrTab_Count).to_currency :=  p_to_currency_tab(i);
                                 CurrAttrTab(l_AttrTab_Count).rate :=  p_rate_tab(i);
                                 CurrAttrTab(l_AttrTab_Count).numerator := p_numerator_tab(i);
				 CurrAttrTab(l_AttrTab_Count).conv_date := p_conversion_date_tab(i); /* Code added for bug 5907315 */
                                 CurrAttrTab(l_AttrTab_Count).denominator := 1 ;

                          END IF;

                       END IF;

                   ELSE

                       p_conversion_date_tab(i) := NVL(p_conversion_date_tab(i), sysdate);
                       l_converted_amount := GL_CURRENCY_API.convert_amount_sql
                                             (  p_from_currency_tab(i)      ,
                                                p_to_currency_tab(i)        ,
                                                p_conversion_date_tab(i)    ,
                                                p_conversion_type_tab(i)    ,
                                                p_amount_tab(i)            )  ;

                        IF ( l_converted_amount = -1 ) THEN

                            x_status_tab(i) := 'PA_NO_EXCH_RATE_EXISTS_'|| p_conversion_between;

                        ELSIF ( l_converted_amount = -2 ) THEN

                            x_status_tab(i) := 'PA_CURR_NOT_VALID_' || p_conversion_between;

                        ELSE

                            p_converted_amount_tab(i) := l_converted_amount ;


                            l_numerator :=  GL_CURRENCY_API.get_rate_numerator_sql(
                                           p_from_currency_tab(i),
                                           p_to_currency_tab(i),
                                           p_conversion_date_tab(i),
                                           p_conversion_type_tab(i) );

                            p_numerator_tab(i) := l_numerator ;

                            l_denominator :=  GL_CURRENCY_API.get_rate_denominator_sql(
                                             p_from_currency_tab(i),
                                             p_to_currency_tab(i),
                                             p_conversion_date_tab(i),
                                             p_conversion_type_tab(i) );

                            p_denominator_tab(i) := l_denominator ;

                            -- Get conversion rate by using the x_numerator and x_denominator

                            IF (( p_numerator_tab(i) > 0 ) AND ( p_denominator_tab(i) > 0 )) THEN

                                p_rate_tab(i) := round(p_numerator_tab(i) / p_denominator_tab(i),20);

                                IF p_cache_flag = 'Y' then

                                   l_AttrTab_count := l_AttrTab_Count + 1;
                                   CurrAttrTab(l_AttrTab_Count).conv_between :=  p_conversion_between;
                                   CurrAttrTab(l_AttrTab_Count).from_currency :=  p_from_currency_tab(i);
                                   CurrAttrTab(l_AttrTab_Count).to_currency :=  p_to_currency_tab(i);
                                   CurrAttrTab(l_AttrTab_Count).rate :=  p_rate_tab(i);
                                   CurrAttrTab(l_AttrTab_Count).numerator := p_numerator_tab(i);
				   CurrAttrTab(l_AttrTab_Count).conv_date := p_conversion_date_tab(i); /* Code added for bug 5907315 */
                                   CurrAttrTab(l_AttrTab_Count).denominator := p_denominator_tab(i) ;

                                END IF;

                            ELSE

                                IF (( p_numerator_tab(i) = -2 ) OR
                                         (p_denominator_tab(i) = -2 )) THEN

                                    x_status_tab(i) := 'PA_CURR_NOT_VALID_' || p_conversion_between;

                                ELSE

                                    x_status_tab(i) := 'PA_NO_EXCH_RATE_EXISTS_' || p_conversion_between;

                                END IF;

                            END IF;

                        END IF ;

                   END IF;

                END IF ;

             END IF ;

         END LOOP;

   EXCEPTION

        WHEN others THEN
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => 'PA_MULTI_CURRENCY_BILLING',
                    p_procedure_name   => 'convert_amount_bulk');

             RAISE ;

   END convert_amount_bulk;

/*----------------------------------------------------------------------------------------+
|   Procedure  :   init_cache                                                             |
|   Purpose    :   This procedure sets the rounding precision attributes of a project for |
|                  project, project functional, invoice revenue processing currency       |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                             Mode    Description                                |
|     ==================================================================================  |
|     p_project_id                     IN      Project ID                                 |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/
   PROCEDURE init_cache (p_project_id IN NUMBER) IS


        l_prectab_count                 NUMBER;

        l_CurrCodeTab                   PA_PLSQL_DATATYPES.Char30TabTyp;
        l_MauTab                        PA_PLSQL_DATATYPES.NumTabTyp;
        l_SpTab                         PA_PLSQL_DATATYPES.NumTabTyp;
        l_EpTab                         PA_PLSQL_DATATYPES.NumTabTyp;

        lv_found_flag                    VARCHAR2(1);

        cursor prec_info is
           SELECT FC.Currency_Code currency_code,
                  FC.Minimum_Accountable_Unit mau,
                  FC.Precision sp,
                  FC.Extended_Precision ep
           FROM FND_CURRENCIES FC
           WHERE  EXISTS
                (SELECT null FROM
                 pa_projects_all pr
                 where pr.project_id = p_project_id AND
                 fc.currency_code in (pr.project_currency_code,
                                            pr.projfunc_currency_code)
                UNION
                SELECT null from
                PA_SUMMARY_PROJECT_FUNDINGS spf
                WHERE project_id = p_project_id
                 AND  spf.funding_currency_code = fc.currency_code
                 AND spf.total_baselined_amount <> 0 )
           ORDER BY currency_code;

   BEGIN

       CurrAttrTab.delete;
       l_prectab_count := CurrPrecTab.count;

       OPEN prec_info;

       LOOP
          FETCH prec_info BULK COLLECT INTO l_CurrCodeTab,
                                            l_MauTab, l_SpTab, l_EpTab;
          IF l_CurrCodeTab.COUNT =0 THEN

             EXIT;

          END IF;

          for i in l_CurrCodeTab.first..l_CurrCodeTab.Last loop

              lv_found_flag := 'N';

              IF CurrPrecTab.Count <> 0 then

                 for j in CurrPrecTab.first..CurrPrecTab.Last loop

                     if l_CurrCodeTab(i) = CurrPrecTab(j).curr_code then

                        lv_found_flag := 'Y';

                        exit;

                     end if;

                 END LOOP;

              end if;

              if lv_found_flag = 'N' then

                 l_prectab_count := l_prectab_count  + 1;

                 CurrPrecTab(l_prectab_count).curr_code := l_CurrCodeTab(i);
                 CurrPrecTab(l_prectab_count).mau       := l_MauTab(i);
                 CurrPrecTab(l_prectab_count).sp        := l_SpTab(i);
                 CurrPrecTab(l_prectab_count).ep        := l_EpTab(i);

              end if;

          END LOOP;

          l_CurrCodeTab.delete;
          l_MauTab.delete;
          l_SpTab.delete;
          l_EpTab.delete;

       END LOOP;

   END init_cache;

/*----------------------------------------------------------------------------------------+
|   Procedure  :   get_trans_currency_info                                                |
|   Purpose    :   This procedure gets the rounding precision attributes of a currency    |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                             Mode    Description                                |
|     ==================================================================================  |
|     p_curr_code                      IN      Currency Code                              |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/
   PROCEDURE Get_Trans_Currency_Info (p_curr_code IN varchar2, x_mau out NOCOPY number,
                               x_sp out NOCOPY number, x_ep out NOCOPY  number) IS
   BEGIN

       SELECT FC.Minimum_Accountable_Unit,
           FC.Precision,
           FC.Extended_Precision
       INTO x_mau,
            x_sp,
            x_ep
       FROM FND_CURRENCIES FC
       WHERE FC.Currency_Code = p_curr_code;

   END Get_Trans_Currency_Info;


/*----------------------------------------------------------------------------------------+
|   Function   :   round_trans_currency_amt                                               |
|   Purpose    :   The round_trans_currency_amt returns the round off amount based on the |
|                  currency code                                                          |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                             Mode    Description                                |
|     ==================================================================================  |
|     p_amount                         IN      The amount to be rounded                   |
|     p_curr_code                      IN      Currency Code                              |
|     ==================================================================================  |
|   Returns    :  Number
+----------------------------------------------------------------------------------------*/
   FUNCTION round_trans_currency_amt ( p_amount  IN NUMBER,
                                       p_Curr_Code IN VARCHAR2 ) RETURN NUMBER
   IS

     l_mau           fnd_currencies.minimum_accountable_unit%TYPE;
     l_sp            fnd_currencies.precision%TYPE;
     l_ep            fnd_currencies.extended_precision%TYPE;

     l_prectab_count                 NUMBER;
     l_found_flag                    VARCHAR2(1):= 'F';

   BEGIN

       l_found_flag := 'F';

       l_prectab_count := CurrPrecTab.count;

       IF CurrPrecTab.Count <> 0 then

          FOR i in CurrPrecTab.first..CurrPrecTab.last loop

              if CurrPrecTab(i).curr_code = p_Curr_Code then

                 l_found_flag := 'T';
                 l_mau := CurrPrecTab(i).mau;
                 l_sp  := CurrPrecTab(i).sp ;
                 l_ep  := CurrPrecTab(i).ep ;

                 exit;

              end if;

          end loop;

       end if;

       if l_found_flag = 'F' THEN

          l_prectab_count := l_prectab_count  + 1;

          Get_Trans_Currency_Info(
            p_curr_code     => p_curr_code,
            x_mau           => l_mau,
            x_sp            => l_sp,
            x_ep            => l_ep);

          CurrPrecTab(l_prectab_count).curr_code := p_curr_code;
          CurrPrecTab(l_prectab_count).mau       := l_mau;
          CurrPrecTab(l_prectab_count).sp        := l_sp;
          CurrPrecTab(l_prectab_count).ep        := l_ep;

       end if;

       IF l_mau IS NOT NULL THEN

          IF l_mau < 0.00001 THEN
            RETURN( round(p_Amount, 5));
          ELSE
            RETURN( round(p_Amount/l_mau) * l_mau );
          END IF;

       ELSIF l_sp IS NOT NULL THEN

          IF l_sp > 5 THEN
            RETURN( round(p_Amount, 5));
          ELSE
            RETURN( round(p_Amount, l_sp));
          END IF;

       ELSE

            RETURN( round(p_Amount, 5));

       END IF;

   END round_trans_currency_amt;


   Function check_mcb_trans_exist (p_project_id IN NUMBER) return varchar2 is

      l_baseline_amount       number;

      lv_return_flag          varchar2(1);


   BEGIN

       lv_return_flag := 'N';
       -- check to see if any non zero baselined funding records exists

       SELECT sum(nvl(allocated_amount,0))
       INTO   l_baseline_amount
       FROM  PA_PROJECT_FUNDINGS P
       WHERE P.PROJECT_ID   = p_project_id
       AND budget_type_code = 'BASELINE';

       if l_baseline_amount <> 0 then

          lv_return_flag := 'Y';
          return (lv_return_flag);

       end if;

       -- check to see if any draft funding records exists

       begin

/* Modified the code for bug 3686650
             SELECT 'Y' into lv_return_flag
             FROM  PA_PROJECT_FUNDINGS P
             WHERE P.PROJECT_ID   = p_project_id
             AND budget_type_code = 'DRAFT';
*/
             SELECT 'Y' into lv_return_flag FROM dual
              WHERE exists
                (SELECT project_id
                   FROM pa_project_fundings
                  WHERE project_id = p_project_id
                    AND budget_type_code = 'DRAFT');

             return (lv_return_flag);

       exception

              when others then

                  lv_return_flag := 'N';

       end;

       -- check to see if any Event records exists

       begin

             SELECT 'Y' into lv_return_flag from dual
             where exists
                    (select project_id
                     from pa_events
                     where project_id = p_project_id);

             return (lv_return_flag);

       exception

              when others then

                  lv_return_flag := 'N';

       end;

       -- check to see if any EI records exists

       begin

/*Commented for bug 3088683
             SELECT 'Y' into lv_return_flag from dual
             where exists
                    (select T.project_id
                     from pa_expenditure_items_all E, pa_tasks T
                     where T.project_id = p_project_id
                     and  E.task_id = T.task_id);
End of comment for bug 3088683 */

/*Added for bug 3088683 */

             SELECT 'Y' into lv_return_flag from dual
             where exists
                    (select E.project_id
                     from pa_expenditure_items_all E
                     where E.project_id = p_project_id);

/*End of change  for bug 3088683 */

             return (lv_return_flag);

       exception

              when others then

                  lv_return_flag := 'N';

       end;

       return (lv_return_flag);

   EXCEPTION

      when others then

           return 'Y';

   END check_mcb_trans_exist;

   PROCEDURE get_project_types_dflt(
           p_project_type           IN    VARCHAR2,
           x_baseline_flag          OUT NOCOPY   VARCHAR2,
           x_nl_rt_sch_id           OUT NOCOPY   NUMBER,
           x_nl_rt_sch_name         OUT NOCOPY   VARCHAR2,
           x_rate_sch_currency_code OUT NOCOPY VARCHAR2 ) IS


          cursor cur_proj_types IS
          SELECT ppt.baseline_funding_flag
                 ,ppt.NON_LAB_STD_BILL_RT_SCH_ID
                 ,brs.std_bill_rate_schedule
                 ,brs.rate_sch_currency_code
          FROM   pa_project_types ppt, pa_std_bill_rate_schedules brs
          WHERE  ppt.project_type = p_project_type
          AND    ppt.non_lab_std_bill_rt_sch_id = brs.bill_rate_sch_id(+);

   BEGIN



        OPEN cur_proj_types;
        FETCH cur_proj_types INTO x_baseline_flag, x_nl_rt_sch_id,
                                  x_nl_rt_sch_name, x_rate_sch_currency_code;
        CLOSE cur_proj_types;

  /* Added the below for NOCOPY mandate */
   EXCEPTION WHEN OTHERS THEN
     x_baseline_flag := NULL;
     x_nl_rt_sch_id := NULL;
     x_nl_rt_sch_name := NULL;
     x_rate_sch_currency_code := NULL;
     raise;
   END get_project_types_dflt;


   FUNCTION check_cross_ou_fund_exist RETURN VARCHAR2 IS

         lv_return_flag          varchar2(1);

   BEGIN

        SELECT 'Y' INTO lv_return_flag FROM DUAL
        WHERE EXISTS ( SELECT  spf.project_id
                       FROM    pa_summary_project_fundings spf, pa_agreements a,
                               pa_projects_all P
                       WHERE   spf.agreement_id = a.agreement_id
                       AND     spf.project_id = p.project_id
                       AND     a.org_id <> p.org_id);


        RETURN (lv_return_flag);

   EXCEPTION

        WHEN OTHERS THEN

             lv_return_flag := 'N';
             RETURN (lv_return_flag);

   END check_cross_ou_fund_exist;


   FUNCTION check_cross_ou_billrate_exist RETURN VARCHAR2 IS

         lv_return_flag          varchar2(1);

   BEGIN

        SELECT 'Y' INTO lv_return_flag FROM DUAL
        WHERE EXISTS (SELECT p.project_type_id
                      FROM pa_std_bill_rate_schedules_all br, pa_project_types p
                      WHERE ( p.job_bill_rate_schedule_id = br.BILL_RATE_SCH_ID
                              AND  NVL(p.org_id,-99) <> NVL(br.org_id,-99))
                      OR    ( p.emp_bill_rate_schedule_id = br.BILL_RATE_SCH_ID
                              AND  NVL(p.org_id,-99) <> NVL(br.org_id,-99))
                      OR    ( p.non_lab_std_bill_rt_sch_id = br.BILL_RATE_SCH_ID
                              AND  NVL(p.org_id,-99) <> NVL(br.org_id,-99)));

        RETURN (lv_return_flag);

   EXCEPTION

        WHEN OTHERS THEN

             BEGIN

                 SELECT 'Y' INTO lv_return_flag FROM DUAL
                 WHERE EXISTS (SELECT p.project_id
                               FROM pa_std_bill_rate_schedules_all br, pa_projects p
                               WHERE ( p.job_bill_rate_schedule_id = br.BILL_RATE_SCH_ID
                                       AND  NVL(p.org_id,-99) <> NVL(br.org_id,-99))
                               OR    ( p.emp_bill_rate_schedule_id = br.BILL_RATE_SCH_ID
                                       AND  NVL(p.org_id,-99) <> NVL(br.org_id,-99))
                               OR    ( p.non_lab_std_bill_rt_sch_id = br.BILL_RATE_SCH_ID
                                       AND  NVL(p.org_id,-99) <> NVL(br.org_id,-99)));

                 RETURN (lv_return_flag);

             EXCEPTION

                  WHEN OTHERS THEN

                       BEGIN

/* Fix for Performance bug 4939354

                            SELECT 'Y' INTO lv_return_flag FROM DUAL
                            WHERE EXISTS (SELECT p.project_id
                                          FROM pa_std_bill_rate_schedules_all br, pa_projects p,
                                               pa_tasks t
                                          WHERE  p.project_id = t.project_id
                                          AND   (    ( t.job_bill_rate_schedule_id = br.BILL_RATE_SCH_ID
                                                       AND  NVL(p.org_id,-99) <> NVL(br.org_id,-99))
                                                  OR ( t.emp_bill_rate_schedule_id = br.BILL_RATE_SCH_ID
                                                       AND  NVL(p.org_id,-99) <> NVL(br.org_id,-99))
                                                  OR ( t.non_lab_std_bill_rt_sch_id = br.BILL_RATE_SCH_ID
                                                       AND  NVL(p.org_id,-99) <> NVL(br.org_id,-99))));
*/
                            SELECT 'Y' INTO lv_return_flag FROM DUAL
                            WHERE EXISTS (SELECT p.project_id
                                          FROM  pa_projects p, pa_tasks t
                                          WHERE  p.project_id = t.project_id
                                          AND EXISTS
                                              (select null
                                               FROM pa_std_bill_rate_schedules_all br
                                               WHERE (  (t.job_bill_rate_schedule_id = br.BILL_RATE_SCH_ID
                                                         AND  NVL(p.org_id,-99) <> NVL(br.org_id,-99))
                                                      OR ( t.emp_bill_rate_schedule_id = br.BILL_RATE_SCH_ID
                                                           AND  NVL(p.org_id,-99) <> NVL(br.org_id,-99))
                                                      OR ( t.non_lab_std_bill_rt_sch_id = br.BILL_RATE_SCH_ID
                                                           AND  NVL(p.org_id,-99) <> NVL(br.org_id,-99))
                                                     )));

                            RETURN (lv_return_flag);

                       EXCEPTION

                           WHEN OTHERS THEN

                                lv_return_flag := 'N';
                                RETURN (lv_return_flag);
                       END;
             END;

   END check_cross_ou_billrate_exist;

   Function is_baseline_funding_enabled (p_project_id IN NUMBER) return varchar2 is

      lv_baseline_flag      VARCHAR2(1);

   begin

       select baseline_funding_flag into lv_baseline_flag
       from pa_projects_all
       where project_id = p_project_id;

       return lv_baseline_flag;

   exception

       when others then

             return 'N';

   end is_baseline_funding_enabled;

   FUNCTION proj_cust_curr( p_project_id VARCHAR2,
                            p_curr_code VARCHAR2 ) return VARCHAR2
   is

         CURSOR cur_proj_cust IS
                SELECT 'x'
                FROM pa_project_customers
                WHERE INV_CURRENCY_CODE = p_curr_code
                AND project_id = p_project_id;

         v_dummy_char VARCHAR2(1);
   begin

        open cur_proj_cust;
        fetch cur_proj_cust into v_dummy_char;

        IF cur_proj_cust%FOUND THEN
           CLOSE cur_proj_cust;
           RETURN 'N';
        ELSE
           CLOSE cur_proj_cust;
           RETURN 'Y';
        END IF;
   end proj_cust_curr;

----------------------------------------------------------------------------------
-- Purpose:  This function will return value 'Y' if Project Functional Currency
--           is not the same as that of invoice currency.
--
-- Inputs: Project_ID and Project_Functional_Currency_Code
----------------------------------------------------------------------------------
FUNCTION MCB_Flag_Required(
  P_Project_ID          IN  PA_PROJECTS_ALL.Project_ID%TYPE,
  P_PFC_Currency_Code   IN  PA_PROJECTS_ALL.ProjFunc_Currency_Code%TYPE
)
RETURN VARCHAR2
IS

l_Flag VARCHAR2(1);
BEGIN
  -- Check whether the given Project has any Project Customers with
  --  different currency code, other than the Given Currency Code
  BEGIN
    SELECT 'Y'
    INTO   l_Flag
    FROM   Dual
    WHERE  Exists ( SELECt 1 FROM PA_Project_Customers
                    WHERE  Project_ID        = p_Project_ID
                    AND    Inv_Currency_Code <> p_pfc_Currency_Code);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_Flag := 'N';
  END;

  -- Check whether the given Project has any Invoice transactions having
  -- different currency code, other than the Given Currency Code
  IF l_Flag = 'N'
  THEN
    BEGIN
      SELECT 'Y'
      INTO   l_Flag
      FROM   Dual
      WHERE  Exists ( SELECT 1 FROM PA_Draft_Invoices_All
                      WHERE  Project_ID        = p_Project_ID
                      AND    Inv_Currency_Code <> p_pfc_Currency_Code);
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_Flag := 'N';
    END;
  END IF;

  RETURN l_Flag ; -- Return 'Y' if yes else 'N' if No, after checking above conditions

END MCB_Flag_Required;


FUNCTION get_currency( P_org_id IN pa_implementations_all.org_id%TYPE)
   RETURN VARCHAR2
IS

BEGIN

   return( G_Curr_Tab(P_org_id));

EXCEPTION WHEN others THEN
   raise;
END get_currency;


   FUNCTION Check_update_ou_mcb_flag RETURN VARCHAR2 IS

         lv_return_flag          varchar2(1);
	 /* Added local variable l_currency_code for bug 2872748 */
	 l_currency_code	 fnd_currencies.currency_code%TYPE;
   BEGIN

     /* Code addition for bug 2872748 starts */
     begin
       select pa_currency.get_currency_code
       into   l_currency_code
       from dual ;
     end;
     /* Code addition for bug 2872748 ends */

        SELECT 'N' INTO lv_return_flag FROM DUAL
        WHERE EXISTS ( SELECT  a.agreement_id
                       FROM    pa_agreements a
                       WHERE   a.agreement_currency_code <> l_currency_code);
     /* for bug 2872748 replaced pa_currency.get_currency_code with l_currency_code in above sql */

        RETURN (lv_return_flag);

   EXCEPTION

        WHEN OTHERS THEN

             BEGIN

                 SELECT 'N' INTO lv_return_flag FROM DUAL
                 WHERE EXISTS ( SELECT  b.bill_rate_sch_id
/*   Commented for bug 2867740
			        FROM    pa_bill_rates b
                                WHERE   b.RATE_CURRENCY_CODE <> pa_currency.get_currency_code);   */
/* Bug fix for bug 2867740 Starts Here */
				FROM    pa_std_bill_rate_schedules b
                                WHERE   b.RATE_SCH_CURRENCY_CODE <> pa_currency.get_currency_code);
/* Bug fix for bug 2867740 Ends Here */
                 RETURN (lv_return_flag);
             EXCEPTION

                 WHEN OTHERS THEN

                      lv_return_flag := 'Y';
                      RETURN (lv_return_flag);
             END;


   END Check_update_ou_mcb_flag;

   Function check_mcb_setup_exists (p_project_id IN NUMBER) return varchar2 is

      lv_return_flag          varchar2(1);
      lv_projfunc_currency    varchar2(15);

   BEGIN
       lv_return_flag := 'N';

       SELECT projfunc_currency_code into lv_projfunc_currency
       FROM pa_projects
       WHERE project_id = p_project_id;

       BEGIN
           SELECT 'Y' into lv_return_flag from dual
           where exists (select null
                         from pa_billing_assignments asg
/*                         where nvl(asg.project_id,-99) = p_project_id         Bug 2702200 Modified on 20/12/2002*/
                         where asg.project_id = p_project_id
			 and   asg.project_id IS NOT NULL
                         and asg.rate_override_currency_code <> lv_projfunc_currency);
            RETURN (lv_return_flag);

       EXCEPTION
            WHEN OTHERS THEN
                lv_return_flag := 'N';
       END;

       BEGIN
           SELECT 'Y' into lv_return_flag from dual
           where exists (select null
                         FROM pa_job_bill_rate_overrides jbr
/*                         where nvl(jbr.project_id,-99) = p_project_id        Bug 2702200 Modified on 20/12/2002 */
 			 where jbr.project_id = p_project_id
			 and   jbr.project_id IS NOT NULL
                         and jbr.rate_currency_code <> lv_projfunc_currency);

            RETURN (lv_return_flag);

       EXCEPTION
            WHEN OTHERS THEN
                lv_return_flag := 'N';
       END;

       BEGIN
           SELECT 'Y' into lv_return_flag from dual
           where exists (select null
                         FROM pa_nl_bill_rate_overrides nlr
/*                         where nvl(nlr.project_id,-99) = p_project_id      Bug 2702200 Modified on 20/12/2002 */
                         where nlr.project_id = p_project_id
			 and nlr.project_id IS NOT NULL
                         and nlr.rate_currency_code <> lv_projfunc_currency);

            RETURN (lv_return_flag);

       EXCEPTION
            WHEN OTHERS THEN
                lv_return_flag := 'N';
       END;


       BEGIN
           SELECT 'Y' into lv_return_flag from dual
           where exists (select null
                         FROM pa_emp_bill_rate_overrides emp
/*                         where nvl(emp.project_id,-99) = p_project_id         Bug 2702200 Modified on 20/12/2002 */
			 where emp.project_id = p_project_id
			 and emp.project_id IS NOT NULL
                         and emp.rate_currency_code <> lv_projfunc_currency);

            RETURN (lv_return_flag);

       EXCEPTION
            WHEN OTHERS THEN
                lv_return_flag := 'N';
       END;


       BEGIN
           SELECT 'Y' into lv_return_flag from dual
           where exists (select null
                         FROM   PA_STD_BILL_RATE_SCHEDULES_all br, pa_projects p
                         where p.project_id = p_project_id
                         and br.BILL_RATE_SCH_ID in
                               (nvl(p.job_bill_rate_schedule_id,-99),
                                nvl(p.emp_bill_rate_schedule_id,-99),
                                nvl(p.non_lab_std_bill_rt_sch_id,-99))
                         and br.RATE_SCH_CURRENCY_CODE <> lv_projfunc_currency);

            RETURN (lv_return_flag);

       EXCEPTION
            WHEN OTHERS THEN
                lv_return_flag := 'N';
      END;
--- task level overrides


       BEGIN
           SELECT 'Y' into lv_return_flag from dual
           where exists (select null
                         from pa_billing_assignments asg, pa_tasks t
                         where t.project_id = p_project_id
/*                         and nvl(asg.top_task_id,-99) = t.task_id   Bug 2702200 Modified on 20/12/2002 */
			 and asg.top_task_id = t.task_id
                         and asg.project_id  = t.project_id  -- added for bug 3517177
			 and asg.top_task_id IS NOT NULL
                         and asg.rate_override_currency_code <>lv_projfunc_currency);

            RETURN (lv_return_flag);

       EXCEPTION
            WHEN OTHERS THEN
                lv_return_flag := 'N';
       END;

       BEGIN
           SELECT 'Y' into lv_return_flag from dual
           where exists (select null
                         FROM pa_job_bill_rate_overrides jbr, pa_tasks t
                         where t.project_id = p_project_id
/*                         and nvl(jbr.task_id,-99) = t.task_id        Bug 2702200 Modified on 20/12/2002 */
			 and jbr.task_id = t.task_id
			 and jbr.task_id IS NOT NULL
                         and jbr.rate_currency_code <> lv_projfunc_currency);

            RETURN (lv_return_flag);

       EXCEPTION
            WHEN OTHERS THEN
                lv_return_flag := 'N';
       END;

       BEGIN
           SELECT 'Y' into lv_return_flag from dual
           where exists (select null
                         FROM pa_nl_bill_rate_overrides nlr, pa_tasks t
                         where t.project_id = p_project_id
/*                         and nvl(nlr.task_id,-99) = t.task_id          Modifed on 20/12/2002 */
			 and nlr.task_id = t.task_id
			 and nlr.task_id IS NOT NULL
                         and nlr.rate_currency_code <> lv_projfunc_currency);

            RETURN (lv_return_flag);

       EXCEPTION
            WHEN OTHERS THEN
                lv_return_flag := 'N';
       END;


       BEGIN
           SELECT 'Y' into lv_return_flag from dual
           where exists (select null
                         FROM pa_emp_bill_rate_overrides emp, pa_tasks t
                         where t.project_id = p_project_id
/*                         and nvl(emp.task_id,-99) = t.task_id             Modifed on 20/12/2002*/
			 and emp.task_id = t.task_id
			 and emp.task_id IS NOT NULL
                         and emp.rate_currency_code <> lv_projfunc_currency);

            RETURN (lv_return_flag);

       EXCEPTION
            WHEN OTHERS THEN
                lv_return_flag := 'N';
       END;


       BEGIN
           SELECT 'Y' into lv_return_flag from dual
           where exists (select null
                         FROM   PA_STD_BILL_RATE_SCHEDULES_all br, pa_tasks t
                         where t.project_id = p_project_id
                         and br.BILL_RATE_SCH_ID in
                               (nvl(t.job_bill_rate_schedule_id,-99),
                                nvl(t.emp_bill_rate_schedule_id,-99),
                                nvl(t.non_lab_std_bill_rt_sch_id, -99))
                         and br.RATE_SCH_CURRENCY_CODE <> lv_projfunc_currency);

            RETURN (lv_return_flag);

       EXCEPTION
            WHEN OTHERS THEN
                lv_return_flag := 'N';
      END;

      return (lv_return_flag);

   EXCEPTION

       WHEN OTHERS THEN
           lv_return_flag := 'N';
           return (lv_return_flag);

   END check_mcb_setup_exists;

/* Added the given below procedure for Enhancement bug 2520222
   It is being called from customer window of project form.
   This procedure will check if the assigned customer is having valid funding lines and
   user is trying to change existing contribution from non zero to zero then it will give error.*/

   Procedure Check_Cust_Funding_Exists(
         p_proj_customer_id         IN    NUMBER,
         p_project_id               IN    NUMBER,
         p_cust_contribution        IN    NUMBER,
         x_return_status            OUT NOCOPY   VARCHAR2,
         x_msg_data                 OUT NOCOPY   VARCHAR2,
         x_msg_count                OUT NOCOPY   NUMBER
         )
IS
  CURSOR C_fund IS
        SELECT 'x'
        FROM    pa_agreements a,
                pa_summary_project_fundings f
        WHERE a.customer_id   = p_proj_customer_id
          AND a.agreement_id  = f.agreement_id
          AND f.project_id    = p_project_id
          AND ( f.total_unbaselined_amount <>0
                OR f.total_baselined_amount <> 0);

   x_funding_exists	VARCHAR2(1):= NULL;
BEGIN

   x_return_status     := 'S'; -- FND_API.G_RET_STS_SUCCESS;

   IF ( p_cust_contribution = 0 ) THEN

     OPEN C_fund;
     FETCH C_fund
     INTO x_funding_exists;
     CLOSE C_fund;

     IF (x_funding_exists IS NOT NULL) THEN
	x_return_status     := 'E'; -- FND_API.G_RET_STS_ERROR;
        x_msg_data          := 'PA_BILL_CUST_CONTR_ZERO';
        x_msg_count         := 1;
     ELSE
	x_return_status     := 'S'; -- FND_API.G_RET_STS_SUCCESS;
     END IF;

   END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status     := 'U'; -- FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data          := SUBSTR(SQLERRM,1,50);
    x_msg_count         := 1;

END Check_Cust_Funding_Exists;

/* till here */

END pa_multi_currency_billing;

/
