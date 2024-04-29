--------------------------------------------------------
--  DDL for Package Body PA_FUND_REVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FUND_REVAL_PVT" AS
   --$Header: PAXFRPPB.pls 120.3.12010000.3 2009/12/15 19:50:25 dlella ship $

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   revaluate_funding                                                      |
   |   Purpose    :   To revaluate funding for a given/range or projects                     |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |                                   If run mode is 'SINGLE' this parameter should  have   |
   |                                   valid  project id. Otherwise NULL/0                   |
   |     p_project_type_id     IN      Project Type ID                                       |
   |     p_from_proj_number    IN      Start Project Number                                  |
   |                                   If run mode is 'RANGE' this parameter will have       |
   |                                   project number/ NULL                                  |
   |     p_to_proj_number      IN      End Project Number                                    |
   |                                   If run mode is 'RANGE' this parameter will have       |
   |                                   project number/ NULL                                  |
   |     p_thru_date           IN      Revaluation Process Date                              |
   |     p_rate_type           IN      Revaluation Rate type                                 |
   |     p_rate_date           IN      Revaluation Rate date                                 |
   |     p_baseline_flag       IN      Baseline flag indicating if the adjustment            |
   |                                    line is to be baselined or not                       |
   |     p_debug_mode          IN      Debug Mode                                            |
   |     p_run_mode            IN      Run mode                                              |
   |                                   Values are 'SINGLE', 'RANGE', 'DELETE'                |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/


   PROCEDURE Revaluate_funding(
             p_project_id        IN    NUMBER,
             p_project_type_id   IN    NUMBER,
             p_from_proj_number  IN    VARCHAR2,
             p_to_proj_number    IN    VARCHAR2,
             p_thru_date         IN    DATE,
             p_rate_type         IN    VARCHAR2	,
             p_rate_date         IN    DATE,
             p_baseline_flag     IN    VARCHAR2,
             p_debug_mode        IN    VARCHAR2,
             p_run_mode          IN    VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS

         l_FromProjNum              VARCHAR2(25);
         l_ToProjNum                VARCHAR2(25);
         l_ProjTypeId               NUMBER;

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;
         l_LogMsg                   VARCHAR2(250);

   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         Initialize;


         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.revaluate_funding-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

            l_LogMsg := 'Parameters : Project Id:' || p_project_id ||
                       ' Project Type Id:' || p_project_type_id ||
                       ' Start Proj No:' || p_from_proj_number ||
                       ' End Proj No:' || p_to_proj_number;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            l_LogMsg :=  'Thru Date:' || to_char(p_thru_date, 'DD-MON-YYYY') ||
                       ' Rate Type:' || p_rate_type ||
                       ' Rate Date:' || p_rate_date ||
                       ' Run Mode:' || p_run_mode ||
                       ' Baseline Flag:' || p_baseline_flag;

            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

         END IF;


         /* Date till which transactions are to be picked */
         G_THRU_DATE := NVL(p_thru_date, SYSDATE);

         /* Exchange rate date for currency conversion */
         G_RATE_DATE := NVL(p_rate_date, G_THRU_DATE);

         /* Exchange rate type for currency conversion */
         G_RATE_TYPE := p_rate_type;

         /* Flag indicating if net adjustment lines are to be baselined */
         G_BASELINE_FLAG := p_baseline_flag;

         /* Flag indicating if revaluation process is being executed. Required for MC triggers
            to determine if conversion is to be done or to be read from PL/SQL tables (populated by
            Revaluation process */
         G_REVAL_FLAG := 'Y';


         l_FromProjNum := p_from_proj_number;
         l_ToProjNum :=   p_to_proj_number;
         l_ProjTypeId :=   p_project_type_id;

         get_start_end_proj_num (
             p_project_id        => p_project_id,
             p_run_mode          => p_run_mode,
             x_from_proj_number  => l_FromProjNum,
             x_to_proj_number    => l_ToProjNum,
             x_Project_type_id   => l_ProjTypeId,
             x_return_status     => l_return_status,
             x_msg_count         => l_msg_count,
             x_msg_data          => l_msg_data) ;

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

            RAISE FND_API.G_EXC_ERROR;

         END IF;

         IF p_run_mode = 'DELETE' THEN

            get_delete_projects(
                p_project_type_id   => l_ProjTypeId,
                p_from_proj_number  => l_FromProjNum,
                p_to_proj_number    => l_ToProjNum,
                p_run_mode          => p_run_mode,
                x_return_status     => l_return_status,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

               RAISE FND_API.G_EXC_ERROR;

            END IF;


         ELSE

            get_rsob_ids(
                x_return_status     => l_return_status,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

               RAISE FND_API.G_EXC_ERROR;

            END IF;

            get_reval_projects(
                p_project_id        => p_project_id,
                p_project_type_id   => l_ProjTypeId,
                p_from_proj_number  => l_FromProjNum,
                p_to_proj_number    => l_ToProjNum,
                p_run_mode          => p_run_mode,
                x_return_status     => l_return_status,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

               RAISE FND_API.G_EXC_ERROR;

            END IF;

         END IF; /* p_run_mode = DELETE */

         G_REVAL_FLAG := 'N';

         IF G_DEBUG_MODE = 'Y' THEN

            pa_debug.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.revaluate_funding-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;


   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK;

             IF G_DEBUG_MODE = 'Y' THEN

                 PA_DEBUG.g_err_stage := 'Expected: ' || l_msg_data ;
                 PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK;
             G_REVAL_FLAG := 'N';

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'Unexpected :' ||l_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             ROLLBACK;
             G_REVAL_FLAG := 'N';
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'Revaluate_funding:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;


   END Revaluate_funding;

   /*----------------------------------------------------------------------------------------+
   |   Procedure   :   validate_project_eligibility                                          |
   |   Purpose     :   To validate eligibility criteria for a given project                  |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_run_mode            IN      Run Mode                                              |
   |     x_eligible_flag       OUT     Indicates if the project meets eligibility criteria   |
   |                                   for revaluation                                       |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE validate_project_eligibility(
             p_project_id        IN    NUMBER,
             p_run_mode          IN    VARCHAR2,
             x_eligible_flag     OUT   NOCOPY VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS

         l_ReasonCode                    VARCHAR2(30);
         l_ReportId                      NUMBER;
         l_ErrorFlag                     VARCHAR2(1) := NULL;

         UNREL_INV_REV_EXIST             EXCEPTION;
         UNBASELINED_REVAL_FUNDS_EXIST   EXCEPTION;

         l_return_status                 VARCHAR2(30) := NULL;
         l_msg_count                     NUMBER       := NULL;
         l_msg_data                      VARCHAR2(250) := NULL;
         l_LogMsg                        VARCHAR2(250);

   BEGIN

         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;
         x_eligible_flag    := 'T';


         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.validate_project_eligibility-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;


         /* check for any unreleased invoices/revenue */

         Check_Unrel_invoice_revenue(
                        p_project_id     =>  p_project_id,
                        x_exist_flag     => l_ErrorFlag,
                        x_reason_code    => l_ReasonCode,
                        x_return_status  => l_return_status,
                        x_msg_count      => l_msg_count,
                        x_msg_data       => l_msg_data) ;

         IF G_DEBUG_MODE = 'Y' THEN

            l_LogMsg := 'Unrel invoice/revenue exists flag : ' || l_ErrorFlag ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

         END IF;

         IF l_ErrorFlag = 'T' THEN

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Unrel invoice/revenue exists flag : ' || l_ReasonCode;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            Insert_distribution_warnings(p_project_id     => p_project_id,
                                    p_reason_code    => l_ReasonCode,
                                    x_return_status  => l_return_status,
                                    x_msg_count      => l_msg_count,
                                    x_msg_data       => l_msg_data) ;


            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

               RAISE FND_API.G_EXC_ERROR;

            ELSE

               RAISE UNREL_INV_REV_EXIST;

            END IF;

         END IF;

         /* check for any unbaselined revaluation adjustment funding lines */

         l_ErrorFlag := Check_reval_unbaselined_funds(p_project_id =>  p_project_id);

         IF G_DEBUG_MODE = 'Y' THEN

            l_LogMsg := 'Unbaselined reval adj lines exists flag : ' || l_ErrorFlag;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

         END IF;

         IF l_ErrorFlag = 'T' THEN

            IF p_run_mode = 'SINGLE' THEN

               Delete_unbaselined_adjmts(p_project_id     => p_project_id,
                                         p_run_mode       => p_run_mode,
                                         x_return_status  => l_return_status,
                                         x_msg_count      => l_msg_count,
                                         x_msg_data       => l_msg_data) ;

               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                  RAISE FND_API.G_EXC_ERROR;

               END IF;

            ELSE

               l_ReasonCode := 'PA_FR_UNBASELINED_FUNDS_EXIST';

               Insert_distribution_warnings(p_project_id     => p_project_id,
                                       p_reason_code    => l_ReasonCode,
                                       x_return_status  => l_return_status,
                                       x_msg_count      => l_msg_count,
                                       x_msg_data       => l_msg_data) ;

               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                  RAISE FND_API.G_EXC_ERROR;

               ELSE

                  RAISE UNBASELINED_REVAL_FUNDS_EXIST;

               END IF;

            END IF;

         END IF;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.validate_project_eligibility-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN UNREL_INV_REV_EXIST THEN
             x_eligible_flag := 'F';

        WHEN UNBASELINED_REVAL_FUNDS_EXIST THEN
             x_eligible_flag := 'F';

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'Validate_project_eligibility:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END validate_project_eligibility;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   get_rsob_ids                                                           |
   |   Purpose    :   To get reporting set of book ids for the primary set of book id        |
   |                  Also sets global flags to indicate if MC is to be processed in AR/PA   |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE get_rsob_ids(
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS


       /* This CURSOR selects all reporting set of books enabled for the primary set of book id
          in PA */

       /* R12 :  Ledger Architecture Changes : The table gl_mc_reporting_options will  obsoleted, replace with
          new table gl_alc_ledger_rships_v and corresponding columns */

       /* CURSOR rsob is SELECT rep.reporting_set_of_books_id reporting_set_of_books_id ,
                             rep.reporting_currency_code, rep.conversion_type
                      FROM   gl_mc_reporting_options rep, pa_implementations imp
                      WHERE  rep.primary_set_of_books_id = imp.set_of_books_id
                      AND    enabled_flag = 'Y'
                      AND    rep.org_id = imp.org_id
                      AND    application_id = 275;  */

          CURSOR rsob is SELECT rep.ledger_id   reporting_set_of_books_id ,
                             rep.currency_code reporting_currency_code,
                             rep.alc_default_conv_rate_type conversion_type
                      FROM   gl_alc_ledger_rships_v rep, pa_implementations imp
                      WHERE  rep.source_ledger_id = imp.set_of_books_id
                      AND    rep.relationship_enabled_flag  = 'Y'
                      AND    (rep.org_id = -99 OR rep.org_id = imp.org_id)
                      AND    rep.application_id = 275;




       /* This CURSOR selects all reporting set of books enabled for the primary set of book id
          in AR */

       /* R12 :  Ledger Architecture Changes : The table gl_mc_reporting_options will  obsoleted, replace with
          new table gl_alc_ledger_rships_v and corresponding columns */


      /*  CURSOR rsob_ar_mc is SELECT rep.reporting_set_of_books_id reporting_set_of_books_id ,
                             rep.reporting_currency_code, rep.conversion_type
                      FROM   gl_mc_reporting_options rep, pa_implementations imp
                      WHERE  rep.primary_set_of_books_id = imp.set_of_books_id
                      AND    enabled_flag = 'Y'
                      AND    rep.org_id = imp.org_id
                      AND    application_id = PA_FUND_REVAL_UTIL.get_ar_application_id;  */


          CURSOR rsob_ar_mc is SELECT rep.ledger_id reporting_set_of_books_id ,
                             rep.currency_code reporting_currency_code,
                             rep.alc_default_conv_rate_type conversion_type
                      FROM   gl_alc_ledger_rships_v  rep, pa_implementations imp
                      WHERE  rep.source_ledger_id  = imp.set_of_books_id
                      AND    rep.relationship_enabled_flag  = 'Y'
                      AND    (rep.org_id = -99 OR rep.org_id = imp.org_id)
                      AND    application_id = PA_FUND_REVAL_UTIL.get_ar_application_id;




       l_return_status               VARCHAR2(30) := NULL;
       l_msg_count                   NUMBER       := NULL;
       l_msg_data                    VARCHAR2(250) := NULL;

       l_LogMsg                      VARCHAR2(250);

       l_EnabledFlag                 VARCHAR2(1);
       l_SobIdIdx                    NUMBER;

   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.get_rsob_ids-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         /* Gets primary set of book id and MRC funding enabled flag */

/*
         SELECT set_of_books_id, nvl(ENABLE_MRC_FOR_FUND_FLAG , 'N')
         into G_SET_OF_BOOKS_ID, G_MRC_FUND_ENABLED_FLAG FROM pa_implementations;
*/

         SELECT set_of_books_id, 'N' -- nvl(REVAL_MRC_FUNDING_FLAG , 'N')
         into G_SET_OF_BOOKS_ID, G_MRC_FUND_ENABLED_FLAG FROM pa_implementations;

        /* Global Flag indicating if AR module is installed */
         G_AR_INSTALLED_FLAG := get_ar_installed;

        /* Global Flag indicating if AR should process only for primary set of books id */
         G_AR_PRIMARY_ONLY := 'N';

        /* Global Flag indicating if PA should process only for primary set of books id */
         G_PRIMARY_ONLY := 'N';

         /* If MRC for funding is not enabled, then only primary set of book id should be processed
            in PA and AR, So set both flags to Y */

         IF G_MRC_FUND_ENABLED_FLAG = 'N' THEN

            G_AR_PRIMARY_ONLY := 'Y';
            G_PRIMARY_ONLY := 'Y';

            /* Populate set of book id list with primary set of book id */
            G_SobListTab(G_set_of_books_id).EnabledFlag := G_AR_INSTALLED_FLAG;


            IF G_SobListTab.COUNT = 0  THEN

               /* No reporting currency is enabled for this OU .
                  Only primary set of books id is to be processed in both ar and PA */
               G_AR_PRIMARY_ONLY := 'Y';
               G_PRIMARY_ONLY := 'Y';
               G_SobListTab(G_set_of_books_id).EnabledFlag := G_AR_INSTALLED_FLAG;

           /* ELSE */

               /* This flag will indicated if AR has atleast one reporting currency enabled for
                  primary set of book id */

               /* Check if the reporting set of book list is enabled in AR also */

               IF l_EnabledFlag = 'N' THEN

                  G_AR_PRIMARY_ONLY := 'Y';
                  -- G_PRIMARY_ONLY := 'N';

               ELSE

                  G_AR_PRIMARY_ONLY := 'N';
                  -- G_PRIMARY_ONLY := 'N';

               END IF;

               G_SobListTab(G_set_of_books_id).EnabledFlag := G_AR_INSTALLED_FLAG;
            END IF;

         END IF;

         IF G_DEBUG_MODE = 'Y' THEN

            l_LogMsg := 'AR installed : ' || G_AR_INSTALLED_FLAG || ' AR primary only :' ||
                          G_AR_PRIMARY_ONLY || ' MRC fund enabled:' || G_MRC_FUND_ENABLED_FLAG  ||
                          ' Primary set of book id :' || G_SET_OF_BOOKS_ID;

            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

         END IF;

         l_SobIdIdx := G_SobListTab.FIRST;

         LOOP

             EXIT WHEN l_SobIdIdx IS NULL;

             IF G_DEBUG_MODE = 'Y' THEN

                l_LogMsg := 'SOB Id:' || l_SobIdIdx || ' enabled flag:' || G_SobListTab(l_SobIdIdx).EnabledFlag ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

             END IF;

             l_SobIdIdx := G_SobListTab.NEXT(l_SobIdIdx);
         END LOOP;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.get_rsob_ids-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'get_rsob_ids:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END get_rsob_ids;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   get_ar_installed                                                       |
   |   Purpose    :   To chekc if ar is installed for primary set of books                   |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   FUNCTION get_ar_installed  RETURN VARCHAR2 IS

       l_ar_installed VARCHAR2(1);

   BEGIN

        l_ar_installed := PA_FUND_REVAL_UTIL.is_ar_installed;

        RETURN l_ar_installed;

   END get_ar_installed;


   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   Get_start_end_proj_num                                                 |
   |   Purpose    :   If project id is given (SINGLE)                                        |
   |                     start/end project number will be the same                           |
   |                  If  it is RANGE and either start/end project number is given, then     |
   |                  min(segment1) or max(segment1) will be assigned respectively           |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_run_mode            IN      Process Mode - SINGLE/RANGE                           |
   |     x_from_proj_number    IN OUT  Start project number                                  |
   |     x_to_proj_number      IN OUT  End project number                                    |
   |     x_project_type_id     IN OUT  Project Type ID                                       |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE get_start_end_proj_num(
             p_project_id        IN     NUMBER,
             p_run_mode          IN     VARCHAR2,
             x_from_proj_number  IN OUT NOCOPY VARCHAR2,
             x_to_proj_number    IN OUT NOCOPY VARCHAR2,
             x_project_type_id   IN OUT    NOCOPY NUMBER,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS


         l_FromProjNum              VARCHAR2(25);
         l_ToProjNum                VARCHAR2(25);
         l_ProjTypeId               NUMBER;

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;
         l_LogMsg                   VARCHAR2(250);


   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.get_start_end_proj_num-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         IF p_run_mode = 'SINGLE' THEN

           SELECT p.segment1, pt.project_type_id
           INTO l_FromProjNum, l_ProjTypeId
           FROM pa_projects p, pa_project_types pt
           WHERE p.project_id = p_project_id
           AND pt.project_type = p.project_type;

           l_ToProjNum := l_FromProjNum;

         ELSE
            l_ProjTypeId := x_project_type_id;

            IF nvl(x_from_proj_number, 'NULL') = 'NULL' THEN

               /*
                 SELECT MIN(P.segment1)
                 INTO l_FromProjNum
                 FROM PA_PROJECTS P , PA_PROJECT_TYPES T
                 WHERE  T.project_type_id (+) = l_ProjTypeId
                 AND    P.Project_type = T.Project_type
                 AND    T.Project_type_class_code = 'CONTRACT';
               */

               /* Commented for performance
               SELECT proj.seg1
               INTO l_FromProjNum
               FROM (
                       SELECT t.project_type_class_code, MIN(P.segment1) seg1
                       FROM PA_PROJECTS P , PA_PROJECT_TYPES T
                       WHERE  T.project_type_id  = NVL(l_ProjTypeId,0)
                       AND    P.Project_type  = T.Project_type
                       AND    T.Project_type_class_code = 'CONTRACT'
                       AND    NVL(l_ProjTypeId,0) <> 0
                       GROUP BY t.project_type_class_code
                       UNION
                       SELECT t.project_type_class_code, MIN(P.segment1) seg1
                       FROM PA_PROJECTS P , PA_PROJECT_TYPES T
                       WHERE P.Project_type  = T.Project_type
                       AND    T.Project_type_class_code = 'CONTRACT'
                       AND nvl(l_ProjTypeId,0) = 0
                        group by t.project_type_class_code
                       )  proj;
               */

               l_FromProjNum := '0';

            ELSE

               l_FromProjNum := x_from_proj_number ;

            END IF;

            IF nvl(x_to_proj_number, 'NULL') = 'NULL' THEN

               /*
                 SELECT MAX(P.segment1)
                 INTO l_ToProjNum
                 FROM PA_PROJECTS P , PA_PROJECT_TYPES T
                 WHERE  T.project_type_id (+) = l_ProjTypeId
                 AND    P.Project_type = T.Project_type
                 AND    T.Project_type_class_code = 'CONTRACT';
               */

               /* Commented for performance
               SELECT proj.seg1
               INTO l_ToProjNum
               FROM (
                       SELECT t.project_type_class_code, MAX(P.segment1) seg1
                       FROM PA_PROJECTS P , PA_PROJECT_TYPES T
                       WHERE  T.project_type_id  = NVL(l_ProjTypeId,0)
                       AND    P.Project_type  = T.Project_type
                       AND    T.Project_type_class_code = 'CONTRACT'
                       AND    NVL(l_ProjTypeId,0) <> 0
                       GROUP BY t.project_type_class_code
                       UNION
                       SELECT t.project_type_class_code, MAX(P.segment1) seg1
                       FROM PA_PROJECTS P , PA_PROJECT_TYPES T
                       WHERE P.Project_type  = T.Project_type
                       AND    T.Project_type_class_code = 'CONTRACT'
                       AND nvl(l_ProjTypeId,0) = 0
                        group by t.project_type_class_code
                       )  proj;
               */

               l_ToProjNum := 'zzzzzzzzzzzzzzzzzzz';
            ELSE

               l_ToProjNum := x_to_proj_number ;

            END IF;

         END IF ;

         x_from_proj_number := l_FromProjNum;
         x_to_proj_number := l_ToProjNum;
         x_project_type_id := l_ProjTypeId;

         IF G_DEBUG_MODE = 'Y' THEN

            l_LogMsg := 'Start Proj No: ' || x_from_proj_number ||
                        ' End Proj No:' || x_to_proj_number ||
                        ' Proj Type Id:' || x_Project_type_id;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.get_start_end_proj_num-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'get_start_end_proj_num:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END get_start_end_proj_num;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   Check_Unrel_invoice_revenue
   |   Purpose    :   To check if the given project_id (SINGLE MODE) has any                 |
   |                  unreleased invoice/revenue transactions                                |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     x_exist_flag          OUT     Flag indicating if unreleased invoice/revenue exists  |
   |                                   'T' or 'F'                                            |
   |     x_reason_code         OUT     If revenue exists - PA_FR_UNREL_REV_EXIST             |
   |                                   If invoice exists - PA_FR_UNREL_INV_EXIST             |
   |                                   If none exists - null                                 |
   |                                   This procedure will first check for revenue then      |
   |                                   invoice                                               |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE Check_Unrel_invoice_revenue (
             p_project_id        IN    NUMBER,
             x_exist_flag        OUT   NOCOPY VARCHAR2,
             x_reason_code       OUT   NOCOPY VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS

        l_ExistFlag        VARCHAR2(1);
        l_return_status             VARCHAR2(30) := NULL;
        l_msg_count                 NUMBER       := NULL;
        l_msg_data                  VARCHAR2(250) := NULL;
        l_LogMsg                   VARCHAR2(250);


   BEGIN

         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;
         x_reason_code      := NULL;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.Check_Unrel_invoice_revenue-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

        /* Check for any unapproved or unreleased invoices */

        BEGIN

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Checking for Unrel Draft Revenues';
               PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

            END IF;

            SELECT 'T' INTO x_exist_flag
            FROM DUAL
            WHERE EXISTS ( SELECT NULL
                       FROM pa_draft_revenues r
                       WHERE r.project_id = p_project_id
                       AND   r.released_date IS NULL);

            x_reason_code := 'PA_FR_UNREL_REV_EXIST';

        EXCEPTION

            WHEN OTHERS THEN

                 x_exist_flag := 'F';
        END;
/*commented the check for unreleased invoice for funding revaluation  for Bug 8874394 */
    /*    IF x_exist_flag = 'F' THEN

           BEGIN

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Checking for Unrel Draft Invoice';
                  PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

               END IF;

               SELECT 'T' INTO x_exist_flag
               FROM DUAL
               WHERE EXISTS ( SELECT NULL
                              FROM   pa_draft_invoices i
                              WHERE  i.project_id = p_project_id
                              and    i.released_by_person_id IS NULL);

               x_exist_flag := 'T';
               x_reason_code := 'PA_FR_UNREL_INV_EXIST';

           EXCEPTION

               WHEN OTHERS THEN

                    x_exist_flag := 'F';
           END;

        END IF;*/

        /* end of comment for bug Bug 8874394 */

        IF G_DEBUG_MODE = 'Y' THEN

           PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.Check_Unrel_invoice_revenue-----------' ;
           PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

        END IF;

   EXCEPTION

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'Check_Unrel_invoice_revenue:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END Check_Unrel_invoice_revenue;


   /*----------------------------------------------------------------------------------------+
   |   FUNCTION  :   Check_reval_unbaselined_funds                                           |
   |   Purpose    :   To check (if any) unbaselined revaluation adjustment lines exist       |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   FUNCTION Check_reval_unbaselined_funds (
             p_project_id        IN    NUMBER) RETURN VARCHAR2  IS


       l_ExistFlag   VARCHAR2(1);

   BEGIN

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.Check_reval_unbaseline_funds-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         SELECT 'T' INTO l_ExistFlag
         FROM DUAL
         WHERE EXISTS (SELECT NULL
                       FROM pa_project_fundings
                       WHERE project_id = p_project_id
                       AND funding_category = 'REVALUATION'
                       AND budget_type_code = 'DRAFT');

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.Check_reval_unbaseline_funds-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         RETURN l_ExistFlag;

   EXCEPTION

        WHEN NO_DATA_FOUND THEN
             RETURN 'F';

   END Check_reval_unbaselined_funds;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   Delete_unbaselined_adjmts                                              |
   |   Purpose    :   To delete (if any) unbaselined revaluation adjutment lines             |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_run_mode            IN      Run Mode - SINGLE,RANGE, DELETE                       |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE Delete_Unbaselined_Adjmts (
             p_project_id        IN    NUMBER,
             p_run_mode          IN    VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS

         CURSOR fund_recs is
                SELECT project_funding_id, agreement_id, project_id, task_id, projfunc_allocated_amount,
                       projfunc_realized_gains_amt, projfunc_realized_losses_amt, invproc_allocated_amount,
                       revproc_allocated_amount
                FROM pa_project_fundings
                WHERE project_id = p_project_id
                AND funding_category = 'REVALUATION'
                AND budget_type_code = 'DRAFT';

         l_FundingIdTab              PA_PLSQL_DATATYPES.IdTabTyp;
         l_AgreementIdTab            PA_PLSQL_DATATYPES.IdTabTyp;
         l_ProjectIdTab              PA_PLSQL_DATATYPES.IdTabTyp;
         l_TaskIdTab                 PA_PLSQL_DATATYPES.IdTabTyp;
         l_ProjfuncAllocTab          PA_PLSQL_DATATYPES.NumTabTyp;
         l_ProjfuncGainsTab          PA_PLSQL_DATATYPES.NumTabTyp;
         l_ProjfuncLossTab           PA_PLSQL_DATATYPES.NumTabTyp;
         l_InvprocAllocTab           PA_PLSQL_DATATYPES.NumTabTyp;
         l_RevprocAllocTab           PA_PLSQL_DATATYPES.NumTabTyp;

         l_ReasonCode                VARCHAR2(30);

         l_TotalFetch                NUMBER := 0;
         l_ThisFetch                 NUMBER := 0;
         l_FetchSize                 NUMBER := 50;

         l_return_status             VARCHAR2(30) := NULL;
         l_msg_count                 NUMBER       := NULL;
         l_msg_data                  VARCHAR2(250) := NULL;
         l_LogMsg                    VARCHAR2(250);

   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.Delete_Unbaselined_Adjmts-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         OPEN fund_recs;
         LOOP
              FETCH fund_recs BULK COLLECT INTO l_FundingIdTab,
                                              l_AgreementIdTab,
                                              l_ProjectIdTab,
                                              l_TaskIdTab,
                                              l_ProjfuncAllocTab,
                                              l_ProjfuncGainsTab,
                                              l_ProjfuncLossTab,
                                              l_InvprocAllocTab,
                                              l_RevprocAllocTab
                            LIMIT l_FetchSize;

              l_ThisFetch := fund_recs%ROWCOUNT - l_TotalFetch;
              l_TotalFetch := fund_recs%ROWCOUNT ;

              IF l_ThisFetch > 0 THEN

                 FORALL i IN l_FundingIdTab.FIRST..l_FundingIdTab.LAST
                        DELETE FROM pa_events
                        WHERE project_funding_id = l_FundingIdTab(i)
			AND   Project_ID         = l_ProjectIdTab(i);

                 FORALL i IN l_FundingIdTab.FIRST..l_FundingIdTab.LAST
                        DELETE FROM pa_project_fundings
                        WHERE project_funding_id = l_FundingIdTab(i);

                 FORALL i IN l_ProjfuncAllocTab.FIRST..l_ProjfuncAllocTab.LAST
                        UPDATE pa_summary_project_fundings
                        SET    projfunc_unbaselined_amount =
                                      nvl(projfunc_unbaselined_amount,0) - nvl(l_ProjfuncAllocTab(i),0),
                               invproc_unbaselined_amount =
                                      nvl(invproc_unbaselined_amount,0) - nvl(l_InvprocAllocTab(i),0),
                               revproc_unbaselined_amount =
                                      nvl(revproc_unbaselined_amount,0) - nvl(l_RevprocAllocTab(i),0),
                               projfunc_realized_gains_amt =
                                      nvl(projfunc_realized_gains_amt,0) - nvl(l_ProjfuncGainsTab(i),0),
                               projfunc_realized_losses_amt =
                                      nvl(projfunc_realized_losses_amt,0) - nvl(l_ProjfuncLossTab(i),0)
                        WHERE agreement_id = l_AgreementIdTab(i)
                        AND   project_id = l_ProjectIdTab(i)
                        AND   nvl(task_id,-99) = nvl(l_TaskIdTab(i),-99);

                 /* Insert the details of project funding line deleted as delete process requires output */

                 IF p_run_mode = 'DELETE' THEN

                    l_ReasonCode := NULL;

                    FOR j IN l_AgreementIdTab.FIRST..l_AgreementIdTab.LAST LOOP

                        Insert_distribution_warnings(
                               p_project_id     => p_project_id,
                               p_task_id        => l_TaskIdTab(j),
                               p_agreement_id   => l_AgreementIdTab(j),
                               p_reason_code    => l_ReasonCode,
                               x_return_status  => l_return_status,
                               x_msg_count      => l_msg_count,
                               x_msg_data       => l_msg_data) ;


                        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                              RAISE FND_API.G_EXC_ERROR;

                        END IF;

                    END LOOP;

                 END IF; /*p_run_mode = 'DELETE' */

              END IF; /* l_ThisFetch > 0 */

              /* Initialize for next fetch */
              l_FundingIdTab.DELETE;
              l_AgreementIdTab.DELETE;
              l_ProjectIdTab.DELETE;
              l_TaskIdTab.DELETE;
              l_ProjfuncAllocTab.DELETE;
              l_ProjfuncGainsTab.DELETE;
              l_ProjfuncLossTab.DELETE;
              l_InvprocAllocTab.DELETE;
              l_RevprocAllocTab.DELETE;

              IF l_ThisFetch < l_FetchSize THEN
                  EXIT;
              END IF;

         END LOOP;
         CLOSE fund_recs;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.Delete_Unbaselined_Adjmts-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'Delete_Unbaselined_Adjmts:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END Delete_Unbaselined_Adjmts;


   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   Insert_distribution_warnings                                                |
   |   Purpose    :   To insert rejection reasons in distribution table                      |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_agreement_id        IN      Agreement ID                                          |
   |     p_task_id             IN      Task id of summary project funding                    |
   |     p_reason_code         IN      Rejection Reason                                      |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE Insert_distribution_warnings(
             p_project_id        IN    NUMBER,
             p_agreement_id      IN    NUMBER DEFAULT NULL,
             p_task_id           IN    NUMBER DEFAULT NULL,
             p_reason_code       IN    VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS


         l_return_status             VARCHAR2(30) := NULL;
         l_msg_count                 NUMBER       := NULL;
         l_msg_data                  VARCHAR2(250) := NULL;

         l_LogMsg                    VARCHAR2(250);
         l_Reason                    VARCHAR2(250);

         CURSOR rej_reason IS SELECT meaning FROM PA_LOOKUPS
                WHERE lookup_type =  'FUNDING REVAL REJECTION'
                AND   lookup_code = p_reason_code;

   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.Insert_distribution_warnings-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

            l_LogMsg := 'Reason :' || p_reason_code;
            PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

         END IF;

         IF p_reason_code IS NOT NULL THEN

            OPEN rej_reason;
            FETCH rej_reason INTO l_reason;
            CLOSE rej_reason;

         END IF;

         INSERT INTO PA_DISTRIBUTION_WARNINGS
         (
              PROJECT_ID, AGREEMENT_ID, TASK_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
              CREATION_DATE, CREATED_BY, REQUEST_ID, PROGRAM_APPLICATION_ID,
              PROGRAM_ID, PROGRAM_UPDATE_DATE, WARNING_MESSAGE_CODE, WARNING_MESSAGE
         )
         VALUES
         (
              p_project_id, p_agreement_id, p_task_id, SYSDATE, G_LAST_UPDATED_BY,
              SYSDATE, G_LAST_UPDATED_BY, G_REQUEST_ID, G_PROGRAM_APPLICATION_ID,
              G_PROGRAM_ID, SYSDATE, p_reason_code, l_reason
         );

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.Insert_distribution_warnings-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'Insert_distribution_warnings:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END Insert_distribution_warnings;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   initialize                                                             |
   |   Purpose    :   To initialize all required params/debug requirements                   |
   +----------------------------------------------------------------------------------------*/


   PROCEDURE Initialize IS

        l_debug_mode VARCHAR2(10);

   BEGIN

         fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
         l_debug_mode := NVL(l_debug_mode, 'N');
         G_DEBUG_MODE := l_debug_mode;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_UTIL.initialize-----------';
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         G_LAST_UPDATE_LOGIN := fnd_global.login_id;
         G_REQUEST_ID := fnd_global.conc_request_id;
         G_PROGRAM_APPLICATION_ID := fnd_global.prog_appl_id;
         G_PROGRAM_ID := fnd_global.conc_program_id;
         G_LAST_UPDATED_BY := fnd_global.user_id;
         G_CREATED_BY :=  fnd_global.user_id;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.Set_Curr_Function( p_function   => 'Funding Revaluation',
                                     p_debug_mode => l_debug_mode             );

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_UTIL.initialize-----------';
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   END initialize;


   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   get_reval_projects                                                     |
   |   Purpose    :   To open all projects eligible for funding revaluation based on         |
   |                  given project numbers                                                  |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_project_type_id     IN      Project Type ID                                       |
   |     p_from_proj_number    IN      Start project number                                  |
   |     p_to_proj_number      IN      End project number                                    |
   |     p_run_mode            IN      Run mode                                              |
   |                                   Values are 'SINGLE', 'RANGE'                          |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE get_reval_projects(
             p_project_id        IN    NUMBER,
             p_project_type_id   IN    NUMBER,
             p_from_proj_number  IN    VARCHAR2,
             p_to_proj_number    IN    VARCHAR2,
             p_run_mode          IN    VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS


       /* This CURSOR selects all projects with the following criteria
              a) should be contract  projects
              b) revaluate_funding_flag is enabled
              c) Falls within the given range start/end project numbers */

         CURSOR open_projects IS
                SELECT P.project_id, P.baseline_funding_flag,
                       P.include_gains_losses_flag include_gains_losses_flag,
                       P.carrying_out_organization_id,
                       P.projfunc_bil_rate_type projfunc_bil_rate_type,
                       P.projfunc_bil_exchange_rate projfunc_bil_exchange_rate,
                       DECODE(P.invproc_currency_type,
                              'PROJECT_CURRENCY', P.project_bil_rate_type,
                              'PROJFUNC_CURRENCY', P.projfunc_bil_rate_type,
                              'FUNDING_CURRENCY', P.funding_rate_type) invproc_rate_type,
                       DECODE(P.invproc_currency_type,
                              'PROJECT_CURRENCY', P.project_bil_exchange_rate,
                              'PROJFUNC_CURRENCY', P.projfunc_bil_exchange_rate,
                              'FUNDING_CURRENCY', P.funding_exchange_rate) invproc_exchange_rate,
                       T.RLZD_GAINS_EVENT_TYPE_ID,
                       T.RLZD_LOSSES_EVENT_TYPE_ID
                FROM pa_projects P, pa_project_types T
                WHERE P.segment1 BETWEEN p_from_proj_number
                               AND p_to_proj_number
                AND   P.PROJECT_TYPE = T.PROJECT_TYPE
                AND   T.DIRECT_FLAG = 'Y'
                AND   T.PROJECT_TYPE_ID  = NVL(P_PROJECT_TYPE_ID ,T.project_type_id)
                AND   NVL(P.revaluate_funding_flag, 'N') = 'Y'
                AND   NVL(P.template_flag, 'N') = 'N'
                ORDER BY segment1 ;

      /* Removed the +join and added NVL to handle it */

         CURSOR get_event_type(l_EventTypeId NUMBER) IS
                SELECT event_type, description from pa_event_types
                WHERE event_type_id  = l_EventTypeId;

         l_EligibleFlag             VARCHAR2(1);
         l_ReasonCode               VARCHAR2(30);
         l_GainEventTypeId          NUMBER;
         l_LossEventTypeId          NUMBER;

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;
         l_ErrCode                  NUMBER       := NULL;
         l_LogMsg                   VARCHAR2(250);

   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.get_reval_projects-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

            l_LogMsg := 'From prj:' || p_from_proj_number ||
                         ' To prj:' || p_to_proj_number ||
                         ' Proj type:' || p_project_type_id ;
            PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

         END IF;


         FOR proj_rec in open_projects LOOP

             /* Checks if project passes eligibility criterion */

             IF G_DEBUG_MODE = 'Y' THEN

                l_LogMsg := 'Project ID :' || proj_rec.project_id ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

             END IF;

             validate_project_eligibility (
                                    p_project_id     => proj_rec.project_id,
                                    p_run_mode       => p_run_mode,
                                    x_eligible_flag  => l_EligibleFlag,
                                    x_return_status  => l_return_status,
                                    x_msg_count      => l_msg_count,
                                    x_msg_data       => l_msg_data);

             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                 RAISE FND_API.G_EXC_ERROR;

             END IF;

             IF G_DEBUG_MODE = 'Y' THEN

                l_LogMsg := 'Reval Eligible :' || l_EligibleFlag ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

             END IF;

             IF l_EligibleFlag = 'T' THEN /* Project is qualified for revaluation */

                /* Initialize all global objects maintained across project/agreement */

                G_InvCompTab.DELETE;
                G_RetnApplAmtTab.DELETE;
                G_RevalCompTab.DELETE;

                PA_MULTI_CURRENCY_BILLING.init_cache(p_project_id => proj_rec.project_id);

                G_ProjLvlGlobRec.project_id := proj_rec.project_id;
                G_ProjLvlGlobRec.carrying_out_organization_id := proj_rec.carrying_out_organization_id;
                G_ProjLvlGlobRec.baseline_funding_flag := proj_rec.baseline_funding_flag;
                G_ProjLvlGlobRec.include_gains_losses_flag := proj_rec.include_gains_losses_flag;
                G_ProjLvlGlobRec.projfunc_bil_rate_type := proj_rec.projfunc_bil_rate_type;
                G_ProjLvlGlobRec.projfunc_bil_exchange_rate := proj_rec.projfunc_bil_exchange_rate;
                G_ProjLvlGlobRec.invproc_rate_type := proj_rec.invproc_rate_type;
                G_ProjLvlGlobRec.invproc_exchange_rate := proj_rec.invproc_exchange_rate;
                G_ProjLvlGlobRec.Zero_dollar_reval_flag := 'Y';
                l_GainEventTypeId := proj_rec.rlzd_gains_event_type_id;
                l_LossEventTypeId := proj_rec.rlzd_losses_event_type_id;

                OPEN get_event_type (l_GainEventTypeId);
                FETCH get_event_type INTO G_ProjLvlGlobRec.gain_event_type, G_ProjLvlGlobRec.gain_event_desc;
                CLOSE get_event_type;

                OPEN get_event_type (l_LossEventTypeId);
                FETCH get_event_type INTO G_ProjLvlGlobRec.loss_event_type, G_ProjLvlGlobRec.loss_event_desc;
                CLOSE get_event_type;

                IF G_DEBUG_MODE = 'Y' THEN

                   l_LogMsg := 'Loss Event type:' || G_ProjLvlGlobRec.loss_event_type ||
                               ' Gain Event type:' ||  G_ProjLvlGlobRec.gain_event_type;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                   l_LogMsg := 'Proj Lvl Baseline Flag :' || G_ProjLvlGlobRec.baseline_funding_flag ||
                               ' Proj Lvl include gains/losses flag :' ||  G_ProjLvlGlobRec.include_gains_losses_flag;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                   l_LogMsg := 'Proj Lvl PFC Rate Type :' || G_ProjLvlGlobRec.projfunc_bil_rate_type ||
                               ' Proj Lvl PFC Exch Rate :' ||  G_ProjLvlGlobRec.projfunc_bil_exchange_rate;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                   l_LogMsg := 'Proj Lvl IPC Rate Type :' || G_ProjLvlGlobRec.invproc_rate_type ||
                               ' Proj Lvl IPC Exch Rate :' ||  G_ProjLvlGlobRec.invproc_exchange_rate;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                END IF;

                get_spf_lines (x_return_status  => l_return_status,
                               x_msg_count      => l_msg_count,
                               x_msg_data       => l_msg_data);

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

                   IF G_ProjLvlGlobRec.Zero_dollar_reval_flag = 'Y' THEN

                      l_ReasonCode := 'PA_FR_NO_REVALUATION';

                      Insert_distribution_warnings(
                             p_project_id     => G_ProjLvlGlobRec.project_id,
                             p_reason_code    => l_ReasonCode,
                             x_return_status  => l_return_status,
                             x_msg_count      => l_msg_count,
                             x_msg_data       => l_msg_data) ;

                      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                            RAISE FND_API.G_EXC_ERROR;

                      END IF;

                   ELSE

                      IF nvl(G_BASELINE_FLAG,'N') = 'Y' AND
                            nvl(G_ProjLvlGlobRec.baseline_funding_flag,'N') = 'Y' THEN

                         IF G_DEBUG_MODE = 'Y' THEN

                            l_LogMsg := 'Calling Baselining';
                            PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

                         END IF;

                         l_ErrCode := 0;


                         PA_BASELINE_FUNDING_PKG.create_budget_baseline (
                                    p_project_id   => G_ProjLvlGlobRec.project_id,
                                    x_err_code     => l_ErrCode,
                                    x_status       => l_msg_data );

                         IF l_ErrCode <> 0 THEN

                            /* Baselining error is handled here b'cos there are no expected
                            error code /messages defined specifically for it. Also dependent
                            on budget model */
                            /*Bug 3986205 : Replaced p_project_id with G_ProjLvlGlobRec.project_id in the following INSERT statement */

                            INSERT INTO PA_DISTRIBUTION_WARNINGS
                            (
                                 PROJECT_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
                                 CREATION_DATE, CREATED_BY, REQUEST_ID, PROGRAM_APPLICATION_ID,
                                 PROGRAM_ID, PROGRAM_UPDATE_DATE, WARNING_MESSAGE_CODE, WARNING_MESSAGE
                            )
                            VALUES
                            (
                                 G_ProjLvlGlobRec.project_id, SYSDATE, G_LAST_UPDATED_BY,
                                 SYSDATE, G_LAST_UPDATED_BY, G_REQUEST_ID, G_PROGRAM_APPLICATION_ID,
                                 G_PROGRAM_ID, SYSDATE, 'BASELINE ERROR', l_msg_data
                            );

                         END IF; /* l_ErrCode <> 0 */

                      END IF; /* nvl(G_BASELINE_FLAG,'N') = 'Y'  */

                   END IF; /* Zero dollar reval flag */

                END IF; /* l_return_status */

                COMMIT; /* Commit all processing for the current project */

             END IF; /* Eligible flag */

         END LOOP ; /* Open_projects*/

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.get_reval_projects-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;


   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'get_reval_projects:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END get_reval_projects;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   get_spf_lines                                                          |
   |   Purpose    :   To get summary project funding lines for a project initialized in      |
   |                  G_ProjLvlGlobRec structure                                             |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE get_spf_lines(
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS

         /* This CURSOR selects the summary project funding lines with non-zero baselined amount
            for the given project in primary set of book id only*/

         CURSOR get_spf_lines (l_ProjectId NUMBER) is
                SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                       SPF.agreement_id   agreement_id,
                       SPF.task_id   task_id,
                       SPF.funding_currency_code funding_currency_code,
                       SPF.project_currency_code project_currency_code,
                       SPF.projfunc_currency_code projfunc_currency_code,
                       SPF.invproc_currency_code invproc_currency_code,
                       SPF.total_baselined_amount total_baselined_amount,
                       SPF.projfunc_baselined_amount projfunc_baselined_amount,
                       SPF.invproc_baselined_amount invproc_baselined_amount,
                       SPF.projfunc_realized_gains_amt projfunc_realized_gains_amt,
                       SPF.projfunc_realized_losses_amt projfunc_realized_losses_amt,
                       SPF.projfunc_accrued_amount projfunc_accrued_amount,
                       SPF.invproc_billed_amount invproc_billed_amount,
                       PC.retention_level_code retention_level_code,
                       PC.customer_id customer_id
                FROM   pa_summary_project_fundings SPF, pa_agreements_all A, pa_project_customers PC
                WHERE  SPF.project_id = l_ProjectId
                AND    A.agreement_id = SPF.agreement_id
                AND    PC.customer_id = A.customer_id
                AND    PC.project_id = SPF.project_id
                AND    (NVL(SPF.total_baselined_amount,0) <> 0)
                ORDER BY PC.customer_id, SPF.agreement_id, SPF.task_id , set_of_books_id;

         /* This CURSOR selects the summary project funding lines with non-zero baselined amount
            for the given project in primary and reporting set of book ids */


        /* R12 :  Ledger Architecture Changes : The table gl_mc_reporting_options will  obsoleted, replace with
           new table gl_alc_ledger_rships_v and corresponding columns */

/* mrc migration to SLA bug 4571438
         CURSOR get_all_spf_lines (l_ProjectId NUMBER) is
                (SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                        SPF.agreement_id   agrmt_id,
                        SPF.task_id   task_id,
                        SPF.funding_currency_code funding_currency_code,
                        SPF.project_currency_code project_currency_code,
                        SPF.projfunc_currency_code projfunc_currency_code,
                        SPF.invproc_currency_code invproc_currency_code,
                        SPF.total_baselined_amount total_baselined_amount,
                        SPF.projfunc_baselined_amount projfunc_baselined_amount,
                        SPF.invproc_baselined_amount invproc_baselined_amount,
                        SPF.projfunc_realized_gains_amt projfunc_realized_gains_amt,
                        SPF.projfunc_realized_losses_amt projfunc_realized_losses_amt,
                        SPF.projfunc_accrued_amount projfunc_accrued_amount,
                        SPF.invproc_billed_amount invproc_billed_amount,
                        PC.retention_level_code retention_level_code,
                        PC.customer_id cust_id
                 FROM   pa_summary_project_fundings SPF, pa_agreements_all A, pa_project_customers PC
                 WHERE  SPF.project_id = l_ProjectId
                 AND    A.agreement_id = SPF.agreement_id
                 AND    PC.customer_id = A.customer_id
                 AND    PC.project_id = SPF.project_id
                 AND    (NVL(SPF.total_baselined_amount,0) <> 0)
                UNION
                 SELECT SPF_mc.set_of_books_id,
                        SPF.agreement_id   agrmt_id,
                        SPF.task_id   task_id,
                        SPF.funding_currency_code funding_currency_code,
                        'NA' project_currency_code,
                        SPF_mc.currency_code projfunc_currency_code,
                        SPF.invproc_currency_code invproc_currency_code,
                        SPF.total_baselined_amount total_baselined_amount,
                        SPF_mc.total_baselined_amount projfunc_baselined_amount,
                        SPF.invproc_baselined_amount invproc_baselined_amount,
                        SPF_mc.realized_gains_amt projfunc_realized_gains_amt,
                        SPF_mc.realized_losses_amt projfunc_realized_losses_amt,
                        SPF_mc.total_accrued_amount projfunc_accrued_amount,
                        SPF.invproc_billed_amount invproc_billed_amount,
                        PC.retention_level_code retention_level_code,
                        PC.customer_id cust_id
                 FROM   pa_mc_sum_proj_fundings SPF_mc,  pa_summary_project_fundings SPF,
                        pa_agreements_all A, pa_project_customers PC,
                        gl_alc_ledger_rships_v  rep, pa_implementations imp
                 WHERE SPF.project_id = l_ProjectId
                 AND   A.agreement_id = SPF.agreement_id
                 AND   PC.customer_id = A.customer_id
                 AND   PC.project_id = SPF.project_id
                 AND   (NVL(SPF.total_baselined_amount,0) <> 0)
                 AND   rep.source_ledger_id = imp.set_of_books_id
                 AND   rep.relationship_enabled_flag  = 'Y'
                 AND   (rep.org_id = -99 OR rep.org_id = imp.org_id)
                 AND   rep.application_id = 275
                 AND   spf_mc.set_of_books_id =rep.ledger_id
                 AND   spf_mc.project_id = spf.project_id
                 AND   spf_mc.agreement_id = spf.agreement_id
                 AND   nvl(spf_mc.task_id,0) = nvl(spf.task_id,0)
                )
                ORDER BY cust_id, agrmt_id, task_id , set_of_books_id; */

         l_SetOfBookIdTab           PA_PLSQL_DATATYPES.IDTabTyp;
         l_AgreementIdTab           PA_PLSQL_DATATYPES.IDTabTyp;
         l_TaskIdTab                PA_PLSQL_DATATYPES.IDTabTyp;
         l_FCCurrTab                PA_PLSQL_DATATYPES.Char30TabTyp;
         l_PCCurrTab                PA_PLSQL_DATATYPES.Char30TabTyp;
         l_PFCCurrTab               PA_PLSQL_DATATYPES.Char30TabTyp;
         l_IPCCurrTab               PA_PLSQL_DATATYPES.Char30TabTyp;
         l_FCBaseAmtTab             PA_PLSQL_DATATYPES.NumTabTyp;
         l_PFCBaseAmtTab            PA_PLSQL_DATATYPES.NumTabTyp;
         l_IPCBaseAmtTab            PA_PLSQL_DATATYPES.NumTabTyp;
         l_PFCGainAmtTab            PA_PLSQL_DATATYPES.NumTabTyp;
         l_PFCLossAmtTab            PA_PLSQL_DATATYPES.NumTabTyp;
         l_PFCAccruedAmtTab         PA_PLSQL_DATATYPES.NumTabTyp;
         l_IPCBilledAmtTab          PA_PLSQL_DATATYPES.NumTabTyp;
         l_RetnLevelTab             PA_PLSQL_DATATYPES.Char30TabTyp;
         l_CustomerIdTab            PA_PLSQL_DATATYPES.IDTabTyp;

         l_SPFLineTab               SPFTabTyp;

         l_PrvAgrId                 NUMBER := 0;
         l_PrvTaskId                NUMBER := 0;
         l_RetnLevelCode            VARCHAR2(30);

         l_TotalFetch               NUMBER := 0;
         l_ThisFetch                NUMBER := 0;
         l_FetchSize                NUMBER := 50;

         l_ReasonCode                    VARCHAR2(30);
         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;
         l_LogMsg                   VARCHAR2(250);
   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.get_spf_lines-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         /* When only primary set of book id is processed each SPF is unique and processing
            should be invoked for every record
            All the required values are passed into a global table G_RevalCompTab (indexed by set_of_books_id
            which will be used across routines to get revaluated amounts
            Table is used b'cos there will be multiple records for single spf when RC is being included

            When both primary and reporting set of books id are processed, for every set of book id
            there will be an SPF record. Since primary and reporting are processed together (AR amounts would be
            for all sob 's of each invoice), the processing is called once for all sobs/agreement/task
            So the global table will have all required components for all SOB's of an agreement/task combination

         */
         G_RevalCompTab.DELETE; /* Intialize for each project */

         IF G_PRIMARY_ONLY = 'Y' THEN

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Cursor get_spf_lines ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            OPEN get_spf_lines (G_ProjLvlGlobRec.project_id);
            LOOP
               FETCH get_spf_lines BULK COLLECT INTO l_SetOfBookIdTab, l_AgreementIdTab, l_TaskIdTab,
                                                     l_FCCurrTab, l_PCCurrTab, l_PFCCurrTab, l_IPCCurrTab,
                                                     l_FCBaseAmtTab, l_PFCBaseAmtTab, l_IPCBaseAmtTab,
                                                     l_PFCGainAmtTab, l_PFCLossAmtTab,
                                                     l_PFCAccruedAmtTab, l_IPCBilledAmtTab,
                                                     l_RetnLevelTab, l_CustomerIdTab
                                        LIMIT l_FetchSize;

               l_ThisFetch := get_spf_lines%ROWCOUNT - l_TotalFetch;
               l_TotalFetch := get_spf_lines%ROWCOUNT ;

               IF l_ThisFetch > 0 THEN


                  FOR i in l_SetOfBookIdTab.FIRST..l_SetOfBookIdTab.LAST LOOP

                      l_RetnLevelCode := l_RetnLevelTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).project_id :=  G_ProjLvlGlobRec.project_id;
                      G_RevalCompTab(l_SetOfBookIdTab(i)).agreement_id := l_AgreementIdTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).task_id := l_TaskIdTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).set_of_books_id := l_SetOfBookIdTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).enabled_flag := G_SobListTab(l_SetOfBookIdTab(i)).EnabledFlag;
                      G_RevalCompTab(l_SetOfBookIdTab(i)).funding_currency_code := l_FCCurrTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).project_currency_code :=  l_PCCurrTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).projfunc_currency_code := l_PFCCurrTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).invproc_currency_code := l_IPCCurrTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).total_baselined_amount := nvl(l_FCBaseAmtTab(i),0);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).projfunc_baselined_amount := nvl(l_PFCBaseAmtTab(i),0);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).invproc_baselined_amount := nvl(l_IPCBaseAmtTab(i),0);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).realized_gains_amount := nvl(l_PFCGainAmtTab(i),0);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).realized_losses_amount := nvl(l_PFCLossAmtTab(i),0);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).projfunc_accrued_amount := nvl(l_PFCAccruedAmtTab(i),0);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).invproc_billed_amount := nvl(l_IPCBilledAmtTab(i),0);

                      /* Call processing routine for every SPF as no reporting set of books are processed */
                      process_spf_lines (
                              p_agreement_id         => l_AgreementIdTab(i),
                              p_task_id              => l_TaskIdTab(i),
                              p_retention_level_code => l_RetnLevelCode,
                              x_return_status        => l_return_status,
                              x_msg_count            => l_msg_count,
                              x_msg_data             => l_msg_data);

                      G_RevalCompTab.DELETE; /* Initialize for next SPF record */

                      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                         RAISE FND_API.G_EXC_ERROR;

                      END IF;

                  END LOOP; /* l_SetOfBookIdTab */

               END IF; /* l_ThisFetch > 0 */

               /* Initialize for next fetch */
               l_SetOfBookIdTab.DELETE;
               l_AgreementIdTab.DELETE;
               l_TaskIdTab.DELETE;
               l_FCCurrTab.DELETE;
               l_PCCurrTab.DELETE;
               l_PFCCurrTab.DELETE;
               l_IPCCurrTab.DELETE;
               l_FCBaseAmtTab.DELETE;
               l_PFCBaseAmtTab.DELETE;
               l_IPCBaseAmtTab.DELETE;
               l_PFCGainAmtTab.DELETE;
               l_PFCLossAmtTab.DELETE;
               l_PFCAccruedAmtTab.DELETE;
               l_IPCBilledAmtTab.DELETE;
               l_RetnLevelTab.DELETE;
               l_CustomerIdTab.DELETE;

               IF l_ThisFetch < l_FetchSize THEN

                  Exit;

               END IF;

            END LOOP; /* get_spf_lines */
            CLOSE get_spf_lines ;

        /* mrc migration to SLA bug 4571438 ELSE
         (      IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Cursor get_all_spf_lines ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            OPEN get_all_spf_lines (G_ProjLvlGlobRec.project_id);
            LOOP

               FETCH get_all_spf_lines BULK COLLECT INTO l_SetOfBookIdTab, l_AgreementIdTab, l_TaskIdTab,
                                                     l_FCCurrTab, l_PCCurrTab, l_PFCCurrTab, l_IPCCurrTab,
                                                     l_FCBaseAmtTab, l_PFCBaseAmtTab, l_IPCBaseAmtTab,
                                                     l_PFCGainAmtTab, l_PFCLossAmtTab,
                                                     l_PFCAccruedAmtTab, l_IPCBilledAmtTab,
                                                     l_RetnLevelTab, l_CustomerIdTab
                                        LIMIT l_FetchSize;

               l_ThisFetch := get_all_spf_lines%ROWCOUNT - l_TotalFetch;
               l_TotalFetch := get_all_spf_lines%ROWCOUNT ;

               IF l_ThisFetch > 0 THEN

                  FOR i in l_SetOfBookIdTab.FIRST..l_SetOfBookIdTab.LAST LOOP

                      -- Call processing routine for every SPF only group all reporting set of books together
                       --  Call processing only when agreement/task changes

                      IF l_PrvAgrId = 0 THEN
                         l_PrvAgrId := l_AgreementIdTab(i);
                         l_PrvTaskId := nvl(l_TaskIdTab(i),0);
                      END IF;

                      IF ((l_PrvAgrId <> l_AgreementIdTab(i)) OR
                           (l_PrvTaskId <> nvl(l_TaskIdTab(i),0)))  THEN

                          process_spf_lines (
                                   p_agreement_id         => l_PrvAgrId,
                                   p_task_id              => l_PrvTaskId,
                                   p_retention_level_code => l_RetnLevelCode,
                                   x_return_status        => l_return_status,
                                   x_msg_count            => l_msg_count,
                                   x_msg_data             => l_msg_data);

                          G_RevalCompTab.DELETE;

                          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                             RAISE FND_API.G_EXC_ERROR;

                          END IF;

                          l_PrvAgrId := l_AgreementIdTab(i);
                          l_PrvTaskId := l_TaskIdTab(i);

                      END IF;
                      l_RetnLevelCode := l_RetnLevelTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).project_id :=  G_ProjLvlGlobRec.project_id;
                      G_RevalCompTab(l_SetOfBookIdTab(i)).agreement_id := l_AgreementIdTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).task_id := l_TaskIdTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).set_of_books_id := l_SetOfBookIdTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).enabled_flag := G_SobListTab(l_SetOfBookIdTab(i)).EnabledFlag;
                      G_RevalCompTab(l_SetOfBookIdTab(i)).funding_currency_code := l_FCCurrTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).project_currency_code :=  l_PCCurrTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).projfunc_currency_code := l_PFCCurrTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).invproc_currency_code := l_IPCCurrTab(i);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).total_baselined_amount := nvl(l_FCBaseAmtTab(i),0);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).projfunc_baselined_amount := nvl(l_PFCBaseAmtTab(i),0);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).invproc_baselined_amount := nvl(l_IPCBaseAmtTab(i),0);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).realized_gains_amount := nvl(l_PFCGainAmtTab(i),0);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).realized_losses_amount := nvl(l_PFCLossAmtTab(i),0);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).projfunc_accrued_amount := nvl(l_PFCAccruedAmtTab(i),0);
                      G_RevalCompTab(l_SetOfBookIdTab(i)).invproc_billed_amount := nvl(l_IPCBilledAmtTab(i),0);
                  END LOOP;

               END IF; -- l_ThisFetch > 0

               IF l_ThisFetch < l_FetchSize THEN

                  IF l_ThisFetch > 0 THEN

                     -- Process for last set of records

                        process_spf_lines (
                              p_agreement_id         => l_PrvAgrId,
                              p_task_id              => l_PrvTaskId,
                              p_retention_level_code => l_RetnLevelCode,
                              x_return_status        => l_return_status,
                              x_msg_count            => l_msg_count,
                              x_msg_data             => l_msg_data);

                        G_RevalCompTab.DELETE;

                        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                            RAISE FND_API.G_EXC_ERROR;

                        END IF;

                  END IF; -- l_ThisFetch > 0

                  EXIT;

               END IF; -- l_ThisFetch < l_Fetchsize

               -- Initialize for next fetch
               l_SetOfBookIdTab.DELETE;
               l_AgreementIdTab.DELETE;
               l_TaskIdTab.DELETE;
               l_FCCurrTab.DELETE;
               l_PCCurrTab.DELETE;
               l_PFCCurrTab.DELETE;
               l_IPCCurrTab.DELETE;
               l_FCBaseAmtTab.DELETE;
               l_PFCBaseAmtTab.DELETE;
               l_IPCBaseAmtTab.DELETE;
               l_PFCGainAmtTab.DELETE;
               l_PFCLossAmtTab.DELETE;
               l_PFCAccruedAmtTab.DELETE;
               l_IPCBilledAmtTab.DELETE;
               l_RetnLevelTab.DELETE;
               l_CustomerIdTab.DELETE;

            END LOOP; -- get_all_spf_lines
            CLOSE get_all_spf_lines ;
 */
         END IF;

         /* This code is added for bug 2569816. The project may not have any funding at all  but
            other eligibility criteria may have satisfied*/

         IF l_TotalFetch = 0 THEN

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'No funding for revaluation ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;
            /*
               The following 2 global values are reinitialized
               1) To avoid printing that no adjustment found in calling routine as by default it is set to Y
                  and modified to N only when there are adjustments done. In this case there will not be any
                  adjustment as there is no funding . So explicitly setting it to N

               2) This is actually read from project table. In the parent routine there is a check for zero
                  dollar flag => if N baseline routine will be called if baseline_funding_flag = 'Y'. So
                  re setting this will not call baseline routine there
            */

            G_ProjLvlGlobRec.Zero_dollar_reval_flag := 'N';
            G_ProjLvlGlobRec.baseline_funding_flag  := 'N';

            l_ReasonCode := 'PA_FR_NO_FUNDING';

            Insert_distribution_warnings(
                  p_project_id     => G_ProjLvlGlobRec.project_id,
                  p_reason_code    => l_ReasonCode,
                  x_return_status  => l_return_status,
                  x_msg_count      => l_msg_count,
                  x_msg_data       => l_msg_data) ;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

               RAISE FND_API.G_EXC_ERROR;

            END IF;

         END IF;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.get_spf_lines-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'get_spf_lines:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END get_spf_lines;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   process_spf_lines                                                      |
   |   Purpose    :   To process spf lines based on project/task level funding               |
   |                  project/task level retention                                           |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_agreement_id          IN      Agreement ID                                        |
   |     p_task_id               IN      Task ID of summary project funding                  |
   |     p_retention_level_code  IN      Retention level code                                |
   |     x_return_status         OUT     Return status of this procedure                     |
   |     x_msg_count             OUT     Error message count                                 |
   |     x_msg_data              OUT     Error message                                       |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE process_spf_lines(
             p_agreement_id         IN    NUMBER,
             p_task_id              IN    NUMBER,
             p_retention_level_code IN    VARCHAR2,
             x_return_status        OUT   NOCOPY VARCHAR2,
             x_msg_count            OUT   NOCOPY NUMBER,
             x_msg_data             OUT   NOCOPY VARCHAR2)   IS



         l_TskFundPrjRetnFlag       VARCHAR2(1);
         l_InvPrcdFlag              VARCHAR2(1);

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;
         l_LogMsg                   VARCHAR2(250);
   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.process_spf_lines-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

            l_LogMsg := 'Agreement Id:' || p_agreement_id ||
                        ' Task Id:'     || p_task_id ||
                        ' Retention Level:' || p_retention_level_code;

            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

         END IF;

         /* When the project is funded by top task level the spf will be for every agreement/
            top task. But the invoices will be by agreement which will have multiple top task.

            When the agreement is read for the first time (that is for the first task being funded)
            all the invoices for that agreement are read and the line amounts are cached against the task in
            global table G_InvCompTab. This table will have for an agreement, the summary amounts of invoice
            components (including AR amounts) for all the tasks(for all sob's) that are being funded by this agreement.

            During subsequent runs of the same agreement (for other tasks being funded by this agreement),
            this global table is checked for data. If exists then invoice reading routine is bypassed. The prorated
            amounts for the task of this SPF is read from this table and used for further
            processing. In order to bypass invoice reading routine the flag l_InvPrcdFlag will be
            set to indicate that invoices for this agreement/task are already in the cache

            This cache will be initialized at project level and at SPF level when agreement changes

            In the case of project level funding, this table will have for an agreement, the summary amounts of invoice
            components for all sob's
         */

         /* When there is task level funding and project level retention all paid retention
            amounts will have to be split across task level funding.
            First all retention paid amounts for the agreement/project is computed and cached in G_RetnApplAmtTab.
            While reading regular invoices, if task level funding/project level retention agreemnt , the retained amount
            for each task of the invoice is read from RDL/ERDL/DII. On a FirstCome basis, this
            retained amount is adjusted against available paid retention amount (from G_RetnApplAmtTab).
         */

        /*Initilize flag that no mismatch in funding and retention level */
         l_TskFundPrjRetnFlag := 'N';

        /*Initilize flag that invoices are not already processed */
         l_InvPrcdFlag           := 'N';


         IF G_InvCompTab.COUNT <> 0 THEN  /* some invoice amounts are cached */

            IF G_InvCompTab(G_InvCompTab.FIRST).agreement_id <> p_agreement_id THEN  /* If not for current areement */

               /* Initialize retention applied amount and invoice amounts cache */
               G_InvCompTab.DELETE;
               G_RetnApplAmtTab.DELETE;

            END IF; /*Current agreement */

         END IF; /* Invoice components */

         IF nvl(p_task_id,0) <> 0 THEN /* Task level funding */

            IF G_InvCompTab.COUNT <> 0 THEN  /* invoice amounts are cached for the same agreement*/

                l_InvPrcdFlag := 'Y';  /* Invoices are already read and cached */

            END IF;

            IF p_retention_level_code = 'PROJECT' THEN

               l_TskFundPrjRetnFlag := 'Y'; /* Task level funding project level retention */

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Task Level Funding Project level Retention';
                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

               /*  paid amounts are to be computed only if include gains/loss flag is set*/

               IF ((G_RetnApplAmtTab.COUNT = 0) AND (G_ProjLvlGlobRec.include_gains_losses_flag =  'Y')) THEN

                  get_retn_appl_amount(
                       p_project_id      => G_ProjLvlGlobRec.project_id,
                       p_agreement_id    => p_agreement_id,
                       x_return_status   => l_return_status,
                       x_msg_count       => l_msg_count,
                       x_msg_data        => l_msg_data);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                      RAISE FND_API.G_EXC_ERROR;

                  END IF;

               END IF; /* G_RentApplAmtTab.COUNT */

            END IF; /* p_retention_level_code */

         END IF; /* task level funding */

         /* This procedure opens all invoice lines for a given project/agreement/task */

         IF l_InvPrcdFlag = 'N' THEN

            /* For a given project/agreement this routine computes the following amounts

                   If the agreement is task level funding this routine will populate revaluation invoice
                       component amounts for each agreement/top_task  in a global table G_InvCompTab
                   If the agreement is project level funding this routine will populate revaluation invoice
                       component amounts for each agreement in a global table G_InvCompTab

                   Depending on primary only or both primary and reporting set of books, this table will have
                   one record per SPF record /per SOB

                   The computed amounts will be

                       a) billed amount (FC/PFC(MC)/IPC)
                       b) applied amount (FC/PFC(MC)/IPC)
                       c) due amount (FC/PFC(MC)/IPC)
                       d) gain amount (PFC(MC))
                       e) loss amount (PFC(MC))

                       These amounts will be populated in G_InvCompTab

                    */

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Calling Invoice processing for this project/agreement - First time';
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            /* Only if include_gains_losses_flag is set, invoice is to be read sequentially
               else it can be summed up in one shot as only backlog will be revaluated */

            IF (G_ProjLvlGlobRec.include_gains_losses_flag =  'Y') THEN

               get_invoice_components(
                   p_project_id             => G_ProjLvlGlobRec.project_id,
                   p_agreement_id           => p_agreement_id,
                   p_task_id                => p_task_id,
                   p_TaskFund_ProjRetn_Flag => l_TskFundPrjRetnFlag,
                   x_return_status          => l_return_status,
                   x_msg_count              => l_msg_count,
                   x_msg_data               => l_msg_data);

               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                  RAISE FND_API.G_EXC_ERROR;

               END IF;

            ELSE

               get_sum_invoice_components(
                   p_project_id             => G_ProjLvlGlobRec.project_id,
                   p_agreement_id           => p_agreement_id,
                   p_task_id                => p_task_id,
                   x_return_status          => l_return_status,
                   x_msg_count              => l_msg_count,
                   x_msg_data               => l_msg_data);

               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                  RAISE FND_API.G_EXC_ERROR;

               END IF;

            END IF; /* IF (G_ProjLvlGlobRec.include_gains_losses_flag =  'Y') */

         END IF;

         /* This procedure will compute the final revaluation amounts from two global tables
             G_RevalCompTab and G_InvCompTab */

         compute_adjustment_amounts(
                 p_agreement_id        => p_agreement_id,
                 p_task_id             => p_task_id,
                 x_return_status       => l_return_status,
                 x_msg_count           => l_msg_count,
                 x_msg_data            => l_msg_data);

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

            RAISE FND_API.G_EXC_ERROR;

         END IF;

        create_adjustment_line (
                 x_return_status       => l_return_status,
                 x_msg_count           => l_msg_count,
                 x_msg_data            => l_msg_data);

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

            RAISE FND_API.G_EXC_ERROR;

         END IF;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.process_spf_lines-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'process_spf_lines:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END process_spf_lines;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   get_retn_appl_amount                                                   |
   |   Purpose    :   To get applied/FXGL amounts for retention invoices                     |
   |                  This will be only executed for task level funding with project level   |
   |                  retention invoices                                                     |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_agreement_id        IN      Agreement ID                                          |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   |  Description :  This routine processes all retention invoices for a given project/agreement|
   |                 It computes the total applied amount and FXGL amounts for primary as well  |
   |                 as reporting set of books id.                                              |
   |                 The global table G_RetnApplAmtTab has the structure                        |
   |        sob_id             - primary/ reporting set of book id                              |
   |        ar_applied_amt_fc  - applied amount in funding currency                             |
   |        projfunc_applied_amount - applied amount in projfunc currency for primary sob            |
   |                             applied amount in reporting currency for reporting sob         |
   |        projfunc_gain_amount    - FXGL gain amount in projfunc currency for primary sob          |
   |                             FXGL gain amount in reporting currency for reporting sob       |
   |        projfunc_loss_amount    - FXGL loss amount in projfunc currency for primary sob          |
   |                             FXGL loss  amount in reporting currency for reporting sob      |
   |        ar_adj_app_amt_fc  - total adjusted amount in funding currency                      |
   |        ar_adj_app_amt_pfc - total adjusted amount in projfunc/reporting currency           |
   |        ar_adj_gain_amt_pfc - total adjusted FXGL gain amount in projfunc/reporting currency|
   |        ar_adj_loss_amt_pfc - total adjusted FXGL loss amount in projfunc/reporting currency|
   +-------------------------------------------------------------------------------------------*/
   PROCEDURE get_retn_appl_amount(
             p_project_id        IN      NUMBER,
             p_agreement_id      IN      NUMBER,
             x_return_status     OUT     NOCOPY VARCHAR2,
             x_msg_count         OUT     NOCOPY NUMBER,
             x_msg_data          OUT     NOCOPY VARCHAR2)   IS


       /* This CURSOR fetches all retention invoice amount for a given project/agreement_id in
          primary sob */

       CURSOR get_retn_invoices IS
              SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     di.draft_invoice_num,
                     dii.projfunc_currency_code,
                     dii.funding_currency_code,
                     di.inv_currency_code,
                     di.system_reference,
                     di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount
              FROM pa_draft_invoice_items dii,
                   pa_draft_invoices di
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND di.transfer_status_code = 'A'
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND nvl(di.retention_invoice_flag, 'N') = 'Y'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num, dii.projfunc_currency_code,
                       dii.funding_currency_code, di.inv_currency_code,
                       di.system_reference,di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       decode(di.draft_invoice_num_credited, NULL, 'N', 'Y');

       /* This CURSOR fetches all retention invoice amount for a given project/agreement_id in
          primary and reporint sob
       */

  /* R12 :  Ledger Architecture Changes : The table gl_mc_reporting_options will be  obsolete, replace with
     new table gl_alc_ledger_rships_v and corresponding columns */
/* mrc migration to SLA bug 4571438
       CURSOR get_all_retn_invoices IS
              (SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     di.draft_invoice_num drft_inv_num,
                     dii.projfunc_currency_code,
                     dii.funding_currency_code,
                     di.inv_currency_code,
                     di.system_reference,
                     di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount
              FROM pa_draft_invoice_items dii,
                   pa_draft_invoices di
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND di.transfer_status_code = 'A'
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND nvl(di.retention_invoice_flag, 'N') = 'Y'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num, dii.projfunc_currency_code,
                       dii.funding_currency_code, di.inv_currency_code,
                       di.system_reference,di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       decode(di.draft_invoice_num_credited, NULL, 'N', 'Y')
             UNION
              SELECT dii_mc.set_of_books_id,
                     di.draft_invoice_num drft_inv_num,
                     dii_mc.currency_code projfunc_currency_code,
                     dii.funding_currency_code,
                     di.inv_currency_code,
                     di.system_reference,
                     di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,
                     sum(dii_mc.amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount
              FROM pa_draft_invoice_items dii, pa_mc_draft_inv_items dii_mc, pa_draft_invoices di,
                   gl_alc_ledger_rships_v rep, pa_implementations imp
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND di.transfer_status_code = 'A'
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND rep.source_ledger_id  = imp.set_of_books_id
              AND rep.relationship_enabled_flag = 'Y'
              AND (rep.org_id = -99 OR rep.org_id = imp.org_id)
              AND rep.application_id = 275
              AND dii_mc.set_of_books_id =rep.ledger_id
              AND dii_mc.project_id = dii.project_id
              AND dii_mc.draft_invoice_num = dii.draft_invoice_num
              AND dii_mc.line_num = dii.line_num
              AND nvl(di.retention_invoice_flag, 'N') = 'Y'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num, dii_mc.set_of_books_id, dii_mc.currency_code,
                       dii.funding_currency_code, di.inv_currency_code, di.system_reference,di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       decode(di.draft_invoice_num_credited, NULL, 'N', 'Y')
               )
              ORDER BY drft_inv_num, set_of_books_id; */


         l_SetOfBookIdTab           PA_PLSQL_DATATYPES.IdTabTyp;
         l_DraftInvNumTab           PA_PLSQL_DATATYPES.NumTabTyp;
         l_PFCCurrTab               PA_PLSQL_DATATYPES.Char30TabTyp;
         l_FCCurrTab                PA_PLSQL_DATATYPES.Char30TabTyp;
         l_ITCCurrTab               PA_PLSQL_DATATYPES.Char30TabTyp;
         l_SysRefTab                PA_PLSQL_DATATYPES.NumTabTyp;
         l_StatusCodeTab            PA_PLSQL_DATATYPES.Char30TabTyp;
         l_CancelFlgTab             PA_PLSQL_DATATYPES.Char1TabTyp;
         l_ClCrMemoFlgTab           PA_PLSQL_DATATYPES.Char1TabTyp;
         l_WrOffFlgTab              PA_PLSQL_DATATYPES.Char1TabTyp;
         l_CrMemoFlgTab             PA_PLSQL_DATATYPES.Char1TabTyp;
         l_BillAmtPFCTab            PA_PLSQL_DATATYPES.NumTabTyp;
         l_BillAmtFCTab             PA_PLSQL_DATATYPES.NumTabTyp;
         l_BillAmtITCTab            PA_PLSQL_DATATYPES.NumTabTyp;

         l_PrvInvNum                NUMBER := 0;
         l_SystemRef                NUMBER ;
         l_StatusCode               VARCHAR2(1);
         l_AdjInvFlag               VARCHAR2(1);

         l_RetnInvTab               RetnInvTabTyp;

         l_TotalFetch               NUMBER := 0;
         l_ThisFetch                NUMBER := 0;
         l_FetchSize                NUMBER := 50;

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;
         l_LogMsg                   VARCHAR2(250);
         l_InvoiceStatus            VARCHAR2(30);

   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.get_retn_appl_amount-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         /* When only primary set of book id is processed each invoice is unique and processing
            should be invoked for every record
            All the required values are passed into a table structure l_RetnInvTab (indexed by set_of_books_id)
            Table is used b'cos there will be multiple records for single invoice when RC is being included

            When both primary and reporting set of books id are processed, for every set of book id
            there will be an invoice record. Since primary and reporting are processed together (AR amounts would be
            for all sob 's of each invoice), the processing is called once for all sobs/invoice
            So the global table G_RetnInvApplAmtTab will have all required components for all SOB's of an invoice .
         */


         IF G_PRIMARY_ONLY = 'Y' THEN -- (

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Cursor get_retn_invoices ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            OPEN get_retn_invoices;

            LOOP
                FETCH get_retn_invoices BULK COLLECT INTO l_SetOfBookIdTab, l_DraftInvNumTab,
                                   l_PFCCurrTab, l_FCCurrTab,
                                   l_ITCCurrTab, l_SysRefTab, l_StatusCodeTab,
                                   l_CancelFlgTab, l_ClCrMemoFlgTab, l_WrOffFlgTab, l_CrMemoFlgTab,
                                   l_BillAmtPFCTab, l_BillAmtFCTab,
                                   l_BillAmtITCTab
                              LIMIT l_FetchSize;

                l_ThisFetch := get_retn_invoices%ROWCOUNT - l_TotalFetch;
                l_TotalFetch := get_retn_invoices%ROWCOUNT ;

                IF l_ThisFetch > 0 THEN

                   FOR i in l_SetOfBookIdTab.FIRST..l_SetOfBookIdTab.LAST LOOP

                       l_RetnInvTab(l_SetOfBookIdTab(i)).set_of_books_id := l_SetOfBookIdTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).draft_invoice_num := l_DraftInvNumTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).projfunc_currency_code := l_PFCCurrTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).funding_currency_code := l_FCCurrTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).inv_currency_code := l_ITCCurrTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).system_reference := l_SysRefTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).projfunc_bill_amount := l_BillAmtPFCTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).funding_bill_amount := l_BillAmtFCTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).inv_amount := l_BillAmtITCTab(i);
                       l_SystemRef :=  l_SysRefTab(i);
                       l_StatusCode :=  l_StatusCodeTab(i);
                       l_AdjInvFlag := 'N';

                       IF  ((l_CancelFlgTab(i) = 'Y') OR (l_ClCrMemoFlgTab(i) = 'Y') OR  (l_WrOffFlgTab(i) = 'Y')
                             OR (l_CrMemoFlgTab(i) = 'Y')) THEN

                           l_AdjInvFlag := 'Y';

                       END IF;


                       /* Call processing routine for every invoice as no reporting set of books are processed */

                       process_retention_invoices (
                                         p_system_reference     => l_SystemRef,
                                         p_invoice_status       => l_StatusCode,
                                         p_adjust_flag          => l_AdjInvFlag,
                                         p_RetnInvTab           => l_RetnInvTab,
                                         x_return_status        => l_return_status,
                                         x_msg_count            => l_msg_count,
                                         x_msg_data             => l_msg_data);

                       l_RetnInvTab.DELETE;

                       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                          RAISE FND_API.G_EXC_ERROR;

                       END IF;

                   END LOOP; /*SetOfBookIdTab */

                END IF; /* l_ThisFetch > 0 */


                /* Initialize for next fetch */
                l_SetOfBookIdTab.DELETE;
                l_DraftInvNumTab.DELETE;
                l_PFCCurrTab.DELETE;
                l_FCCurrTab.DELETE;
                l_ITCCurrTab.DELETE;
                l_SysRefTab.DELETE;
                l_CancelFlgTab.DELETE;
                l_CrMemoFlgTab.DELETE;
                l_WrOffFlgTab.DELETE;
                l_ClCrMemoFlgTab.DELETE;
                l_BillAmtPFCTab.DELETE;
                l_BillAmtFCTab.DELETE;
                l_BillAmtITCTab.DELETE;

                IF l_ThisFetch < l_FetchSize THEN
                   Exit;
                END IF;

            END LOOP; /* get_retn_invoices ) */

            CLOSE get_retn_invoices ;

        /* mrc migration to SLA bug 4571438  ELSE -- (

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Cursor get_all_retn_invoices ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            OPEN get_all_retn_invoices;

            LOOP
                FETCH get_all_retn_invoices BULK COLLECT INTO l_SetOfBookIdTab, l_DraftInvNumTab,
                                   l_PFCCurrTab, l_FCCurrTab,
                                   l_ITCCurrTab, l_SysRefTab, l_StatusCodeTab,
                                   l_CancelFlgTab, l_ClCrMemoFlgTab, l_WrOffFlgTab, l_CrMemoFlgTab,
                                   l_BillAmtPFCTab, l_BillAmtFCTab,
                                   l_BillAmtITCTab
                              LIMIT l_FetchSize;

                l_ThisFetch := get_all_retn_invoices%ROWCOUNT - l_TotalFetch;
                l_TotalFetch := get_all_retn_invoices%ROWCOUNT ;

                IF l_ThisFetch > 0 THEN

                   FOR i in l_SetOfBookIdTab.FIRST..l_SetOfBookIdTab.LAST LOOP

                       --  Call processing routine for every invoice only group all reporting set of books together
                        --   Call processing only when invoice changes

                       IF l_PrvInvNum = 0 THEN
                          l_PrvInvNum := l_DraftInvNumTab(i);
                       END IF;

                       IF ((l_PrvInvNum <> l_DraftInvNumTab(i))) THEN

                          process_retention_invoices (
                                         p_system_reference     => l_SystemRef,
                                         p_invoice_status       => l_StatusCode,
                                         p_adjust_flag          => l_AdjInvFlag,
                                         p_RetnInvTab           => l_RetnInvTab,
                                         x_return_status        => l_return_status,
                                         x_msg_count            => l_msg_count,
                                         x_msg_data             => l_msg_data);

                          l_RetnInvTab.DELETE;

                          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                             RAISE FND_API.G_EXC_ERROR;

                          END IF;

                          l_PrvInvNum := l_DraftInvNumTab(i);

                       END IF;
                       l_RetnInvTab(l_SetOfBookIdTab(i)).set_of_books_id := l_SetOfBookIdTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).draft_invoice_num := l_DraftInvNumTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).projfunc_currency_code := l_PFCCurrTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).funding_currency_code := l_FCCurrTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).inv_currency_code := l_ITCCurrTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).system_reference := l_SysRefTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).projfunc_bill_amount := l_BillAmtPFCTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).funding_bill_amount := l_BillAmtFCTab(i);
                       l_RetnInvTab(l_SetOfBookIdTab(i)).inv_amount := l_BillAmtITCTab(i);
                       l_SystemRef  := l_SysRefTab(i);
                       l_StatusCode  := l_StatusCodeTab(i);

                       l_AdjInvFlag := 'N';

                       IF  ((l_CancelFlgTab(i) = 'Y') OR (l_ClCrMemoFlgTab(i) = 'Y') OR  (l_WrOffFlgTab(i) = 'Y')
                             OR (l_CrMemoFlgTab(i) = 'Y')) THEN

                           l_AdjInvFlag := 'Y';

                       END IF;

                   END LOOP; -- l_SetOfBookIdTab

               END IF; -- l_ThisFetch > 0

               IF l_ThisFetch < l_FetchSize THEN

                  -- Process for last set of records

                  IF (l_ThisFetch > 0 ) THEN

                      process_retention_invoices (
                          p_system_reference     => l_SystemRef,
                          p_invoice_status       => l_StatusCode,
                          p_adjust_flag          => l_AdjInvFlag,
                          p_RetnInvTab           => l_RetnInvTab,
                          x_return_status        => l_return_status,
                          x_msg_count            => l_msg_count,
                          x_msg_data             => l_msg_data);

                     l_RetnInvTab.DELETE;

                     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                        RAISE FND_API.G_EXC_ERROR;

                     END IF;

                  END IF; -- l_ThisFetch > 0

                  EXIT;

               END IF; -- l_ThisFetch < l_Fetchsize

               -- Initialize for next fetch
                l_SetOfBookIdTab.DELETE;
                l_DraftInvNumTab.DELETE;
                l_PFCCurrTab.DELETE;
                l_FCCurrTab.DELETE;
                l_ITCCurrTab.DELETE;
                l_SysRefTab.DELETE;
                l_CancelFlgTab.DELETE;
                l_ClCrMemoFlgTab.DELETE;
                l_WrOffFlgTab.DELETE;
                l_CrMemoFlgTab.DELETE;
                l_BillAmtPFCTab.DELETE;
                l_BillAmtFCTab.DELETE;
                l_BillAmtITCTab.DELETE;

            END LOOP; -- get_all_retn_invoices

            CLOSE get_all_retn_invoices ; -- ) */

         END IF;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.get_retn_appl_amount-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'get_retn_appl_amount:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END get_retn_appl_amount;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   process_retn_invoices                                                  |
   |   Purpose    :   To get retention paid amount for an invoice                            |
   |                  This procedure gets paid amount for one invoice in all set of book ids |
   |                  This is executed only when there is task level funding /project level  |
   |                  retention                                                              |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_SystemReference       IN      System Refrence                                     |
   |     p_Invoice_Status        IN      Indicates if the input invoice status is accepted   |
   |                                     in AR or Not                                        |
   |     p_Adjust_Flag             IN      'Y' Indicates if the invoice is a write-off/cancel/
   |                                       credit memo
   |     p_RetnInvTab            IN      Retention Invoice of all set of books for which     |
   |                                     paid amounts and FXGL are to be computed            |
   |     x_return_status         OUT     Return status of this procedure                     |
   |     x_msg_count             OUT     Error message count                                 |
   |     x_msg_data              OUT     Error message                                       |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE  process_retention_invoices (
              p_system_reference     IN   NUMBER,
              p_Invoice_Status       IN   VARCHAR2,
              p_adjust_flag          IN    VARCHAR2,
              p_RetnInvTab           IN   RetnInvTabTyp,
              x_return_status        OUT  NOCOPY VARCHAR2,
              x_msg_count            OUT  NOCOPY NUMBER,
              x_msg_data             OUT  NOCOPY VARCHAR2)   IS

         l_ArApplAmtPFC             NUMBER := 0;
         l_ArApplAmtFC              NUMBER := 0;
         l_ArGainAmtPFC             NUMBER := 0;
         l_ArLossAmtPFC             NUMBER := 0;

         l_BillAmtITC               NUMBER := 0;
         l_BillAmtFC                NUMBER := 0;
         l_ErrorStatus              VARCHAR2(30) := NULL;

         l_ArAmtsTab                ArAmtsTabTyp;

         l_SobId                    NUMBER;
         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;
         l_LogMsg                   VARCHAR2(250);

         l_SobIdIdx                    NUMBER;
   BEGIN

         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.process_retention_invoice-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         /* For the given retention invoice (System Reference )this procedure will return
            applied and FXGL amounts in PFC/ITC in case of primary set of book id.
            applied and FXGL amounts in reporting currency for reporting set of book id

            ArAmtsTab is index by set of book id. This will have one row for each reporting
            set of book id and one for primary set of book id

            Since this routine does at each invoice level the total is summed up against
            each agreement/sob id and stored in global table G_RetnApplAmtTab
           */

         l_ArAmtsTab.DELETE;

         /* p_adjust_flag indicates if the invoice is an adjustment invoice (credit memo/write-off/cancel)
            If so and transferred to AR, the invoiced amount should be returned as paid amount. This is b'cos
            AR returns the adjustment amount + paid amount for the original invoice and returns zero for
            the adjustment invoice. This would result in write-off amount being treated as billed and fully paid
            for Funding revaluation, but invoice model will have this write-off as available funding. Funding
            Revaluation needs to have this as backlog amount to be in sync with invoice model. In order to achieve
            this , the following code else part of if p_adjust_flag is written. AR amounts are forced to return
            the adjustment amount, which will offset the billed and paid amount making it to be in sync with
            invoice model */


         IF p_adjust_flag = 'N' THEN

            get_ar_amounts (
               p_customer_trx_id => p_System_Reference,
               p_invoice_status  => p_invoice_status,
               x_ArAmtsTab       => l_ArAmtsTab,
               x_return_status   => l_return_status,
               x_msg_count       => l_msg_count,
               x_msg_data        => l_msg_data);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

               RAISE FND_API.G_EXC_ERROR;

            END IF;

        ELSE
            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg:= ' Retention Adjustment Invoice ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            IF ((G_ProjLvlGlobRec.include_gains_losses_flag =  'Y') AND
                 (p_invoice_status = 'A') AND (G_AR_INSTALLED_FLAG = 'Y')) THEN

               l_SobId :=  p_RetnInvTab.FIRST;

               LOOP

                 EXIT WHEN l_SobId IS NULL;

                 l_ArAmtsTab(l_SobId).set_of_books_id          := p_RetnInvTab(l_SobId).set_of_books_id;
                 l_ArAmtsTab(l_SobId).inv_applied_amount       := p_RetnInvTab(l_SobId).inv_amount;
                 l_ArAmtsTab(l_SobId).projfunc_applied_amount  := p_RetnInvTab(l_SobId).projfunc_bill_amount;
                 l_ArAmtsTab(l_SobId).projfunc_gain_amount     := 0;
                 l_ArAmtsTab(l_SobId).projfunc_loss_amount     := 0;

                 l_SobId := p_RetnInvTab.NEXT(l_SobId);

               END LOOP;

            END IF;

        END IF;

         /* G_SobListTab has all set of books id including primary and reproting set of books id
            Also the element enabled_flag indicates if AR also has the set of book id enabled.
            If this flag is 'N', it indicates thatn
                set of book id is enabled in 'PA' but not in AR
            In this case the paid amounts will be prorated (AR will return zero

         */

         l_SobIdIdx := G_SobListTab.FIRST;

         LOOP

              EXIT WHEN l_SobIdIdx IS NULL;

              l_ArApplAmtFC := 0;
              l_ArApplAmtPFC := 0;
              l_ArGainAmtPFC := 0;
              l_ArLossAmtPFC := 0;
              l_ErrorStatus  := '';
              l_BillAmtITC := 0;
              l_BillAmtFC := 0;
              l_SobId := l_SobIdIdx;

              IF G_DEBUG_MODE = 'Y' THEN

                 l_LogMsg := ' ' ;
                 PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

                 l_LogMsg := 'Sob Id:' || l_SobIdIdx ;
                 PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

                 l_LogMsg := '==================';
                 PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

              END IF;


              IF ((l_ArAmtsTab.EXISTS(l_SobIdIdx)) AND (p_RetnInvTab.EXISTS(l_SobIdIdx))) THEN


                 /* If  funding currency and invoice currency are different
                    prorate the AR amounts for funding curency*/

                 IF p_RetnInvTab(l_SobIdIdx).inv_currency_code <> p_RetnInvTab(l_SobIdIdx).funding_currency_code THEN

                    IF p_RetnInvTab(l_SobIdIdx).funding_currency_code =
                                     p_RetnInvTab(l_SobIdIdx).projfunc_currency_code THEN

                       IF G_DEBUG_MODE = 'Y' THEN

                          l_LogMsg := 'Retention - FC and ITC are different, but = PFC  - assigning';
                          PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

                       END IF;

                       l_ArApplAmtFC := l_ArAmtsTab(l_SobIdIdx).projfunc_applied_amount;

                    ELSE

                       l_BillAmtITC := p_RetnInvTab(l_SobIdIdx).inv_amount;
                       l_BillAmtFC := p_RetnInvTab(l_SobIdIdx).funding_bill_amount;


                       IF l_BillAmtITC <> 0 THEN   /* Added for bug 3547687 */

                            l_ArApplAmtFC := (l_ArAmtsTab(l_SobIdIdx).inv_applied_amount / l_BillAmtITC) * l_BillAmtFc;
                       ELSE
                             l_ArApplAmtFC := 0;
                       END IF;

                        IF G_DEBUG_MODE = 'Y' THEN

                          l_LogMsg := 'Retention - FC and ITC are different - Prorating' ||
                                      ' Retn appl amt ITC :' || l_ArAmtsTab(l_SobIdIdx).inv_applied_amount ||
                                      ' Retn amt ITC :' || l_BillAmtITC ||
                                      ' Retn amt FC :' ||  l_BillAmtFC;

                          PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

                       END IF;

                    END IF;

                 ELSE

                    l_ArApplAmtFC := l_ArAmtsTab(l_SobIdIdx).inv_applied_amount;

                 END IF;

                 l_ArApplAmtPFC := l_ArAmtsTab(l_SobIdIdx).projfunc_applied_amount;
                 l_ArGainAmtPFC := l_ArAmtsTab(l_SobIdIdx).projfunc_gain_amount;
                 l_ArLossAmtPFC := l_ArAmtsTab(l_SobIdIdx).projfunc_loss_amount;


              END IF; /*((l_ArAmtsTab.EXISTS(l_SobIdIdx)) AND (p_RetnInvTab.EXISTS(l_SobIdIdx))) */

              IF G_RetnApplAmtTab.EXISTS(l_SobIdIdx) THEN

                 G_RetnApplAmtTab(l_SobIdIdx).funding_applied_amount :=
                                  nvl(G_RetnApplAmtTab(l_SobIdIdx).funding_applied_amount,0) +  l_ArApplAmtFC;
                 G_RetnApplAmtTab(l_SobIdIdx).projfunc_applied_amount :=
                                  nvl(G_RetnApplAmtTab(l_SobIdIdx).projfunc_applied_amount,0) +  l_ArApplAmtPFC;
                 G_RetnApplAmtTab(l_SobIdIdx).projfunc_gain_amount :=
                                  nvl(G_RetnApplAmtTab(l_SobIdIdx).projfunc_gain_amount,0) +  l_ArGainAmtPFC;
                 G_RetnApplAmtTab(l_SobIdIdx).projfunc_loss_amount :=
                                  nvl(G_RetnApplAmtTab(l_SobIdIdx).projfunc_loss_amount,0) +  l_ArLossAmtPFC;
                 G_RetnApplAmtTab(l_SobIdIdx).funding_adj_appl_amount := 0;
                 G_RetnApplAmtTab(l_SobIdIdx).projfunc_adj_appl_amount :=  0;
                 G_RetnApplAmtTab(l_SobIdIdx).projfunc_adj_gain_amount :=  0;
                 G_RetnApplAmtTab(l_SobIdIdx).projfunc_adj_loss_amount :=  0;
                 G_RetnApplAmtTab(l_SobIdIdx).error_status :=  l_ErrorStatus;

              ELSE

                 G_RetnApplAmtTab(l_SobIdIdx).set_of_books_id := l_SobIdIdx;
                 G_RetnApplAmtTab(l_SobIdIdx).funding_applied_amount := l_ArApplAmtFC;
                 G_RetnApplAmtTab(l_SobIdIdx).projfunc_applied_amount := l_ArApplAmtPFC;
                 G_RetnApplAmtTab(l_SobIdIdx).projfunc_gain_amount := l_ArGainAmtPFC;
                 G_RetnApplAmtTab(l_SobIdIdx).projfunc_loss_amount := l_ArLossAmtPFC;
                 G_RetnApplAmtTab(l_SobIdIdx).error_status :=  l_ErrorStatus;

              END IF;

              IF G_DEBUG_MODE = 'Y' THEN

                 l_LogMsg := 'Appl Amt FC:' || round(l_ArApplAmtFC,5) ||
                             ' Appl Amt PFC:' || round(l_ArApplAmtPFC,5) ||
                             ' Gain Amt PFC:' || round(l_ArGainAmtPFC,5) ||
                             ' Loss Amt PFC:' || round(l_ArLossAmtPFC,5);

                 PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

              END IF;

              l_SobIdIdx := G_SobListTab.NEXT(l_SobIdIdx);

         END LOOP;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.process_retention_invoices-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);
             G_RetnApplAmtTab(l_SobId).error_status := x_msg_data;

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'process_retention_invoices:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END process_retention_invoices ;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   get_invoice_components                                                 |
   |   Purpose    :   To fetch and compute invoice related components for funding revaluation|
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                      Mode    Description                                       |
   |     ==================================================================================  |
   |     p_project_id              IN      Project ID                                        |
   |     p_agreement_id            IN      Agreement_id                                      |
   |     p_task_id                 IN      Task Id of summary project funding                |
   |     p_TaskFund_ProjRetn_Flag  IN      Indicates if the agreement is task levl funding   |
   |                                       and retention setup for project is project level  |
   |     x_return_status           OUT     Return status of this procedure                   |
   |     x_msg_count               OUT     Error message count                               |
   |     x_msg_data                OUT     Error message                                     |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE get_invoice_components(
             p_project_id             IN     NUMBER,
             p_agreement_id           IN     NUMBER,
             p_task_id                IN     NUMBER,
             p_TaskFund_ProjRetn_Flag IN     VARCHAR2,
             x_return_status          OUT    NOCOPY VARCHAR2,
             x_msg_count              OUT    NOCOPY NUMBER,
             x_msg_data               OUT    NOCOPY VARCHAR2)   IS



       /* The following CURSOR will select all invoices for given project/agreement for
          primary set of book id and will get executed for
          a) project level funding/project level retention - p_task_id will be zero
          b) project level funding/task level retention    -p_task_id will be zero
                  All task level retention amounts will be summarized to project level funding amounts
       */

       CURSOR get_proj_invoices IS
             (SELECT 'REGULAR-PROJ' invoice_type,
                     PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     0 task_id,
                     di.draft_invoice_num drft_inv_num,
                     dii.invproc_currency_code, dii.projfunc_currency_code, dii.funding_currency_code,
                     di.inv_currency_code, di.system_reference, di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,
                     sum(dii.amount) amount,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount,
                     0 retn_amount,
                     0 projfunc_retn_amount,
                     0 funding_retn_amount,
                     0 inv_retn_amount
              FROM pa_draft_invoice_items dii,
                   pa_draft_invoices di
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND dii.invoice_line_type <> 'RETENTION'
              AND nvl(di.retention_invoice_flag, 'N') = 'N'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num,
                       dii.invproc_currency_code,dii.projfunc_currency_code,
                       dii.funding_currency_code, di.inv_currency_code, di.system_reference, di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       decode(di.draft_invoice_num_credited, NULL, 'N', 'Y')
              UNION
              SELECT 'RETENTION-PROJ' invoice_type,
                     PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     0 task_id,
                     di.draft_invoice_num drft_inv_num,
                     dii.invproc_currency_code, dii.projfunc_currency_code, dii.funding_currency_code,
                     di.inv_currency_code, di.system_reference, di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,
                     sum(dii.amount) amount,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount,
                     0 retn_amount,
                     0 projfunc_retn_amount,
                     0 funding_retn_amount,
                     0 inv_retn_amount
              FROM pa_draft_invoice_items dii,
                   pa_draft_invoices di
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND nvl(di.retention_invoice_flag, 'N') = 'Y'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num,
                       dii.invproc_currency_code,dii.projfunc_currency_code,
                       dii.funding_currency_code, di.inv_currency_code, di.system_reference, di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       decode(di.draft_invoice_num_credited, NULL, 'N', 'Y'))
              ORDER BY drft_inv_num;

       /* The following CURSOR will select all invoices for given project/agreement for
          primary and reporting set of book ids  */


  /* R12 :  Ledger Architecture Changes : The table gl_mc_reporting_options will be  obsolete, replace with
     new table gl_alc_ledger_rships_v and corresponding columns */

/* mrc migration to SLA bug 4571438
       CURSOR get_all_proj_invoices IS
             (SELECT 'REGULAR-PROJ' invoice_type,
                     PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     0 task_id,
                     di.draft_invoice_num drft_inv_num,
                     dii.invproc_currency_code, dii.projfunc_currency_code, dii.funding_currency_code,
                     di.inv_currency_code, di.system_reference, di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,
                     sum(dii.amount) amount,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount,
                     0 retn_amount,
                     0 projfunc_retn_amount,
                     0 funding_retn_amount,
                     0 inv_retn_amount
              FROM pa_draft_invoice_items dii,
                   pa_draft_invoices di
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND dii.invoice_line_type <> 'RETENTION'
              AND nvl(di.retention_invoice_flag, 'N') = 'N'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num,
                       dii.invproc_currency_code,dii.projfunc_currency_code,
                       dii.funding_currency_code, di.inv_currency_code, di.system_reference , di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       decode(di.draft_invoice_num_credited, NULL, 'N', 'Y')
              UNION
              SELECT 'RETENTION-PROJ' invoice_type,
                     PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     0 task_id,
                     di.draft_invoice_num drft_inv_num,
                     dii.invproc_currency_code,
                     dii.projfunc_currency_code,
                     dii.funding_currency_code,
                     di.inv_currency_code,
                     di.system_reference,
                     di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,
                     sum(dii.amount) amount,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount,
                     0 retn_amount,
                     0 projfunc_retn_amount,
                     0 funding_retn_amount,
                     0 inv_retn_amount
              FROM pa_draft_invoice_items dii,
                   pa_draft_invoices di
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND nvl(di.retention_invoice_flag, 'N') = 'Y'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num,
                       dii.invproc_currency_code,dii.projfunc_currency_code,
                       dii.funding_currency_code, di.inv_currency_code, di.system_reference , di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       decode(di.draft_invoice_num_credited, NULL, 'N', 'Y')
              UNION
              SELECT 'REGULAR-PROJ' invoice_type,
                     dii_mc.set_of_books_id,
                     0 task_id,
                     di.draft_invoice_num drft_inv_num,
                     dii.invproc_currency_code,
                     dii_mc.currency_code projfunc_currency_code,
                     dii.funding_currency_code,
                     di.inv_currency_code,
                     di.system_reference,
                     di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,
                     sum(dii.amount) amount,
                     sum(dii_mc.amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount,
                     0 retn_amount,
                     0 projfunc_retn_amount,
                     0 funding_retn_amount,
                     0 inv_retn_amount
              FROM pa_mc_draft_inv_items dii_mc, pa_draft_invoice_items dii, pa_draft_invoices di,
                   gl_alc_ledger_rships_v rep, pa_implementations imp
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND dii.invoice_line_type <> 'RETENTION'
              AND rep.source_ledger_id = imp.set_of_books_id
              AND rep.relationship_enabled_flag  = 'Y'
              AND  (rep.org_id = -99 OR rep.org_id = imp.org_id)
              AND rep.application_id = 275
              AND dii_mc.set_of_books_id =rep.ledger_id
              AND dii_mc.project_id = dii.project_id
              AND dii_mc.draft_invoice_num = dii.draft_invoice_num
              AND dii_mc.line_num = dii.line_num
              AND nvl(di.retention_invoice_flag, 'N') = 'N'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num,dii_mc.set_of_books_id,
                       dii.invproc_currency_code, dii_mc.currency_code,
                       dii.funding_currency_code, di.inv_currency_code, di.system_reference , di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       decode(di.draft_invoice_num_credited, NULL, 'N', 'Y')
              UNION
              SELECT 'RETENTION-PROJ' invoice_type,
                     dii_mc.set_of_books_id,
                     0 task_id,
                     di.draft_invoice_num drft_inv_num,
                     dii.invproc_currency_code,
                     dii_mc.currency_code projfunc_currency_code,
                     dii.funding_currency_code,
                     di.inv_currency_code,
                     di.system_reference,
                     di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,
                     sum(dii.amount) amount,
                     sum(dii_mc.amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount,
                     0 retn_amount,
                     0 projfunc_retn_amount,
                     0 funding_retn_amount,
                     0 inv_retn_amount
              FROM pa_mc_draft_inv_items dii_mc, pa_draft_invoice_items dii, pa_draft_invoices di,
                   gl_alc_ledger_rships_v rep, pa_implementations imp
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND rep.source_ledger_id = imp.set_of_books_id
              AND rep.relationship_enabled_flag  = 'Y'
              AND (rep.org_id = -99 OR rep.org_id = imp.org_id)
              AND rep.application_id = 275
              AND dii_mc.set_of_books_id =rep.ledger_id
              AND dii_mc.project_id = dii.project_id
              AND dii_mc.draft_invoice_num = di.draft_invoice_num
              AND dii_mc.line_num = dii.line_num
              AND nvl(di.retention_invoice_flag, 'N') = 'Y'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num,dii_mc.set_of_books_id,
                       dii.invproc_currency_code, dii_mc.currency_code,
                       dii.funding_currency_code, di.inv_currency_code, di.system_reference, di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       DECOde(di.draft_invoice_num_credited, NULL, 'N', 'Y')
                )
              ORDER BY drft_inv_num, set_of_books_id; */

       /* The following CURSOR will select all invoices for given project/agreement for
          primary set of book id and will get executed for
          a) task level funding/task level retention
          In the case of task level funding /project level retention, only the regular invoices will get selected
          Also the retained amount for the task is obtained separately from RDL.DII.ERDL. To eliminate project
          level retention lines from regular invoice, nvl(dii.task_id) <> 0 is added
          Project level Retention invoices are not required as the retained amount will be calculated for each invoice
          from RDL ERDL DII. These are eliminated by the check nvl(dii.task_id,0) <> 0
       */
       CURSOR get_task_invoices IS
             (SELECT 'REGULAR-TASK' invoice_type,
                     PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     dii.task_id,
                     di.draft_invoice_num drft_inv_num,
                     dii.invproc_currency_code, dii.projfunc_currency_code, dii.funding_currency_code,
                     di.inv_currency_code, di.system_reference, di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,

/*
                     The following is commented and changed as below.

                     sum(dii.amount) amount,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount

                     Standard line amount is required to get the billed amount in PA

                     Retention line amount is required to get the Net line amount (standard - retention)

                     Net line amount is required as AR amounts (invoice level)  are for net invoice amount

                     In order to get the task level (line level) AR amounts, invoice level  AR amounts will be
                     prorated.
                            (invoice level AR amount / invoice level net amount) * task level net amount
*/
/*                  Commented for bug 2794334
                     sum(decode(dii.invoice_line_type,'STANDARD',
                              dii.amount,0)) amount,
                     sum(decode(dii.invoice_line_type,'STANDARD',
                              dii.projfunc_bill_amount,0)) projfunc_bill_amount,
                     sum(decode(dii.invoice_line_type,'STANDARD',
                              dii.funding_bill_amount,0)) funding_bill_amount,
                     sum(decode(dii.invoice_line_type,'STANDARD',
                              dii.inv_amount,0)) inv_amount,
*/
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              0, dii.amount)) amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              0, dii.projfunc_bill_amount)) projfunc_bill_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              0, dii.funding_bill_amount)) funding_bill_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              0, dii.inv_amount)) inv_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              dii.amount,0)) retn_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              dii.projfunc_bill_amount,0)) projfunc_retn_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              dii.funding_bill_amount,0))  funding_retn_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              dii.inv_amount,0)) inv_retn_amount
              FROM pa_draft_invoice_items dii,
                   pa_draft_invoices di
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND nvl(dii.task_id,0) <> 0
              -- AND dii.invoice_line_type <> 'RETENTION'
              AND nvl(di.retention_invoice_flag, 'N') = 'N'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num, dii.task_id,
                       dii.invproc_currency_code,dii.projfunc_currency_code,
                       dii.funding_currency_code, di.inv_currency_code, di.system_reference , di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       decode(di.draft_invoice_num_credited, NULL, 'N', 'Y')
              UNION
              SELECT 'RETENTION-TASK' invoice_type,
                     PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     dii.task_id,
                     di.draft_invoice_num drft_inv_num,
                     dii.invproc_currency_code, dii.projfunc_currency_code, dii.funding_currency_code,
                     di.inv_currency_code, di.system_reference, di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,
                     sum(dii.amount) amount,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount,
                     0 retn_amount,
                     0 projfunc_retn_amount,
                     0 funding_retn_amount,
                     0 inv_retn_amount
              FROM pa_draft_invoice_items dii,
                   pa_draft_invoices di
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND NVL(dii.task_id,0) <> 0
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND nvl(di.retention_invoice_flag, 'N') = 'Y'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num, dii.task_id,
                       dii.invproc_currency_code,dii.projfunc_currency_code,
                       dii.funding_currency_code, di.inv_currency_code, di.system_reference, di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       decode(di.draft_invoice_num_credited, NULL, 'N', 'Y'))
              ORDER BY drft_inv_num, task_id;


       /* This CURSOR is same as previous CURSOR except that ti will select for both primary and reporting set of
           books isd */

  /* R12 :  Ledger Architecture Changes : The table gl_mc_reporting_options will be  obsolete, replace with
     new table gl_alc_ledger_rships_v and corresponding columns */

 /* mrc migration to SLA bug 4571438      CURSOR get_all_task_invoices IS
             (SELECT 'REGULAR-TASK' invoice_type,
                     PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     dii.task_id,
                     di.draft_invoice_num drft_inv_num,
                     dii.invproc_currency_code, dii.projfunc_currency_code, dii.funding_currency_code,
                     di.inv_currency_code, di.system_reference, di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              0, dii.amount)) amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              0, dii.projfunc_bill_amount)) projfunc_bill_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              0, dii.funding_bill_amount)) funding_bill_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              0, dii.inv_amount)) inv_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              dii.amount,0)) retn_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              dii.projfunc_bill_amount,0)) projfunc_retn_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              dii.funding_bill_amount,0)) funding_retn_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              dii.inv_amount,0)) inv_retn_amount
              FROM pa_draft_invoice_items dii,
                   pa_draft_invoices di
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND nvl(dii.task_id,0) <> 0
              -- AND dii.invoice_line_type <> 'RETENTION'
              AND nvl(di.retention_invoice_flag, 'N') = 'N'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num, dii.task_id,
                       dii.invproc_currency_code,dii.projfunc_currency_code,
                       dii.funding_currency_code, di.inv_currency_code, di.system_reference , di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       decode(di.draft_invoice_num_credited, NULL, 'N', 'Y')
              UNION
              SELECT 'RETENTION-TASK' invoice_type,
                     PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     dii.task_id,
                     di.draft_invoice_num drft_inv_num,
                     dii.invproc_currency_code, dii.projfunc_currency_code, dii.funding_currency_code,
                     di.inv_currency_code, di.system_reference, di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,
                     sum(dii.amount) amount,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount,
                     0 retn_amount,
                     0 projfunc_retn_amount,
                     0 funding_retn_amount,
                     0 inv_retn_amount
              FROM pa_draft_invoice_items dii,
                   pa_draft_invoices di
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND NVL(dii.task_id,0) <> 0
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND nvl(di.retention_invoice_flag, 'N') = 'Y'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num, dii.task_id,
                       dii.invproc_currency_code,dii.projfunc_currency_code,
                       dii.funding_currency_code, di.inv_currency_code, di.system_reference , di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       decode(di.draft_invoice_num_credited, NULL, 'N', 'Y')
              UNION
              SELECT 'REGULAR-TASK' invoice_type,
                     dii_mc.set_of_books_id,
                     dii.task_id,
                     di.draft_invoice_num drft_inv_num,
                     dii.invproc_currency_code,
                     dii_mc.currency_code projfunc_currency_code,
                     dii.funding_currency_code,
                     di.inv_currency_code,
                     di.system_reference, di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              0, dii.amount)) amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              0, dii_mc.amount)) projfunc_bill_amount,    -- changed dii.projfunc_bill_amount to dii_mc.amount bug2827328
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              0, dii.funding_bill_amount)) funding_bill_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              0, dii.inv_amount)) inv_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              dii.amount,0)) retn_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              dii_mc.amount,0)) projfunc_retn_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              dii.funding_bill_amount,0)) funding_retn_amount,
                     sum(decode(dii.invoice_line_type,'RETENTION',
                              dii.inv_amount,0)) inv_retn_amount
              FROM pa_mc_draft_inv_items dii_mc, pa_draft_invoice_items dii, pa_draft_invoices di,
                   gl_alc_ledger_rships_v  rep, pa_implementations imp
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND nvl(dii.task_id,0) <> 0
             --  AND dii.invoice_line_type <> 'RETENTION'
              AND rep.source_ledger_id = imp.set_of_books_id
              AND rep.relationship_enabled_flag  = 'Y'
              AND (rep.org_id = -99 OR rep.org_id = imp.org_id)
              AND rep.application_id = 275
              AND dii_mc.set_of_books_id =rep.ledger_id
              AND dii_mc.project_id = dii.project_id
              AND dii_mc.draft_invoice_num = dii.draft_invoice_num
              AND dii_mc.line_num = dii.line_num
              AND nvl(di.retention_invoice_flag, 'N') = 'N'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num,dii.task_id, dii_mc.set_of_books_id,
                       dii.invproc_currency_code, dii_mc.currency_code,
                       dii.funding_currency_code, di.inv_currency_code, di.system_reference , di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       decode(di.draft_invoice_num_credited, NULL, 'N', 'Y')
              UNION
              SELECT 'RETENTION-TASK' invoice_type,
                     dii_mc.set_of_books_id,
                     dii.task_id,
                     di.draft_invoice_num drft_inv_num,
                     dii.invproc_currency_code,
                     dii_mc.currency_code projfunc_currency_code,
                     dii.funding_currency_code,
                     di.inv_currency_code,
                     di.system_reference, di.transfer_status_code,
                     nvl(di.canceled_flag, 'N') canceled_flag,
                     nvl(di.cancel_credit_memo_flag, 'N') cancel_credit_memo_flag,
                     nvl(di.write_off_flag, 'N') write_off_flag,
                     decode(di.draft_invoice_num_credited, NULL, 'N', 'Y') credit_memo_flag,
                     sum(dii.amount) amount,
                     sum(dii_mc.amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount,
                     0 retn_amount,
                     0 projfunc_retn_amount,
                     0 funding_retn_amount,
                     0 inv_retn_amount
              FROM pa_mc_draft_inv_items dii_mc, pa_draft_invoice_items dii, pa_draft_invoices di,
                   gl_alc_ledger_rships_v  rep, pa_implementations imp
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND NVL(dii.task_id,0) <> 0
              AND rep.source_ledger_id = imp.set_of_books_id
              AND rep.relationship_enabled_flag  = 'Y'
              AND (rep.org_id = -99 OR rep.org_id = imp.org_id)
              AND rep.application_id = 275
              AND dii_mc.set_of_books_id =rep.ledger_id
              AND dii_mc.project_id = dii.project_id
              AND dii_mc.draft_invoice_num = dii.draft_invoice_num
              AND dii_mc.line_num = dii.line_num
              AND nvl(di.retention_invoice_flag, 'N') = 'Y'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY di.draft_invoice_num,dii.task_id, dii_mc.set_of_books_id,
                       dii.invproc_currency_code, dii_mc.currency_code,
                       dii.funding_currency_code, di.inv_currency_code, di.system_reference, di.transfer_status_code,
                       canceled_flag, cancel_credit_memo_flag, write_off_flag,
                       decode(di.draft_invoice_num_credited, NULL, 'N', 'Y')
            )
              ORDER BY drft_inv_num, task_id,set_of_books_id; */


         l_InvTypeTab                  PA_PLSQL_DATATYPES.Char30TabTyp;
         l_SetOfBookIdTab              PA_PLSQL_DATATYPES.IdTabTyp;
         l_TaskIdTab                   PA_PLSQL_DATATYPES.IdTabTyp;
         l_DraftInvNumTab              PA_PLSQL_DATATYPES.NumTabTyp;
         l_IPCCurrTab                  PA_PLSQL_DATATYPES.Char30TabTyp;
         l_PFCCurrTab                  PA_PLSQL_DATATYPES.Char30TabTyp;
         l_FCCurrTab                   PA_PLSQL_DATATYPES.Char30TabTyp;
         l_ITCCurrTab                  PA_PLSQL_DATATYPES.Char30TabTyp;
         l_SysRefTab                   PA_PLSQL_DATATYPES.NumTabTyp;
         l_StatusCodeTab               PA_PLSQL_DATATYPES.Char30TabTyp;
         l_BillAmtIPCTab               PA_PLSQL_DATATYPES.NumTabTyp;
         l_BillAmtPFCTab               PA_PLSQL_DATATYPES.NumTabTyp;
         l_BillAmtFCTab                PA_PLSQL_DATATYPES.NumTabTyp;
         l_BillAmtITCTab               PA_PLSQL_DATATYPES.NumTabTyp;
         l_RetnAmtIPCTab               PA_PLSQL_DATATYPES.NumTabTyp;
         l_RetnAmtPFCTab               PA_PLSQL_DATATYPES.NumTabTyp;
         l_RetnAmtFCTab                PA_PLSQL_DATATYPES.NumTabTyp;
         l_RetnAmtITCTab               PA_PLSQL_DATATYPES.NumTabTyp;
         l_CancelFlgTab                PA_PLSQL_DATATYPES.Char1TabTyp;
         l_ClCrMemoFlgTab                PA_PLSQL_DATATYPES.Char1TabTyp;
         l_WrOffFlgTab                 PA_PLSQL_DATATYPES.Char1TabTyp;
         l_CrMemoFlgTab                PA_PLSQL_DATATYPES.Char1TabTyp;



         l_InvTab                      InvTabTyp;
         l_InvIdx                      NUMBER := 0;
         l_InvoiceType                 VARCHAR2(30);
         l_SystemRef                   VARCHAR2(30);
         l_StatusCode                  VARCHAR2(30);
         l_AdjInvFlag                  VARCHAR2(1);
         l_DraftInvNum                 NUMBER;
         l_PrvInvNum                   NUMBER := 0;


         l_TotalFetch               NUMBER := 0;
         l_ThisFetch                NUMBER := 0;
         l_FetchSize                NUMBER := 50;

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;
         l_LogMsg                   VARCHAR2(250);
   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.get_invoice_components-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         /* This procedure get invoice lines for the given project/agreement id.

            If the project is funded at project level then there will be one line per invoice/
            set of book id
            If the project is funded at task level then there will be one line per task/invoice/
            set of book id

            When only primary set of book id is processed and funding level is project, an invoice will
            have only one record fetched and subsequent processing should be invoked for every record

            When primary with task level funding is processed, an invoice will have as many records as the
            number of tasks it comprises and subsequent processing should be invoked only once per set of
            invoice records (i.e for each draft invoice number ) The same is the case when reporting set of
            books are involved for both project and task level funding

            Single/ Multiple record for an invoice (per draft_invoice_num) are passed into a table struture
            l_InvTab

          */

         /* l_AdjInvFlag = 'Y' indicates that the invoice is an adjusting invoice due to Cancel/credit-memo/write-off
            This is required b'cos AR will not return any paid amounts pertaining to these invoice. But this
            amount will be added with the original invoice and returned.

            Total funding amount = 1000

               Inv num   billed amount    paid amount
            Eg inv 1     500              400
               inv 2     -100             0      (Crediting invoice for 1)

            In the above case when both invoices are accpted in AR , for original invoice the paid amount will
            be returned as 500. No amount will be returned for write-off invoice. So the  funding backlog will be 500.

            But currently our invoice model will have this write off amount as available funding. In order to sync
            Funding revaluation also with the invoice model, when this flag is set to 'Y'and accepted in AR, we will
            force  get_ar_amounts to return paid amount also as -100.
         */

         IF G_PRIMARY_ONLY = 'Y' THEN -- (

            IF NVL(p_task_id,0) = 0 THEN  /* Project level funding */

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Cursor get_proj_invoices ' ;
                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

               OPEN get_proj_invoices;

               LOOP

                   FETCH get_proj_invoices BULK COLLECT INTO l_InvTypeTab, l_SetOfBookIdTab, l_TaskIdTab,
                                                             l_DraftInvNumTab, l_IPCCurrTab, l_PFCCurrTab,
                                                             l_FCCurrTab, l_ITCCurrTab, l_SysRefTab, l_StatusCodeTab,
                                                             l_CancelFlgTab, l_ClCrMemoFlgTab, l_WrOffFlgTab, l_CrMemoFlgTab,
                                                             l_BillAmtIPCTab, l_BillAmtPFCTab, l_BillAmtFCTab,
                                                             l_BillAmtITCTab, l_RetnAmtIPCTab,
                                                             l_RetnAmtPFCTab, l_RetnAmtFCTab, l_RetnAmtITCTab
                                           LIMIT  l_FetchSize;

                   l_ThisFetch := get_proj_invoices%ROWCOUNT - l_TotalFetch;
                   l_TotalFetch := get_proj_invoices%ROWCOUNT ;

                   IF l_ThisFetch > 0 THEN

                      FOR i in l_SetOfBookIdTab.FIRST..l_SetOfBookIdTab.LAST LOOP

                          l_InvTab(l_SetOfBookIdTab(i)).set_of_books_id := l_SetOfBookIdTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).task_id := l_TaskIdTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).projfunc_currency_code := l_PFCCurrTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).funding_currency_code := l_FCCurrTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).invproc_currency_code := l_IPCCurrTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).inv_currency_code := l_ITCCurrTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).amount := l_BillAmtIPCTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).projfunc_bill_amount := l_BillAmtPFCTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).funding_bill_amount := l_BillAmtFCTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).inv_amount := l_BillAmtITCTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).retn_amount := l_RetnAmtIPCTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).projfunc_retn_amount := l_RetnAmtPFCTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).funding_retn_amount := l_RetnAmtFCTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).inv_retn_amount := l_RetnAmtITCTab(i);
                          l_SystemRef :=  l_SysRefTab(i);
                          l_StatusCode := l_StatusCodeTab(i);
                          l_DraftInvNum :=  l_DraftInvNumTab(i);
                          l_InvoiceType :=  l_InvTypeTab(i);
                          l_AdjInvFlag := 'N';

                          IF  ((l_CancelFlgTab(i) = 'Y') OR (l_ClCrMemoFlgTab(i) = 'Y') OR  (l_WrOffFlgTab(i) = 'Y')
                                OR (l_CrMemoFlgTab(i) = 'Y')) THEN

                              l_AdjInvFlag := 'Y';

                          END IF;

                          /* Call processing routine for every invoice as no reporting set of books are processed */

                          derive_reval_components (
                                         p_project_id               => p_project_id,
                                         p_task_id                  => p_task_id,
                                         p_agreement_id             => p_agreement_id,
                                         p_draft_inv_num            => l_DraftInvNum,
                                         p_system_reference         => l_SystemRef,
                                         p_invoice_status           => l_StatusCode,
                                         p_adjust_flag              => l_AdjInvFlag,
                                         p_TaskFund_ProjRetn_Flag   => p_TaskFund_ProjRetn_Flag,
                                         p_invoice_type             => l_InvoiceType,
                                         p_InvTab                   => l_InvTab,
                                         x_return_status            => l_return_status,
                                         x_msg_count                => l_msg_count,
                                         x_msg_data                 => l_msg_data);

                          l_InvTab.DELETE;

                          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                             RAISE FND_API.G_EXC_ERROR;

                          END IF;

                      END LOOP; /*SetOfBookIdTab LOO */

                  END IF; /* l_ThisFetch */

                  /* Initialize for next fetch */
                  l_SetOfBookIdTab.DELETE;
                  l_InvTypeTab.DELETE;
                  l_DraftInvNumTab.DELETE;
                  l_TaskIdTab.DELETE;
                  l_IPCCurrTab.DELETE;
                  l_PFCCurrTab.DELETE;
                  l_FCCurrTab.DELETE;
                  l_ITCCurrTab.DELETE;
                  l_SysRefTab.DELETE;
                  l_StatusCodeTab.DELETE;
                  l_CancelFlgTab.DELETE;
                  l_ClCrMemoFlgTab.DELETE;
                  l_WrOffFlgTab.DELETE;
                  l_CrMemoFlgTab.DELETE;
                  l_BillAmtPFCTab.DELETE;
                  l_BillAmtFCTab.DELETE;
                  l_BillAmtITCTab.DELETE;
                  l_BillAmtIPCTab.DELETE;
                  l_RetnAmtIPCTab.DELETE;
                  l_RetnAmtPFCTab.DELETE;
                  l_RetnAmtFCTab.DELETE;
                  l_RetnAmtITCTab.DELETE;

                  IF l_ThisFetch < l_FetchSize THEN
                     Exit;
                  END IF;

               END LOOP; /*get_proj_invoices*/

               CLOSE get_proj_invoices;

            ELSE   /* Task Level funding */

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Cursor get_task_invoices ' ;
                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

               l_InvIdx := 0;
               OPEN get_task_invoices;

               LOOP

                   FETCH get_task_invoices BULK COLLECT INTO l_InvTypeTab, l_SetOfBookIdTab, l_TaskIdTab,
                                                             l_DraftInvNumTab, l_IPCCurrTab, l_PFCCurrTab,
                                                             l_FCCurrTab, l_ITCCurrTab, l_SysRefTab, l_StatusCodeTab,
                                                             l_CancelFlgTab, l_ClCrMemoFlgTab, l_WrOffFlgTab, l_CrMemoFlgTab,
                                                             l_BillAmtIPCTab, l_BillAmtPFCTab, l_BillAmtFCTab,
                                                             l_BillAmtITCTab, l_RetnAmtIPCTab,
                                                             l_RetnAmtPFCTab, l_RetnAmtFCTab, l_RetnAmtITCTab
                                           LIMIT  l_FetchSize;

                   l_ThisFetch := get_task_invoices%ROWCOUNT - l_TotalFetch;
                   l_TotalFetch := get_task_invoices%ROWCOUNT ;

                   IF l_ThisFetch > 0 THEN

                      FOR i in l_SetOfBookIdTab.FIRST..l_SetOfBookIdTab.LAST LOOP
                         /* Call processing routine only if draft invoice number changes */

                          IF l_PrvInvNum = 0 THEN
                             l_PrvInvNum := l_DraftInvNumTab(i);
                          END IF;

                          IF (l_PrvInvNum <> l_DraftInvNumTab(i))  THEN

                              derive_reval_components (
                                         p_project_id               => p_project_id,
                                         p_task_id                  => p_task_id,
                                         p_agreement_id             => p_agreement_id,
                                         p_draft_inv_num            => l_PrvInvNum,
                                         p_system_reference         => l_SystemRef,
                                         p_invoice_status           => l_StatusCode,
                                         p_adjust_flag              => l_AdjInvFlag,
                                         p_TaskFund_ProjRetn_Flag   => p_TaskFund_ProjRetn_Flag,
                                         p_invoice_type             => l_InvoiceType,
                                         p_InvTab                   => l_InvTab,
                                         x_return_status            => l_return_status,
                                         x_msg_count                => l_msg_count,
                                         x_msg_data                 => l_msg_data);

                              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                              ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                                 RAISE FND_API.G_EXC_ERROR;

                              END IF;

                              l_InvTab.DELETE;
                              l_PrvInvNum := l_DraftInvNumTab(i);
                              l_InvIdx := 0;

                          END IF; /*(l_PrvInvNum <> l_DraftInvNumTab(i)) */

                          l_InvIdx := l_InvIdx + 1;
                          l_InvTab(l_InvIdx).set_of_books_id := l_SetOfBookIdTab(i);
                          l_InvTab(l_InvIdx).task_id := l_TaskIdTab(i);
                          l_InvTab(l_InvIdx).projfunc_currency_code := l_PFCCurrTab(i);
                          l_InvTab(l_InvIdx).funding_currency_code := l_FCCurrTab(i);
                          l_InvTab(l_InvIdx).invproc_currency_code := l_IPCCurrTab(i);
                          l_InvTab(l_InvIdx).inv_currency_code := l_ITCCurrTab(i);
                          l_InvTab(l_InvIdx).amount := l_BillAmtIPCTab(i);
                          l_InvTab(l_InvIdx).projfunc_bill_amount := l_BillAmtPFCTab(i);
                          l_InvTab(l_InvIdx).funding_bill_amount := l_BillAmtFCTab(i);
                          l_InvTab(l_InvIdx).inv_amount := l_BillAmtITCTab(i);
                          l_InvTab(l_InvIdx).retn_amount := l_RetnAmtIPCTab(i);
                          l_InvTab(l_InvIdx).projfunc_retn_amount := l_RetnAmtPFCTab(i);
                          l_InvTab(l_InvIdx).funding_retn_amount := l_RetnAmtFCTab(i);
                          l_InvTab(l_InvIdx).inv_retn_amount := l_RetnAmtITCTab(i);
                          l_SystemRef :=  l_SysRefTab(i);
                          l_StatusCode :=  l_StatusCodeTab(i);
                          l_InvoiceType :=  l_InvTypeTab(i);
                          l_AdjInvFlag := 'N';

                          IF  ((l_CancelFlgTab(i) = 'Y') OR (l_ClCrMemoFlgTab(i) = 'Y') OR  (l_WrOffFlgTab(i) = 'Y')
                               OR (l_CrMemoFlgTab(i) = 'Y')) THEN

                              l_AdjInvFlag := 'Y';

                          END IF;


                      END LOOP ;/* l_SetOfBookIdTab*/

                   END IF; /* l_ThisFetch > 0  */


                   /* Process for last set of records */
                   IF (l_ThisFetch < l_FetchSize)  THEN

                      /* Bug 2548142 : added check that atleast a record has been fetched
                       IF (l_ThisFetch > 0 ) THEN - Changing this for bug 4099886 */
		       IF (l_PrvInvNum <> 0 ) THEN

                          derive_reval_components (
                               p_project_id               => p_project_id,
                               p_task_id                  => p_task_id,
                               p_agreement_id             => p_agreement_id,
                               p_draft_inv_num            => l_PrvInvNum,
                               p_system_reference         => l_SystemRef,
                               p_invoice_status           => l_StatusCode,
                               p_adjust_flag              => l_AdjInvFlag,
                               p_TaskFund_ProjRetn_Flag   => p_TaskFund_ProjRetn_Flag,
                               p_invoice_type             => l_InvoiceType,
                               p_InvTab                   => l_InvTab,
                               x_return_status            => l_return_status,
                               x_msg_count                => l_msg_count,
                               x_msg_data                 => l_msg_data);

                          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                             RAISE FND_API.G_EXC_ERROR;

                          END IF;

                          l_InvTab.DELETE;
                          l_InvIdx := 0;

                       END IF; /* l_ThisFetch > 0 */

                       EXIT;

                   END IF; /* l_ThisFetch < l_FetchSize */
                   /* Initialize for next fetch */
                   l_SetOfBookIdTab.DELETE;
                   l_InvTypeTab.DELETE;
                   l_DraftInvNumTab.DELETE;
                   l_TaskIdTab.DELETE;
                   l_IPCCurrTab.DELETE;
                   l_PFCCurrTab.DELETE;
                   l_FCCurrTab.DELETE;
                   l_ITCCurrTab.DELETE;
                   l_SysRefTab.DELETE;
                   l_StatusCodeTab.DELETE;
                   l_CancelFlgTab.DELETE;
                   l_ClCrMemoFlgTab.DELETE;
                   l_WrOffFlgTab.DELETE;
                   l_CrMemoFlgTab.DELETE;
                   l_BillAmtPFCTab.DELETE;
                   l_BillAmtFCTab.DELETE;
                   l_BillAmtITCTab.DELETE;
                   l_BillAmtIPCTab.DELETE;
                   l_RetnAmtIPCTab.DELETE;
                   l_RetnAmtPFCTab.DELETE;
                   l_RetnAmtFCTab.DELETE;
                   l_RetnAmtITCTab.DELETE;

               END LOOP; /*get_task_invoices*/

               CLOSE get_task_invoices;

            END IF; /* p_task_id = 0 */

        -- mrc migration to SLA bug 4571438 ELSE  /* G_PRIMARY_ONLY = 'N' ) */

           /* mrc migration to SLA bug 4571438  ( IF NVL(p_task_id,0) = 0 THEN  -- Project level funding

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Cursor get_all_proj_invoices ' ;
                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

               OPEN get_all_proj_invoices;

               LOOP

                   FETCH get_all_proj_invoices BULK COLLECT INTO l_InvTypeTab, l_SetOfBookIdTab, l_TaskIdTab,
                                                             l_DraftInvNumTab, l_IPCCurrTab, l_PFCCurrTab,
                                                             l_FCCurrTab, l_ITCCurrTab, l_SysRefTab, l_StatusCodeTab,
                                                             l_CancelFlgTab, l_ClCrMemoFlgTab, l_WrOffFlgTab, l_CrMemoFlgTab,
                                                             l_BillAmtIPCTab, l_BillAmtPFCTab, l_BillAmtFCTab,
                                                             l_BillAmtITCTab, l_RetnAmtIPCTab,
                                                             l_RetnAmtPFCTab, l_RetnAmtFCTab, l_RetnAmtITCTab
                                           LIMIT  l_FetchSize;

                   l_ThisFetch := get_all_proj_invoices%ROWCOUNT - l_TotalFetch;
                   l_TotalFetch := get_all_proj_invoices%ROWCOUNT ;

                   IF l_ThisFetch > 0 THEN

                      FOR i in l_SetOfBookIdTab.FIRST..l_SetOfBookIdTab.LAST LOOP
                         -- Call processing routine for every invoice only and not for each task

                          IF l_PrvInvNum = 0 THEN
                             l_PrvInvNum := l_DraftInvNumTab(i);
                          END IF;

                          IF (l_PrvInvNum <> l_DraftInvNumTab(i))  THEN

                              derive_reval_components (
                                         p_project_id               => p_project_id,
                                         p_task_id                  => p_task_id,
                                         p_agreement_id             => p_agreement_id,
                                         p_draft_inv_num            => l_PrvInvNum,
                                         p_system_reference         => l_SystemRef,
                                         p_invoice_status           => l_StatusCode,
                                         p_adjust_flag              => l_AdjInvFlag,
                                         p_TaskFund_ProjRetn_Flag   => p_TaskFund_ProjRetn_Flag,
                                         p_invoice_type             => l_InvoiceType,
                                         p_InvTab                   => l_InvTab,
                                         x_return_status            => l_return_status,
                                         x_msg_count                => l_msg_count,
                                         x_msg_data                 => l_msg_data);

                              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                              ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                                 RAISE FND_API.G_EXC_ERROR;

                              END IF;

                              l_InvTab.DELETE;
                              l_PrvInvNum := l_DraftInvNumTab(i);

                          END IF; -- (l_PrvInvNum <> l_DraftInvNumTab(i))

                          l_InvTab(l_SetOfBookIdTab(i)).set_of_books_id := l_SetOfBookIdTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).task_id := l_TaskIdTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).projfunc_currency_code := l_PFCCurrTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).funding_currency_code := l_FCCurrTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).invproc_currency_code := l_IPCCurrTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).inv_currency_code := l_ITCCurrTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).amount := l_BillAmtIPCTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).projfunc_bill_amount := l_BillAmtPFCTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).funding_bill_amount := l_BillAmtFCTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).inv_amount := l_BillAmtITCTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).retn_amount := l_RetnAmtIPCTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).projfunc_retn_amount := l_RetnAmtPFCTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).funding_retn_amount := l_RetnAmtFCTab(i);
                          l_InvTab(l_SetOfBookIdTab(i)).inv_retn_amount := l_RetnAmtITCTab(i);
                          l_SystemRef :=  l_SysRefTab(i);
                          l_StatusCode :=  l_StatusCodeTab(i);
                          l_InvoiceType :=  l_InvTypeTab(i);
                          l_AdjInvFlag := 'N';

                          IF  ((l_CancelFlgTab(i) = 'Y') OR (l_ClCrMemoFlgTab(i) = 'Y') OR  (l_WrOffFlgTab(i) = 'Y')
                               OR (l_CrMemoFlgTab(i) = 'Y')) THEN

                              l_AdjInvFlag := 'Y';

                          END IF;


                      END LOOP; -- l_SetOfBookIdTab

                   END IF; -- l_ThisFetch > 0

                   -- Process for last set of records
                   IF (l_ThisFetch < l_FetchSize)  THEN

                      -- Bug 2548142 : added check that atleast a record has been fetched
                      -- IF (l_ThisFetch > 0 ) THEN - Changing this for bug 4099886
                      IF (l_PrvInvNum <> 0 ) THEN

                         derive_reval_components (
                               p_project_id               => p_project_id,
                               p_task_id                  => p_task_id,
                               p_agreement_id             => p_agreement_id,
                               p_draft_inv_num            => l_PrvInvNum,
                               p_system_reference         => l_SystemRef,
                               p_invoice_status           => l_StatusCode,
                               p_adjust_flag              => l_AdjInvFlag,
                               p_TaskFund_ProjRetn_Flag   => p_TaskFund_ProjRetn_Flag,
                               p_invoice_type             => l_InvoiceType,
                               p_InvTab                   => l_InvTab,
                               x_return_status            => l_return_status,
                               x_msg_count                => l_msg_count,
                               x_msg_data                 => l_msg_data);

                         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                            RAISE FND_API.G_EXC_ERROR;

                         END IF;

                         l_InvTab.DELETE;

                       END IF; -- l_ThisFetch > 0

                       EXIT;

                   END IF; -- l_ThisFetch < l_FetchSize

                   -- Initialize for next fetch
                   l_SetOfBookIdTab.DELETE;
                   l_InvTypeTab.DELETE;
                   l_DraftInvNumTab.DELETE;
                   l_TaskIdTab.DELETE;
                   l_IPCCurrTab.DELETE;
                   l_PFCCurrTab.DELETE;
                   l_FCCurrTab.DELETE;
                   l_ITCCurrTab.DELETE;
                   l_SysRefTab.DELETE;
                   l_StatusCodeTab.DELETE;
                   l_CancelFlgTab.DELETE;
                   l_ClCrMemoFlgTab.DELETE;
                   l_WrOffFlgTab.DELETE;
                   l_CrMemoFlgTab.DELETE;
                   l_BillAmtPFCTab.DELETE;
                   l_BillAmtFCTab.DELETE;
                   l_BillAmtITCTab.DELETE;
                   l_BillAmtIPCTab.DELETE;
                   l_RetnAmtIPCTab.DELETE;
                   l_RetnAmtPFCTab.DELETE;
                   l_RetnAmtFCTab.DELETE;
                   l_RetnAmtITCTab.DELETE;

               END LOOP ; -- get_all_proj_invoices

               CLOSE get_all_proj_invoices;

            ELSE   -- Task Level funding

               l_InvIdx := 0;

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Cursor get_all_task_invoices ' ;
                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

               OPEN get_all_task_invoices;

               LOOP

                   FETCH get_all_task_invoices BULK COLLECT INTO l_InvTypeTab, l_SetOfBookIdTab, l_TaskIdTab,
                                                             l_DraftInvNumTab, l_IPCCurrTab, l_PFCCurrTab,
                                                             l_FCCurrTab, l_ITCCurrTab, l_SysRefTab, l_StatusCodeTab,
                                                             l_CancelFlgTab, l_ClCrMemoFlgTab, l_WrOffFlgTab, l_CrMemoFlgTab,
                                                             l_BillAmtIPCTab, l_BillAmtPFCTab, l_BillAmtFCTab,
                                                             l_BillAmtITCTab, l_RetnAmtIPCTab,
                                                             l_RetnAmtPFCTab, l_RetnAmtFCTab, l_RetnAmtITCTab
                                           LIMIT  l_FetchSize;

                   l_ThisFetch := get_all_task_invoices%ROWCOUNT - l_TotalFetch;
                   l_TotalFetch := get_all_task_invoices%ROWCOUNT ;

                   IF l_ThisFetch > 0 THEN


                      FOR i in l_SetOfBookIdTab.FIRST..l_SetOfBookIdTab.LAST LOOP
                         -- Call processing routine for every invoice only and not for each task

                          IF l_PrvInvNum = 0 THEN
                             l_PrvInvNum := l_DraftInvNumTab(i);
                          END IF;

                          IF (l_PrvInvNum <> l_DraftInvNumTab(i))  THEN

                              derive_reval_components (
                                         p_project_id               => p_project_id,
                                         p_task_id                  => p_task_id,
                                         p_agreement_id             => p_agreement_id,
                                         p_draft_inv_num            => l_PrvInvNum,
                                         p_system_reference         => l_SystemRef,
                                         p_invoice_status           => l_StatusCode,
                                         p_adjust_flag              => l_AdjInvFlag,
                                         p_TaskFund_ProjRetn_Flag   => p_TaskFund_ProjRetn_Flag,
                                         p_invoice_type             => l_InvoiceType,
                                         p_InvTab                   => l_InvTab,
                                         x_return_status            => l_return_status,
                                         x_msg_count                => l_msg_count,
                                         x_msg_data                 => l_msg_data);

                              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                              ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                                 RAISE FND_API.G_EXC_ERROR;

                              END IF;

                              l_InvTab.DELETE;
                              l_InvIdx := 0;
                              l_PrvInvNum := l_DraftInvNumTab(i);

                          END IF; -- (l_PrvInvNum <> l_DraftInvNumTab(i))
                          l_InvIdx := l_InvIdx + 1;
                          l_InvTab(l_InvIdx).set_of_books_id := l_SetOfBookIdTab(i);
                          l_InvTab(l_InvIdx).task_id := l_TaskIdTab(i);
                          l_InvTab(l_InvIdx).projfunc_currency_code := l_PFCCurrTab(i);
                          l_InvTab(l_InvIdx).funding_currency_code := l_FCCurrTab(i);
                          l_InvTab(l_InvIdx).invproc_currency_code := l_IPCCurrTab(i);
                          l_InvTab(l_InvIdx).inv_currency_code := l_ITCCurrTab(i);
                          l_InvTab(l_InvIdx).amount := l_BillAmtIPCTab(i);
                          l_InvTab(l_InvIdx).projfunc_bill_amount := l_BillAmtPFCTab(i);
                          l_InvTab(l_InvIdx).funding_bill_amount := l_BillAmtFCTab(i);
                          l_InvTab(l_InvIdx).inv_amount := l_BillAmtITCTab(i);
                          l_InvTab(l_InvIdx).retn_amount := l_RetnAmtIPCTab(i);
                          l_InvTab(l_InvIdx).projfunc_retn_amount := l_RetnAmtPFCTab(i);
                          l_InvTab(l_InvIdx).funding_retn_amount := l_RetnAmtFCTab(i);
                          l_InvTab(l_InvIdx).inv_retn_amount := l_RetnAmtITCTab(i);
                          l_SystemRef :=  l_SysRefTab(i);
                          l_StatusCode :=  l_StatusCodeTab(i);
                          l_InvoiceType :=  l_InvTypeTab(i);
                          l_AdjInvFlag := 'N';

                          IF  ((l_CancelFlgTab(i) = 'Y') OR (l_ClCrMemoFlgTab(i) = 'Y') OR  (l_WrOffFlgTab(i) = 'Y')
                               OR (l_CrMemoFlgTab(i) = 'Y')) THEN

                              l_AdjInvFlag := 'Y';

                          END IF;


                      END LOOP ; -- l_SetOfBookIdTab

                   END IF; -- l_ThisFetch > 0

                   -- Process for last set of records
                   IF (l_ThisFetch < l_FetchSize)  THEN

                      -- Bug 2548142 : added check that atleast a record has been fetched
                      -- IF (l_ThisFetch > 0 ) THEN - Changed this for bug 4099886
		      IF (l_PrvInvNum <> 0 ) THEN

                         derive_reval_components (
                               p_project_id               => p_project_id,
                               p_task_id                  => p_task_id,
                               p_agreement_id             => p_agreement_id,
                               p_draft_inv_num            => l_PrvInvNum,
                               p_system_reference         => l_SystemRef,
                               p_invoice_status           => l_StatusCode,
                               p_adjust_flag              => l_AdjInvFlag,
                               p_TaskFund_ProjRetn_Flag   => p_TaskFund_ProjRetn_Flag,
                               p_invoice_type             => l_InvoiceType,
                               p_InvTab                   => l_InvTab,
                               x_return_status            => l_return_status,
                               x_msg_count                => l_msg_count,
                               x_msg_data                 => l_msg_data);

                         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                            RAISE FND_API.G_EXC_ERROR;

                         END IF;

                         l_InvTab.DELETE;
                         l_InvIdx := 0;

                      END IF; -- l_ThisFetch > 0

                      EXIT;

                   END IF; -- l_ThisFetch < l_FetchSize
                   -- Initialize for next fetch
                   l_SetOfBookIdTab.DELETE;
                   l_InvTypeTab.DELETE;
                   l_DraftInvNumTab.DELETE;
                   l_TaskIdTab.DELETE;
                   l_IPCCurrTab.DELETE;
                   l_PFCCurrTab.DELETE;
                   l_FCCurrTab.DELETE;
                   l_ITCCurrTab.DELETE;
                   l_SysRefTab.DELETE;
                   l_StatusCodeTab.DELETE;
                   l_CancelFlgTab.DELETE;
                   l_ClCrMemoFlgTab.DELETE;
                   l_WrOffFlgTab.DELETE;
                   l_CrMemoFlgTab.DELETE;
                   l_BillAmtPFCTab.DELETE;
                   l_BillAmtFCTab.DELETE;
                   l_BillAmtITCTab.DELETE;
                   l_BillAmtIPCTab.DELETE;
                   l_RetnAmtIPCTab.DELETE;
                   l_RetnAmtPFCTab.DELETE;
                   l_RetnAmtFCTab.DELETE;
                   l_RetnAmtITCTab.DELETE;

               END LOOP ; -- get_all_task_invoices

               CLOSE get_all_task_invoices;

            END IF ; --  )p_task_id = 0  */

         END IF ;/* G_PRIMARY_ONLY */

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.get_invoice_components-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'get_invoice_components:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END get_invoice_components;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   derive_reval_components                                                |
   |   Purpose    :   To derive revaluation components from input invoice record             |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                      Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id              IN      Project ID                                        |
   |     p_task_id                 IN      Task Id of summary project funding                |
   |     p_agreement_id            IN      Agreement_id                                      |
   |     p_draft_inv_num           IN      Draft invoice number that is being processed      |
   |     p_system_reference        IN      System Reference trx_id for AR                    |
   |     p_Invoice_Status          IN      Indicates if the input invoice status is accepted |
   |                                       in AR or Not                                      |
   |     p_Adjust_Flag             IN      'Y' Indicates if the invoice is a write-off/cancel/
   |                                       credit memo
   |     p_TaskFund_ProjRetn_Flag  IN      Indicates if the agreement is task levl funding   |
   |                                       and retention setup for project is project level  |
   |     p_Invoice_Type            IN      Indicates if the invoice type is                  |
   |                                       REGULAR-PROJ, RETENTION-PROJ,                     |
   |                                       REGULAR-TASK, RETENTION-TASK                      |
   |     p_InvTab                  IN      Invoice of all set of books for which             |
   |                                       paid amounts and FXGL are to be computed          |
   |     x_return_status           OUT     Return status of this procedure                   |
   |     x_msg_count               OUT     Error message count                               |
   |     x_msg_data                OUT     Error message                                     |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE derive_reval_components(
             p_project_id               IN    NUMBER,
             p_task_id                  IN    NUMBER,
             p_agreement_id             IN    NUMBER,
             p_draft_inv_num            IN    NUMBER,
             p_system_reference         IN    NUMBER,
             p_invoice_status           IN    VARCHAR2,
             p_adjust_flag              IN    VARCHAR2,
             p_TaskFund_ProjRetn_Flag   IN    VARCHAR2,
             p_Invoice_Type             IN    VARCHAR2,
             p_InvTab                   IN    InvTabTyp,
             x_return_status            OUT   NOCOPY VARCHAR2,
             x_msg_count                OUT   NOCOPY NUMBER,
             x_msg_data                 OUT   NOCOPY VARCHAR2)   IS

/* Bug 3221279 Starts */
         i_from_currency_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
         i_to_currency_tab               PA_PLSQL_DATATYPES.Char30TabTyp;
         i_conversion_date_tab           PA_PLSQL_DATATYPES.DateTabTyp;
         i_conversion_type_tab           PA_PLSQL_DATATYPES.Char30TabTyp;
         i_amount_tab                    PA_PLSQL_DATATYPES.NumTabTyp;
         i_user_validate_flag_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
         i_converted_amount_tab          PA_PLSQL_DATATYPES.NumTabTyp;
         i_denominator_tab               PA_PLSQL_DATATYPES.NumTabTyp;
         i_numerator_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
         i_rate_tab                      PA_PLSQL_DATATYPES.NumTabTyp;
         i_conversion_between            VARCHAR2(6);
         i_cache_flag                    VARCHAR2(1);
         i_status_tab                    PA_PLSQL_DATATYPES.Char30TabTyp;
         i_error_flag                    VARCHAR2(1) := 'N';
         l_ITC_due_amount           NUMBER := 0;
         l_revald_pf_inv_due_amount NUMBER := 0;
         i_ProjfuncRateType         Varchar2(30);
/* Bug 3221279 Ends */

         l_BillAmtITC               NUMBER := 0;
         l_BillAmtFC                NUMBER := 0;

         l_BillAmtIPC               NUMBER := 0;
         l_BillAmtPFC               NUMBER := 0;
         l_ApplAmtFC                NUMBER := 0;
         l_ApplAmtPFC               NUMBER := 0;
         l_DueAmtFC                 NUMBER := 0;
         l_DueAmtPFC                NUMBER := 0;
         l_GainAmtPFC               NUMBER := 0;
         l_LossAmtPFC               NUMBER := 0;

         l_ErrorStatus              VARCHAR2(30);
         l_SobId                    NUMBER;

         l_ArApplAmtPFC             NUMBER := 0;
         l_ArApplAmtFC              NUMBER := 0;
         l_ArGainAmtPFC             NUMBER := 0;
         l_ArLossAmtPFC             NUMBER := 0;
       /* Added for bug 7237486 */
         l_ArAdjAmtPFC             NUMBER := 0;
         l_ArAdjAmtFC              NUMBER := 0;
	       l_ProArAdjAmtPFC          NUMBER := 0;
	       l_ProArAdjAmtFC           NUMBER := 0;
       /* Added for bug 7237486 */

         l_ProApplAmtFC             NUMBER := 0;
         l_ProApplAmtPFC            NUMBER := 0;
         l_ProGainAmtPFC            NUMBER := 0;
         l_ProLossAmtPFC            NUMBER := 0;

         l_NetAmtPFC                NUMBER := 0;
         l_NetAmtFC                 NUMBER := 0;

         l_RetainedAmtPFC           NUMBER := 0;
         l_RetainedAmtFC            NUMBER := 0;

         l_RetnApplAmtPFC           NUMBER := 0;
         l_RetnApplAmtFC            NUMBER := 0;
         l_RetnGainAmtPFC           NUMBER := 0;
         l_RetnLossAmtPFC           NUMBER := 0;

         l_PrvInvTskId              NUMBER := 0;
         l_FoundFlag                VARCHAR2(1);
         l_index                    NUMBER;

         l_InvTotTab                InvTotTabTyp;
         l_AdjTotTab                InvTotTabTyp;
         l_ArAmtsTab                ArAmtsTabTyp;
         l_RetainedAmtTab           RetainedAmtTabTyp ;

         l_TotalFetch               NUMBER := 0;
         l_ThisFetch                NUMBER := 0;
         l_FetchSize                NUMBER := 50;

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;
         l_LogMsg                   VARCHAR2(250);
         l_SobIdIdx                    NUMBER;
   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;


         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.derive_reval_components-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

             i_ProjfuncRateType   := nvl(G_RATE_TYPE, G_ProjLvlGlobRec.projfunc_bil_rate_type); /* Added for Bug 3221279 */

         /* This procedure gets line details of a single invoice (primary set of books only) /
            line details of a single invoice for each set of book id (primary and reproting ).

            Based on the invoice status (if accepted in AR) the AR api will be called
            (this check is done inside get_ar_amounts along with other checks
            - AR Installed/not
            - if Include realized gains/loss is enabled )
            which will return applied amounts and FXGL amounts for the invoice in primary/both primary and reporting .

            If reporting set of book id is not enabled AR api will return 0 for all the amounts of that
            sob id.

            ArAmtsTab is indexed by set of book id. This will have one row for each reporting
            set of book id and one for primary set of book id

            Since this routine does at each invoice level the total is summed up against
            each agreement/sob id and stored in global table G_InvCompTab
           */

         IF G_DEBUG_MODE = 'Y' THEN

            l_LogMsg:= 'Draft Inv Num:' || p_draft_inv_num ||
                       ' Agr Task Id :'|| p_task_id ||
                       ' Sysref :' || p_system_reference ||
                       ' inv stat:' || p_invoice_status ||
                       ' inv type:' || p_Invoice_Type;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

         END IF;

         l_ArAmtsTab.DELETE;

         /* p_adjust_flag indicates if the invoice is an adjustment invoice (credit memo/write-off/cancel)
            If so and transferred to AR, the invoiced amount should be returned as paid amount. This is b'cos
            AR returns the adjustment amount + paid amount for the original invoice and returns zero for
            the adjustment invoice. This would result in write-off amount being treated as billed and fully paid
            for Funding revaluation, but invoice model will have this write-off as available funding. Funding
            Revaluation needs to have this as backlog amount to be in sync with invoice model. In order to achieve
            this , the else part of if p_adjust_flag is written. The total for the invoice is returned by the
            get_invoice_total procedure which is then copied to ARamtstab, so that the processing will continue
            normally from thereon
            AR amounts are forced to return
            the adjustment amount, which will offset the billed and paid amount making it to be in sync with
            invoice model */


         IF p_adjust_flag = 'N' THEN

            get_ar_amounts (
               p_customer_trx_id => p_System_Reference,
               p_invoice_status  => p_invoice_status,
               x_ArAmtsTab       => l_ArAmtsTab,
               x_return_status   => l_return_status,
               x_msg_count       => l_msg_count,
               x_msg_data        => l_msg_data);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

               RAISE FND_API.G_EXC_ERROR;

            END IF;

         ELSE

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg:= ' Adjustment Invoice ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            IF ((G_ProjLvlGlobRec.include_gains_losses_flag =  'Y') AND
                 (p_invoice_status = 'A') AND (G_AR_INSTALLED_FLAG = 'Y')) THEN

               l_AdjTotTab.DELETE;

               get_invoice_total (
                   p_project_id    => p_project_id,
                   p_agreement_id  => p_agreement_id,
                   p_draft_inv_num => p_draft_inv_num,
                   x_InvTotTab     => l_AdjTotTab,
                   x_return_status => l_return_status,
                   x_msg_count     => l_msg_count,
                   x_msg_data      => l_msg_data);

               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                   RAISE FND_API.G_EXC_ERROR;

               END IF;

               l_SobId :=  l_AdjTotTab.FIRST;

               LOOP

                 EXIT WHEN l_SobId IS NULL;

                 l_ArAmtsTab(l_SobId).set_of_books_id          := l_AdjTotTab(l_SobId).set_of_books_id;
                 l_ArAmtsTab(l_SobId).inv_applied_amount       := l_AdjTotTab(l_SobId).inv_amount;
                 l_ArAmtsTab(l_SobId).projfunc_applied_amount  := l_AdjTotTab(l_SobId).projfunc_bill_amount;
                 l_ArAmtsTab(l_SobId).projfunc_gain_amount     := 0;
                 l_ArAmtsTab(l_SobId).projfunc_loss_amount     := 0;

                 l_SobId := l_AdjTotTab.NEXT(l_SobId);

               END LOOP;

            END IF;

         END IF;

         /* If the agreement of the invoice is funding for top task then the invoice total is required
            to prorate the AR amounts (applied and FXGL - which will also be returned for the invoice and not
            at line level ) for each task.

            The procedure get_invoice_total will return for the invoice (for all set of book id's)
            invoice amount in IPC (0 in case of MC), PFC, FC (0 in case of MC). The result tab l_InvTotTab is
            indexed by set_of_books_id */


         IF nvl(p_task_id,0) <> 0 THEN  /* Task level funding */

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg:= 'Task level funding ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            l_InvTotTab.DELETE;

            get_invoice_total (
                p_project_id    => p_project_id,
                p_agreement_id  => p_agreement_id,
                p_draft_inv_num => p_draft_inv_num,
                x_InvTotTab     => l_InvTotTab,
                x_return_status => l_return_status,
                x_msg_count     => l_msg_count,
                x_msg_data      => l_msg_data);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                RAISE FND_API.G_EXC_ERROR;

            END IF;

            FOR i in p_InvTab.first..p_InvTab.last loop

                l_BillAmtITC := 0;
                l_BillAmtFC := 0;

                l_BillAmtIPC := 0;
                l_BillAmtPFC := 0;
                l_ApplAmtFC := 0;
                l_ApplAmtPFC := 0;
                l_DueAmtFC  := 0;
                l_DueAmtPFC  := 0;
                l_GainAmtPFC  := 0;
                l_LossAmtPFC  := 0;

                l_ARApplAmtFC := 0;
                l_ARApplAmtPFC := 0;
                l_ARGainAmtPFC := 0;
                l_ARLossAmtPFC := 0;
/* Added for bug 7237486 */
                l_ArAdjAmtPFC  := 0;
                l_ArAdjAmtFC  := 0;
		l_ProArAdjAmtPFC := 0;
	        l_ProArAdjAmtFC := 0;
/* Added for bug 7237486 */
                l_ProApplAmtFC := 0;
                l_ProApplAmtPFC := 0;
                l_ProGainAmtPFC := 0;
                l_ProLossAmtPFC := 0;
                l_NetAmtPFC     := 0;
                l_NetAmtFC      := 0;

                l_RetainedAmtPFC := 0;
                l_RetainedAmtFC := 0;

                l_ErrorStatus    := '';
                l_SobId := p_InvTab(i).set_of_books_id;

                IF G_DEBUG_MODE = 'Y' THEN

                   l_LogMsg := ' ' ;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

                   l_LogMsg := 'Sob Id:' || l_SobId  || ' Task ID:' || p_InvTab(i).task_id;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

                   l_LogMsg := '=================';
                   PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

                END IF;

                 IF l_ARAmtsTab.EXISTS(l_SobId) THEN
                    /* If funding currency and invoice currency are different
                    prorate the AR amounts for funding currency */
                    IF p_InvTab(i).inv_currency_code <> p_InvTab(i).funding_currency_code THEN
                       IF p_InvTab(i).funding_currency_code = p_InvTab(i).projfunc_currency_code THEN
                          IF G_DEBUG_MODE = 'Y' THEN

                             l_LogMsg := 'FC and ITC are different, but = PFC  - assigning';
                             PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

                          END IF;

                          l_ARApplAmtFC := l_ArAmtsTab(l_SobId).projfunc_applied_amount;
			  l_ArAdjAmtFC  := l_ArAmtsTab(l_SobId).projfunc_adjusted_amount;  /* Added for bug 7237486 */
                       ELSE
/*
                          l_BillAmtITC := p_InvTab(i).inv_amount;
                          l_BillAmtFC := p_InvTab(i).funding_bill_amount;
                          This amount should be net amount and not just standard line amount as AR is on net amount
*/
                          l_BillAmtITC := l_InvTotTab(l_SobId).inv_amount;
                          l_BillAmtFC := l_InvTotTab(l_SobId).funding_bill_amount;

                          IF l_BillAmtITC <> 0 THEN   /* Added for bug 3547687 */
                             l_ARApplAmtFC := (l_ARAmtsTab(l_SobId).inv_applied_amount / l_BillAmtITC) *
                                            l_BillAmtFC;
                           l_ArAdjAmtFC  := (l_ARAmtsTab(l_SobId).inv_adjusted_amount/ l_BillAmtITC) *
                                l_BillAmtFC;   /* Added for bug 7237486 */
                          ELSE
                            l_ARApplAmtFC :=0;
                            	    l_ArAdjAmtFC  :=0;  /* Added for bug 7237486 */
                          END IF;

                          IF G_DEBUG_MODE = 'Y' THEN

                             l_LogMsg := 'FC and ITC are different - Prorating';
                             PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                             l_LogMsg := 'Appl amt ITC:' || l_ARAmtsTab(l_SobId).inv_applied_amount ||
                                         ' Tot Bill amt ITC:' || l_BillAmtITC ||
                                         ' Tot Bill amt FC:' ||  l_BillAmtFC ||
                                         ' Appl amt FC:' ||  round(l_ArApplAmtFc,5) ||
					 ' Adj amount FC ' || round(l_ArAdjAmtFC,5);   /* Added for bug 7237486 */

                             PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                          END IF;

                       END IF;

                    ELSE

                          l_ARApplAmtFC := l_ArAmtsTab(l_SobId).inv_applied_amount;
	  l_ArAdjAmtFC  := l_ArAmtsTab(l_SobId).inv_adjusted_amount;  /* Added for bug 7237486 */
                    END IF;

                    /* Applied amount of the entire invoice */

                    l_ARApplAmtPFC := l_ArAmtsTab(l_SobId).projfunc_applied_amount;
                    l_ARGainAmtPFC := l_ArAmtsTab(l_SobId).projfunc_gain_amount;
                    l_ARLossAmtPFC := l_ArAmtsTab(l_SobId).projfunc_loss_amount;
   l_ArAdjAmtPFC  := l_ArAmtsTab(l_SobId).projfunc_adjusted_amount;  /* Added for bug 7237486 */

		    IF G_DEBUG_MODE = 'Y' THEN   /* Added for bug 7237486*/
                    l_LogMsg := 'AR Adjustment Amount in PFC = '||l_ArAdjAmtPFC;
                    PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);
                    END IF;

                 END IF; /*l_ArAmtsTab.EXISTS(l_SobId) */
                 /* AR might not have received any payment. Avoid division by zero error */
                 IF l_ARApplAmtPFC <> 0 THEN
                    /* Prorate the applied amount of  the invoice to the task in porcessing
                       Net amount of the task should be used for proration */

                    /* If task level funding and project level retention, the retention amount for each task
                       will be derived separately */

                    IF p_TaskFund_ProjRetn_Flag = 'Y' THEN
                       /* The procedure get_retained_amount gets retained amount of a single task/invoice for
                          primary or primary and reporting set of books id. Since p_InvTab is indexed by
                          invoice_num, task, set_of_book_id, this procedure needs to be called only once for
                          each task

                          l_RetainedAmtTab is index by set of books id*/

                       /* Get retained amount for the invoice/current task for primary /primay and reporting */
                       IF l_PrvInvTskId <> p_InvTab(i).task_id THEN

                          l_PrvInvTskId :=  p_InvTab(i).task_id;

                          l_RetainedAmtTab.DELETE;
                          get_retained_amount(
                                   p_project_id          => p_project_id,
                                   p_task_id             => l_PrvInvTskId,
                                   p_draft_inv_num       => p_draft_inv_num,
                                   x_RetainedAmtTab      => l_RetainedAmtTab,
                                   x_return_status       => l_return_status,
                                   x_msg_count           => l_msg_count,
                                   x_msg_data            => l_msg_data);
                          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                             RAISE FND_API.G_EXC_ERROR;

                          END IF;

                       END IF; /* l_PrvInvTskId <> p_InvTab(i).task_id */
                       IF l_RetainedAmtTab.EXISTS(l_SobId) THEN
                          l_RetainedAmtPFC := nvl(l_RetainedAmtTab(l_SobID).projfunc_retained_amount,0);
                          l_RetainedAmtFC  := nvl(l_RetainedAmtTab(l_SobID).funding_retained_amount,0);

                       END IF;

                       /* In order to get net amount retained amount should be subtracted from standard
                          amount. In ERDL/DII/RDL it is stored as positive amount */

                       l_NetAmtPFC := p_InvTab(i).projfunc_bill_amount - l_RetainedAmtPFC;
                       l_NetAmtFC  := p_InvTab(i).funding_bill_amount -  l_RetainedAmtFC;

                    ELSE /* p_TaskFund_ProjRetn_Flag = 'N' */

                       /* In order to get net amount retained amount should be subtracted from standard
                          amount. As this is a retention line in draft invoice items, it is stored as
                          negative amount. Hence adding here */

                       l_NetAmtPFC := p_InvTab(i).projfunc_bill_amount + p_InvTab(i).projfunc_retn_amount;
                       l_NetAmtFC  := p_InvTab(i).funding_bill_amount + p_InvTab(i).funding_retn_amount;

                    END IF ; /* IF p_TaskFund_ProjRetn_Flag = 'Y' */

                    IF G_DEBUG_MODE = 'Y' THEN

                       l_LogMsg := 'Net Amt PFC:' || round(l_NetAmtPFC,5) ||
                                   ' Net Amt FC:' || round(l_NetAmtFC,5);

                       PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                    END IF;

/*
                    l_ProApplAmtFc := (l_ARApplAmtFC/l_InvTotTab(l_SobId).funding_bill_amount )*
                                            p_InvTab(i).funding_bill_amount;
                    l_ProApplAmtPFC := (l_ARApplAmtPFC/l_InvTotTab(l_SobId).projfunc_bill_amount )*
                                            p_InvTab(i).projfunc_bill_amount;
*/
                    l_ProApplAmtFC := (l_ARApplAmtFC/l_InvTotTab(l_SobId).funding_bill_amount )* l_NetAmtFC;
                    l_ProApplAmtPFC := (l_ARApplAmtPFC/l_InvTotTab(l_SobId).projfunc_bill_amount )* l_NetAmtPFC;
  l_ProArAdjAmtFC  := (l_ArAdjAmtFC/l_InvTotTab(l_SobId).funding_bill_amount )* l_NetAmtFC;  /* Added for bug 7237486 */
		    l_ProArAdjAmtPFC := (l_ArAdjAmtPFC/l_InvTotTab(l_SobId).projfunc_bill_amount )* l_NetAmtPFC;  /* Added for bug 7237486 */
                    l_ProGainAmtPFC := (l_ARGainAmtPFC/l_ARApplAmtPFC)* l_ProApplAmtPFC;
                    l_ProLossAmtPFC := (l_ARLossAmtPFC/l_ARApplAmtPFC)* l_ProApplAmtPFC;

                 END IF; /* IF l_ARApplAmtPFC <> 0 */

                 IF p_Invoice_Type = 'REGULAR-TASK' THEN /* Task level Normal invoice */

                    /* Billed amounts in different currencies */
                    l_BillAmtIPC := p_InvTab(i).amount;
                    l_BillAmtPFC := p_InvTab(i).projfunc_bill_amount;
                    l_BillAmtFC  := p_InvTab(i).funding_bill_amount;

                    /* Due amount is difference in billed amount and paid amount (prorated in case of task level funding) */

                    l_DueAmtFC := l_BillAmtFC - l_ProApplAmtFC + l_ProArAdjAmtFC;  /* Added for bug 7237486 */
                    l_ApplAmtFC := l_ProApplAmtFC;

                    l_DueAmtPFC := l_BillAmtPFC - l_ProApplAmtPFC + l_ProArAdjAmtPFC;  /* Added for bug 7237486 */
                    l_ApplAmtPFC :=  l_ProApplAmtPFC;

                    l_GainAmtPFC := l_ProGainAmtPFC;
                    l_LossAmtPFC := l_ProLossAmtPFC;

                    /* If task level funding and project level retention, appllied amounts for retention invoices
                       are already cached in G_RetnApplAmtTab. This will also be adjusted againt each invoice if
                       it has retention amounts. The retained amount will be adjusted only if the invoice status
                       is accepted in AR */

                    IF p_TaskFund_ProjRetn_Flag = 'Y' AND p_invoice_status = 'A' THEN


                       IF l_RetainedAmtTab.EXISTS(l_SobId) THEN

                          l_RetainedAmtPFC := nvl(l_RetainedAmtTab(l_SobID).projfunc_retained_amount,0);
                          l_RetainedAmtFC  := nvl(l_RetainedAmtTab(l_SobID).funding_retained_amount,0);

                          IF l_RetainedAmtPFC <> 0 THEN /* only if the invoice/task has any retained amount */

                             adjust_appl_amount (
                                   p_project_id          => p_project_id,
                                   p_agreement_id        => p_agreement_id,
                                   p_SobId               => l_SobId,
                                   p_retained_amount_pfc => l_RetainedAmtPFC,
                                   p_retained_amount_fc  => l_RetainedAmtFC,
                                   x_retn_appl_amt_pfc   => l_RetnApplAmtPFC ,
                                   x_retn_appl_amt_fc    => l_RetnApplAmtFC,
                                   x_retn_Gain_amt_pfc   => l_RetnGainAmtPFC ,
                                   x_retn_Loss_amt_Pfc   => l_RetnLossAmtPFC,
                                   x_return_status       => l_return_status,
                                   x_msg_count           => l_msg_count,
                                   x_msg_data            => l_msg_data);

                             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                                RAISE FND_API.G_EXC_ERROR;

                             END IF;

                             /* Since due amount also has retention amount, when retention amount is paid
                                deduct from due amount and add it to applied amount */

                             l_DueAmtFC := l_DueAmtFC - l_RetnApplAmtFC;
                             l_ApplAmtFC := l_ApplAmtFC + l_RetnApplAmtFC;

                             l_DueAmtPFC := l_DueAmtPFC - l_RetnApplAmtPFC;
                             l_ApplAmtPFC := l_ApplAmtPFC + l_RetnApplAmtPFC;

                             l_GainAmtPFC := l_GainAmtPFC + l_RetnGainAmtPFC;
                             l_LossAmtPFC := l_LossAmtPFC + l_RetnLossAmtPFC;

                          END IF; /* l_RetainedAmtPFC <> 0 */

                       END IF; /*l_RetainedAmtTab.EXISTS(l_SobId) */

                    END IF; /* p_TaskFund_ProjRetn_Flag = 'Y'*/

                 ELSIF p_Invoice_Type = 'RETENTION-TASK' THEN

                    /* This will get executed only for task level funding with task level retention
                       Since the billed amounts are already accounted when the regular invoice
                       holding the retention is processed, here it is 0*/

                    l_BillAmtIPC := 0;
                    l_BillAmtPFC := 0;
                    l_BillAmtFC := 0;

                    l_DueAmtFC := 0 - l_ProApplAmtFC;
                    l_ApplAmtFC := l_ProApplAmtFC;

                    l_DueAmtPFC := 0 - l_ProApplAmtPFC;
                    l_ApplAmtPFC := l_ProApplAmtPFC;

                    l_GainAmtPFC := l_ProGainAmtPFC;
                    l_LossAmtPFC := l_ProLossAmtPFC;

                END IF ;/* p_Invoice_Type = 'REGULAR-TASK' */

/*  Bug 3221279 -  Start */


                /* Commented for bug 3569699
                /* Changed the Index for l_ArAmtsTab,G_SobListTab and p_InvTab for bug 3555798
                IF l_ArAmtsTab.EXISTS(l_SobId) THEN
                     l_ITC_due_amount := (p_InvTab(i).inv_amount-l_ARAmtsTab(l_SobId).inv_applied_amount);
                ELSE
                     l_ITC_due_amount := p_InvTab(i).inv_amount;
	        END IF; /*l_ArAmtsTab.EXISTS(l_SobIdIdx)
                 */

                /* IF condition added for Bug 3569699 */
                IF p_InvTab(i).funding_bill_amount <> 0 THEN
                     l_ITC_due_amount := pa_currency.round_trans_currency_amt(
                                 (l_DueAmtFC * (p_InvTab(i).inv_amount / p_InvTab(i).funding_bill_amount)),p_InvTab(i).inv_currency_code);
                ELSE
                    l_ITC_due_amount:= 0;
                END IF;

               IF G_DEBUG_MODE = 'Y' THEN
                 l_LogMsg := 'original inv due amount : p_InvTab(i).inv_amount ' || p_InvTab(i).inv_amount;
		 IF l_ArAmtsTab.EXISTS(l_SobId) THEN
		    l_LogMsg:=l_LogMsg||'original inv due amount : l_ARAmtsTab(l_SobId).inv_applied_amount: ' ||l_ARAmtsTab(l_SobId).inv_applied_amount;
                 ELSE
		    l_LogMsg:=l_LogMsg||'original inv due amount : l_ARAmtsTab(l_SobId).inv_applied_amount: 0';
		 END IF;
                 PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);
                 l_LogMsg := 'New inv due amount : p_InvTab(i).inv_amount ' || p_InvTab(i).inv_amount;
                 l_LogMsg := l_LogMsg || 'New inv due amount : p_InvTab(i).funding_bill_amount ' || p_InvTab(i).funding_bill_amount;
                 l_LogMsg := l_LogMsg || 'New inv due amount : l_DueAmtFC ' || l_DueAmtFC;
                 l_LogMsg := l_LogMsg || 'New inv due amount : ' || l_ITC_due_amount ;
                 PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);
                 l_LogMsg := ' '; /* Bug 4346765 */
               END IF;

                i_conversion_type_tab.DELETE;
                i_to_currency_tab.DELETE;
                i_from_currency_tab.DELETE;
                i_amount_tab.DELETE;
                i_user_validate_flag_tab.DELETE;
                i_converted_amount_tab.DELETE;
                i_denominator_tab.DELETE;
                i_numerator_tab.DELETE;
                i_rate_tab.DELETE;
                i_status_tab.DELETE;


         /* Populating to get rate for conversion from funding to projfunc currency
            The amount is passed as 1 because only the rate is required to pass it to client extension */
            IF p_InvTab(i).inv_currency_code <> nvl(G_SobListTab(l_SobId).ReportingCurrencyCode,
                                                        p_InvTab(i).projfunc_currency_code) then
                i_from_currency_tab(1) :=  p_InvTab(i).inv_currency_code;
		i_to_currency_tab(1) :=  nvl(G_SobListTab(l_SobId).ReportingCurrencyCode,  p_InvTab(i).projfunc_currency_code);
		i_conversion_date_tab(1) := G_RATE_DATE;
	        i_conversion_type_tab(1) := nvl(G_SobListTab(l_SobId).ConversionType,i_ProjfuncRateType);
                i_amount_tab(1) := 1;
                i_user_validate_flag_tab(1) := 'Y';
                i_converted_amount_tab(1) := 0;
                i_denominator_tab(1) := 0;
                i_numerator_tab(1) := 0;
                i_rate_tab(1) := 0;
                i_conversion_between:= 'IC_PFC';


                PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
                      p_from_currency_tab             => i_from_currency_tab,
                      p_to_currency_tab               => i_to_currency_tab,
                      p_conversion_date_tab           => i_conversion_date_tab,
                      p_conversion_type_tab           => i_conversion_type_tab,
                      p_amount_tab                    => i_amount_tab,
                      p_user_validate_flag_tab        => i_user_validate_flag_tab,
                      p_converted_amount_tab          => i_converted_amount_tab,
                      p_denominator_tab               => i_denominator_tab,
                      p_numerator_tab                 => i_numerator_tab,
                      p_rate_tab                      => i_rate_tab,
                      x_status_tab                    => i_status_tab,
                      p_conversion_between            => i_conversion_between,
                      p_cache_flag                    => 'Y');

                IF (i_status_tab(1) <> 'N') THEN

                      ROLLBACK;

                       --l_msg_data := l_status_tab(1);
                       l_return_status := FND_API.G_RET_STS_ERROR;

            /* Stamp rejection reason in PA_SPF */
                       insert_rejection_reason_spf (
                             p_project_id     => G_ProjLvlGlobRec.project_id,
                             p_agreement_id   => p_agreement_id,
                             p_task_id        => p_task_id,
                             p_reason_code    => i_status_tab(1),
                             x_return_status  => l_return_status,
                             x_msg_count      => l_msg_count,
                             x_msg_data       => l_msg_data) ;

                       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                       ELSE /* l_return_status = FND_API.G_RET_STS_UNEXP_ERROR */

                          l_msg_data := i_status_tab(1);
                          l_return_status := FND_API.G_RET_STS_ERROR;

                          RAISE FND_API.G_EXC_ERROR;

                       END IF; /* l_return_status = FND_API.G_RET_STS_UNEXP_ERROR */
                END IF; /* i_status_tab(1) <> 'N' */
                l_revald_pf_inv_due_amount := l_ITC_due_amount*i_rate_tab(1);

                l_LogMsg := 'Inv currency code :' || p_InvTab(i).inv_currency_code;
		l_LogMsg := l_LogMsg || ' to currency : ' ||  p_InvTab(i).projfunc_currency_code ;
                l_LogMsg := l_LogMsg || 'l_ITC_due_amount :' || l_ITC_due_amount || 'projfunc_rate_type :' || i_ProjfuncRateType;
                l_LogMsg := l_LogMsg || 'projfunc_inv_rate after calling amount_bulk :' || i_rate_tab(1);
                l_LogMsg := l_LogMsg || 'projfunc_inv_duie amount after assigning :' ||  l_revald_pf_inv_due_amount ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);
                l_LogMsg := ' '; /* Bug 4346765 */

             ELSE
                l_revald_pf_inv_due_amount := l_ITC_due_amount;

                l_LogMsg := l_LogMsg || 'l_ITC_due_amount :' || l_ITC_due_amount || 'projfunc_rate_type :' || i_ProjfuncRateType;
                l_LogMsg := l_LogMsg || 'projfunc_inv_due amount after assigning :' ||  l_revald_pf_inv_due_amount ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);
                l_LogMsg := ' '; /* Bug 4346765 */
            END IF; /* if IC<>PFC */
/*  Bug 3221279 -  End */


                /* Put in g_InvCompTab
                   Since invoices are processed only once for an agreement (even though agreement funds multiple tasks)
                   this table will have summary amounts of each agreement-task funding record for primary and reproting
                   set of books. So it is not indexed by sob_id as like other tables
                */
                l_FoundFlag := 'N';
                IF G_InvCompTab.count > 0 THEN
                   FOR j in G_InvCompTab.first..G_InvCompTab.LAST LOOP

                       IF G_InvCompTab(j).set_of_books_id = l_SobID and
                          G_InvCompTab(j).task_id = p_InvTab(i).task_id THEN


                          G_InvCompTab(j).invproc_billed_amount :=
                                        nvl(G_InvCompTab(j).invproc_billed_amount,0) + l_BillAmtIPC;
                          G_InvCompTab(j).funding_billed_amount :=
                                        nvl(G_InvCompTab(j).funding_billed_amount,0) + l_BillAmtFC;
                          G_InvCompTab(j).projfunc_billed_amount :=
                                        nvl(G_InvCompTab(j).projfunc_billed_amount,0) + l_BillAmtPFC;
                          G_InvCompTab(j).funding_applied_amount :=
                                        nvl(G_InvCompTab(j).funding_applied_amount,0) + l_ApplAmtFC;
                          G_InvCompTab(j).projfunc_applied_amount :=
                                        nvl(G_InvCompTab(j).projfunc_applied_amount,0) + l_ApplAmtPFC;
                          G_InvCompTab(j).projfunc_gain_amount :=
                                        nvl(G_InvCompTab(j).projfunc_gain_amount,0) + l_GainAmtPFC;
                          G_InvCompTab(j).projfunc_loss_amount :=
                                        nvl(G_InvCompTab(j).projfunc_loss_amount,0) + l_LossAmtPFC;
                          G_InvCompTab(j).revald_pf_inv_due_amount :=
                                        nvl(G_InvCompTab(j).revald_pf_inv_due_amount,0) + l_revald_pf_inv_due_amount; /* Bug 3221279 */
                         G_InvCompTab(j).funding_adjusted_amount :=
			                nvl(G_InvCompTab(j).funding_adjusted_amount,0) + l_ArAdjAmtFC;  /* Added for bug 7237486 */
			  G_InvCompTab(j).projfunc_adjusted_amount :=
			                nvl(G_InvCompTab(j).projfunc_adjusted_amount,0) + l_ArAdjAmtPFC;   /* Added for bug 7237486 */
                         l_FoundFlag := 'Y';

                          EXIT;
                      END IF;

                   END LOOP;

                END IF;

                IF l_foundFlag = 'N' THEN

                   l_index := G_InvCompTab.Count + 1;

                   G_InvCompTab(l_index).project_id := p_project_id;
                   G_InvCompTab(l_index).agreement_id := p_agreement_id;
                   G_InvCompTab(l_index).task_id := p_InvTab(i).task_id;
                   G_InvCompTab(l_index).set_of_books_id := l_SobId;
                   G_InvCompTab(l_index).invproc_billed_amount := l_BillAmtIPC;
                   G_InvCompTab(l_index).funding_billed_amount := l_BillAmtFC;
                   G_InvCompTab(l_index).projfunc_billed_amount := l_BillAmtPFC;
                   G_InvCompTab(l_index).funding_applied_amount := l_ApplAmtFC;
                   G_InvCompTab(l_index).projfunc_applied_amount := l_ApplAmtPFC;
                   G_InvCompTab(l_index).projfunc_gain_amount := l_GainAmtPFC;
                   G_InvCompTab(l_index).projfunc_loss_amount := l_LossAmtPFC;
                   G_InvCompTab(l_index).revald_pf_inv_due_amount:= l_revald_pf_inv_due_amount;          /* Bug 3221279 */
                     G_InvCompTab(l_index).funding_adjusted_amount := l_ArAdjAmtFC;  /* Added for bug 7237486*/
		   G_InvCompTab(l_index).projfunc_adjusted_amount := l_ArAdjAmtPFC;   /* Added for bug 7237486 */
                END IF;

                IF G_DEBUG_MODE = 'Y' THEN

                   l_LogMsg := 'Billed Amt PFC:' || l_BillAmtPFC ||
                               ' Billed Amt FC:' || l_BillAmtFC ||
                               ' Billed Amt IPC:' || l_BillAmtIPC ;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                   l_LogMsg := 'Appl Amt FC:' || round(l_ApplAmtFC,5) ||
                               ' Appl Amt PFC:' || round(l_ApplAmtPFC,5) ||
                               ' Gain Amt PFC:' || round(l_GainAmtPFC,5) ||
                               ' Loss Amt PFC:' || round(l_LossAmtPFC,5) ;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                END IF;

             END LOOP;

         ELSE  /* project level funding */

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg:= 'Project level funding ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            l_SobIdIdx := G_SobListTab.FIRST;

            LOOP

                EXIT WHEN l_SobIdIdx IS NULL;

                l_BillAmtITC := 0;
                l_BillAmtFC := 0;

                l_BillAmtIPC := 0;
                l_BillAmtPFC := 0;
                l_ApplAmtFC := 0;
                l_ApplAmtPFC := 0;
                l_DueAmtFC  := 0;
                l_DueAmtPFC  := 0;
                l_GainAmtPFC  := 0;
                l_LossAmtPFC  := 0;

                l_ARApplAmtFC := 0;
                l_ARApplAmtPFC := 0;
                l_ARGainAmtPFC := 0;
                l_ARLossAmtPFC := 0;
                /* Added for bug 7237486 */
                l_ArAdjAmtPFC := 0;
                l_ArAdjAmtFC := 0;
/* Added for bug 7237486 */
                l_ErrorStatus    := '';

                IF G_DEBUG_MODE = 'Y' THEN

                   l_LogMsg := ' ' ;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

                   l_LogMsg := 'Sob Id:' || l_SobIdIdx ;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

                   l_LogMsg := '==================';
                   PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

                END IF;

                IF l_ArAmtsTab.EXISTS(l_SobIdIdx) THEN

                    /* If funding currency and invoice currency are different
                    prorate the AR amounts for funding currency */

                    IF p_InvTab(l_SobIdIdx).inv_currency_code <> p_InvTab(l_SobIdIdx).funding_currency_code THEN

                       IF p_InvTab(l_SobIdIdx).funding_currency_code =
                                             p_InvTab(l_SobIdIdx).projfunc_currency_code THEN

                          IF G_DEBUG_MODE = 'Y' THEN

                             l_LogMsg := ' FC and ITC are different, but = PFC  - assigning';
                             PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

                          END IF;

                          l_ARApplAmtFC := l_ArAmtsTab(l_SobIdIdx).projfunc_applied_amount;
		  l_ArAdjAmtFC := l_ArAmtsTab(l_SobIdIdx).projfunc_adjusted_amount;   /* Added for bug 7237486 */

                          IF G_DEBUG_MODE = 'Y' THEN

                             l_LogMsg := ' AR Adjusted amount in FC = '||l_ArAdjAmtFC;   /* Added for bug 7237486 */
                             PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

                                                     END IF;/* Added for bug 7237486 */

                       ELSE

                          l_BillAmtITC := p_InvTab(l_SobIdIdx).inv_amount;
                          l_BillAmtFC := p_InvTab(l_SobIdIdx).funding_bill_amount;

                          IF l_BillAmtITC <> 0 THEN   /* Added for Debug checkin 3547687 */
                               l_ARApplAmtFC := (l_ARAmtsTab(l_SobIdIdx).inv_applied_amount / l_BillAmtITC) *
                                            l_BillAmtFC;
                                              l_ArAdjAmtFC := (l_ARAmtsTab(l_SobIdIdx).inv_adjusted_amount / l_BillAmtITC) *
                                            l_BillAmtFC;  /* Added for bug 7237486 */
                          ELSE
                               l_ARApplAmtFC := 0;
                                 l_ArAdjAmtFC := 0;  /* Added for bug 7237486 */
                          END IF;

                          IF G_DEBUG_MODE = 'Y' THEN

                             l_LogMsg := 'FC and ITC are different - Prorating' ||
                                         'Appl amt ITC:' || l_ARAmtsTab(l_SobIdIdx).inv_applied_amount ||
                                         'Bill amt ITC:' || l_BillAmtITC ||
                                         'Bill amt FC:' ||  l_BillAmtFC;

                             PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                          END IF;

                       END IF;
                    ELSE

                       l_ARApplAmtFC := l_ArAmtsTab(l_SobIdIdx).inv_applied_amount;
                       		       l_ArAdjAmtFC  := l_ArAmtsTab(l_SobIdIdx).inv_adjusted_amount;   /* Added for bug 7237486 */

                    END IF;

                    l_ARApplAmtPFC := l_ArAmtsTab(l_SobIdIdx).projfunc_applied_amount;
                    l_ARGainAmtPFC := l_ArAmtsTab(l_SobIdIdx).projfunc_gain_amount;
                    l_ARLossAmtPFC := l_ArAmtsTab(l_SobIdIdx).projfunc_loss_amount;
                               l_ArAdjAmtPFC := l_ArAmtsTab(l_SobIdIdx).projfunc_adjusted_amount;  /* Added for bug 7237486 */

                          IF G_DEBUG_MODE = 'Y' THEN

                             l_LogMsg := ' AR Adjusted amount in PFC = '||l_ArAdjAmtPFC;   /* Added for bug 7237486 */
                             PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

                          END IF;

                END IF; /*l_ArAmtsTab.EXISTS(l_SobIdIdx) */

                IF p_Invoice_Type = 'REGULAR-PROJ' THEN

                   l_BillAmtIPC :=  p_InvTab(l_SobIdIdx).amount;

                   l_BillAmtPFC := p_InvTab(l_SobIdIdx).projfunc_bill_amount;
                   l_BillAmtFC  := p_InvTab(l_SobIdIdx).funding_bill_amount;

                   l_DueAmtFC := l_BillAmtFC - l_ARApplAmtFC + l_ArAdjAmtFC;   /* Added for bug 7237486 */
                   l_ApplAmtFC := l_ARApplAmtFC;

                   l_DueAmtPFC := l_BillAmtPFC - l_ARApplAmtPFC + l_ArAdjAmtPFC;   /* Added for bug 7237486 */
                   l_ApplAmtPFC := l_ARApplAmtPFC;

                   l_GainAmtPFC := l_ARGainAmtPFC;
                   l_LossAmtPFC := l_ARLossAmtPFC;

                ELSIF p_Invoice_Type = 'RETENTION-PROJ' THEN

                   l_BillAmtIPC := 0;
                   l_BillAmtPFC := 0;
                   l_BillAmtFC := 0;

                   l_DueAmtFC := - l_ARApplAmtFC;
                   l_ApplAmtFC := l_ARApplAmtFC;

                   l_DueAmtPFC :=  - l_ARApplAmtPFC;
                   l_ApplAmtPFC := l_ARApplAmtPFC;

                   l_GainAmtPFC := l_ARGainAmtPFC;
                   l_LossAmtPFC := l_ARLossAmtPFC;

                END IF; /* InvoiceType */

                /* Put in g_InvCompTab */

                /* Commented for bug 2731637 as this tab should be indexed by seq no and not sob id  and rewritten below

                IF G_InvCompTab.EXISTS(l_SobIdIdx) THEN

                        IF G_DEBUG_MODE = 'Y' THEN

                           l_LogMsg := ' Proje level ' || l_SobIdIdx || ' already exists adding';
                           PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                        END IF;

                        G_InvCompTab(l_SobIdIdx).invproc_billed_amount :=
                                        nvl(G_InvCompTab(l_SobIdIdx).invproc_billed_amount,0) + l_BillAmtIPC;

                        G_InvCompTab(l_SobIdIdx).funding_billed_amount :=
                                        nvl(G_InvCompTab(l_SobIdIdx).funding_billed_amount,0) + l_BillAmtFC;
                        G_InvCompTab(l_SobIdIdx).projfunc_billed_amount :=
                                        nvl(G_InvCompTab(l_SobIdIdx).projfunc_billed_amount,0) + l_BillAmtPFC;
                        G_InvCompTab(l_SobIdIdx).funding_applied_amount :=
                                        nvl(G_InvCompTab(l_SobIdIdx).funding_applied_amount,0) + l_ApplAmtFC;
                        G_InvCompTab(l_SobIdIdx).projfunc_applied_amount :=
                                        nvl(G_InvCompTab(l_SobIdIdx).projfunc_applied_amount,0) + l_ApplAmtPFC;
                        G_InvCompTab(l_SobIdIdx).projfunc_gain_amount :=
                                        nvl(G_InvCompTab(l_SobIdIdx).projfunc_gain_amount,0) + l_GainAmtPFC;
                        G_InvCompTab(l_SobIdIdx).projfunc_loss_amount :=
                                        nvl(G_InvCompTab(l_SobIdIdx).projfunc_loss_amount,0) + l_LossAmtPFC;

                ELSE

                        IF G_DEBUG_MODE = 'Y' THEN

                           l_LogMsg := ' Proje level ' || l_SobIdIdx || ' does not exists assigning';
                           PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                        END IF;
                        G_InvCompTab(l_SobIdIdx).project_id := p_project_id;
                        G_InvCompTab(l_SobIdIdx).agreement_id := p_agreement_id;
                        G_InvCompTab(l_SobIdIdx).task_id := p_task_id;
                        G_InvCompTab(l_SobIdIdx).set_of_books_id := l_SobIdIdx;
                        G_InvCompTab(l_SobIdIdx).invproc_billed_amount := l_BillAmtIPC;
                        G_InvCompTab(l_SobIdIdx).funding_billed_amount := l_BillAmtFC;
                        G_InvCompTab(l_SobIdIdx).projfunc_billed_amount := l_BillAmtPFC;
                        G_InvCompTab(l_SobIdIdx).funding_applied_amount := l_ApplAmtFC;
                        G_InvCompTab(l_SobIdIdx).projfunc_applied_amount := l_ApplAmtPFC;
                        G_InvCompTab(l_SobIdIdx).projfunc_gain_amount := l_GainAmtPFC;
                        G_InvCompTab(l_SobIdIdx).projfunc_loss_amount := l_LossAmtPFC;
                END IF;
                */

               /*Bug 3221279 - Start */

                /*  Commented for Bug 3569699
                IF l_ArAmtsTab.EXISTS(l_SobIdIdx) THEN
                     l_ITC_due_amount := (p_InvTab(l_SobIdIdx).inv_amount-l_ARAmtsTab(l_SobIdIdx).inv_applied_amount);
                ELSE
                     l_ITC_due_amount := p_InvTab(l_SobIdIdx).inv_amount;
                END IF; /*l_ArAmtsTab.EXISTS(l_SobIdIdx)
                */

                 /* IF condition added for Bug 3569699 */

                IF p_InvTab(l_SobIdIdx).funding_bill_amount <> 0 THEN
                     l_ITC_due_amount :=  pa_currency.round_trans_currency_amt(
                                 (l_DueAmtFC * (p_InvTab(l_SobIdIdx).inv_amount / p_InvTab(l_SobIdIdx).funding_bill_amount)),
                                                              p_InvTab(l_SobIdIdx).inv_currency_code);
                ELSE
                    l_ITC_due_amount:= 0;
                END IF;


                IF G_DEBUG_MODE = 'Y' THEN
                 l_LogMsg := 'original inv due amount : p_InvTab(l_SobIdIdx).inv_amount ' || p_InvTab(l_SobIdIdx).inv_amount;
                 IF l_ArAmtsTab.EXISTS(l_SobIdIdx) THEN
                    l_LogMsg:=l_LogMsg||'original inv due amount : l_ARAmtsTab(l_SobIdIdx).inv_applied_amount: ' ||l_ARAmtsTab(l_SobIdIdx).inv_applied_amount;
                 ELSE
                    l_LogMsg:=l_LogMsg||'original inv due amount : l_ARAmtsTab(l_SobId).inv_applied_amount: 0';
                 END IF;
                 PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);
                 l_LogMsg := 'New inv due amount : p_InvTab(l_SobIdIdx).inv_amount ' || p_InvTab(l_SobIdIdx).inv_amount;
                 l_LogMsg := l_LogMsg || 'New inv due amount : p_InvTab(l_SobIdIdx).funding_bill_amount ' || p_InvTab(l_SobIdIdx).funding_bill_amount;
                 l_LogMsg := l_LogMsg || 'New inv due amount : l_DueAmtFC ' || l_DueAmtFC;
                 l_LogMsg := l_LogMsg || 'New inv due amount : ' || l_ITC_due_amount ;
                 PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);
                 l_LogMsg := ' '; /* Bug 4346765 */
                END IF;

                i_conversion_type_tab.DELETE;
                i_to_currency_tab.DELETE;
                i_from_currency_tab.DELETE;
                i_amount_tab.DELETE;
                i_user_validate_flag_tab.DELETE;
                i_converted_amount_tab.DELETE;
                i_denominator_tab.DELETE;
                i_numerator_tab.DELETE;
                i_rate_tab.DELETE;
                i_status_tab.DELETE;

         /* Populating to get rate for conversion from funding to projfunc currency
            The amount is passed as 1 because only the rate is required to pass it to client extension */
             if  p_InvTab(l_SobIdIdx).inv_currency_code <> nvl(G_SobListTab(l_SobIdIdx).ReportingCurrencyCode,
                                                               p_InvTab(l_SobIdIdx).projfunc_currency_code) then

                i_from_currency_tab(1) :=  p_InvTab(l_SobIdIdx).inv_currency_code;
		i_to_currency_tab(1) :=  nvl(G_SobListTab(l_SobIdIdx).ReportingCurrencyCode, p_InvTab(l_SobIdIdx).projfunc_currency_code);
		i_conversion_date_tab(1) := G_RATE_DATE;
		i_conversion_type_tab(1) := nvl(G_SobListTab(l_SobIdIdx).ConversionType,i_ProjfuncRateType);
                i_amount_tab(1) := 1;
                i_user_validate_flag_tab(1) := 'Y';
                i_converted_amount_tab(1) := 0;
                i_denominator_tab(1) := 0;
                i_numerator_tab(1) := 0;
                i_rate_tab(1) := 0;
                i_conversion_between:= 'IC_PFC';

                PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
                      p_from_currency_tab             => i_from_currency_tab,
                      p_to_currency_tab               => i_to_currency_tab,
                      p_conversion_date_tab           => i_conversion_date_tab,
                      p_conversion_type_tab           => i_conversion_type_tab,
                      p_amount_tab                    => i_amount_tab,
                      p_user_validate_flag_tab        => i_user_validate_flag_tab,
                      p_converted_amount_tab          => i_converted_amount_tab,
                      p_denominator_tab               => i_denominator_tab,
                      p_numerator_tab                 => i_numerator_tab,
                      p_rate_tab                      => i_rate_tab,
                      x_status_tab                    => i_status_tab,
                      p_conversion_between            => i_conversion_between,
                      p_cache_flag                    => 'Y');

               IF (i_status_tab(1) <> 'N') THEN

                      ROLLBACK;

                       --l_msg_data := l_status_tab(1);
                       l_return_status := FND_API.G_RET_STS_ERROR;

            /* Stamp rejection reason in PA_SPF */
                       insert_rejection_reason_spf (
                             p_project_id     => G_ProjLvlGlobRec.project_id,
                             p_agreement_id   => p_agreement_id,
                             p_task_id        => p_task_id,
                             p_reason_code    => i_status_tab(1),
                             x_return_status  => l_return_status,
                             x_msg_count      => l_msg_count,
                             x_msg_data       => l_msg_data) ;

                       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                       ELSE /* l_return_status = FND_API.G_RET_STS_UNEXP_ERROR */

                          l_msg_data := i_status_tab(1);
                          l_return_status := FND_API.G_RET_STS_ERROR;

                          RAISE FND_API.G_EXC_ERROR;

                       END IF; /* l_return_status = FND_API.G_RET_STS_UNEXP_ERROR */
                END IF; /* i_status_tab(1) <> 'N' */

                l_revald_pf_inv_due_amount := l_ITC_due_amount*i_rate_tab(1);

                l_LogMsg := 'Inv currency code :' || p_InvTab(l_SobIdIdx).inv_currency_code ;
		l_LogMsg := l_LogMsg || ' to currency : ' ||  p_InvTab(l_SobIdIdx).projfunc_currency_code ;
                l_LogMsg := l_LogMsg || 'l_ITC_due_amount :' || l_ITC_due_amount || 'projfunc_rate_type :' || i_ProjfuncRateType;
                l_LogMsg := l_LogMsg || 'projfunc_inv_rate after calling amount_bulk :' || i_rate_tab(1);
                l_LogMsg := l_LogMsg || 'projfunc_inv_due amount after assigning :' ||  l_revald_pf_inv_due_amount ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);
                l_LogMsg := ' '; /* Bug 4346765 */
             ELSE
                l_revald_pf_inv_due_amount := l_ITC_due_amount;

                l_LogMsg := 'Inv currency code :' || p_InvTab(l_SobIdIdx).inv_currency_code ;
                l_LogMsg := l_LogMsg || ' to currency : ' ||  p_InvTab(l_SobIdIdx).projfunc_currency_code ;
                l_LogMsg := l_LogMsg || 'l_ITC_due_amount :' || l_ITC_due_amount || 'projfunc_rate_type :' || i_ProjfuncRateType;
                l_LogMsg := l_LogMsg || 'projfunc_inv_due amount after assigning :' ||  l_revald_pf_inv_due_amount ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);
                l_LogMsg := ' '; /* Bug 4346765 */
            END IF; /* if IC<>PFC */


/* Bug 3221279 ends */


                l_FoundFlag := 'N';
                IF G_InvCompTab.count > 0 THEN
                   FOR j in G_InvCompTab.first..G_InvCompTab.LAST LOOP

                       IF G_InvCompTab(j).set_of_books_id = l_SobIDIdx THEN

                          G_InvCompTab(j).invproc_billed_amount :=
                                        nvl(G_InvCompTab(j).invproc_billed_amount,0) + l_BillAmtIPC;

                          G_InvCompTab(j).funding_billed_amount :=
                                        nvl(G_InvCompTab(j).funding_billed_amount,0) + l_BillAmtFC;

                          G_InvCompTab(j).projfunc_billed_amount :=
                                        nvl(G_InvCompTab(j).projfunc_billed_amount,0) + l_BillAmtPFC;

                          G_InvCompTab(j).funding_applied_amount :=
                                        nvl(G_InvCompTab(j).funding_applied_amount,0) + l_ApplAmtFC;

                          G_InvCompTab(j).projfunc_applied_amount :=
                                        nvl(G_InvCompTab(j).projfunc_applied_amount,0) + l_ApplAmtPFC;

                          G_InvCompTab(j).projfunc_gain_amount :=
                                        nvl(G_InvCompTab(j).projfunc_gain_amount,0) + l_GainAmtPFC;

                          G_InvCompTab(j).projfunc_loss_amount :=
                                        nvl(G_InvCompTab(j).projfunc_loss_amount,0) + l_LossAmtPFC;

                          G_InvCompTab(j).revald_pf_inv_due_amount :=
                                        nvl(G_InvCompTab(j).revald_pf_inv_due_amount ,0) + l_revald_pf_inv_due_amount ;  /* Bug 3221279 */
                          	  G_InvCompTab(j).funding_adjusted_amount :=
			                nvl(G_InvCompTab(j).funding_adjusted_amount,0) + l_ArAdjAmtFC;  /* Added for bug 7237486 */

			  G_InvCompTab(j).projfunc_adjusted_amount :=
			                nvl(G_InvCompTab(j).projfunc_adjusted_amount,0) + l_ArAdjAmtPFC;   /* Added for bug 7237486 */
                          l_FoundFlag := 'Y';

                          EXIT;
                      END IF;

                   END LOOP;

                END IF;

                IF l_foundFlag = 'N' THEN

                   l_index := G_InvCompTab.Count + 1;

                   G_InvCompTab(l_index).project_id := p_project_id;
                   G_InvCompTab(l_index).agreement_id := p_agreement_id;
                   G_InvCompTab(l_index).task_id := p_task_id;
                   G_InvCompTab(l_index).set_of_books_id := l_SobIdIdx;
                   G_InvCompTab(l_index).invproc_billed_amount := l_BillAmtIPC;
                   G_InvCompTab(l_index).funding_billed_amount := l_BillAmtFC;
                   G_InvCompTab(l_index).projfunc_billed_amount := l_BillAmtPFC;
                   G_InvCompTab(l_index).funding_applied_amount := l_ApplAmtFC;
                   G_InvCompTab(l_index).projfunc_applied_amount := l_ApplAmtPFC;
                   G_InvCompTab(l_index).projfunc_gain_amount := l_GainAmtPFC;
                   G_InvCompTab(l_index).projfunc_loss_amount := l_LossAmtPFC;
                   G_InvCompTab(l_index).revald_pf_inv_due_amount := l_revald_pf_inv_due_amount; /* 3221279 */
   G_InvCompTab(l_index).funding_adjusted_amount := l_ArAdjAmtFC;  /* Added for bug 7237486 */
		   G_InvCompTab(l_index).projfunc_adjusted_amount := l_ArAdjAmtPFC;   /* Added for bug 7237486 */
                END IF;
                IF G_DEBUG_MODE = 'Y' THEN

                   l_LogMsg := 'Billed Amt PFC:' || l_BillAmtPFC ||
                               ' Billed Amt FC:' || l_BillAmtFC ||
                               ' Billed Amt IPC:' || l_BillAmtIPC ;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                   l_LogMsg := 'Appl Amt FC:' || round(l_ApplAmtFC,5) ||
                               ' Appl Amt PFC:' || round(l_ApplAmtPFC,5) ||
                               ' Gain Amt PFC:' || round(l_GainAmtPFC,5) ||
                               ' Loss Amt PFC:' || round(l_LossAmtPFC,5) ;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                END IF;

                l_SobIdIdx := G_SobListTab.NEXT(l_SobIdIdx);


            END LOOP; /* l_SobIdIdx loop */

         END IF;  /* project level funding */

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.derive_reval_components-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'derive_reval_components:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END derive_reval_components;


   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   get_invoice_total                                                      |
   |   Purpose    :   To get all amounts total for a given project/agreement/invoice |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                      Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id              IN      Project ID                                        |
   |     p_agreement_id            IN      Agreement_id                                      |
   |     p_draft_inv_num           IN      Draft invoice number that is being processed      |
   |     x_InvTotTab               OUT     Invoice total for the invoice of set_of_books     |
   |     x_return_status           OUT     Return status of this procedure                   |
   |     x_msg_count               OUT     Error message count                               |
   |     x_msg_data                OUT     Error message                                     |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE get_invoice_total(
             p_project_id        IN    NUMBER,
             p_agreement_id      IN    NUMBER,
             p_draft_inv_num     IN    NUMBER,
             x_InvTotTab         OUT   NOCOPY InvTotTabTyp,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS


       l_return_status               VARCHAR2(30) := NULL;
       l_msg_count                   NUMBER       := NULL;
       l_msg_data                    VARCHAR2(250) := NULL;

       l_LogMsg                    VARCHAR2(250);

       CURSOR get_inv_total  IS
              SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     sum(dii.amount) amount,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount
              FROM pa_draft_invoice_items dii
              WHERE dii.project_id = p_project_id
              AND dii.draft_invoice_num = p_draft_inv_num;
              --AND dii.invoice_line_type <> 'RETENTION';


          /* The following CURSOR is same as above but fetches for both primary and reporting set of books */

  /* R12 :  Ledger Architecture Changes : The table gl_mc_reporting_options will be  obsolete, replace with
     new table gl_alc_ledger_rships_v and corresponding columns */

      /* mrc migration to SLA bug 4571438
       CURSOR get_all_inv_total IS
              (SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     sum(dii.amount) amount,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount
              FROM pa_draft_invoice_items dii
              WHERE dii.project_id = p_project_id
              AND dii.draft_invoice_num = p_draft_inv_num
              --AND dii.invoice_line_type <> 'RETENTION'
              UNION
              SELECT dii_mc.set_of_books_id set_of_books_id,
                     sum(dii.amount) amount,
                     sum(dii_mc.amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount,
                     sum(dii.inv_amount) inv_amount
              FROM pa_mc_draft_inv_items dii_mc, pa_draft_invoice_items dii,
                   gl_alc_ledger_rships_v  rep, pa_implementations imp
              WHERE dii.project_id = p_project_id
              AND dii.draft_invoice_num = p_draft_inv_num
             -- AND dii.invoice_line_type <> 'RETENTION'
              AND rep.source_ledger_id = imp.set_of_books_id
              AND rep.relationship_enabled_flag  = 'Y'
              AND (rep.org_id = -99 OR rep.org_id = imp.org_id)
              AND rep.application_id = 275
              AND dii_mc.set_of_books_id =rep.ledger_id
              AND dii_mc.project_id = dii.project_id
              AND dii_mc.draft_invoice_num = dii.draft_invoice_num
              AND dii_mc.line_num = dii.line_num
              GROUP BY dii_mc.set_of_books_id
              )
              ORDER by set_of_books_id;  */

      l_SetOfBookIdTab      PA_PLSQL_DATATYPES.NumTabTyp;
      l_BillAmtIPCTab       PA_PLSQL_DATATYPES.NumTabTyp;
      l_BillAmtPFCTab       PA_PLSQL_DATATYPES.NumTabTyp;
      l_BillAmtFCTab        PA_PLSQL_DATATYPES.NumTabTyp;
      l_BillAmtITCTab       PA_PLSQL_DATATYPES.NumTabTyp;
      l_TotalFetch         NUMBER := 0;
      l_ThisFetch          NUMBER := 0;
      l_FetchSize          NUMBER := 50;


   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.get_invoice_total-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         IF G_PRIMARY_ONLY = 'Y' THEN

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Cursor get_inv_total ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            OPEN get_inv_total;
            LOOP

                FETCH get_inv_total BULK COLLECT INTO l_SetOfBookIdTab, l_BillAmtIPCTab,
                                                      l_BillAmtPFCTab, l_BillAmtFCTab, l_BillAmtITCTab
                                     LIMIT l_FetchSize;

                l_ThisFetch := get_inv_total%ROWCOUNT - l_TotalFetch;
                l_TotalFetch := get_inv_total%ROWCOUNT ;

                IF l_ThisFetch > 0 THEN

                  FOR i in l_SetOfBookIdTab.FIRST..l_SetOfBookIdTab.LAST LOOP
                         x_InvTotTab(l_SetOfBookIDTab(i)).set_of_books_id := l_SetOfBookIdTab(i);
                         x_InvTotTab(l_SetOfBookIDTab(i)).amount := l_BillAmtIPCTab(i);
                         x_InvTotTab(l_SetOfBookIDTab(i)).projfunc_bill_amount := l_BillAmtPFCTab(i);
                         x_InvTotTab(l_SetOfBookIDTab(i)).funding_bill_amount := l_BillAmtFCTab(i);
                         x_InvTotTab(l_SetOfBookIDTab(i)).inv_amount := l_BillAmtITCTab(i);

                         IF G_DEBUG_MODE = 'Y' THEN

                            l_LogMsg := 'Sob Id:' || l_SetOfBookIdTab(i) ||
                                        ' IPC Amt:' || l_BillAmtIPCTab(i) ||
                                        ' PFC Amt:' || l_BillAmtPFCTab(i) ||
                                        ' FC Amt:' || l_BillAmtFCTab(i) ||
                                        ' ITC Amt:' || l_BillAmtITCTab(i);
                            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                         END IF;

                  END LOOP;

                END IF;
               /* Initialize for next fetch */
               l_SetOfBookIdTab.DELETE;
               l_BillAmtIPCTab.DELETE;
               l_BillAmtPFCTab.DELETE;
               l_BillAmtFCTab.DELETE;
               l_BillAmtITCTab.DELETE;

               IF l_ThisFetch < l_FetchSize THEN

                  Exit;

               END IF;
            END LOOP;
            CLOSE get_inv_total;

       /* mrc migration to SLA bug 4571438 (  ELSE

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Cursor get_all_inv_total ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            OPEN get_all_inv_total;

            LOOP

                FETCH get_all_inv_total BULK COLLECT INTO l_SetOfBookIdTab, l_BillAmtIPCTab,
                                                      l_BillAmtPFCTab, l_BillAmtFCTab, l_BillAmtITCTab
                                     LIMIT l_FetchSize;

                l_ThisFetch := get_all_inv_total%ROWCOUNT - l_TotalFetch;
                l_TotalFetch := get_all_inv_total%ROWCOUNT ;

                IF l_ThisFetch > 0 THEN
                  FOR i in l_SetOfBookIdTab.FIRST..l_SetOfBookIdTab.LAST LOOP
                         x_InvTotTab(l_SetOfBookIDTab(i)).set_of_books_id := l_SetOfBookIdTab(i);
                         x_InvTotTab(l_SetOfBookIDTab(i)).amount := l_BillAmtIPCTab(i);
                         x_InvTotTab(l_SetOfBookIDTab(i)).projfunc_bill_amount := l_BillAmtPFCTab(i);
                         x_InvTotTab(l_SetOfBookIDTab(i)).funding_bill_amount := l_BillAmtFCTab(i);
                         x_InvTotTab(l_SetOfBookIDTab(i)).inv_amount := l_BillAmtITCTab(i);

                         IF G_DEBUG_MODE = 'Y' THEN

                            l_LogMsg := 'Sob Id:' || l_SetOfBookIdTab(i) ||
                                        ' IPC Amt:' || l_BillAmtIPCTab(i) ||
                                        ' PFC Amt:' || l_BillAmtPFCTab(i) ||
                                        ' FC Amt:' || l_BillAmtFCTab(i) ||
                                        ' ITC Amt:' || l_BillAmtITCTab(i);
                            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                         END IF;

                  END LOOP;

                END IF;
               -- Initialize for next fetch
               l_SetOfBookIdTab.DELETE;
               l_BillAmtIPCTab.DELETE;
               l_BillAmtPFCTab.DELETE;
               l_BillAmtFCTab.DELETE;
               l_BillAmtITCTab.DELETE;

               IF l_ThisFetch < l_FetchSize THEN

                  Exit;

               END IF;
            END LOOP;
            CLOSE get_all_inv_total;  )*/
         END IF;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.get_invoice_total-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'get_invoice_total:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END get_invoice_total;


   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   get_retained_amount                                                    |
   |   Purpose    :   To get retained amount for task of a draft invoice line when the       |
   |                  retention level is  at project level and funding is at task level      |
   |                  This will be only executed for task level funding project level        |
   |                  retention invoices                                                     |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_task_id             IN      Task ID  (of the invoice line item that is            |
   |                                   being processesd)                                     |
   |     p_draft_inv_num       IN      Draft Invoice num                                     |
   |     x_RetainedAmtTab      OUT     Retained amount for the task in all set_of_books      |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/


   PROCEDURE get_retained_amount(
             p_project_id        IN    NUMBER,
             p_task_id           IN    VARCHAR2,
             p_draft_inv_num     IN    NUMBER,
             x_RetainedAmtTab    OUT   NOCOPY RetainedAmtTabTyp,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS


       /* The following cursors gets the retained amount from RDL /ERDL /DII
          for the given project/draft_invoice/task
          The task id is the task of the draft invoice line that is being processed
          Since retained amount is stored only in invoice processing currency, it is prorated to get in
          project functional and funding currency */

       CURSOR rdl_amount IS
            SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                   SUM((rdl.retained_amount/rdl.bill_amount) * rdl.projfunc_bill_amount) retained_amt_pfc,
                   SUM((rdl.retained_amount/rdl.bill_amount) * rdl.funding_bill_amount) retained_amt_fc
            FROM   pa_cust_rev_dist_lines RDL, pa_draft_invoice_items DII
            WHERE  DII.project_id = p_project_id
            AND    DII.draft_invoice_num = p_draft_inv_num
            AND    NVL(DII.task_id,0) = p_task_id
            AND    RDL.project_id = DII.project_id
            AND    RDL.draft_invoice_num = DII.draft_invoice_num
            AND    RDL.draft_invoice_item_line_num = DII.line_num;

  /* R12 :  Ledger Architecture Changes : The table gl_mc_reporting_options will be  obsolete, replace with
     new table gl_alc_ledger_rships_v and corresponding columns */

     /* mrc migration to SLA bug 4571438  CURSOR rdl_amount_all IS
            (SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                   SUM((rdl.retained_amount/rdl.bill_amount) * rdl.projfunc_bill_amount) retained_amt_pfc,
                   SUM((rdl.retained_amount/rdl.bill_amount) * rdl.funding_bill_amount) retained_amt_fc
            FROM   pa_cust_rev_dist_lines RDL, pa_draft_invoice_items DII
            WHERE  DII.project_id = p_project_id
            AND    DII.draft_invoice_num = p_draft_inv_num
            AND    NVL(DII.task_id,0) = p_task_id
            AND    RDL.project_id = DII.project_id
            AND    RDL.draft_invoice_num = DII.draft_invoice_num
            AND    RDL.draft_invoice_item_line_num = DII.line_num
            UNION
            SELECT RDL_MC.set_of_books_id,
                   SUM((rdl.retained_amount/rdl.bill_amount) * rdl_mc.amount) retained_amt_pfc,
                   SUM((rdl.retained_amount/rdl.bill_amount) * rdl.funding_bill_amount) retained_amt_fc
            FROM   pa_cust_rev_dist_lines RDL, pa_draft_invoice_items DII, pa_mc_cust_rdl_all RDL_MC,
                   gl_alc_ledger_rships_v rep, pa_implementations imp
            WHERE  DII.project_id = p_project_id
            AND    DII.draft_invoice_num = p_draft_inv_num
            AND    NVL(DII.task_id,0) = p_task_id
            AND    RDL.project_id = DII.project_id
            AND    RDL.draft_invoice_num = DII.draft_invoice_num
            AND    RDL.draft_invoice_item_line_num = DII.line_num
            AND    rep.source_ledger_id = imp.set_of_books_id
            AND    rep.relationship_enabled_flag  = 'Y'
            AND    (rep.org_id = -99 OR rep.org_id = imp.org_id)
            AND    rep.application_id = 275
            AND    RDL_MC.set_of_books_id =rep.ledger_id
            AND    RDL_MC.expenditure_item_id = RDL.expenditure_item_id
            AND    RDL_MC.line_num            = RDL.line_num
            GROUP by RDL_MC.set_of_books_id
            )
       ORDER by set_of_books_id; */

       CURSOR erdl_amount IS
            SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                   SUM((erdl.retained_amount/erdl.amount) * erdl.projfunc_bill_amount) retained_amt_pfc,
                   SUM((erdl.retained_amount/erdl.amount) * erdl.funding_bill_amount) retained_amt_fc
            FROM   pa_cust_event_rdl_all ERDL, pa_draft_invoice_items DII
            WHERE  DII.project_id = p_project_id
            AND    DII.draft_invoice_num = p_draft_inv_num
            AND    NVL(DII.task_id,0) = p_task_id
            AND    ERDL.project_id = DII.project_id
            AND    ERDL.draft_invoice_num = DII.draft_invoice_num
            AND    ERDL.draft_invoice_item_line_num = DII.line_num;


  /* R12 :  Ledger Architecture Changes : The table gl_mc_reporting_options will be  obsolete, replace with
     new table gl_alc_ledger_rships_v and corresponding columns */

      /* mrc migration to SLA bug 4571438  CURSOR erdl_amount_all IS
            (SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                   SUM((erdl.retained_amount/erdl.amount) * erdl.projfunc_bill_amount) retained_amt_pfc,
                   SUM((erdl.retained_amount/erdl.amount) * erdl.funding_bill_amount) retained_amt_fc
            FROM   pa_cust_event_rdl_all ERDL, pa_draft_invoice_items DII
            WHERE  DII.project_id = p_project_id
            AND    DII.draft_invoice_num = p_draft_inv_num
            AND    NVL(DII.task_id,0) = p_task_id
            AND    ERDL.project_id = DII.project_id
            AND    ERDL.draft_invoice_num = DII.draft_invoice_num
            AND    ERDL.draft_invoice_item_line_num = DII.line_num
            UNION
            SELECT ERDL_MC.set_of_books_id,
                   SUM((erdl.retained_amount/erdl.amount) * ERDL_MC.amount) retained_amt_pfc,
                   SUM((erdl.retained_amount/erdl.amount) * erdl.funding_bill_amount) retained_amt_fc
            FROM   pa_cust_event_rdl_all ERDL, pa_draft_invoice_items DII,
                   pa_mc_cust_event_rdl_all ERDL_MC,
                   gl_alc_ledger_rships_v  rep, pa_implementations imp
            WHERE  DII.project_id = p_project_id
            AND    DII.draft_invoice_num = p_draft_inv_num
            AND    NVL(DII.task_id,0) = p_task_id
            AND    ERDL.project_id = DII.project_id
            AND    ERDL.draft_invoice_num = DII.draft_invoice_num
            AND    ERDL.draft_invoice_item_line_num = DII.line_num
            AND    rep.source_ledger_id = imp.set_of_books_id
            AND    rep.relationship_enabled_flag  = 'Y'
            AND    (rep.org_id = -99 OR rep.org_id = imp.org_id)
            AND    rep.application_id = 275
            AND    ERDL_MC.set_of_books_id =rep.ledger_id
            AND    ERDL_MC.project_id = ERDL.project_id
            AND    ERDL_MC.event_num = ERDL.event_num
            AND    NVL(ERDL_MC.task_id,0) = NVL(ERDL.task_id,0)
            AND    ERDL_MC.line_num      = ERDL.line_num
            GROUP by ERDL_MC.set_of_books_id
            )
       ORDER by set_of_books_id; */

       CURSOR dii_amount IS
            SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                   SUM((DII.retained_amount/DII.amount) * DII.projfunc_bill_amount) retained_amt_pfc,
                   SUM((DII.retained_amount/DII.amount) * DII.funding_bill_amount) retained_amt_fc
            FROM   pa_draft_invoice_items DII
            WHERE  DII.project_id = p_project_id
            AND    DII.draft_invoice_num = p_draft_inv_num
            AND    DII.task_id = p_task_id
            AND    DII.event_num is not null;

  /* R12 :  Ledger Architecture Changes : The table gl_mc_reporting_options will be  obsolete, replace with
     new table gl_alc_ledger_rships_v and corresponding columns */

     /* mrc migration to SLA bug 4571438  CURSOR dii_amount_all IS
           (SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                   SUM((DII.retained_amount/DII.amount) * DII.projfunc_bill_amount) retained_amt_pfc,
                   SUM((DII.retained_amount/DII.amount) * DII.funding_bill_amount) retained_amt_fc
            FROM   pa_draft_invoice_items DII
            WHERE  DII.project_id = p_project_id
            AND    DII.draft_invoice_num = p_draft_inv_num
            AND    DII.event_num is not null
            AND    DII.task_id = p_task_id
            UNION
            SELECT DII_MC.set_of_books_id,
                   SUM((DII.retained_amount/DII.amount) * DII_MC.amount) retained_amt_pfc,
                   SUM((DII.retained_amount/DII.amount) * DII.funding_bill_amount) retained_amt_fc
            FROM   pa_draft_invoice_items DII, pa_mc_draft_inv_items DII_MC,
                   gl_alc_ledger_rships_v  rep, pa_implementations imp
            WHERE  DII.project_id = p_project_id
            AND    DII.draft_invoice_num = p_draft_inv_num
            AND    DII.task_id = p_task_id
            AND    rep.source_ledger_id = imp.set_of_books_id
            AND    rep.relationship_enabled_flag  = 'Y'
            AND    (rep.org_id = -99 OR rep.org_id = imp.org_id)
            AND    rep.application_id = 275
            AND    DII_MC.set_of_books_id =rep.ledger_id
            AND    DII_MC.project_id = DII.project_id
            AND    DII_MC.draft_invoice_num = DII.draft_invoice_num
            AND    DII_MC.line_num = DII.line_num
            AND    DII.event_num is not null
            GROUP by DII_MC.set_of_books_id
           )
       ORDER by set_of_books_id; */




         l_RetnExistFlag             VARCHAR2(1);

         l_SetOfBookIdTab            PA_PLSQL_DATATYPES.IdTabTyp;
         l_RetainedAmtPFCTab         PA_PLSQL_DATATYPES.NumTabTyp;
         l_RetainedAmtFCTab          PA_PLSQL_DATATYPES.NumTabTyp;


         l_RetainedAmtTab            RetainedAmtTabTyp;
         l_TotalFetch                NUMBER := 0;
         l_ThisFetch                 NUMBER := 0;
         l_FetchSize                 NUMBER := 50;

         l_return_status             VARCHAR2(30) := NULL;
         l_msg_count                 NUMBER       := NULL;
         l_msg_data                  VARCHAR2(250) := NULL;
         l_LogMsg                    VARCHAR2(250);


   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.get_retained_amount-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

            l_LogMsg := 'Project Id:' || p_project_id ||
                        ' Task Id:' || p_task_id ||
                        ' Draft Inv Num:' || p_draft_inv_num ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

         END IF;

         /* This procedure will get retained amount for an invoice/task (of draft invoice items) in
            primary/primary and reporting set of books id

            The result tab x_RetainedAmtTab will have one record (for the task) in case of primary only
             or one record for each of the primary and reporting set of books id */

         /* Check if the invoice has any retention lines. Only if it exists subsequent code will get processed */

         SELECT 'T' INTO l_RetnExistFlag
         FROM DUAL
         WHERE EXISTS (SELECT NULL
                       FROM pa_draft_invoice_items dii
                       WHERE  dii.project_id = p_project_id
                       AND    dii.draft_invoice_num = p_draft_inv_num
                       AND    dii.invoice_line_type = 'RETENTION');


         IF G_PRIMARY_ONLY = 'Y' THEN /* For primary only  ( */

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Cursor rdl_amount ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            l_TotalFetch := 0;
            OPEN rdl_amount;
            LOOP
               FETCH rdl_amount BULK COLLECT INTO l_SetOfBookIdTab, l_RetainedAmtPFCTab, l_RetainedAmtFCTab
                                LIMIT l_FetchSize;

               l_ThisFetch := rdl_amount%ROWCOUNT - l_TotalFetch;
               l_TotalFetch := rdl_amount%ROWCOUNT ;

               IF l_ThisFetch > 0 THEN


                  /* This procedure sums up the amount from the amount tab and adds it to the output tab
                     In order to avoid repetitive coding for each of the tables RDL/ERDL/DII for primary as well as
                     primary and reporting set of books, this procedure is being used
                  */

                  sum_retained_amount(
                             p_task_id           => p_task_id,
                             p_SetOfBookIdTab    => l_SetOfBookIdTab,
                             p_RetainedAmtPFCTab => l_RetainedAmtPFcTab,
                             p_RetainedAmtFCTab  => l_RetainedAmtFCTab,
                             x_RetainedAmtTab    => l_RetainedAmtTab,
                             x_return_status     => l_return_status,
                             x_msg_count         => l_msg_count,
                             x_msg_data          => l_msg_data);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                     RAISE FND_API.G_EXC_ERROR;

                  END IF;

               END IF; /* l_ThisFetch > 0 */

                /* Initialize for next fetch */
                l_SetOfBookIdTab.DELETE;
                l_RetainedAmtPFCTab.DELETE;
                l_RetainedAmtFCTab.DELETE;

                IF l_ThisFetch < l_FetchSize THEN
                   Exit;
                END IF;

            END LOOP; /* open rdl_amount */

            CLOSE rdl_amount ;

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Cursor erdl_amount ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            l_TotalFetch := 0;
            OPEN erdl_amount;
            LOOP
               FETCH erdl_amount BULK COLLECT INTO l_SetOfBookIdTab, l_RetainedAmtPFCTab, l_RetainedAmtFCTab
                                LIMIT l_FetchSize;

               l_ThisFetch := erdl_amount%ROWCOUNT - l_TotalFetch;
               l_TotalFetch := erdl_amount%ROWCOUNT ;

               IF l_ThisFetch > 0 THEN

                  sum_retained_amount(
                             p_task_id           => p_task_id,
                             p_SetOfBookIdTab    => l_SetOfBookIdTab,
                             p_RetainedAmtPFCTab => l_RetainedAmtPFcTab,
                             p_RetainedAmtFCTab  => l_RetainedAmtFCTab,
                             x_RetainedAmtTab    => l_RetainedAmtTab,
                             x_return_status     => l_return_status,
                             x_msg_count         => l_msg_count,
                             x_msg_data          => l_msg_data);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                     RAISE FND_API.G_EXC_ERROR;

                  END IF;

                END IF; /* l_ThisFetch > 0 */

                /* Initialize for next fetch */
                l_SetOfBookIdTab.DELETE;
                l_RetainedAmtPFCTab.DELETE;
                l_RetainedAmtFCTab.DELETE;

                IF l_ThisFetch < l_FetchSize THEN
                   Exit;
                END IF;

            END LOOP; /* open erdl_amount */

            CLOSE erdl_amount ;

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Cursor dii_amount ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            l_TotalFetch := 0;
            OPEN dii_amount;
            LOOP
               FETCH dii_amount BULK COLLECT INTO l_SetOfBookIdTab, l_RetainedAmtPFCTab, l_RetainedAmtFCTab
                                LIMIT l_FetchSize;

               l_ThisFetch := dii_amount%ROWCOUNT - l_TotalFetch;
               l_TotalFetch := dii_amount%ROWCOUNT ;

               IF l_ThisFetch > 0 THEN

                  sum_retained_amount(
                             p_task_id           => p_task_id,
                             p_SetOfBookIdTab    => l_SetOfBookIdTab,
                             p_RetainedAmtPFCTab => l_RetainedAmtPFcTab,
                             p_RetainedAmtFCTab  => l_RetainedAmtFCTab,
                             x_RetainedAmtTab    => l_RetainedAmtTab,
                             x_return_status     => l_return_status,
                             x_msg_count         => l_msg_count,
                             x_msg_data          => l_msg_data);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                     RAISE FND_API.G_EXC_ERROR;

                  END IF;

               END IF; /* l_ThisFetch > 0 */

                /* Initialize for next fetch */
                l_SetOfBookIdTab.DELETE;
                l_RetainedAmtPFCTab.DELETE;
                l_RetainedAmtFCTab.DELETE;

                IF l_ThisFetch < l_FetchSize THEN
                   Exit;
                END IF;

            END LOOP; /* open dii_amount */

            CLOSE dii_amount ; -- )

       /* mrc migration to SLA bug 4571438  ELSE -- G_PRIMARY_ONLY = 'N'  primary and reporting (

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Cursor rdl_amount_all ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            l_TotalFetch := 0;
            OPEN rdl_amount_all;
            LOOP
               FETCH rdl_amount_all BULK COLLECT INTO l_SetOfBookIdTab, l_RetainedAmtPFCTab, l_RetainedAmtFCTab
                                LIMIT l_FetchSize;

               l_ThisFetch := rdl_amount_all%ROWCOUNT - l_TotalFetch;
               l_TotalFetch := rdl_amount_all%ROWCOUNT ;

               IF l_ThisFetch > 0 THEN

                  sum_retained_amount(
                             p_task_id           => p_task_id,
                             p_SetOfBookIdTab    => l_SetOfBookIdTab,
                             p_RetainedAmtPFCTab => l_RetainedAmtPFcTab,
                             p_RetainedAmtFCTab  => l_RetainedAmtFCTab,
                             x_RetainedAmtTab    => l_RetainedAmtTab,
                             x_return_status     => l_return_status,
                             x_msg_count         => l_msg_count,
                             x_msg_data          => l_msg_data);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                     RAISE FND_API.G_EXC_ERROR;

                  END IF;

               END IF; -- l_ThisFetch > 0

                -- Initialize for next fetch
                l_SetOfBookIdTab.DELETE;
                l_RetainedAmtPFCTab.DELETE;
                l_RetainedAmtFCTab.DELETE;

                IF l_ThisFetch < l_FetchSize THEN
                   Exit;
                END IF;

            END LOOP; -- open rdl_amount_all

            CLOSE rdl_amount_all ;

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Cursor erdl_amount_all ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            l_TotalFetch := 0;
            OPEN erdl_amount_all;
            LOOP
               FETCH erdl_amount_all BULK COLLECT INTO l_SetOfBookIdTab, l_RetainedAmtPFCTab, l_RetainedAmtFCTab
                                LIMIT l_FetchSize;

               l_ThisFetch := erdl_amount_all%ROWCOUNT - l_TotalFetch;
               l_TotalFetch := erdl_amount_all%ROWCOUNT ;

               IF l_ThisFetch > 0 THEN

                  sum_retained_amount(
                             p_task_id           => p_task_id,
                             p_SetOfBookIdTab    => l_SetOfBookIdTab,
                             p_RetainedAmtPFCTab => l_RetainedAmtPFcTab,
                             p_RetainedAmtFCTab  => l_RetainedAmtFCTab,
                             x_RetainedAmtTab    => l_RetainedAmtTab,
                             x_return_status     => l_return_status,
                             x_msg_count         => l_msg_count,
                             x_msg_data          => l_msg_data);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                     RAISE FND_API.G_EXC_ERROR;

                  END IF;

                END IF; -- l_ThisFetch > 0

                -- Initialize for next fetch
                l_SetOfBookIdTab.DELETE;
                l_RetainedAmtPFCTab.DELETE;
                l_RetainedAmtFCTab.DELETE;

                IF l_ThisFetch < l_FetchSize THEN
                   Exit;
                END IF;

            END LOOP; -- open erdl_amount_all

            CLOSE erdl_amount_all ;

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'Cursor dii_amount_all ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            l_TotalFetch := 0;
            OPEN dii_amount_all;
            LOOP
               FETCH dii_amount_all BULK COLLECT INTO l_SetOfBookIdTab, l_RetainedAmtPFCTab, l_RetainedAmtFCTab
                                LIMIT l_FetchSize;

               l_ThisFetch := dii_amount_all%ROWCOUNT - l_TotalFetch;
               l_TotalFetch := dii_amount_all%ROWCOUNT ;

               IF l_ThisFetch > 0 THEN

                  sum_retained_amount(
                             p_task_id           => p_task_id,
                             p_SetOfBookIdTab    => l_SetOfBookIdTab,
                             p_RetainedAmtPFCTab => l_RetainedAmtPFcTab,
                             p_RetainedAmtFCTab  => l_RetainedAmtFCTab,
                             x_RetainedAmtTab    => l_RetainedAmtTab,
                             x_return_status     => l_return_status,
                             x_msg_count         => l_msg_count,
                             x_msg_data          => l_msg_data);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                     RAISE FND_API.G_EXC_ERROR;

                  END IF;

               END IF; -- l_ThisFetch > 0

                -- Initialize for next fetch
                l_SetOfBookIdTab.DELETE;
                l_RetainedAmtPFCTab.DELETE;
                l_RetainedAmtFCTab.DELETE;

                IF l_ThisFetch < l_FetchSize THEN
                   Exit;
                END IF;

            END LOOP; -- open dii_amount_all

            CLOSE dii_amount_all ;  ) */

         END IF; /* G_PRIMARY_ONLY = 'N' */

         x_RetainedAmtTab := l_RetainedAmtTab;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.get_retained_amount-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION
        WHEN NO_DATA_FOUND THEN
             x_RetainedAmtTab := l_RetainedAmtTab;
             NULL;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'get_retained_amount:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END get_retained_amount;


   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   sum_retained_amount                                                    |
   |   Purpose    :   This procedure loops thru all the input records and sum up the amount  |
   |                   to respective  amounts in the IN OUT parameter                        |
   |                  This is basically written to avoid this sum up code being repeated in  |
   |                  many places in procedure get_retained_amount                           |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_task_id             IN      Task ID  (of the invoice line item that is            |
   |                                   being processesd)                                     |
   |     p_SetOfBookIdTab      IN      Set of book ids for which the tasks are being         |
   |                                   processed                                             |
   |     p_RetainedAmtPFCTab   IN      Retained Amoount in PFC                               |
   |     p_RetainedAmtFCTab    IN      Retained Amount in Fc                                 |
   |     x_RetainedAmtTab      IN OUT  Summed up amounts,                                    |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE sum_retained_amount(
             p_task_id           IN      NUMBER,
             p_SetOfBookIdTab    IN      PA_PLSQL_DATATYPES.IdTabTyp,
             p_RetainedAmtPFCTab IN      PA_PLSQL_DATATYPES.NumTabTyp,
             p_RetainedAmtFCTab  IN      PA_PLSQL_DATATYPES.NumTabTyp,
             x_RetainedAmtTab    IN OUT  NOCOPY RetainedAmtTabTyp,
             x_return_status     OUT     NOCOPY VARCHAR2,
             x_msg_count         OUT     NOCOPY NUMBER,
             x_msg_data          OUT     NOCOPY VARCHAR2)   IS


         l_SobId                    NUMBER;

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;
         l_LogMsg                   VARCHAR2(250);

   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.sum_retained_amount-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         FOR i in p_SetOfBookIdTab.first .. p_SetOfBookIdTab.Last LOOP

             l_SobId := p_SetOfBookIdTab(i);

             IF x_RetainedAmtTab.Exists (l_SobId) THEN

                x_RetainedAmtTab(l_SobId).projfunc_retained_amount :=
                      nvl(x_RetainedAmtTab(l_SobId).projfunc_retained_amount,0) + nvl(p_RetainedAmtPFCTab(i),0);
                x_RetainedAmtTab(l_SobId).funding_retained_amount :=
                      nvl(x_RetainedAmtTab(l_SobId).funding_retained_amount,0) + nvl(p_RetainedAmtFCTab(i),0);

             ELSE
                x_RetainedAmtTab(l_SobId).task_id := p_task_id;
                x_RetainedAmtTab(l_SobId).set_of_books_id := l_SobId;
                x_RetainedAmtTab(l_SobId).projfunc_retained_amount := nvl(p_RetainedAmtPFCTab(i),0);
                x_RetainedAmtTab(l_SobId).funding_retained_amount :=  nvl(p_RetainedAmtFCTab(i),0);

             END IF;

             IF G_DEBUG_MODE = 'Y' THEN

                l_LogMsg := 'Sob Id:' || l_SobId ||
                            ' PFC Retained Amt:' || round(x_RetainedAmtTab(l_SobId).projfunc_retained_amount,4) ||
                            ' FC Retained Amt:' || round(x_RetainedAmtTab(l_SobId).funding_retained_amount,4);
                PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

             END IF;


         END LOOP;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.sum_retained_amount-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'sum_retained_amount:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END sum_retained_amount;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   adjust_appl_amount                                                      |
   |   Purpose    :   To adjust applied amount of project level retention invoices against      |
   |                  retained amount derived for task                                       |
   |                  This will be only executed for task level funding with project level   |
   |                  retention invoices                                                     |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_agreement_id        IN      Agreement_id                                          |
   |     p_SobId               IN      Set of book id for which the amount is to be          |
   |                                   adjusted                                              |
   |     p_Retained_amt_pfc    IN      Retained Amount in PFC                                |
   |     p_Retained_amt_fc     IN      Retained Amount in FC                                 |
   |     x_retn_appl_amt_pfc   IN      Applied amount adjusted in PFC                        |
   |     x_retn_appl_amt_fc    IN      Applied amount adjusted in FC                         |
   |     x_retn_gain_amt_pfc   IN      Realized Gain amount adjusted in PFC                  |
   |     x_retn_loss_amt_pfc   IN      Realized Loss amount adjusted in PFC                  |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/


   PROCEDURE adjust_appl_amount(
             p_project_id           IN      NUMBER,
             p_agreement_id         IN      NUMBER,
             p_SobId                IN      NUMBER,
             p_retained_amount_pfc  IN      NUMBER,
             p_retained_amount_fc   IN      NUMBER,
             x_retn_appl_amt_pfc    OUT    NOCOPY   NUMBER,
             x_retn_appl_amt_fc     OUT    NOCOPY   NUMBER,
             x_retn_gain_amt_pfc    OUT    NOCOPY   NUMBER,
             x_retn_loss_amt_pfc    OUT    NOCOPY   NUMBER,
             x_return_status        OUT    NOCOPY  VARCHAR2,
             x_msg_count            OUT    NOCOPY  NUMBER,
             x_msg_data             OUT    NOCOPY  VARCHAR2)   IS


       l_return_status               VARCHAR2(30) := NULL;
       l_msg_count                   NUMBER       := NULL;
       l_msg_data                    VARCHAR2(250) := NULL;

       l_LogMsg                    VARCHAR2(250);

       l_BalApplAmtPFC             NUMBER := 0;
       l_BalApplAmtFC              NUMBER := 0;
       l_BalGainAmtPFC             NUMBER := 0;
       l_BalLossAmtPFC             NUMBER := 0;

       l_RetnApplAmtPFC            NUMBER := 0;
       l_RetnApplAmtFC             NUMBER := 0;
       l_RetnGainAmtPFC            NUMBER := 0;
       l_RetnLossAmtPFC            NUMBER := 0;

   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         /* This procedure adjusts the retained amount for the given project/task/sobID of an agreement
            against the applied amount maintained for the project agreement in global table
            G_RetnApplAmtTab
            From the available balance (difference between total applied and already adjusted amounts)
            the current retained amount is adjusted */

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.adjust_appl_amount-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

            l_LogMsg := 'Sob Id:' || p_SobId ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

            l_LogMsg := '==================';
            PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

         END IF;

         x_retn_appl_amt_pfc    := 0;
         x_retn_appl_amt_fc     := 0;
         x_retn_gain_amt_pfc    := 0;
         x_retn_loss_amt_pfc    := 0;


         IF G_RetnApplAmtTab.EXISTS(p_SobId) THEN

            l_BalApplAmtPFC := nvl(G_RetnApplAmtTab(p_SobId).projfunc_applied_amount,0) -
                                            nvl(G_RetnApplAmtTab(p_SobId).projfunc_adj_appl_amount,0);

            l_BalApplAmtFC := nvl(G_RetnApplAmtTab(p_SobId).funding_applied_amount,0) -
                                            nvl(G_RetnApplAmtTab(p_SobId).funding_adj_appl_amount,0);

            l_BalGainAmtPFC := nvl(G_RetnApplAmtTab(p_SobId).projfunc_gain_amount,0) -
                                            nvl(G_RetnApplAmtTab(p_SobId).projfunc_adj_gain_amount,0);

            l_BalLossAmtPFC := nvl(G_RetnApplAmtTab(p_SobId).projfunc_loss_amount,0) -
                                            nvl(G_RetnApplAmtTab(p_SobId).projfunc_adj_loss_amount,0);

            IF l_BalApplAmtPFC <> 0 THEN

               IF p_retained_amount_pfc >= l_BalApplAmtPFC  THEN

                  l_RetnApplAmtPFC := l_BalApplAmtPFC;
                  l_RetnApplAmtFC := l_BalApplAmtFC;

               ELSIF p_retained_amount_pfc < l_BalApplAmtPFC  THEN

                  l_RetnApplAmtPFC := p_retained_amount_pfc;
                  l_RetnApplAmtFC  := p_retained_amount_fc;

               END IF;

               l_RetnGainAmtPFC :=  (l_BalGainAmtPFC/l_BalApplAmtPFC) *  l_RetnApplAmtPFC ;
               l_RetnLossAmtPFC :=  (l_BalLossAmtPFC/l_BalApplAmtPFC) *  l_RetnApplAmtPFC ;

               G_RetnApplAmtTab(p_SobId).projfunc_adj_appl_amount :=
                                        nvl(G_RetnApplAmtTab(p_SobId).projfunc_adj_appl_amount,0) + l_BalApplAmtPFC;
               G_RetnApplAmtTab(p_SobId).funding_adj_appl_amount :=
                                        nvl(G_RetnApplAmtTab(p_SobId).funding_adj_appl_amount ,0)+ l_BalApplAmtFC;
               G_RetnApplAmtTab(p_SobId).projfunc_adj_gain_amount :=
                                        nvl(G_RetnApplAmtTab(p_SobId).projfunc_adj_gain_amount ,0)+ l_RetnGainAmtPFC;
               G_RetnApplAmtTab(p_SobId).projfunc_adj_loss_amount :=
                                        nvl(G_RetnApplAmtTab(p_SobId).projfunc_adj_loss_amount ,0)+ l_RetnlossAmtPFC;

            END IF;

         END IF ;/*G_RetnApplAmtTab.EXISTS(p_SobId) */

         x_retn_appl_amt_pfc := l_RetnApplAmtPFC;
         x_retn_appl_amt_fc  := l_RetnApplAmtFC;
         x_retn_gain_amt_pfc := l_RetnGainAmtPFC;
         x_retn_loss_amt_pfc  := l_RetnLossAmtPFC;

         IF G_DEBUG_MODE = 'Y' THEN

            l_LogMsg := 'PFC Retn Appl Amt:' || round(x_retn_appl_amt_pfc,4) ||
                        ' FC Retn Appl Amt:' || round(x_retn_appl_amt_fc,4) ||
                        ' PFC Retn gain Amt:' || round(x_retn_gain_amt_pfc,4) ||
                        ' PFC Retn loss Amt:' || round(x_retn_loss_amt_pfc,4) ;

            PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.adjust_appl_amount-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'adjust_appl_amount:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END adjust_appl_amount;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   get_sum_invoice_components                                             |
   |   Purpose    :   To fetch and compute invoice related components for a project/agreement|
   |                  This will get executed only if project level realized gain/loss flag   |
   |                  is 'Y'. Since AR is not called, invoices for an agreement/project/task |
   |                  set of books id  can be summed up in single SQL. This routine does this|
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                      Mode    Description                                       |
   |     ==================================================================================  |
   |     p_project_id              IN      Project ID                                        |
   |     p_agreement_id            IN      Agreement_id                                      |
   |     p_task_id                 IN      Task Id of summary project funding                |
   |     x_return_status           OUT     Return status of this procedure                   |
   |     x_msg_count               OUT     Error message count                               |
   |     x_msg_data                OUT     Error message                                     |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE get_sum_invoice_components(
             p_project_id             IN     NUMBER,
             p_agreement_id           IN     NUMBER,
             p_task_id                IN     NUMBER,
             x_return_status          OUT    NOCOPY VARCHAR2,
             x_msg_count              OUT    NOCOPY NUMBER,
             x_msg_data               OUT    NOCOPY VARCHAR2)   IS



       /* The following CURSOR will select all invoices for given project/agreement for
          primary set of book id and will get executed for
          a) project level funding
       */

       CURSOR get_proj_invoices IS
             SELECT  PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     0 task_id,
                     sum(dii.amount) amount,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount
              FROM pa_draft_invoice_items dii,
                   pa_draft_invoices di
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND dii.invoice_line_type <> 'RETENTION'
              AND nvl(di.retention_invoice_flag, 'N') = 'N'
              AND di.invoice_date <= G_THRU_DATE;

       /* The following CURSOR will select all invoices for given project/agreement for
          primary and reporting set of book ids  */

  /* R12 :  Ledger Architecture Changes : The table gl_mc_reporting_options will be  obsolete, replace with
     new table gl_alc_ledger_rships_v and corresponding columns */

   /* mrc migration to SLA bug 4571438    CURSOR get_all_proj_invoices IS
             (SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     0 task_id,
                     sum(dii.amount) amount,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount
              FROM pa_draft_invoice_items dii,
                   pa_draft_invoices di
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND dii.invoice_line_type <> 'RETENTION'
              AND nvl(di.retention_invoice_flag, 'N') = 'N'
              AND di.invoice_date <= G_THRU_DATE
              UNION
              SELECT dii_mc.set_of_books_id,
                     0 task_id,
                     sum(dii.amount) amount,
                     sum(dii_mc.amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount
              FROM pa_mc_draft_inv_items dii_mc, pa_draft_invoice_items dii,
                   pa_draft_invoices di,
                   gl_alc_ledger_rships_v rep, pa_implementations imp
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND dii.invoice_line_type <> 'RETENTION'
              AND rep.source_ledger_id = imp.set_of_books_id
              AND rep.relationship_enabled_flag  = 'Y'
              AND (rep.org_id = -99 OR rep.org_id = imp.org_id)
              AND rep.application_id = 275
              AND dii_mc.set_of_books_id =rep.ledger_id
              AND dii_mc.project_id = dii.project_id
              AND dii_mc.draft_invoice_num = dii.draft_invoice_num
              AND dii_mc.line_num = dii.line_num
              AND nvl(di.retention_invoice_flag, 'N') = 'N'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY dii_mc.set_of_books_id
               )
              ORDER BY set_of_books_id; */

       /* The following CURSOR will select all invoices for given project/agreement for
          primary set of book id and will get executed for
          a) task level funding
       */

       CURSOR get_task_invoices IS
             SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     dii.task_id,
                     sum(dii.amount) amount,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount
              FROM pa_draft_invoice_items dii,
                   pa_draft_invoices di
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND dii.invoice_line_type <> 'RETENTION'
              AND nvl(di.retention_invoice_flag, 'N') = 'N'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY dii.task_id
              ORDER BY task_id;

  /* R12 :  Ledger Architecture Changes : The table gl_mc_reporting_options will be  obsolete, replace with
     new table gl_alc_ledger_rships_v and corresponding columns */

       /* This CURSOR is same as previous CURSOR except that ti will select for both primary and reporting set of
           books isd */
       /* mrc migration to SLA bug 4571438 CURSOR get_all_task_invoices IS
             (SELECT PA_FUND_REVAL_PVT.G_SET_OF_BOOKS_ID set_of_books_id,
                     dii.task_id,
                     sum(dii.amount) amount,
                     sum(dii.projfunc_bill_amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount
              FROM pa_draft_invoice_items dii,
                   pa_draft_invoices di
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND dii.invoice_line_type <> 'RETENTION'
              AND nvl(di.retention_invoice_flag, 'N') = 'N'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY dii.task_id
              UNION
              SELECT dii_mc.set_of_books_id,
                     dii.task_id,
                     sum(dii.amount) amount,
                     sum(dii_mc.amount) projfunc_bill_amount,
                     sum(dii.funding_bill_amount) funding_bill_amount
              FROM pa_mc_draft_inv_items dii_mc, pa_draft_invoice_items dii, pa_draft_invoices di,
                   gl_alc_ledger_rships_v rep, pa_implementations imp
              WHERE di.project_id = p_project_id
              AND di.agreement_id = p_agreement_id
              AND dii.project_id = di.project_id
              AND dii.draft_invoice_num = di.draft_invoice_num
              AND dii.invoice_line_type <> 'RETENTION'
              AND rep.source_ledger_id = imp.set_of_books_id
              AND rep.relationship_enabled_flag  = 'Y'
              AND (rep.org_id = -99 OR rep.org_id = imp.org_id)
              AND rep.application_id = 275
              AND dii_mc.set_of_books_id =rep.ledger_id
              AND dii_mc.project_id = dii.project_id
              AND dii_mc.draft_invoice_num = dii.draft_invoice_num
              AND dii_mc.line_num = dii.line_num
              AND nvl(di.retention_invoice_flag, 'N') = 'N'
              AND di.invoice_date <= G_THRU_DATE
              GROUP BY dii.task_id, dii_mc.set_of_books_id
              )
              ORDER BY task_id,set_of_books_id; */


         l_SetOfBookIdTab              PA_PLSQL_DATATYPES.IdTabTyp;
         l_TaskIdTab                   PA_PLSQL_DATATYPES.IdTabTyp;
         l_BillAmtIPCTab               PA_PLSQL_DATATYPES.NumTabTyp;
         l_BillAmtPFCTab               PA_PLSQL_DATATYPES.NumTabTyp;
         l_BillAmtFCTab                PA_PLSQL_DATATYPES.NumTabTyp;

         l_SobIdIdx                    NUMBER := 0;

         l_TotalFetch               NUMBER := 0;
         l_ThisFetch                NUMBER := 0;
         l_FetchSize                NUMBER := 50;

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;
         l_LogMsg                   VARCHAR2(250);
   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.get_sum_invoice_components-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         /* This procedure gets sum of invoice lines for the given project/agreement id.

            If the project is funded at project level then there will be one line per agreement/
            set of book id
            If the project is funded at task level then there will be one line per agreement/ task/ set of book id

          */


         IF G_PRIMARY_ONLY = 'Y' THEN

            IF NVL(p_task_id,0) = 0 THEN  /* Project level funding */

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Cursor get_sum_proj_invoices ' ;
                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

               OPEN get_proj_invoices;

               LOOP

                   FETCH get_proj_invoices BULK COLLECT INTO l_SetOfBookIdTab, l_TaskIdTab,
                                                             l_BillAmtIPCTab, l_BillAmtPFCTab, l_BillAmtFCTab
                                           LIMIT  l_FetchSize;

                   l_ThisFetch := get_proj_invoices%ROWCOUNT - l_TotalFetch;
                   l_TotalFetch := get_proj_invoices%ROWCOUNT ;

                   IF l_ThisFetch > 0 THEN

                      populate_invoice_amount(
                             p_project_id        => p_project_id,
                             p_agreement_id      => p_agreement_id,
                             p_task_id           => p_task_id,
                             p_SetOfBookIdTab    => l_SetOfBookIdTab,
                             p_TaskIdTab         => l_TaskIdTab,
                             p_BillAmtIPCTab     => l_BillAmtIPCTab,
                             p_BillAmtFCTab      => l_BillAmtFCTab,
                             p_BillAmtPFCTab     => l_BillAmtPFCTab,
                             x_return_status     => l_return_status,
                             x_msg_count         => l_msg_count,
                             x_msg_data          => l_msg_data);

                      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                         RAISE FND_API.G_EXC_ERROR;

                      END IF;

                   END IF; /* l_ThisFetch */

                   /* Initialize for next fetch */
                   l_SetOfBookIdTab.DELETE;
                   l_TaskIdTab.DELETE;
                   l_BillAmtPFCTab.DELETE;
                   l_BillAmtFCTab.DELETE;
                   l_BillAmtIPCTab.DELETE;

                   IF l_ThisFetch < l_FetchSize THEN
                      Exit;
                   END IF;

               END LOOP; /*get_proj_invoices*/

               CLOSE get_proj_invoices;

            ELSE   /* Task Level funding */

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Cursor get_sum_task_invoices ' ;
                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

               OPEN get_task_invoices;

               LOOP

                   FETCH get_task_invoices BULK COLLECT INTO l_SetOfBookIdTab, l_TaskIdTab,
                                                             l_BillAmtIPCTab, l_BillAmtPFCTab, l_BillAmtFCTab
                                           LIMIT  l_FetchSize;

                   l_ThisFetch := get_task_invoices%ROWCOUNT - l_TotalFetch;
                   l_TotalFetch := get_task_invoices%ROWCOUNT ;

                   IF l_ThisFetch > 0 THEN

                      populate_invoice_amount(
                             p_project_id        => p_project_id,
                             p_agreement_id      => p_agreement_id,
                             p_task_id           => p_task_id,
                             p_SetOfBookIdTab    => l_SetOfBookIdTab,
                             p_TaskIdTab         => l_TaskIdTab,
                             p_BillAmtIPCTab     => l_BillAmtIPCTab,
                             p_BillAmtFCTab      => l_BillAmtFCTab,
                             p_BillAmtPFCTab     => l_BillAmtPFCTab,
                             x_return_status     => l_return_status,
                             x_msg_count         => l_msg_count,
                             x_msg_data          => l_msg_data);

                      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                         RAISE FND_API.G_EXC_ERROR;

                      END IF;

                   END IF; /* l_ThisFetch > 0  */


                   /* Initialize for next fetch */
                   l_SetOfBookIdTab.DELETE;
                   l_TaskIdTab.DELETE;
                   l_BillAmtPFCTab.DELETE;
                   l_BillAmtFCTab.DELETE;
                   l_BillAmtIPCTab.DELETE;

                   IF l_ThisFetch < l_FetchSize THEN
                      Exit;
                   END IF;

               END LOOP; /*get_task_invoices*/

               CLOSE get_task_invoices;

            END IF; /* p_task_id = 0 */

        /* mrc migration to SLA bug 4571438 ( ELSE  -- G_PRIMARY_ONLY = 'N'

            IF NVL(p_task_id,0) = 0 THEN  -- Project level funding

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Cursor get_sum_all_proj_invoices ' ;
                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

               OPEN get_all_proj_invoices;

               LOOP

                   FETCH get_all_proj_invoices BULK COLLECT INTO l_SetOfBookIdTab, l_TaskIdTab,
                                                             l_BillAmtIPCTab, l_BillAmtPFCTab, l_BillAmtFCTab
                                           LIMIT  l_FetchSize;

                   l_ThisFetch := get_all_proj_invoices%ROWCOUNT - l_TotalFetch;
                   l_TotalFetch := get_all_proj_invoices%ROWCOUNT ;

                   IF l_ThisFetch > 0 THEN

                      populate_invoice_amount(
                             p_project_id        => p_project_id,
                             p_agreement_id      => p_agreement_id,
                             p_task_id           => p_task_id,
                             p_SetOfBookIdTab    => l_SetOfBookIdTab,
                             p_TaskIdTab         => l_TaskIdTab,
                             p_BillAmtIPCTab     => l_BillAmtIPCTab,
                             p_BillAmtFCTab      => l_BillAmtFCTab,
                             p_BillAmtPFCTab     => l_BillAmtPFCTab,
                             x_return_status     => l_return_status,
                             x_msg_count         => l_msg_count,
                             x_msg_data          => l_msg_data);

                      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                         RAISE FND_API.G_EXC_ERROR;

                      END IF;

                   END IF; -- l_ThisFetch > 0

                   -- Initialize for next fetch
                   l_SetOfBookIdTab.DELETE;
                   l_TaskIdTab.DELETE;
                   l_BillAmtPFCTab.DELETE;
                   l_BillAmtFCTab.DELETE;
                   l_BillAmtIPCTab.DELETE;

                   IF l_ThisFetch < l_FetchSize THEN
                      Exit;
                   END IF;

               END LOOP ; -- get_all_proj_invoices

               CLOSE get_all_proj_invoices;

            ELSE   -- Task Level funding

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Cursor get_sum_all_task_invoices ' ;
                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

               OPEN get_all_task_invoices;

               LOOP

                   FETCH get_all_task_invoices BULK COLLECT INTO l_SetOfBookIdTab, l_TaskIdTab,
                                                             l_BillAmtIPCTab, l_BillAmtPFCTab, l_BillAmtFCTab
                                           LIMIT  l_FetchSize;

                   l_ThisFetch := get_all_task_invoices%ROWCOUNT - l_TotalFetch;
                   l_TotalFetch := get_all_task_invoices%ROWCOUNT ;

                   IF l_ThisFetch > 0 THEN

                      populate_invoice_amount(
                             p_project_id        => p_project_id,
                             p_agreement_id      => p_agreement_id,
                             p_task_id           => p_task_id,
                             p_SetOfBookIdTab    => l_SetOfBookIdTab,
                             p_TaskIdTab         => l_TaskIdTab,
                             p_BillAmtIPCTab     => l_BillAmtIPCTab,
                             p_BillAmtFCTab      => l_BillAmtFCTab,
                             p_BillAmtPFCTab     => l_BillAmtPFCTab,
                             x_return_status     => l_return_status,
                             x_msg_count         => l_msg_count,
                             x_msg_data          => l_msg_data);

                      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                         RAISE FND_API.G_EXC_ERROR;

                      END IF;

                   END IF; -- l_ThisFetch > 0

                   -- Initialize for next fetch
                   l_SetOfBookIdTab.DELETE;
                   l_TaskIdTab.DELETE;
                   l_BillAmtPFCTab.DELETE;
                   l_BillAmtFCTab.DELETE;
                   l_BillAmtIPCTab.DELETE;

                   IF l_ThisFetch < l_FetchSize THEN

                      Exit;

                   END IF;

               END LOOP ; -- get_all_task_invoices

               CLOSE get_all_task_invoices;

            END IF ; -- p_task_id = 0  ) */

         END IF ;/* G_PRIMARY_ONLY */

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.get_sum_invoice_components-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'get_sum_invoice_components:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END get_sum_invoice_components;


   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   populate_invoice_amount                                                |
   |   Purpose    :   This procedure loops thru all the input records and sum up the amount  |
   |                  to respective  amounts in the G_InvCompTab                             |
   |                  This is basically written to avoid this sum up code being repeated in  |
   |                  many places in procedure get_sum_invoice_components                    |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id              IN      Project ID                                        |
   |     p_agreement_id            IN      Agreement_id                                      |
   |     p_task_id                 IN      Task Id of summary project funding                |
   |     p_SetOfBookIdTab          IN      Set of book ids                                   |
   |     p_TaskIdTab               IN      Task Id of the invoice                            |
   |     p_BillAmtIPCTab           IN      Billed amount in IPC                              |
   |     p_BillAmtPFCTab           IN      Billed Amount in PFC                              |
   |     p_BillAmtFCTab            IN      Billed Amount in FC                               |
   |     x_return_status           OUT     Return status of this procedure                   |
   |     x_msg_count               OUT     Error message count                               |
   |     x_msg_data                OUT     Error message                                     |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE populate_invoice_amount(
             p_project_id        IN      NUMBER,
             p_agreement_id      IN      NUMBER,
             p_task_id           IN      NUMBER,
             p_SetOfBookIdTab    IN      PA_PLSQL_DATATYPES.IdTabTyp,
             p_TaskIdTab         IN      PA_PLSQL_DATATYPES.IdTabTyp,
             p_BillAmtIPCTab     IN      PA_PLSQL_DATATYPES.NumTabTyp,
             p_BillAmtFCTab      IN      PA_PLSQL_DATATYPES.NumTabTyp,
             p_BillAmtPFCTab     IN      PA_PLSQL_DATATYPES.NumTabTyp,
             x_return_status     OUT     NOCOPY VARCHAR2,
             x_msg_count         OUT     NOCOPY NUMBER,
             x_msg_data          OUT     NOCOPY VARCHAR2)   IS


         l_SobIdIdx                 NUMBER;
         l_FoundFlag                VARCHAR2(1);
         l_index                    NUMBER;

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;
         l_LogMsg                   VARCHAR2(250);

   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.populate_invoice_amount-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         /* If project level funding G_InvCompTab will have only one record for a set of book id
            If task level funding G_InvComptab table will have summary amounts of each agreement-task
               funding record for primary and reproting set of books. So it is not indexed by sob_id as like other tables

         */

         IF nvl(p_task_id,0) = 0 THEN /* project level funding */

            FOR i in p_SetOfBookIdTab.FIRST..p_SetOfBookIdTab.LAST LOOP

                l_SobIdIdx := p_SetOfBookIdTab(i);

                IF G_DEBUG_MODE = 'Y' THEN

                   l_LogMsg := ' ' ;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

                   l_LogMsg := 'Sob Id:' || l_SobIdIdx ;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

                   l_LogMsg := '==================';
                   PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

                END IF;

                /* Put in g_InvCompTab */

                /* Commented for bug 2731637 as this tab should be indexed by seq no and not sob id  and rewritten below

                IF G_InvCompTab.EXISTS(l_SobIdIdx) THEN
                       --  Data already exists for this set of book just add to it

                   G_InvCompTab(l_SobIdIdx).invproc_billed_amount :=
                                        nvl(G_InvCompTab(l_SobIdIdx).invproc_billed_amount,0) + p_BillAmtIPCTab(i);
                   G_InvCompTab(l_SobIdIdx).funding_billed_amount :=
                                        nvl(G_InvCompTab(l_SobIdIdx).funding_billed_amount,0) + p_BillAmtFCTab(i);
                   G_InvCompTab(l_SobIdIdx).projfunc_billed_amount :=
                                        nvl(G_InvCompTab(l_SobIdIdx).projfunc_billed_amount,0) + p_BillAmtPFCTab(i);

                ELSE

                   -- Data does not exist . First time creation for this set of book just assign it

                   G_InvCompTab(l_SobIdIdx).project_id := p_project_id;
                   G_InvCompTab(l_SobIdIdx).agreement_id := p_agreement_id;
                   G_InvCompTab(l_SobIdIdx).task_id := p_TaskIdTab(i);
                   G_InvCompTab(l_SobIdIdx).set_of_books_id := l_SobIdIdx;
                   G_InvCompTab(l_SobIdIdx).invproc_billed_amount := p_BillAmtIPCTab(i);
                   G_InvCompTab(l_SobIdIdx).funding_billed_amount := p_BillAmtFCTab(i);
                   G_InvCompTab(l_SobIdIdx).projfunc_billed_amount := p_BillAmtPFCTab(i);

                END IF;
                */

                l_FoundFlag := 'N';

                IF G_InvCompTab.count > 0 THEN

                   FOR j in G_InvCompTab.first..G_InvCompTab.LAST LOOP

                       IF G_InvCompTab(j).set_of_books_id = l_SobIDIdx THEN

                          G_InvCompTab(j).invproc_billed_amount :=
                                        nvl(G_InvCompTab(j).invproc_billed_amount,0) + p_BillAmtIPCTab(i);
                          G_InvCompTab(j).funding_billed_amount :=
                                        nvl(G_InvCompTab(j).funding_billed_amount,0) + p_BillAmtFCTab(i);
                          G_InvCompTab(j).projfunc_billed_amount :=
                                        nvl(G_InvCompTab(j).projfunc_billed_amount,0) + p_BillAmtPFCTab(i);

                          l_FoundFlag := 'Y';

                          EXIT;

                      END IF;

                   END LOOP;

                END IF;

                IF l_foundFlag = 'N' THEN

                   l_index := G_InvCompTab.Count + 1;

                   G_InvCompTab(l_index).project_id := p_project_id;
                   G_InvCompTab(l_index).agreement_id := p_agreement_id;
                   G_InvCompTab(l_index).task_id := p_TaskIdTab(i);
                   G_InvCompTab(l_index).set_of_books_id := l_SobIdIdx;
                   G_InvCompTab(l_index).invproc_billed_amount := p_BillAmtIPCTab(i);
                   G_InvCompTab(l_index).funding_billed_amount := p_BillAmtFCTab(i);
                   G_InvCompTab(l_index).projfunc_billed_amount := p_BillAmtPFCTab(i);

                END IF;

                IF G_DEBUG_MODE = 'Y' THEN

                   l_LogMsg := 'Billed Amt PFC:' || p_BillAmtPFCTab(i) ||
                              ' Billed Amt FC:' || p_BillAmtFCTab(i) ||
                              ' Billed Amt IPC:' || p_BillAmtIPCTab(i) ;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                END IF;

            END LOOP; /*SetOfBookIdTab LOO */

         ELSE  /* task level funding */

            FOR i in p_SetOfBookIdTab.FIRST..p_SetOfBookIdTab.LAST LOOP

                l_SobIdIdx := p_SetOfBookIdTab(i);

                IF G_DEBUG_MODE = 'Y' THEN

                   l_LogMsg := ' ' ;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

                   l_LogMsg := 'Sob Id:' || l_SobIdIdx ;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

                   l_LogMsg := '==================';
                   PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

                END IF;

                l_FoundFlag := 'N';

                IF G_InvCompTab.count > 0 THEN

                   FOR j in G_InvCompTab.first..G_InvCompTab.LAST LOOP

                       IF G_InvCompTab(j).set_of_books_id = l_SobIDIdx and
                          G_InvCompTab(j).task_id = p_TaskIdTab(i) THEN

                          G_InvCompTab(j).invproc_billed_amount :=
                                        nvl(G_InvCompTab(j).invproc_billed_amount,0) + p_BillAmtIPCTab(i);
                          G_InvCompTab(j).funding_billed_amount :=
                                        nvl(G_InvCompTab(j).funding_billed_amount,0) + p_BillAmtFCTab(i);
                          G_InvCompTab(j).projfunc_billed_amount :=
                                        nvl(G_InvCompTab(j).projfunc_billed_amount,0) + p_BillAmtPFCTab(i);

                          l_FoundFlag := 'Y';

                          EXIT;

                      END IF;

                   END LOOP;

                END IF;

                IF l_foundFlag = 'N' THEN

                   l_index := G_InvCompTab.Count + 1;

                   G_InvCompTab(l_index).project_id := p_project_id;
                   G_InvCompTab(l_index).agreement_id := p_agreement_id;
                   G_InvCompTab(l_index).task_id := p_TaskIdTab(i);
                   G_InvCompTab(l_index).set_of_books_id := l_SobIdIdx;
                   G_InvCompTab(l_index).invproc_billed_amount := p_BillAmtIPCTab(i);
                   G_InvCompTab(l_index).funding_billed_amount := p_BillAmtFCTab(i);
                   G_InvCompTab(l_index).projfunc_billed_amount := p_BillAmtPFCTab(i);

                END IF;

                IF G_DEBUG_MODE = 'Y' THEN

                   l_LogMsg := 'Billed Amt PFC:' || p_BillAmtPFCTab(i) ||
                               ' Billed Amt FC:' || p_BillAmtFCTab(i) ||
                               ' Billed Amt IPC:' || p_BillAmtIPCTab(i) ;
                   PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                END IF;

             END LOOP;

         END IF;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.populate_invoice_amount-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'populate_invoice_amount:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END populate_invoice_amount;


   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   compute_adjustment_amounts                                             |
   |   Purpose    :   To revaluate all computed amounts from funding currency to             |
   |                  projfunctional/invproc currency                                        |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_task_id             IN      Task Id of summary project funding                    |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE compute_adjustment_amounts(
             p_agreement_id            IN      NUMBER,
             p_task_id                 IN      NUMBER,
             x_return_status           OUT     NOCOPY VARCHAR2,
             x_msg_count               OUT     NOCOPY NUMBER,
             x_msg_data                OUT     NOCOPY VARCHAR2)   IS



         l_from_currency_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
         l_to_currency_tab               PA_PLSQL_DATATYPES.Char30TabTyp;
         l_conversion_date_tab           PA_PLSQL_DATATYPES.DateTabTyp;
         l_conversion_type_tab           PA_PLSQL_DATATYPES.Char30TabTyp;
         l_amount_tab                    PA_PLSQL_DATATYPES.NumTabTyp;
         l_user_validate_flag_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
         l_converted_amount_tab          PA_PLSQL_DATATYPES.NumTabTyp;
         l_denominator_tab               PA_PLSQL_DATATYPES.NumTabTyp;
         l_numerator_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
         l_rate_tab                      PA_PLSQL_DATATYPES.NumTabTyp;
         l_conversion_between            VARCHAR2(6);
         l_cache_flag                    VARCHAR2(1);
         l_status_tab                    PA_PLSQL_DATATYPES.Char30TabTyp;
         l_error_flag                    VARCHAR2(1) := 'N';

         l_FundingCurrencyCode           VARCHAR2(30);
         l_ProjfuncCurrencyCode          VARCHAR2(30);
         l_InvprocCurrencyCode           VARCHAR2(30);

         l_FundingBacklogAmount          NUMBER := 0;
         l_FundingPaidAmount             NUMBER := 0;
         l_FundingUnpaidAmount           NUMBER := 0;

         l_ProjfuncBacklogAmount         NUMBER := 0;
         l_ProjfuncPaidAmount            NUMBER := 0;
         l_ProjfuncUnpaidAmount          NUMBER := 0;
         l_ProjfuncBilledAmount          NUMBER := 0;

         l_InvprocBacklogAmount          NUMBER := 0;

         l_RevalBacklogAmtFC             NUMBER := 0;
         l_RvldBacklogAmtFC              NUMBER := 0;
         l_DueAmtFC                      NUMBER := 0;

         l_RvldBacklogAmtPFC              NUMBER := 0;
         l_RvldDueAmtPFC                  NUMBER := 0;

         l_RvldBacklogAmtIPC              NUMBER := 0;

         l_ProjFuncRate                  NUMBER;
         l_InvProcRate                   NUMBER;

         l_ProjfuncRateType              VARCHAR2(30);
         l_InvprocRateType               VARCHAR2(30);

         l_ProjfuncRevalRate             NUMBER;
         l_ProjfuncRevalType             VARCHAR2(30);

         l_InvprocRevalRate              NUMBER;
         l_InvprocRevalType              VARCHAR2(30);

         l_RevaluationIndex              NUMBER;

         l_return_status                 VARCHAR2(30) := NULL;
         l_msg_count                     NUMBER       := NULL;
         l_msg_data                      VARCHAR2(250) := NULL;
         l_LogMsg                        VARCHAR2(250);

         l_status                        NUMBER;

         l_SobIdIdx                    NUMBER;

         l_OrgId                       NUMBER;
         l_ResultCode                  VARCHAR2(100);
         l_NumeratorRate               NUMBER;
         l_DenominatorRate             NUMBER;
         l_RcInvDueAmount              NUMBER;
         l_RcBacklogAmount             NUMBER;

         /* The following 2 variables introduced for bug 2636048 */
         l_PFCDueBefReval              NUMBER;
         l_InvOvrFndFlag               VARCHAR2(1) := 'N';

         l_McErrorFlag                 VARCHAR2(1);
   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.compute_adjustment_amounts-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         SELECT NVL(org_id,-99) INTO l_OrgId FROM PA_IMPLEMENTATIONS;

         l_FundingCurrencyCode := G_RevalCompTab(G_SET_OF_BOOKS_ID).funding_currency_code;
         l_ProjFuncCurrencyCode := G_RevalCompTab(G_SET_OF_BOOKS_ID).projfunc_currency_code;
         l_InvprocCurrencyCode := G_RevalCompTab(G_SET_OF_BOOKS_ID).Invproc_currency_code;

         l_ProjFuncRate       := G_ProjLvlGlobRec.projfunc_bil_exchange_rate;
         l_InvProcRate       := G_ProjLvlGlobRec.InvProc_exchange_rate;

         IF G_DEBUG_MODE = 'Y' THEN

            l_LogMsg := 'Currency:' ||
                        ' FC Currency :' || l_FundingCurrencyCode ||
                        ' PFC Currency :' || l_ProjFuncCurrencyCode ||
                        ' IPC Currency :' || l_InvprocCurrencyCode;

            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

         END IF;

         /* In case run-time param rate type is null assign from projec level */

         l_ProjfuncRateType   := nvl(G_RATE_TYPE, G_ProjLvlGlobRec.projfunc_bil_rate_type);
         l_InvprocRateType   := nvl(G_RATE_TYPE, G_ProjLvlGlobRec.invproc_rate_type);

         IF G_DEBUG_MODE = 'Y' THEN

            l_LogMsg := 'Conversion attributes assigned:' ||
                        ' PFC Rate type:' || l_ProjfuncRateType  ||
                        ' IPC Rate type:' || l_InvprocRateType;

            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

         END IF;


         l_from_currency_tab.DELETE;
         l_to_currency_tab.DELETE;
         l_conversion_date_tab.DELETE;
         l_conversion_type_tab.DELETE;
         l_amount_tab.DELETE;
         l_user_validate_flag_tab.DELETE;
         l_converted_amount_tab.DELETE;
         l_denominator_tab.DELETE;
         l_numerator_tab.DELETE;
         l_rate_tab.DELETE;
         l_status_tab.DELETE;

         /* Populating to get rate for conversion from funding to projfunc currency
            The amount is passed as 1 because only the rate is required to pass it to client extension */

         l_from_currency_tab(1) := l_FundingCurrencyCode;
         l_to_currency_tab(1) := l_ProjFuncCurrencyCode;
         l_conversion_date_tab(1) := G_RATE_DATE;
         l_conversion_type_tab(1) := l_ProjFuncRateType;
         l_amount_tab(1) := 1;
         l_user_validate_flag_tab(1) := 'Y';
         l_converted_amount_tab(1) := 0;
         l_denominator_tab(1) := 0;
         l_numerator_tab(1) := 0;
         l_rate_tab(1) := l_ProjFuncRate;
         l_conversion_between:= 'FC_PFC';

         PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
               p_from_currency_tab             => l_from_currency_tab,
               p_to_currency_tab               => l_to_currency_tab,
               p_conversion_date_tab           => l_conversion_date_tab,
               p_conversion_type_tab           => l_conversion_type_tab,
               p_amount_tab                    => l_amount_tab,
               p_user_validate_flag_tab        => l_user_validate_flag_tab,
               p_converted_amount_tab          => l_converted_amount_tab,
               p_denominator_tab               => l_denominator_tab,
               p_numerator_tab                 => l_numerator_tab,
               p_rate_tab                      => l_rate_tab,
               x_status_tab                    => l_status_tab,
               p_conversion_between            => l_conversion_between,
               p_cache_flag                    => 'Y');

         IF (l_status_tab(1) <> 'N') THEN

            ROLLBACK;

            --l_msg_data := l_status_tab(1);
            l_return_status := FND_API.G_RET_STS_ERROR;

            /* Stamp rejection reason in PA_SPF */
            insert_rejection_reason_spf (
                  p_project_id     => G_ProjLvlGlobRec.project_id,
                  p_agreement_id   => p_agreement_id,
                  p_task_id        => p_task_id,
                  p_reason_code    => l_status_tab(1),
                  x_return_status  => l_return_status,
                  x_msg_count      => l_msg_count,
                  x_msg_data       => l_msg_data) ;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSE

               l_msg_data := l_status_tab(1);
               l_return_status := FND_API.G_RET_STS_ERROR;

               RAISE FND_API.G_EXC_ERROR;

            END IF;

         ELSE
            /* Store the actual projfunc rate and rate type for later use that will be used by conversion api */

            l_ProjfuncRevalRate := l_rate_tab(1);
            l_ProjfuncRevalType := l_conversion_type_tab(1);


            l_from_currency_tab.DELETE;
            l_to_currency_tab.DELETE;
            l_conversion_date_tab.DELETE;
            l_conversion_type_tab.DELETE;
            l_amount_tab.DELETE;
            l_user_validate_flag_tab.DELETE;
            l_converted_amount_tab.DELETE;
            l_denominator_tab.DELETE;
            l_numerator_tab.DELETE;
            l_rate_tab.DELETE;
            l_status_tab.DELETE;

            /* Populating to get rate for conversion from funding to invproc currency
              The amount is passed as 1 because only the rate is required to pass it to client extension */

            l_from_currency_tab(1) := l_FundingCurrencyCode;
            l_to_currency_tab(1) := l_InvprocCurrencyCode;
            l_conversion_date_tab(1) := G_RATE_DATE;
            l_conversion_type_tab(1) := l_InvprocRateType;
            l_amount_tab(1) := 1;
            l_user_validate_flag_tab(1) := 'Y';
            l_converted_amount_tab(1) := 0;
            l_denominator_tab(1) := 0;
            l_numerator_tab(1) := 0;
            l_rate_tab(1) := l_InvprocRate;
            l_conversion_between:= 'FC_IPC';

            PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
               p_from_currency_tab             => l_from_currency_tab,
               p_to_currency_tab               => l_to_currency_tab,
               p_conversion_date_tab           => l_conversion_date_tab,
               p_conversion_type_tab           => l_conversion_type_tab,
               p_amount_tab                    => l_amount_tab,
               p_user_validate_flag_tab        => l_user_validate_flag_tab,
               p_converted_amount_tab          => l_converted_amount_tab,
               p_denominator_tab               => l_denominator_tab,
               p_numerator_tab                 => l_numerator_tab,
               p_rate_tab                      => l_rate_tab,
               x_status_tab                    => l_status_tab,
               p_conversion_between            => l_conversion_between,
               p_cache_flag                    => 'Y');

            IF (l_status_tab(1) <> 'N') THEN

               ROLLBACK;
               --l_msg_data := l_status_tab(1);
               l_return_status := FND_API.G_RET_STS_ERROR;

               /* Stamp rejection reason in PA_SPF */
               insert_rejection_reason_spf (
                  p_project_id     => G_ProjLvlGlobRec.project_id,
                  p_agreement_id   => p_agreement_id,
                  p_task_id        => p_task_id,
                  p_reason_code    => l_status_tab(1),
                  x_return_status  => l_return_status,
                  x_msg_count      => l_msg_count,
                  x_msg_data       => l_msg_data) ;

               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSE

                  l_msg_data := l_status_tab(1);
                  l_return_status := FND_API.G_RET_STS_ERROR;

                  RAISE FND_API.G_EXC_ERROR;

               END IF;

            ELSE

               /* Store the actual invproc rate and rate type for later use that will be used by conversion api */
               l_InvprocRevalRate := l_rate_tab(1);
               l_InvprocRevalType := l_conversion_type_tab(1);

            END IF;

        END IF;

        IF G_DEBUG_MODE = 'Y' THEN

           l_LogMsg := 'Conv attr before client extension ' ;
           PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

           l_LogMsg := 'PFC rate type:' || l_ProjfuncRevalType ||
                           ' PFC Rate:' || l_ProjfuncRevalRate ||
                           ' IPC rate type:' || l_InvprocRevalType ||
                           ' IPC Rate:' || l_InvprocRevalRate;

           PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

        END IF;

        /* No invoices have been generated.*/

        /* Invoices may have been generated , But for this agreement/task combination there may not by
           any invoice. So initialize assuming there are no invoices */

       l_FundingBacklogAmount := G_RevalCompTab(G_SET_OF_BOOKS_ID).total_baselined_amount ;
       l_FundingPaidAmount := 0;
       l_FundingUnpaidAmount := 0;
       l_ProjfuncBacklogAmount := G_RevalCompTab(G_SET_OF_BOOKS_ID).projfunc_baselined_amount;
       l_ProjfuncPaidAmount := 0;
       l_ProjfuncUnpaidAmount := 0;
       l_ProjfuncBilledAmount := 0;
       l_InvprocBacklogAmount := G_RevalCompTab(G_SET_OF_BOOKS_ID).invproc_baselined_amount;

        IF G_InvCompTab.COUNT <> 0 THEN

         /* G_InvCompTab has invoice summary for an agreemnt /all task (task level funding/all set of books
            Loop thru this to get for current agreement/task/primary set of book as client extension is to
            be called only for primary set of book */

            FOR i in G_InvCompTab.first..G_InvCompTab.LAST LOOP


                IF ((G_InvCompTab(i).set_of_books_id = G_SET_OF_BOOKS_ID) AND
                    (G_InvCompTab(i).agreement_id = G_RevalCompTab(G_SET_OF_BOOKS_ID).agreement_id) AND
                    (nvl(G_InvCompTab(i).task_id,0) = nvl(G_RevalCompTab(G_SET_OF_BOOKS_ID).task_id,0))) THEN

                    /* Commented and rewritten for bug 2636048 Uncommented for bug 3532963 */

                    l_FundingBacklogAmount :=
                              G_RevalCompTab(G_SET_OF_BOOKS_ID).total_baselined_amount - G_InvCompTab(i).funding_billed_amount;

                    l_ProjfuncBacklogAmount :=
                        G_RevalCompTab(G_SET_OF_BOOKS_ID).projfunc_baselined_amount - G_InvCompTab(i).projfunc_billed_amount;

                    l_InvprocBacklogAmount :=
                        G_RevalCompTab(G_SET_OF_BOOKS_ID).invproc_baselined_amount - G_InvCompTab(i).invproc_billed_amount;

                    l_FundingPaidAmount := nvl(G_InvCompTab(i).funding_applied_amount,0);
                    l_ProjfuncPaidAmount := nvl(G_InvCompTab(i).projfunc_applied_amount,0);

                    /* Check if invoiced amount > total funding (baselined amount) */

                    IF nvl(G_RevalCompTab(G_SET_OF_BOOKS_ID).total_baselined_amount,0) >=
                           nvl(G_InvCompTab(i).funding_billed_amount,0)  THEN

                       /*l_FundingBacklogAmount :=
                              nvl(G_RevalCompTab(G_SET_OF_BOOKS_ID).total_baselined_amount,0) -
                              nvl(G_InvCompTab(i).funding_billed_amount,0); */

                       l_InvOvrFndFlag := 'N'; /* Invoiced amount has not exceeded funding amount*/

                    ELSE

                       /* Invoiced amount has exceeded the funding ammount. There is no backlog */

                       --l_FundingBacklogAmount := 0;

                       l_InvOvrFndFlag := 'Y'; /* Invoiced amount has exceeded funding amount */

                    END IF;

/* Following code commented for bug 3532963

                      IF nvl(G_RevalCompTab(G_SET_OF_BOOKS_ID).projfunc_baselined_amount,0) >=
                           nvl(G_InvCompTab(i).projfunc_billed_amount,0)  THEN

                       l_ProjfuncBacklogAmount :=
                              nvl(G_RevalCompTab(G_SET_OF_BOOKS_ID).Projfunc_baselined_amount,0) -
                              nvl(G_InvCompTab(i).Projfunc_billed_amount,0);

                    ELSE

                        Invoiced amount has exceeded the funding ammount. There is no backlog

                       l_ProjfuncBacklogAmount := 0;

                    END IF;


                   IF nvl(G_RevalCompTab(G_SET_OF_BOOKS_ID).invproc_baselined_amount,0) >=
                           nvl(G_InvCompTab(i).invproc_billed_amount,0)  THEN

                       l_InvprocBacklogAmount :=
                              nvl(G_RevalCompTab(G_SET_OF_BOOKS_ID).invproc_baselined_amount,0) -
                              nvl(G_InvCompTab(i).invproc_billed_amount,0);

                    ELSE

                        Invoiced amount has exceeded the funding ammount. There is no backlog

                       l_InvprocBacklogAmount := 0;

                    END IF;
End  3532963 */

                    l_FundingUnpaidAmount := 0;
                    l_ProjfuncUnpaidAmount := 0;
                    l_ProjfuncBilledAmount := 0;

                    /* Only if this flag is set, unpaid amount will be revaluated Bug 2548136*/
                    IF (G_ProjLvlGlobRec.include_gains_losses_flag =  'Y') THEN

                                             l_FundingUnpaidAmount := G_InvCompTab(i).funding_billed_amount - G_InvCompTab(i).funding_applied_amount
                                                 + G_InvCompTab(i).funding_adjusted_amount; /* Added for bug 7237486*/
                        l_ProjfuncUnpaidAmount := G_InvCompTab(i).projfunc_billed_amount - G_InvCompTab(i).projfunc_applied_amount
                                                 + G_InvCompTab(i).projfunc_adjusted_amount; /* Added for bug 7237486 */
                    END IF;

                    EXIT;

                END IF; /* current agreement of primary set of book */

            END LOOP; /* Invoice tab */

        END IF; /* IF G_InvCompTab.COUNT = 0 THEN */

        PA_Client_Extn_Funding_Reval.Funding_Revaluation_factor (
                          P_Project_ID              => G_ProjLvlGlobRec.project_id,
                          P_Top_Task_ID             => G_RevalCompTab(G_SET_OF_BOOKS_ID).task_id,
                          P_Agreement_ID            => G_RevalCompTab(G_SET_OF_BOOKS_ID).agreement_id,
                          P_Funding_Currency        => G_RevalCompTab(G_SET_OF_BOOKS_ID).funding_currency_code,
                          P_Projfunc_Currency       => G_RevalCompTab(G_SET_OF_BOOKS_ID).projfunc_currency_code,
                          P_InvProc_Currency        => G_RevalCompTab(G_SET_OF_BOOKS_ID).invproc_currency_code,
                          P_reval_through_date      => G_THRU_DATE,
                          P_reval_rate_date         => G_RATE_DATE,
                          P_projfunc_rate_type      => l_ProjfuncRevalType,
                          P_reval_projfunc_rate     => l_ProjfuncRevalRate,
                          P_Invproc_rate_type       => l_InvprocRevalType,
                          P_reval_Invproc_rate      => l_InvprocRevalRate,
                          P_Funding_Backlog_Amount  => l_FundingBacklogAmount,
                          P_Funding_paid_Amount     => l_FundingPaidAmount,
                          P_Funding_Unpaid_Amount   => l_FundingUnpaidAmount,
                          P_Projfunc_Backlog_Amount => l_ProjfuncBacklogAmount,
                          P_Projfunc_paid_Amount    => l_ProjfuncPaidAmount,
                          P_Projfunc_Unpaid_Amount  => l_ProjfuncUnpaidAmount,
                          P_Invproc_Backlog_amount  => l_InvprocBacklogAmount,
                          X_funding_reval_factor    => l_RevaluationIndex,
                          X_Status                  => l_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

               RAISE FND_API.G_EXC_ERROR;

        END IF;

        IF G_DEBUG_MODE = 'Y' THEN

           l_LogMsg := 'Revaluation Index ' || l_RevaluationIndex ;
           PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

        END IF;

         /* Do conversion for revaluation using the attributes derived at the beginning of the call */

         l_SobIdIdx := G_RevalCompTab.FIRST;

         LOOP

            EXIT WHEN l_SobIdIdx IS NULL;

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := ' ' ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

               l_LogMsg := 'Sob Id:' || l_SobIdIdx ;
               PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

               l_LogMsg := '==================';
               PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

            END IF;

            /* Initialize assuming there are no invoices */
            G_RevalCompTab(l_SobIdIdx).funding_inv_applied_amount :=  0;
            G_RevalCompTab(l_SobIdIdx).funding_inv_due_amount := 0;
            G_RevalCompTab(l_SobIdIdx).funding_backlog_amount :=  G_RevalCompTab(l_SobIdIdx).total_baselined_amount;
            G_RevalCompTab(l_SobIdIdx).projfunc_realized_gains_amt := 0;
            G_RevalCompTab(l_SobIdIdx).projfunc_realized_losses_amt := 0;
            G_RevalCompTab(l_SobIdIdx).projfunc_inv_applied_amount :=  0;
            l_InvprocBacklogAmount := nvl(G_RevalCompTab(l_SobIdIdx).invproc_baselined_amount,0);
            l_ProjfuncBilledAmount := 0;

            l_InvOvrFndFlag  := 'N';
            IF G_InvCompTab.count <> 0 THEN /* invoices have been generated */

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Invoices have been generated';
                  PA_FUND_REVAL_UTIL.Log_Message(p_message =>l_LogMsg);

               END IF;

               FOR i in G_InvCompTab.first..G_InvCompTab.LAST LOOP

                   /* Do only for current agreement/all set of book ids */

                   IF G_DEBUG_MODE = 'Y' THEN

                      l_LogMsg := 'Inv tab: sobid:' || G_InvCompTab(i).set_of_books_id ||
                                  ' agr id:' || G_InvCompTab(i).agreement_id ||
                                  ' tsk id:' || G_InvCompTab(i).task_id;

                      PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                      l_LogMsg := 'Reval tab: sobid:' || l_SobIdIdx ||
                                  ' agr id:' || G_RevalCompTab(l_SobIdIdx).agreement_id ||
                                  ' tsk id:' || G_RevalCompTab(l_SobIdIdx).task_id;

                      PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                   END IF;

                   IF ((G_InvCompTab(i).set_of_books_id = l_SobIdIdx) AND
                       (G_InvCompTab(i).agreement_id = G_RevalCompTab(l_SobIdIdx).agreement_id) AND
                       (nvl(G_InvCompTab(i).task_id,0) = nvl(G_RevalCompTab(l_SobIdIdx).task_id,0))) THEN

                       G_RevalCompTab(l_SobIdIdx).funding_backlog_amount :=
                                 pa_currency.round_trans_currency_amt(
                                   (G_RevalCompTab(l_SobIdIdx).total_baselined_amount -
                                           nvl(G_InvCompTab(i).funding_billed_amount,0)),
                                    G_RevalCompTab(l_SobIdIdx).Funding_Currency_Code);

                       /* Billed amount over funding amount . May be soft limit agreement Bug 2636048 */

                       IF nvl(G_RevalCompTab(l_SobIdIdx).funding_backlog_amount,0) < 0 THEN

                          --G_RevalCompTab(l_SobIdIdx).funding_backlog_amount := 0; /* Commented for bug 3532963 */
                          l_InvOvrFndFlag  := 'Y';

                       ELSE
                          l_InvOvrFndFlag  := 'N';

                       END IF;


                       /* Invproc backlog amount before revaluation is required as adjustment amount will be the difference
                          in backlog amount before and after revaluation. For IPC only backlog amount will be revaluated */

                       /* Billed amount over funding amount . May be soft limit agreement Bug 2636048 */

    /* Commented for bug 3532963  IF l_InvOvrFndFlag = 'Y' THEN

                          l_InvprocBacklogAmount := 0;

                       ELSE */
                          l_InvprocBacklogAmount :=
                                 pa_currency.round_trans_currency_amt(
                                    (G_RevalCompTab(l_SobIdIdx).invproc_baselined_amount -
                                                                   nvl(G_InvCompTab(i).invproc_billed_amount,0)),
                                     G_RevalCompTab(l_SobIdIdx).invproc_Currency_Code);

                       --END IF;

                       G_RevalCompTab(l_SobIdIdx).funding_inv_applied_amount :=
                                 pa_currency.round_trans_currency_amt( nvl(G_InvCompTab(i).funding_applied_amount,0),
                                                                       G_RevalCompTab(l_SobIdIdx).Funding_Currency_Code);

                       G_RevalCompTab(l_SobIdIdx).funding_inv_due_amount := 0;

                       /* If include_gains_losses_flag is not set, then the projfunc billed amount should be added to
                          total revalued amount, as otherwise this component will come in adjustment amount. Only backlog
                          amount will be revaluated and the billed amount will be added as is to total_revalued_amount of PFC
                       */
                       l_ProjfuncBilledAmount := 0;

                       /* Only if this flag is set, unpaid amount will be revaluated Bug 2548136*/

                       IF (G_ProjLvlGlobRec.include_gains_losses_flag =  'Y') THEN

                          IF G_DEBUG_MODE = 'Y' THEN

                             l_LogMsg := ' FC billed amount:' || G_InvCompTab(i).funding_billed_amount ||
                                         ' FC Appl amount: ' || round(G_InvCompTab(i).funding_applied_amount,5) ||
                                         ' nvl(G_InvCompTab(i).revald_pf_inv_due_amount,0) : ' || nvl(G_InvCompTab(i).revald_pf_inv_due_amount,0);
                             PA_FUND_REVAL_UTIL.log_message(l_LogMsg);

                          END IF;

                          G_RevalCompTab(l_SobIdIdx).funding_inv_due_amount :=
                                 pa_currency.round_trans_currency_amt(
                                      (nvl(G_InvCompTab(i).funding_billed_amount,0) -
                                                                     nvl(G_InvCompTab(i).funding_applied_amount,0) +
					       nvl(G_InvCompTab(i).funding_adjusted_amount,0)),   /* Added for bug 7237486 */
                                       G_RevalCompTab(l_SobIdIdx).Funding_Currency_Code);

                         G_RevalCompTab(l_SobIdIdx).projfunc_inv_due_amount :=             /* Added for bug 3221279 */
                                 pa_currency.round_trans_currency_amt(
                                      nvl(G_InvCompTab(i).revald_pf_inv_due_amount,0),
                                       G_RevalCompTab(l_SobIdIdx).projfunc_Currency_Code);

                          /* This is required for Bug 2548136. The adjustment amount requires the difference in due amount
                             before and after revaluation */

                          l_PFCDueBefReval  :=
                                 pa_currency.round_trans_currency_amt(
                                      (nvl(G_InvCompTab(i).projfunc_billed_amount,0) -
                                               nvl(G_InvCompTab(i).projfunc_applied_amount,0)),
                                       G_RevalCompTab(l_SobIdIdx).projfunc_Currency_Code);

                          G_RevalCompTab(l_SobIdIdx).projfunc_realized_gains_amt :=
                                 pa_currency.round_trans_currency_amt(
                                    nvl(G_InvCompTab(i).projfunc_gain_amount,0),
                                    G_RevalCompTab(l_SobIdIdx).projfunc_Currency_Code) -
                                 G_RevalCompTab(l_SobIdIdx).realized_gains_amount;

                          G_RevalCompTab(l_SobIdIdx).projfunc_realized_losses_amt :=
                                 pa_currency.round_trans_currency_amt(
                                     nvl(G_InvCompTab(i).projfunc_loss_amount,0) ,
                                     G_RevalCompTab(l_SobIdIdx).projfunc_Currency_Code) -
                                 G_RevalCompTab(l_SobIdIdx).realized_losses_amount;
                       ELSE

                          l_PFCDueBefReval  :=  0;

                          l_ProjfuncBilledAmount :=
                                 pa_currency.round_trans_currency_amt(
                                      nvl(G_InvCompTab(i).projfunc_billed_amount,0),
                                      G_RevalCompTab(l_SobIdIdx).projfunc_Currency_Code);

                          G_RevalCompTab(l_SobIdIdx).projfunc_realized_gains_amt := 0;
                          G_RevalCompTab(l_SobIdIdx).projfunc_realized_losses_amt := 0;

                          IF G_DEBUG_MODE = 'Y' THEN

                             l_LogMsg := 'PFC billed amount (only when include gains losses is N):' || l_ProjfuncBilledAmount;
                             PA_FUND_REVAL_UTIL.log_message(l_LogMsg);

                          END IF;

                       END IF;

                      /*

                       Moved above within if and end if
                       G_RevalCompTab(l_SobIdIdx).projfunc_realized_gains_amt :=
                                 pa_currency.round_trans_currency_amt(
                                    nvl(G_InvCompTab(i).projfunc_gain_amount,0),
                                    G_RevalCompTab(l_SobIdIdx).projfunc_Currency_Code) -
                                 G_RevalCompTab(l_SobIdIdx).realized_gains_amount;

                       G_RevalCompTab(l_SobIdIdx).projfunc_realized_losses_amt :=
                                 pa_currency.round_trans_currency_amt(
                                     nvl(G_InvCompTab(i).projfunc_loss_amount,0) ,
                                     G_RevalCompTab(l_SobIdIdx).projfunc_Currency_Code) -
                                 G_RevalCompTab(l_SobIdIdx).realized_losses_amount;
                       */

                       G_RevalCompTab(l_SobIdIdx).projfunc_inv_applied_amount :=
                                 pa_currency.round_trans_currency_amt( nvl(G_InvCompTab(i).projfunc_applied_amount,0),
                                                                       G_RevalCompTab(l_SobIdIdx).projfunc_Currency_Code);

                       Exit;

                   END IF;

               END LOOP; /*G_InvCompTab loop */

            END IF; /* IF G_InvCompTab.count <. 0 */

            G_RevalCompTab(l_SobIdIdx).funding_reval_amount :=  G_RevalCompTab(l_SobIdIdx).total_baselined_amount;
            G_RevalCompTab(l_SobIdIdx).projfunc_reval_amount :=  G_RevalCompTab(l_SobIdIdx).projfunc_baselined_amount;
            G_RevalCompTab(l_SobIdIdx).invproc_reval_amount :=  G_RevalCompTab(l_SobIdIdx).invproc_baselined_amount;
            G_RevalCompTab(l_SobIdIdx).funding_revaluation_factor :=  l_RevaluationIndex;

            --l_RevalBacklogAmtFC := G_RevalCompTab(l_SobIdIdx).funding_backlog_amount  * l_RevaluationIndex;
            l_DueAmtFC := G_RevalCompTab(l_SobIdIdx).funding_inv_due_amount  ;

            l_FundingCurrencyCode := G_RevalCompTab(l_SobIdIdx).funding_currency_code;
            l_ProjFuncCurrencyCode := G_RevalCompTab(l_SobIdIdx).projfunc_currency_code;
            l_InvprocCurrencyCode := G_RevalCompTab(l_SobIdIdx).Invproc_currency_code;



             /* 1234 Begin - 3532963 */
            IF (G_RevalCompTab(l_SobIdIdx).funding_backlog_amount < 0) THEN
                IF  ((l_RevaluationIndex IS NULL) OR (l_RevaluationIndex <> 1))  THEN
                   l_RevalBacklogAmtFC :=
                         pa_currency.round_trans_currency_amt((G_RevalCompTab(l_SobIdIdx).funding_backlog_amount * nvl(l_RevaluationIndex,0)),
                                                                                          G_RevalCompTab(l_SobIdIdx).funding_currency_code);
                ELSE
                   l_RevalBacklogAmtFC := 0;
                   G_RevalCompTab(l_SobIdIdx).funding_backlog_amount := 0;
                END IF;
           ELSE
                l_RevalBacklogAmtFC :=
                    pa_currency.round_trans_currency_amt((G_RevalCompTab(l_SobIdIdx).funding_backlog_amount * nvl(l_RevaluationIndex,0)),
                                                                                          G_RevalCompTab(l_SobIdIdx).funding_currency_code);
           END IF;
            /* End- 3532963 */

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'FC Backlog: ' || l_RevalBacklogAmtFC ||
                           ' FC Due:' || round(l_DueAmtFC,5) ||
                           ' FC :'   || l_FundingCurrencyCode ||
                           ' PFC: ' || l_ProjfuncCurrencyCode ;

               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            IF l_SobIdIdx = G_SET_OF_BOOKS_ID THEN

               /* This was derived just before this loop  as required by client extension
                  So assigning the same. If the currencies are same previous call to converion might have
                  nulled out the rate type /rate .So check for null and reassign the original*/

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Primary Processing attributes';
                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

               l_ProjfuncRateType := nvl(l_ProjfuncRevalType, l_ProjfuncRateType);
               l_InvprocRateType :=  nvl(l_InvprocRevalType,l_InvprocRateType);
               l_ProjfuncRate := nvl(l_ProjfuncRevalRate,l_ProjfuncRate);
               l_InvprocRate := nvl(l_InvprocRevalRate,l_InvprocRate);

               IF G_DEBUG_MODE = 'Y' THEN

                   l_LogMsg := 'PFC Rate Type:' || l_ProjfuncRateType ||
                               ' IPC Rate Type:' || l_InvprocRateType ||
                               ' PFC Rate: ' || l_ProjFuncRate ||
                               ' IPC Rate: ' || l_InvprocRate ;

                   PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

               l_from_currency_tab.DELETE;
               l_to_currency_tab.DELETE;
               l_conversion_date_tab.DELETE;
               l_conversion_type_tab.DELETE;
               l_amount_tab.DELETE;
               l_user_validate_flag_tab.DELETE;
               l_converted_amount_tab.DELETE;
               l_denominator_tab.DELETE;
               l_numerator_tab.DELETE;
               l_rate_tab.DELETE;
               l_status_tab.DELETE;

               /* Populating for projfunc backlog amount revaluation */

               l_from_currency_tab(1) := l_FundingCurrencyCode;
               l_to_currency_tab(1) := l_ProjfuncCurrencyCode;
               l_conversion_date_tab(1) := G_RATE_DATE;
               l_conversion_type_tab(1) := l_ProjfuncRateType;
               l_amount_tab(1) := l_RevalBacklogAmtFC;
               l_user_validate_flag_tab(1) := 'Y';
               l_converted_amount_tab(1) := 0;
               l_denominator_tab(1) := 0;
               l_numerator_tab(1) := 0;
               l_rate_tab(1) := l_ProjFuncRate;
               l_conversion_between:= 'FC_PFC';
               l_cache_flag:= 'Y';
               l_status_tab(1) := 'N';

               /* Populating for projfunc due amount revaluation */

               l_from_currency_tab(2) := l_FundingCurrencyCode;
               l_to_currency_tab(2) := l_ProjfuncCurrencyCode;
               l_conversion_date_tab(2) := G_RATE_DATE;
               l_conversion_type_tab(2) := l_ProjfuncRateType;
               l_amount_tab(2) := l_DueAmtFC;
               l_user_validate_flag_tab(2) := 'Y';
               l_converted_amount_tab(2) := 0;
               l_denominator_tab(2) := 0;
               l_numerator_tab(2) := 0;
               l_rate_tab(2) := l_ProjFuncRate;
               l_conversion_between:= 'FC_PFC';
               l_cache_flag:= 'Y';
               l_status_tab(2) := 'N';

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Calling conversion for PFC ';
                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

               PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
                    p_from_currency_tab             => l_from_currency_tab,
                    p_to_currency_tab               => l_to_currency_tab,
                    p_conversion_date_tab           => l_conversion_date_tab,
                    p_conversion_type_tab           => l_conversion_type_tab,
                    p_amount_tab                    => l_amount_tab,
                    p_user_validate_flag_tab        => l_user_validate_flag_tab,
                    p_converted_amount_tab          => l_converted_amount_tab,
                    p_denominator_tab               => l_denominator_tab,
                    p_numerator_tab                 => l_numerator_tab,
                    p_rate_tab                      => l_rate_tab,
                    x_status_tab                    => l_status_tab,
                    p_conversion_between            => l_conversion_between,
                    p_cache_flag                    => 'Y');

               IF ((l_status_tab(1) <> 'N') OR (l_status_tab(2) <> 'N' ))THEN

                  ROLLBACK;

                  --l_msg_data := l_status_tab(1);
                  l_return_status := FND_API.G_RET_STS_ERROR;

                  /* Stamp rejection reason in PA_SPF */
                  insert_rejection_reason_spf (
                     p_project_id     => G_ProjLvlGlobRec.project_id,
                     p_agreement_id   => p_agreement_id,
                     p_task_id        => p_task_id,
                     p_reason_code    => l_status_tab(1),
                     x_return_status  => l_return_status,
                     x_msg_count      => l_msg_count,
                     x_msg_data       => l_msg_data) ;

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                  ELSE

                     l_msg_data := l_status_tab(1);
                     l_return_status := FND_API.G_RET_STS_ERROR;

                     RAISE FND_API.G_EXC_ERROR;

                  END IF;

               ELSE

                   /* Assign the conversion result to the raval comp table */

                   G_RevalCompTab(l_SobIdIdx).reval_projfunc_rate_type :=  l_ProjfuncRateType; /* l_conversion_type_tab(1); Bug 3561113 */
                   G_RevalCompTab(l_SobIdIdx).reval_projfunc_rate :=  l_rate_tab(1);
         /*        G_RevalCompTab(l_SobIdIdx).projfunc_inv_due_amount :=  l_converted_amount_tab(2); commented for Bug 3221279 */
                   G_RevalCompTab(l_SobIdIdx).projfunc_backlog_amount :=  l_converted_amount_tab(1);

                   IF G_DEBUG_MODE = 'Y' THEN

                      l_LogMsg := 'After Conversion' ||
                                  ' PFC Rate type:' || l_conversion_type_tab(1) ||
                                  ' l_ProjfuncRateType: ' || l_ProjfuncRateType ||
                                  ' PFC Rate :' || l_rate_tab(1);

                      PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                      l_LogMsg :=  'PFC Revald Due amt :' || l_converted_amount_tab(2) ||
                                  ' PFC Revald backlog amt :' || l_converted_amount_tab(1);

                      PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                   END IF;

               END IF;

               l_from_currency_tab.DELETE;
               l_to_currency_tab.DELETE;
               l_conversion_date_tab.DELETE;
               l_conversion_type_tab.DELETE;
               l_amount_tab.DELETE;
               l_user_validate_flag_tab.DELETE;
               l_converted_amount_tab.DELETE;
               l_denominator_tab.DELETE;
               l_numerator_tab.DELETE;
               l_rate_tab.DELETE;
               l_status_tab.DELETE;

               /*  Populating for invproc backlog amount revaluation */

               l_from_currency_tab(1) := l_FundingCurrencyCode;
               l_to_currency_tab(1) := l_InvprocCurrencyCode;
               l_conversion_date_tab(1) := G_RATE_DATE;
               l_conversion_type_tab(1) := l_InvprocRateType;
               l_amount_tab(1) := l_RevalBacklogAmtFC;
               l_user_validate_flag_tab(1) := 'Y';
               l_converted_amount_tab(1) := 0;
               l_denominator_tab(1) := 0;
               l_numerator_tab(1) := 0;
               l_rate_tab(1) := l_InvProcRate;
               l_conversion_between:= 'FC_IPC';
               l_cache_flag:= 'Y';
               l_status_tab(1) := 'N';

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Calling conversion for IPC ';
                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

               PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
                    p_from_currency_tab             => l_from_currency_tab,
                    p_to_currency_tab               => l_to_currency_tab,
                    p_conversion_date_tab           => l_conversion_date_tab,
                    p_conversion_type_tab           => l_conversion_type_tab,
                    p_amount_tab                    => l_amount_tab,
                    p_user_validate_flag_tab        => l_user_validate_flag_tab,
                    p_converted_amount_tab          => l_converted_amount_tab,
                    p_denominator_tab               => l_denominator_tab,
                    p_numerator_tab                 => l_numerator_tab,
                    p_rate_tab                      => l_rate_tab,
                    x_status_tab                    => l_status_tab,
                    p_conversion_between            => l_conversion_between,
                    p_cache_flag                    => 'Y');

               IF (l_status_tab(1) <> 'N') THEN

                  ROLLBACK;
                  --l_msg_data := l_status_tab(1);
                  l_return_status := FND_API.G_RET_STS_ERROR;

                  /* Stamp rejection reason in PA_SPF */
                  insert_rejection_reason_spf (
                        p_project_id     => G_ProjLvlGlobRec.project_id,
                        p_agreement_id   => p_agreement_id,
                        p_task_id        => p_task_id,
                        p_reason_code    => l_status_tab(1),
                        x_return_status  => l_return_status,
                        x_msg_count      => l_msg_count,
                        x_msg_data       => l_msg_data) ;

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                  ELSE

                     l_msg_data := l_status_tab(1);
                     l_return_status := FND_API.G_RET_STS_ERROR;

                     RAISE FND_API.G_EXC_ERROR;

                  END IF;


               ELSE

                  /* In invoice proc currency only backlog amount will be revaluated . So revalued amount
                      and backlog amount will be same */

                  G_RevalCompTab(l_SobIdIdx).reval_invproc_rate_type :=  l_conversion_type_tab(1);
                  G_RevalCompTab(l_SobIdIdx).reval_invproc_rate :=  l_rate_tab(1);
                  G_RevalCompTab(l_SobIdIdx).invproc_backlog_amount :=  l_converted_amount_tab(1);
                  G_RevalCompTab(l_SobIdIdx).invproc_revalued_amount :=  l_converted_amount_tab(1);

                  IF G_DEBUG_MODE = 'Y' THEN

                     l_LogMsg := 'IPC Rate type:' || l_conversion_type_tab(1) ||
                                 ' IPC Rate :' || l_rate_tab(1);

                     PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                     l_LogMsg := 'IPC Revald backlog amt :' || l_converted_amount_tab(1) ||
                                 ' IPC backlog amt :' || l_InvprocBacklogAmount;

                     PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                  END IF;

               END IF;

            ELSE

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Reporting Processing Attributes';
                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

               l_InvProcBacklogAmount := 0;

               /* For reporting set of books, the rule is to use the conversion attributes
                  that was used to convert betweent funding and PFC in primary set of books
                  This is available upfront (calculated at the beginning of the procedure)
                  This will be null if FC = PFC. In this case the rate type from
                  gl_mc_reporting options (stored in GSobListTab will be used */

               l_ProjfuncRateType := nvl(G_RATE_TYPE,
                                                    nvl(l_ProjfuncRevalType,G_SobListTab(l_SobIdIdx).ConversionType));
               l_ProjfuncRate := nvl(l_ProjfuncRevalRate,l_ProjfuncRate);

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'PFC Rate type:' || l_ProjfuncRateType ||
                              ' PFC Rate :' || l_ProjfuncRate ;

                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;

/* mrc migration to SLA bug 4571438
               gl_mc_currency_pkg.get_rate(p_primary_set_of_books_id     => G_SET_OF_BOOKS_ID,
                                               p_reporting_set_of_books_id   => l_SobIdIdx,
                                               p_trans_date                  => G_RATE_DATE,
                                               p_trans_currency_code         => l_FundingCurrencyCode,
                                               p_trans_conversion_type       => l_ProjfuncRateType,
                                               p_trans_conversion_date       => G_RATE_DATE,
                                               p_trans_conversion_rate       => l_ProjfuncRate,
                                               p_application_id              => 275,
                                               p_org_id                      => l_OrgId,
                                               p_fa_book_type_code           => NULL,
                                               p_je_source_name              => NULL,
                                               p_je_category_name            => NULL,
                                               p_result_code                 => l_ResultCode,
                                               p_denominator_rate            => l_DenominatorRate,
                                               p_numerator_rate              => l_NumeratorRate);

               l_RcBacklogAmount  := pa_mc_currency_pkg.CurrRound(((l_RevalBacklogAmtFC/l_DenominatorRate)*
                                l_NumeratorRate), l_ProjFuncCurrencyCode);

               l_RcInvDueAmount  := pa_mc_currency_pkg.CurrRound(((l_DueAmtFC/l_DenominatorRate)*
                                l_NumeratorRate), l_ProjFuncCurrencyCode);

*/

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'After Conversion' ||
                              ' PFC Rate type:' || l_ProjfuncRateType ||
                              ' PFC Rate :' || l_ProjfuncRate ||
                              ' Numerator :' || l_NumeratorRate ||
                              ' Denominator :' || l_DenominatorRate ;
                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);


                  l_LogMsg := 'PFC RVLD due amt:' || l_RcInvDueAmount ||
                              ' PFC RVLD backlog amt:' || l_RcBacklogAmount;

                  PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               END IF;


               /* Assign the conversion result to the raval comp table */

               G_RevalCompTab(l_SobIdIdx).reval_projfunc_rate_type :=  l_ProjfuncRateType;
               G_RevalCompTab(l_SobIdIdx).reval_projfunc_rate :=  l_ProjfuncRate;
        /*     G_RevalCompTab(l_SobIdIdx).projfunc_inv_due_amount :=  l_RcInvDueAmount; Commented for bug 3221279 */
               G_RevalCompTab(l_SobIdIdx).projfunc_backlog_amount :=  l_RcBacklogAmount;

               /*For reporting set of books there is no concept of IPC Assign null*/


               G_RevalCompTab(l_SobIdIdx).reval_invproc_rate_type :=  NULL;
               G_RevalCompTab(l_SobIdIdx).reval_invproc_rate :=  NULL;
               G_RevalCompTab(l_SobIdIdx).invproc_backlog_amount :=  NULL;
               G_RevalCompTab(l_SobIdIdx).invproc_revalued_amount :=  NULL;

            END IF; /* IF l_SobIdIdx = G_SET_OF_BOOKS_ID */



           /* Commenting and changing as projfunc_realized_gains_amt already has incremental gain/loss amount */
           /* Uncommented for bug 3532963 */

              G_RevalCompTab(l_SobIdIdx).projfunc_revalued_amount :=
                                     nvl(G_RevalCompTab(l_SobIdIdx).projfunc_realized_gains_amt,0) -
                                     nvl(G_RevalCompTab(l_SobIdIdx).projfunc_realized_losses_amt,0) +
                                     nvl(G_RevalCompTab(l_SobIdIdx).realized_gains_amount,0) -
                                     nvl(G_RevalCompTab(l_SobIdIdx).realized_losses_amount,0) +
                                     nvl(G_RevalCompTab(l_SobIdIdx).projfunc_inv_applied_amount,0) +
                                     nvl(G_RevalCompTab(l_SobIdIdx).projfunc_inv_due_amount,0) +
                                     nvl(G_RevalCompTab(l_SobIdIdx).projfunc_backlog_amount,0) +
                                     l_ProjfuncBilledAmount;

/*  Commented for bug 3532963
            IF  (l_InvOvrFndFlag = 'Y') THEN  /* Bug 2636048

                /* If billed amount exceeds funding amount and include rlzd gain/loss is Y then
                   total revalued amount is incr rlzd gain/loss + difference between
                   unpaid amount after reval and unpaid amount before reval

                IF (G_ProjLvlGlobRec.include_gains_losses_flag =  'Y')  THEN

                     G_RevalCompTab(l_SobIdIdx).projfunc_revalued_amount :=
                                     nvl(G_RevalCompTab(l_SobIdIdx).projfunc_realized_gains_amt,0) -
                                     nvl(G_RevalCompTab(l_SobIdIdx).projfunc_realized_losses_amt,0) +
                                     nvl(G_RevalCompTab(l_SobIdIdx).projfunc_inv_due_amount,0) - l_PFCDueBefReval;

                    /* +  G_RevalCompTab(l_SobIdIdx).projfunc_baselined_amount ;

                ELSE

                     G_RevalCompTab(l_SobIdIdx).projfunc_revalued_amount := 0;

                END IF;

                G_RevalCompTab(l_SobIdIdx).projfunc_allocated_amount :=  nvl(G_RevalCompTab(l_SobIdIdx).projfunc_revalued_amount,0);

                G_RevalCompTab(l_SobIdIdx).invproc_allocated_amount := 0;
                G_RevalCompTab(l_SobIdIdx).invproc_revalued_amount  := 0;

                IF G_DEBUG_MODE = 'Y' THEN

                   l_LogMsg := 'Billed amt over funding amt ' ||
                             ' PFC revald amount:' || round(G_RevalCompTab(l_SobIdIdx).projfunc_revalued_amount,5) ||
                             ' IPC revald amount:' || round(G_RevalCompTab(l_SobIdIdx).invproc_revalued_amount,5);

                   PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

                END IF;

           ELSE */

                /* l_ProjfuncBilledAmount will have billed invoice amount only when include realized gains/losses is N
                   as in this case applied/due/gain/loss amounts will be 0. Billed amount should not be available in
                   adjustment/allocated amount */

              IF G_DEBUG_MODE = 'Y' THEN
                l_LogMsg := ' PFC_invapplamt :'|| G_RevalCompTab(l_SobIdIdx).projfunc_inv_applied_amount || 'PF_invoice_due_amount: ' ;
                l_LogMsg := l_LogMsg || G_RevalCompTab(l_SobIdIdx).projfunc_inv_due_amount || 'PFbacklog: ';
                l_LogMsg := l_LogMsg || G_RevalCompTab(l_SobIdIdx).projfunc_backlog_amount ||'PF billed amount: '|| l_ProjfuncBilledAmount ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);
                l_LogMsg := ' '; /* Bug 4346765 */
              END IF;

                G_RevalCompTab(l_SobIdIdx).projfunc_revalued_amount :=
                                     nvl(G_RevalCompTab(l_SobIdIdx).projfunc_realized_gains_amt,0) -
                                     nvl(G_RevalCompTab(l_SobIdIdx).projfunc_realized_losses_amt,0) +
                                     nvl(G_RevalCompTab(l_SobIdIdx).realized_gains_amount,0) -
                                     nvl(G_RevalCompTab(l_SobIdIdx).realized_losses_amount,0) +
                                     nvl(G_RevalCompTab(l_SobIdIdx).projfunc_inv_applied_amount,0) +
                                     nvl(G_RevalCompTab(l_SobIdIdx).projfunc_inv_due_amount,0) +
                                     nvl(G_RevalCompTab(l_SobIdIdx).projfunc_backlog_amount,0) +
                                     l_ProjfuncBilledAmount;

                G_RevalCompTab(l_SobIdIdx).projfunc_allocated_amount :=
                              nvl(G_RevalCompTab(l_SobIdIdx).projfunc_revalued_amount,0) -
                              nvl(G_RevalCompTab(l_SobIdIdx).projfunc_reval_amount,0) ;

                G_RevalCompTab(l_SobIdIdx).invproc_allocated_amount :=
                                    nvl(G_RevalCompTab(l_SobIdIdx).invproc_revalued_amount,0) - l_InvprocBacklogAmount;

           --END IF;
/*

            G_RevalCompTab(l_SobIdIdx).projfunc_allocated_amount :=
                              nvl(G_RevalCompTab(l_SobIdIdx).projfunc_revalued_amount,0) -
                              nvl(G_RevalCompTab(l_SobIdIdx).projfunc_reval_amount,0) ;
*/


            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'After Revaluation' ||
                          ' PFC revald amount:' || round(G_RevalCompTab(l_SobIdIdx).projfunc_revalued_amount,5) ||
                          ' PFC reval amount:' || round(G_RevalCompTab(l_SobIdIdx).projfunc_reval_amount,5) ||
                          ' PFC adj amount:' || round(G_RevalCompTab(l_SobIdIdx).projfunc_allocated_amount,5);

               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

               l_LogMsg := 'After Revaluation' ||
                          ' IPC revald amount:' || round(G_RevalCompTab(l_SobIdIdx).invproc_revalued_amount,5) ||
                          ' IPC reval amount:' || round(G_RevalCompTab(l_SobIdIdx).invproc_reval_amount,5) ||
                          ' IPC adj amount:' || round(G_RevalCompTab(l_SobIdIdx).invproc_allocated_amount,5);

               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

	  /* Change Request: When the invoiced amount in funding currency exceeds the funded amount in funding currency,
			     process should not do any revaluation
	     Fix	   : When the invoiced amount in funding currency exceeds the funded amount in funding currency,
			     insert the warning into distributions and
			     update the summary project funding with rejectionr reason as INVOICED_EXCEEDS_FUNDED
	  */

         /*   Changes Start ------------------------------------ Commented for bug 3532963

	   IF (NVL(l_InvOvrFndFlag,'N') ='Y') AND (nvl(l_RevaluationIndex,1)=1)  THEN  /* Added AND condition for bug 3532963

			ROLLBACK;

 			l_return_status := FND_API.G_RET_STS_ERROR;

                  	/* Stamp rejection reason in PA_SPF

                  	insert_rejection_reason_spf (
                     		p_project_id     => G_ProjLvlGlobRec.project_id,
                     		p_agreement_id   => p_agreement_id,
                     		p_task_id        => p_task_id,
                     		p_reason_code    => 'PA_FR_INVOICED_EXCEEDS_FUNDED',
                     		x_return_status  => l_return_status,
                     		x_msg_count      => l_msg_count,
                     		x_msg_data       => l_msg_data) ;

                  	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                     		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                  	ELSE

                     		l_msg_data := 'Invoiced amount exceeds the funded amount';
                     		l_return_status := FND_API.G_RET_STS_ERROR;

                     		RAISE FND_API.G_EXC_ERROR;

                  END IF;

	 END IF;

            Changes End  ------------------------------------ */

            l_SobIdIdx := G_RevalCompTab.NEXT(l_SobIdIdx);

         END LOOP; /* l_SobIdIdx loop */

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.compute_adjustment_amounts-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'compute_adjustment_amounts:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END compute_adjustment_amounts;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   insert_rejection_reason_spf                                            |
   |   Purpose    :   To insert rejection reason in SPF                                      |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_agreement_id        IN      Agreement_id                                          |
   |     p_task_id             IN      Task Id of summary project funding                    |
   |     p_reason_code         IN      Rejection reason code                                 |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE insert_rejection_reason_spf(
             p_project_id        IN    NUMBER,
             p_agreement_id      IN    VARCHAR2,
             p_task_id           IN    VARCHAR2,
             p_reason_code       IN    VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS


       l_return_status               VARCHAR2(30) := NULL;
       l_msg_count                   NUMBER       := NULL;
       l_msg_data                    VARCHAR2(250) := NULL;

       l_ErrMsg                      VARCHAR2(250);

   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.insert_rejection_reason_spf-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         UPDATE pa_summary_project_fundings
         SET  reval_rejection_code = p_reason_code,
              last_update_date = sysdate,
              last_updated_by =  G_LAST_UPDATED_BY,
              last_update_login =  G_LAST_UPDATE_LOGIN,
              program_application_id = G_PROGRAM_APPLICATION_ID ,
              program_id = G_PROGRAM_ID,
              program_update_date= SYSDATE,
              request_id= G_REQUEST_ID
         WHERE project_id = p_project_id
         AND   agreement_id = p_agreement_id
         AND   nvl(task_id,0) = nvl(p_task_id,0);

         Insert_distribution_warnings(
                p_project_id     => p_project_id,
                p_task_id        => p_task_id,
                p_agreement_id   => p_agreement_id,
                p_reason_code    => p_Reason_Code,
                x_return_status  => l_return_status,
                x_msg_count      => l_msg_count,
                x_msg_data       => l_msg_data) ;


         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

               RAISE FND_API.G_EXC_ERROR;

         END IF;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.insert_rejection_reason_spf-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'insert_rejection_reason_spf:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END insert_rejection_reason_spf;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   create_adjustment_line                                                 |
   |   Purpose    :   To create adjustment line for revaluated funding amounts               |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE create_adjustment_line(
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS

         l_ProjectFundingId              NUMBER;
         l_Rowid                         VARCHAR2(20);
         l_NonZeroExists                 VARCHAR2(1);
         l_SobId                         NUMBER;

         l_return_status                 VARCHAR2(30) := NULL;
         l_msg_count                     NUMBER       := NULL;
         l_msg_data                      VARCHAR2(250) := NULL;
         l_LogMsg                        VARCHAR2(250);

         CURSOR check_all_non_zero_amt(l_project_funding_id NUMBER) IS
                SELECT 'Y' non_zero_amt
                FROM DUAL
                WHERE EXISTS ( SELECT  NULL
                               FROM pa_project_fundings
                               WHERE project_funding_id = l_project_funding_id
                               AND  (  projfunc_allocated_amount <> 0
                                       OR   projfunc_realized_gains_amt <> 0
                                       OR   projfunc_realized_losses_amt <> 0
                                       OR   invproc_allocated_amount <> 0)
                              /* mrc migration to SLA bug 4571438 UNION
                               SELECT  NULL
                               FROM pa_mc_project_fundings
                               WHERE project_funding_id = l_project_funding_id
                               AND  (  allocated_amount <> 0
                                       OR   realized_gains_amt <> 0
                                       OR   realized_losses_amt <> 0) */ );

       l_SobIdIdx    NUMBER;

       l_TotalPFCAmount NUMBER;
       l_TotalIPCAmount NUMBER;

   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.create_adustment_line-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         /* Insert into table pa_project_fundings */
         l_SobId := G_SET_OF_BOOKS_ID;

         IF G_DEBUG_MODE = 'Y' THEN

            l_LogMsg := 'Set of books:' || l_SobId ||
                        ' Rate type:' ||  G_RevalCompTab(l_SobId).reval_projfunc_rate_type ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

         END IF;

          l_LogMsg := ' Bug 3532963 : G_RevalCompTab(l_SobId).agreement_id :' ||  G_RevalCompTab(l_SobId).agreement_id ||
                        ' invproc_allocated_amount :' ||  G_RevalCompTab(l_SobId).invproc_allocated_amount ||
                        ' projfunc_allocated_amount : ' ||  G_RevalCompTab(l_SobId).projfunc_allocated_amount;

            PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

         IF ((G_PRIMARY_ONLY = 'N') OR ( G_RevalCompTab(l_SobId).projfunc_allocated_amount <> 0)
                                   OR (G_RevalCompTab(l_SobId).invproc_allocated_amount <> 0)
                                   OR (G_RevalCompTab(l_SobId).projfunc_realized_gains_amt <> 0)
                                   OR (G_RevalCompTab(l_SobId).projfunc_realized_losses_amt <> 0)) THEN

            PA_PROJECT_FUNDINGS_PKG. Insert_Row (
                 X_Rowid                         => l_RowId ,
                 X_Project_Funding_Id            => l_ProjectFundingId ,
                 X_Last_Update_Date              => SYSDATE,
                 X_Last_Updated_By               => G_LAST_UPDATED_BY ,
                 X_Creation_Date                 => SYSDATE ,
                 X_Created_By                    => G_LAST_UPDATED_BY ,
                 X_Last_Update_Login             => G_LAST_UPDATE_LOGIN ,
                 X_Agreement_Id                  => G_RevalCompTab(l_SobId).agreement_id ,
                 X_Project_Id                    => G_RevalCompTab(l_SobId).project_id ,
                 X_Task_Id                       => G_RevalCompTab(l_SobId).task_id ,
                 X_Budget_Type_Code              => 'DRAFT' ,
                 X_Allocated_Amount              => 0 ,
                 X_Date_Allocated                => G_RATE_DATE,
                 X_Attribute_Category            => NULL ,
                 X_Attribute1                    => NULL ,
                 X_Attribute2                    => NULL ,
                 X_Attribute3                    => NULL ,
                 X_Attribute4                    => NULL ,
                 X_Attribute5                    => NULL ,
                 X_Attribute6                    => NULL ,
                 X_Attribute7                    => NULL ,
                 X_Attribute8                    => NULL ,
                 X_Attribute9                    => NULL ,
                 X_Attribute10                   => NULL ,
                 X_pm_funding_reference          => NULL ,
                 X_pm_product_code               => NULL ,
                 x_funding_currency_code         => G_RevalCompTab(l_SobId).funding_currency_code ,
                 x_project_currency_code         => G_RevalCompTab(l_SobId).project_currency_code ,
                 x_project_rate_type             => NULL,
                 x_project_rate_date             => NULL,
                 x_project_exchange_rate         => NULL,
                 x_project_allocated_amount      => NULL,
                 x_projfunc_currency_code        => G_RevalCompTab(l_SobId).projfunc_currency_code ,
                 x_projfunc_rate_type            => NULL,
                 x_projfunc_rate_date            => NULL,
                 x_projfunc_exchange_rate        => NULL,
                 x_projfunc_allocated_amount     => G_RevalCompTab(l_SobId).projfunc_allocated_amount ,
                 x_invproc_currency_code         => G_RevalCompTab(l_SobId).invproc_currency_code ,
                 x_invproc_rate_type             => NULL,
                 x_invproc_rate_date             => NULL,
                 x_invproc_exchange_rate         => NULL,
                 x_invproc_allocated_amount      => G_RevalCompTab(l_SobId).invproc_allocated_amount ,
                 x_revproc_currency_code         => G_RevalCompTab(l_SobId).projfunc_currency_code ,
                 x_revproc_rate_type             => G_RevalCompTab(l_SobId).reval_projfunc_rate_type ,
                 x_revproc_rate_date             => NULL,
                 x_revproc_exchange_rate         => NULL,
                 x_revproc_allocated_amount      => G_RevalCompTab(l_SobId).projfunc_allocated_amount ,
                 x_funding_category              => 'REVALUATION' ,
                 x_revaluation_through_date      => G_THRU_DATE ,
                 x_revaluation_rate_date         => G_RATE_DATE ,
                 x_reval_projfunc_rate_type      => G_RevalCompTab(l_SobId).reval_projfunc_rate_type ,
                 x_revaluation_projfunc_rate     => G_RevalCompTab(l_SobId).reval_projfunc_rate ,
                 x_reval_invproc_rate_type       => G_RevalCompTab(l_SobId).reval_invproc_rate_type ,
                 x_revaluation_invproc_rate      => G_RevalCompTab(l_SobId).reval_invproc_rate  ,
                 x_funding_inv_applied_amount    => G_RevalCompTab(l_SobId).funding_inv_applied_amount,
                 x_funding_inv_due_amount        => G_RevalCompTab(l_SobId).funding_inv_due_amount,
                 x_funding_backlog_amount        => G_RevalCompTab(l_SobId).funding_backlog_amount,
                 x_projfunc_realized_gains_amt   => G_RevalCompTab(l_SobId).projfunc_realized_gains_amt,
                 x_projfunc_realized_losses_amt  => G_RevalCompTab(l_SobId).projfunc_realized_losses_amt,
                 x_projfunc_inv_applied_amount   => G_RevalCompTab(l_SobId).projfunc_inv_applied_amount,
                 x_projfunc_inv_due_amount       => G_RevalCompTab(l_SobId).projfunc_inv_due_amount,
                 x_projfunc_backlog_amount       => G_RevalCompTab(l_SobId).projfunc_backlog_amount,
                 x_non_updateable_flag           => 'Y',
                 x_invproc_backlog_amount        => G_RevalCompTab(l_SobId).invproc_backlog_amount,
                 x_funding_reval_amount          => G_RevalCompTab(l_SobId).funding_reval_amount,
                 x_projfunc_reval_amount         => G_RevalCompTab(l_SobId).projfunc_reval_amount,
                 x_projfunc_revalued_amount      => G_RevalCompTab(l_SobId).projfunc_revalued_amount,
                 x_invproc_reval_amount          => G_RevalCompTab(l_SobId).invproc_reval_amount,
                 x_invproc_revalued_amount       => G_RevalCompTab(l_SobId).invproc_revalued_amount,
                 x_funding_revaluation_factor    => G_RevalCompTab(l_SobId).funding_revaluation_factor,
                 x_request_id                    => G_REQUEST_ID,
                 x_program_application_id        => G_PROGRAM_APPLICATION_ID,
                 x_program_id                    => G_PROGRAM_ID,
                 x_program_update_date           => SYSDATE);

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := 'After Insert Project Funding Id:' || l_ProjectFundingId;
               PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

            END IF;

            l_NonZeroExists := 'N';

            IF G_PRIMARY_ONLY = 'N' THEN

               OPEN check_all_non_zero_amt (l_ProjectFundingId);
               FETCH check_all_non_zero_amt INTO l_NonZeroExists;
               CLOSE check_all_non_zero_amt;

            ELSE

               l_NonZeroExists := 'Y';

            END IF;

            IF l_NonZeroExists = 'Y' THEN

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Non zero elements exist';
                  PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

               END IF;

               UPDATE pa_summary_project_fundings
               SET    projfunc_unbaselined_amount =
                            nvl(projfunc_unbaselined_amount,0) + G_RevalCompTab(l_SobId).projfunc_allocated_amount,
                      revproc_unbaselined_amount =
                            nvl(revproc_unbaselined_amount,0) + G_RevalCompTab(l_SobId).projfunc_allocated_amount,
                      invproc_unbaselined_amount =
                            nvl(invproc_unbaselined_amount,0) + G_RevalCompTab(l_SobId).invproc_allocated_amount,
                      projfunc_realized_gains_amt =
                            nvl(projfunc_realized_gains_amt,0) + G_RevalCompTab(l_SobId).projfunc_realized_gains_amt,
                      projfunc_realized_losses_amt =
                            nvl(projfunc_realized_losses_amt,0) + G_RevalCompTab(l_SobId).projfunc_realized_losses_amt,
                      reval_rejection_code = NULL
               WHERE project_id = G_RevalCompTab(l_SobId).project_id
               AND   agreement_id = G_RevalCompTab(l_SobId).agreement_id
               AND   nvl(task_id,0) = nvl(G_RevalCompTab(l_SobId).task_id,0);

               G_ProjLvlGlobRec.Zero_dollar_reval_flag := 'N';

               /* Generate warning message if
                          sum of pfc baselined amount and pfc adjustment amount goes below pfc accrued amount
                          sum of ipc baselined amount and ipc adjustment amount goes below ipc billed amount
               */
               check_accrued_billed_level (
                         x_return_status       => l_return_status,
                         x_msg_count           => l_msg_count,
                         x_msg_data            => l_msg_data);

               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                     RAISE FND_API.G_EXC_ERROR;

               END IF;


               IF G_ProjLvlGlobRec.include_gains_losses_flag = 'Y' THEN

                  /* Move projfunc_realized_gains_amt of G_RevalCompTab to
                          event_amount of the same as required by event trigger */

                  l_SobIdIdx := G_SobListTab.FIRST;

                  LOOP

                      EXIT WHEN l_SobIdIdx IS NULL;
                      G_RevalCompTab(l_SobIdIdx).event_amount := G_RevalCompTab(l_SobIdIdx).projfunc_realized_gains_amt;
                      l_SobIdIdx := G_SobListTab.NEXT(l_SobIdIdx);

                  END LOOP;

                  /* Gain event. Added agreement_id parameter for federal */
                  insert_event_record (
                         p_project_id            => G_RevalCompTab(l_SobId).project_id,
                         p_task_id               => G_RevalCompTab(l_SobId).task_id,
                         p_event_type            => G_ProjLvlGlobRec.gain_event_type,
                         p_event_desc            => G_ProjLvlGlobRec.gain_event_type,
                         p_Bill_trans_rev_amount => G_RevalCompTab(l_SobId).projfunc_realized_gains_amt ,
                         p_project_funding_id    => l_ProjectFundingId,
			 p_agreement_id          => G_RevalCompTab(l_SobId).agreement_id,
                         x_return_status         => l_return_status,
                         x_msg_count             => l_msg_count,
                         x_msg_data              => l_msg_data) ;


                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                     RAISE FND_API.G_EXC_ERROR;

                  END IF;

                  /* Move projfunc_realized_loss_amt of G_RevalCompTab to
                          event_amount of the same as required by event trigger */

                  l_SobIdIdx := G_SobListTab.FIRST;

                  LOOP

                      EXIT WHEN l_SobIdIdx IS NULL;
                      G_RevalCompTab(l_SobIdIdx).event_amount := G_RevalCompTab(l_SobIdIdx).projfunc_realized_losses_amt;
                      l_SobIdIdx := G_SobListTab.NEXT(l_SobIdIdx);

                  END LOOP;


                  /* Loss event. Added agreement_id parameter for federal */
                  insert_event_record (
                         p_project_id            => G_RevalCompTab(l_SobId).project_id,
                         p_task_id               => G_RevalCompTab(l_SobId).task_id,
                         p_event_type            => G_ProjLvlGlobRec.loss_event_type,
                         p_event_desc            => G_ProjLvlGlobRec.loss_event_type,
                         p_Bill_trans_rev_amount => G_RevalCompTab(l_SobId).projfunc_realized_losses_amt ,
                         p_project_funding_id    => l_ProjectFundingId,
			 p_agreement_id          => G_RevalCompTab(l_SobId).agreement_id,
                         x_return_status         => l_return_status,
                         x_msg_count             => l_msg_count,
                         x_msg_data              => l_msg_data) ;


                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                     RAISE FND_API.G_EXC_ERROR;

                  END IF;

               END IF; /* G_ProjLvlGlobRec.include_gains_losses_flag = 'Y' */

            ELSE

               IF G_DEBUG_MODE = 'Y' THEN

                  l_LogMsg := 'Non zero elements does notexist';
                  PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

               END IF;

               DELETE FROM pa_project_fundings
               WHERE  project_funding_id = l_ProjectFundingId;

            END IF; /* l_NonZeroExists = 'Y' */

         END IF; /* ((G_PRIMARY_ONLY = 'N') OR ( G_RevalCompTab(l_SobId).projfunc_allocated_amount <> 0) */

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.create_adustment_line-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'create_adjustment_line:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END create_adjustment_line;


   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   insert_event_record                                                    |
   |   Purpose    :   To insert event record for gains/losses amount                         |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id              IN      Project ID                                        |
   |     p_task_id                 IN      Task Id of summary project funding                |
   |     p_event_type              IN      Event type (gain/loss event type )                |
   |     p_event_desc              IN      Event description (gain/loss event description )  |
   |     p_bill_trans_rev_amount   IN      Amount (Realized gain/loss amount)                |
   |     p_project_funding_id      IN      Funding line Id for which this event is created   |
   |     x_return_status           OUT     Return status of this procedure                   |
   |     x_msg_count               OUT     Error message count                               |
   |     x_msg_data                OUT     Error message                                     |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE insert_event_record(
                  p_project_id             IN   NUMBER,
                  p_task_id                IN   NUMBER,
                  p_event_type             IN   VARCHAR2,
                  p_event_desc             IN   VARCHAR2,
                  p_Bill_trans_rev_amount  IN   NUMBER,
                  p_project_funding_id     IN   NUMBER,
		  p_agreement_id           IN   NUMBER,
                  x_return_status          OUT  NOCOPY VARCHAR2,
                  x_msg_count              OUT  NOCOPY NUMBER,
                  x_msg_data               OUT  NOCOPY VARCHAR2) IS

       l_RowId                       VARCHAR2(30);
       l_EventId                     NUMBER;
       l_EventNum                    NUMBER;
       l_SobId                       NUMBER;
       l_ZeroRevAmtFlag              VARCHAR2(1);

       l_return_status               VARCHAR2(30) := NULL;
       l_msg_count                   NUMBER       := NULL;
       l_msg_data                    VARCHAR2(250) := NULL;

       l_LogMsg                      VARCHAR2(250);
       l_NonZeroExists               VARCHAR2(1);

       CURSOR check_all_non_zero_amt(l_EventId NUMBER) IS
                SELECT 'Y' non_zero_amt
                FROM DUAL
                WHERE EXISTS ( SELECT  NULL
                               FROM pa_events
                               WHERE event_id = l_EventId
                               AND  bill_trans_rev_amount <> 0
                             /* mrc migration to SLA bug 4571438  UNION
                               SELECT  NULL
                               FROM pa_mc_events
                               WHERE event_id = l_EventId
                               AND  revenue_amount <> 0 */ );


   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.insert_event_record-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         l_SobId := G_SET_OF_BOOKS_ID;

         IF p_bill_trans_rev_amount = 0 THEN

            l_ZeroRevAmtFlag := 'Y';

         ELSE

            l_ZeroRevAmtFlag := 'N';

         END IF;

         /* If processing is only for primary, and if realized gain/loss amount is zero event should
            not be created. If RC is also involved, then the event should be created and checked for
            zero dollar events in all reporting set of books. If zero, the record(s) will be deleted */

         IF ((p_bill_trans_rev_amount <> 0)  OR (G_PRIMARY_ONLY = 'N')) THEN

           SELECT nvl(max(event_num),0) into l_EventNum
           FROM   pa_events
           WHERE  project_id = G_RevalCompTab(l_SobId).project_id
           AND    nvl(task_id,0) =  nvl(G_RevalCompTab(l_SobId).task_id,0);

           l_EventNum := l_EventNum + 1;

           IF G_DEBUG_MODE = 'Y' THEN

              l_LogMsg := 'Event Num:' || l_EventNum;
              PA_FUND_REVAL_UTIL.Log_Message(p_message=>l_LogMsg);

           END IF;

            pa_events_pkg.insert_row (
                       X_Rowid                      => l_RowId ,
                       X_Event_Id                   => l_EventId ,
                       X_Task_Id                    => p_task_id ,
                       X_Event_Num                  => l_EventNum ,
                       X_Last_Update_Date           => SYSDATE ,
                       X_Last_Updated_By            => G_LAST_UPDATED_BY ,
                       X_Creation_Date              => SYSDATE ,
                       X_Created_By                 => G_LAST_UPDATED_BY ,
                       X_Last_Update_Login          => G_LAST_UPDATE_LOGIN ,
                       X_Event_Type                 => p_event_type ,
                       X_Description                => p_event_desc ,
                       X_Bill_Amount                => 0 ,
                       X_Revenue_Amount             => 0 ,
                       X_Revenue_Distributed_Flag   => 'N' ,
                       X_Zero_Revenue_Amount_Flag   => l_ZeroRevAmtFlag,
                       X_Bill_Hold_Flag             => 'N' ,
                       X_Completion_Date            => G_RATE_DATE ,
                       X_Rev_Dist_Rejection_Code    => NULL ,
                       X_Attribute_Category         => NULL ,
                       X_Attribute1                 => NULL ,
                       X_Attribute2                 => NULL ,
                       X_Attribute3                 => NULL ,
                       X_Attribute4                 => NULL ,
                       X_Attribute5                 => NULL ,
                       X_Attribute6                 => NULL ,
                       X_Attribute7                 => NULL ,
                       X_Attribute8                 => NULL ,
                       X_Attribute9                 => NULL ,
                       X_Attribute10                => NULL ,
                       X_Project_Id                 => p_project_id ,
                       X_Organization_Id            => G_ProjLvlGlobRec.carrying_out_organization_id ,
                       X_Billing_Assignment_Id      => NULL ,
                       X_Event_Num_Reversed         => NULL ,
                       X_Calling_Place              => NULL ,
                       X_Calling_Process            => NULL ,
                       X_Bill_Trans_Currency_Code   => G_RevalCompTab(l_SobId).projfunc_currency_code ,
                       X_Bill_Trans_Bill_Amount     => 0 ,  -- Changed from NULL for bug2829565
                       X_Bill_Trans_rev_Amount      => p_bill_trans_rev_amount ,
                       X_Project_Currency_Code      => G_RevalCompTab(l_SobId).project_currency_code ,
                       X_Project_Rate_Type          => NULL ,
                       X_Project_Rate_Date          => NULL ,
                       X_Project_Exchange_Rate      => NULL ,
                       X_Project_Inv_Rate_Date      => NULL ,
                       X_Project_Inv_Exchange_Rate  => NULL ,
                       X_Project_Bill_Amount        => NULL ,
                       X_Project_Rev_Rate_Date      => NULL ,
                       X_Project_Rev_Exchange_Rate  => NULL ,
                       X_Project_Revenue_Amount     => NULL ,
                       X_ProjFunc_Currency_Code     => G_RevalCompTab(l_SobId).projfunc_currency_code  ,
                       X_ProjFunc_Rate_Type         => NULL ,
                       X_ProjFunc_Rate_Date         => NULL ,
                       X_ProjFunc_Exchange_Rate     => NULL ,
                       X_ProjFunc_Inv_Rate_Date     => NULL ,
                       X_ProjFunc_Inv_Exchange_Rate => NULL ,
                       X_ProjFunc_Bill_Amount       => NULL ,
                       X_ProjFunc_Rev_Rate_Date     => NULL ,
                       X_Projfunc_Rev_Exchange_Rate => NULL ,
                       X_ProjFunc_Revenue_Amount    => NULL ,
                       X_Funding_Rate_Type          => NULL ,
                       X_Funding_Rate_Date          => NULL ,
                       X_Funding_Exchange_Rate      => NULL ,
                       X_Invproc_Currency_Code      => G_RevalCompTab(l_SobId).invproc_currency_code  ,
                       X_Invproc_Rate_Type          => NULL ,
                       X_Invproc_Rate_Date          => NULL ,
                       X_Invproc_Exchange_Rate      => NULL ,
                       X_Revproc_Currency_Code      => G_RevalCompTab(l_SobId).projfunc_currency_code ,
                       X_Revproc_Rate_Type          => NULL ,
                       X_Revproc_Rate_Date          => NULL ,
                       X_Revproc_Exchange_Rate      => NULL ,
                       X_Inv_Gen_Rejection_Code     => NULL ,
                       X_Adjusting_Revenue_Flag     => NULL ,
                       X_non_updateable_flag        => 'Y' ,
                       X_revenue_hold_flag          => 'Y' ,
                       X_project_funding_id         => p_project_funding_id,
		       X_agreement_id               => p_agreement_id);

             l_NonZeroExists := 'N';

             IF G_PRIMARY_ONLY = 'N' THEN /* Check for non zero amounts in all set of books */

                 OPEN check_all_non_zero_amt (l_EventId);
                 FETCH check_all_non_zero_amt INTO l_NonZeroExists;
                 CLOSE check_all_non_zero_amt;

             ELSE

                l_NonZeroExists := 'Y';

             END IF;

             IF NVL(l_NonZeroExists, 'N') = 'N' THEN

                DELETE FROM pa_events
                WHERE  event_id = l_EventId;

             END IF;

         END IF; /* ((p_bill_trans_rev_amount <> 0)  OR (G_PRIMARY_ONLY = 'N')) */

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.insert_event_record-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'insert_event_record:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END insert_event_record;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   get_ar_amounts                                                         |
   |   Purpose    :   To get applied/fxgl amounts from AR                                    |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_customer_trx_id     IN      System Reference of Invoice Record                    |
   |     p_Invoice_Status      IN      Indicates if the input invoice status is accepted     |
   |                                   in AR or Not                                          |
   |     x_ArAmtsTab           OUT     Appled/FXGL amounts for the given invoice record      |
   |                                   in all set of books id                                |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE get_ar_amounts(
                 p_customer_trx_id   IN NUMBER,
                 p_invoice_status    IN VARCHAR2,
                 x_ArAmtsTab         OUT NOCOPY ArAmtsTabTyp,
                 x_return_status     OUT NOCOPY VARCHAR2,
                 x_msg_count         OUT NOCOPY NUMBER,
                 x_msg_data          OUT NOCOPY VARCHAR2)   IS


       l_return_status               VARCHAR2(30) := NULL;
       l_msg_count                   NUMBER       := NULL;
       l_msg_data                    VARCHAR2(250) := NULL;

       l_LogMsg                      VARCHAR2(250);
       l_ArAmtsTab                   ArAmtsTabTyp;

       l_ApplicationId               NUMBER := 275;
       l_ProcessRsob                 VARCHAR2(1);
       l_AppliedAmtList              ARP_PA_UTILS.r_appl_amt_list;
       l_SobIdIdx                    NUMBER;

   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.get_ar_amounts-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         x_ArAmtsTab := l_ArAmtsTab;

         IF ((G_ProjLvlGlobRec.include_gains_losses_flag =  'Y') AND
             (p_invoice_status = 'A') AND (G_AR_INSTALLED_FLAG = 'Y')) THEN


            IF G_AR_PRIMARY_ONLY = 'Y' THEN /* Do not process for reporting set of books */

                  l_ProcessRsob := 'N';

            ELSE

                  l_ProcessRsob := 'Y'; /* Process for reporting set of books */
            END IF;


            ARP_PA_UTILS. get_line_applied(
                      p_application_id    => l_ApplicationId,
                      p_customer_trx_id   => p_customer_trx_id,
                      p_as_of_date        => G_THRU_DATE,
                      p_process_rsob      => l_ProcessRsob,
                      x_applied_amt_list  => l_AppliedAmtList,
                      x_return_status     => l_return_status,
                      x_msg_count         => l_msg_count,
                      x_msg_data          => l_msg_data);


            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

               RAISE FND_API.G_EXC_ERROR;

            END IF;

            /* AR uses acctd amount for projfunc amount and amount for transaction amount
               Moving the data to suit PA terminology as it is widely used in the code */

            IF l_AppliedAmtList.COUNT <> 0 THEN

/*
               l_SobIdIdx := l_AppliedAmtList.FIRST;
*/

               l_SobIdIdx := G_SobListTab.FIRST;

               LOOP

                   EXIT WHEN l_SobIdIdx IS NULL;

                   IF (l_AppliedAmtList.EXISTS(l_SobIdIdx)) THEN

                      l_ArAmtsTab(l_SobIdIdx).set_of_books_id := l_AppliedAmtList(l_SobIdIdx).sob_id ;
                      l_ArAmtsTab(l_SobIdIdx).inv_applied_amount := l_AppliedAmtList(l_SobIdIdx).amount_applied ;
                      l_ArAmtsTab(l_SobIdIdx).projfunc_applied_amount := l_AppliedAmtList(l_SobIdIdx).acctd_amount_applied ;
                      l_ArAmtsTab(l_SobIdIdx).projfunc_gain_amount := l_AppliedAmtList(l_SobIdIdx).exchange_gain;
                      l_ArAmtsTab(l_SobIdIdx).projfunc_loss_amount := l_AppliedAmtList(l_SobIdIdx).exchange_loss;
       l_ArAmtsTab(l_SobIdIdx).inv_adjusted_amount := nvl(l_AppliedAmtList(l_SobIdIdx).line_adjusted,0);  /* Added for bug 7237486 */
		      l_ArAmtsTab(l_SobIdIdx).projfunc_adjusted_amount := nvl(l_AppliedAmtList(l_SobIdIdx).acctd_line_adjusted,0);  /* Added for bug 7237486 */
                      IF G_DEBUG_MODE = 'Y' THEN

                         l_LogMsg := 'Sob:' || l_SobIdIdx ||
                                     ' ITC Appl amt:' || l_ArAmtsTab(l_SobIdIdx).inv_applied_amount ||
                                     ' PFC Appl amt:' || l_ArAmtsTab(l_SobIdIdx).projfunc_applied_amount ||
                                     ' PFC gain amt:' || l_ArAmtsTab(l_SobIdIdx).projfunc_gain_amount ||
                                                  ' PFC loss amt:' || l_ArAmtsTab(l_SobIdIdx).projfunc_loss_amount ||
				     ' AR Adj amt in IC :' || l_ArAmtsTab(l_SobIdIdx).inv_adjusted_amount ||
				     ' AR Adj amt in PFCC :' || l_ArAmtsTab(l_SobIdIdx).projfunc_adjusted_amount;  /* Added for bug 7237486*/
                         PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

                      END IF;

                   ELSE

                      l_ArAmtsTab(l_SobIdIdx).set_of_books_id := l_SobIdIdx ;
                      l_ArAmtsTab(l_SobIdIdx).inv_applied_amount := 0;
                      l_ArAmtsTab(l_SobIdIdx).projfunc_applied_amount := 0 ;
                      l_ArAmtsTab(l_SobIdIdx).projfunc_gain_amount := 0;
                      l_ArAmtsTab(l_SobIdIdx).projfunc_loss_amount := 0 ;
     l_ArAmtsTab(l_SobIdIdx).inv_adjusted_amount := 0; /* Added for bug 7237486 */
		      l_ArAmtsTab(l_SobIdIdx).projfunc_adjusted_amount := 0; /* Added for bug 7237486 */

                   END IF;

                   l_SobIdIdx := G_SobListTab.NEXT(l_SobIdIdx);
/*
                   l_SobIdIdx := l_AppliedAmtList.NEXT(l_SobIdIdx);
*/

               END LOOP;

            END IF; /* l_AppliedAmtList.COUNT <> 0 */

         END IF;
         x_ArAmtsTab := l_ArAmtsTab;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.get_ar_amounts-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'get_ar_amounts:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END get_ar_amounts;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   Clear_distribution_warnings                                            |
   |   Purpose    :   To delete any rejection reason that is logged by revaluation process   |
   |                  for the request id                                                     |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_request_id          IN      Request ID                                            |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE clear_distribution_warnings(
             p_request_id        IN    NUMBER,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS


       l_return_status               VARCHAR2(30) := NULL;
       l_msg_count                   NUMBER       := NULL;
       l_msg_data                    VARCHAR2(250) := NULL;

       l_LogMsg                    VARCHAR2(250);

   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.clear_distribution_warnings-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         DELETE from pa_distribution_warnings
         WHERE request_id = p_request_id;

         COMMIT;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.clear_distribution_warnings-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'clear_distribution_warnings:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END clear_distribution_warnings;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   check_accrued_billed_level                                             |
   |   Purpose    :   Generate warning message if sum of                                     |
   |                  pfc baselined amount and pfc adjustment amount goes below              |
   |                           pfc accrued amount                                            |
   |                  ipc baselined amount and ipc adjustment amount goes below              |
   |                           ipc billed amount                                             |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

   PROCEDURE check_accrued_billed_level(
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS

         l_SobId                         NUMBER;
         l_TotalPFCAmount                NUMBER;
         l_TotalIPCAmount                NUMBER;

         l_ReasonCode                    VARCHAR2(30);


         l_return_status                 VARCHAR2(30) := NULL;
         l_msg_count                     NUMBER       := NULL;
         l_msg_data                      VARCHAR2(250) := NULL;
         l_LogMsg                        VARCHAR2(250);



   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.check_accrued_billed_level-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

         l_SobId := G_SET_OF_BOOKS_ID;

         l_TotalPFCAmount := G_RevalCompTab(l_SobId).projfunc_baselined_amount + G_RevalCompTab(l_SobId).projfunc_allocated_amount;
         l_TotalIPCAmount := G_RevalCompTab(l_SobId).invproc_baselined_amount + G_RevalCompTab(l_SobId).invproc_allocated_amount;

         IF l_TotalPFCAmount < nvl(G_RevalCompTab(l_SobId).projfunc_accrued_amount,0) THEN

            l_ReasonCode := 'PA_FR_ACCRUED_LT_BASELINED_AMT';

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := l_ReasonCode;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            Insert_distribution_warnings(
                        p_project_id     => G_RevalCompTab(l_SobId).project_id,
                        p_agreement_id   => G_RevalCompTab(l_SobId).agreement_id,
                        p_task_id        => G_RevalCompTab(l_SobId).task_id,
                        p_reason_code    => l_ReasonCode,
                        x_return_status  => l_return_status,
                        x_msg_count      => l_msg_count,
                        x_msg_data       => l_msg_data) ;


            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

               RAISE FND_API.G_EXC_ERROR;

            END IF;


         END IF;

         IF l_TotalIPCAmount < nvl(G_RevalCompTab(l_SobId).invproc_billed_amount,0) THEN

            l_ReasonCode := 'PA_FR_BILLED_LT_BASELINED_AMT';

            IF G_DEBUG_MODE = 'Y' THEN

               l_LogMsg := l_ReasonCode;
               PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

            END IF;

            Insert_distribution_warnings(
                        p_project_id     => G_RevalCompTab(l_SobId).project_id,
                        p_agreement_id   => G_RevalCompTab(l_SobId).agreement_id,
                        p_task_id        => G_RevalCompTab(l_SobId).task_id,
                        p_reason_code    => l_ReasonCode,
                        x_return_status  => l_return_status,
                        x_msg_count      => l_msg_count,
                        x_msg_data       => l_msg_data) ;


            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

               RAISE FND_API.G_EXC_ERROR;

            END IF;

         END IF;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.check_accrued_billed_level-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'check_accrued_billed_level:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END check_accrued_billed_level;

   /*----------------------------------------------------------------------------------------+
   |   Procedure  :   Get_Delete_Projects                                                    |
   |   Purpose    :   To open all projects eligible for funding revaluation and has          |
   |                  unbaselined adjustment lines                                           |
   |                  given project numbers                                                  |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_project_type_id     IN      Project Type ID                                       |
   |     p_from_proj_number    IN      Start project number                                  |
   |     p_to_proj_number      IN      End project number                                    |
   |     p_run_mode            IN      Run mode                                              |
   |                                   Values are 'SINGLE', 'RANGE'                          |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
   PROCEDURE get_delete_projects(
             p_project_type_id   IN    NUMBER,
             p_from_proj_number  IN    VARCHAR2,
             p_to_proj_number    IN    VARCHAR2,
             p_run_mode          IN    VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS


       /* This CURSOR selects all projects with the following criteria
              a) should be contract  projects
              b) revaluate_funding_flag is enabled
              c) has unbaselined adjustments */

         CURSOR open_projects IS
                SELECT P.segment1, P.project_id, P.baseline_funding_flag,
                       P.include_gains_losses_flag include_gains_losses_flag
                FROM pa_projects P, pa_project_types T
                WHERE P.segment1 BETWEEN p_from_proj_number
                               AND p_to_proj_number
                AND   P.PROJECT_TYPE = T.PROJECT_TYPE
                AND   T.DIRECT_FLAG = 'Y'
                AND   T.PROJECT_TYPE_ID  = NVL(P_PROJECT_TYPE_ID ,T.project_type_id)
                AND   NVL(P.revaluate_funding_flag, 'N') = 'Y'
                AND   NVL(P.template_flag, 'N') = 'N'
                AND   exists ( SELECT NULL
                               FROM pa_project_fundings
                               WHERE project_id = P.project_id
                               AND funding_category = 'REVALUATION'
                               AND budget_type_code = 'DRAFT')
                ORDER BY segment1 ;

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;
         l_ErrCode                  NUMBER       := NULL;
         l_LogMsg                   VARCHAR2(250);

   BEGIN
         x_return_status    := FND_API.G_RET_STS_SUCCESS;
         x_msg_count        := 0;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Entering PA_FUND_REVAL_PVT.get_delete_projects-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

            l_LogMsg := 'From prj:' || p_from_proj_number ||
                         ' To prj:' || p_to_proj_number ||
                         ' Proj type:' || p_project_type_id ;
            PA_FUND_REVAL_UTIL.Log_Message(l_LogMsg);

         END IF;


         FOR proj_rec in open_projects LOOP

             IF G_DEBUG_MODE = 'Y' THEN

                l_LogMsg := 'Project ID :' || proj_rec.project_id ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => l_LogMsg);

             END IF;


             Delete_unbaselined_adjmts(
                    p_project_id     => proj_rec.project_id,
                    p_run_mode       => p_run_mode,
                    x_return_status  => l_return_status,
                    x_msg_count      => l_msg_count,
                    x_msg_data       => l_msg_data) ;

             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                RAISE FND_API.G_EXC_ERROR;

             END IF;

             COMMIT; /* Commit delete for the current project */

         END LOOP;

         IF G_DEBUG_MODE = 'Y' THEN

            PA_DEBUG.g_err_stage := '-----------Exiting PA_FUND_REVAL_PVT.get_delete_projects-----------' ;
            PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

         END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data := SUBSTR(SQLERRM,1,100);

             IF G_DEBUG_MODE = 'Y' THEN

                PA_DEBUG.g_err_stage := 'get_reval_projects:' || x_msg_data ;
                PA_FUND_REVAL_UTIL.Log_Message(p_message => PA_DEBUG.g_err_stage);

             END IF;

   END get_delete_projects;

END PA_FUND_REVAL_PVT;

/
