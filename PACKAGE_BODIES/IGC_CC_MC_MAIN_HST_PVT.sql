--------------------------------------------------------
--  DDL for Package Body IGC_CC_MC_MAIN_HST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_MC_MAIN_HST_PVT" as
/* $Header: IGCCMMHB.pls 120.3.12000000.4 2007/10/19 06:19:35 smannava ship $  */

 G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_MC_MAIN_HST_PVT';
 g_debug_flag        VARCHAR2(1) := 'N' ;

/* ================================================================================
                         PROCEDURE Insert_Row => IGC_CC_MC_HEADER_HISTORY
   ===============================================================================*/

PROCEDURE get_rsobs_Headers(
   p_api_version               IN       NUMBER,
   p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN       NUMBER := FND_API.G_VALID_LEVEL_FULL,
   X_return_status             OUT NOCOPY      VARCHAR2,
   x_msg_count                 OUT NOCOPY      NUMBER,
   x_msg_data                  OUT NOCOPY      VARCHAR2,
   p_CC_Header_Id              IN       NUMBER,
   p_Set_Of_Books_Id           IN       NUMBER,
   l_Application_Id            IN       NUMBER,
   p_org_id                    IN       NUMBER,
   l_Conversion_Date           IN       DATE,
   p_CC_Version_num            IN       NUMBER,
   p_CC_Version_Action         IN       VARCHAR2
) IS

   l_sob_list            gl_mc_info.r_sob_list := gl_mc_info.r_sob_list();
   l_row_count           NUMBER;
   l_FROM_CURR           varchar2(10);
   l_TO_CURR             varchar2(10);
   l_Conversion_Rate     Number;
   l_Conversion_Type     VARCHAR2(30);
   l_rsob_id             GL_ALC_LEDGER_RSHIPS_V.LEDGER_ID%TYPE;
   l_rate_exists         VARCHAR2(1);
   l_api_version         NUMBER := 1.0;
   l_api_name            VARCHAR2(30) := 'GET_RSOBS_HEADERS';
   l_return_status       VARCHAR2(1);
   l_row_id              VARCHAR2(18);

   /* Commented below query and added one below during r12 MRC uptake for bug#6341012*/
  /* CURSOR c_conversion_type IS
     SELECT conversion_type
       FROM gl_mc_reporting_options
      WHERE primary_set_of_books_id   = p_Set_Of_Books_Id
        AND reporting_set_of_books_id = l_rsob_id
        AND ORG_ID                    = p_Org_Id
        AND application_id            = l_Application_Id; */
 CURSOR c_conversion_type IS
     SELECT ALC_DEFAULT_CONV_RATE_TYPE
       FROM GL_ALC_LEDGER_RSHIPS_V
      WHERE primary_ledger_id   = p_Set_Of_Books_Id
        AND ledger_id = l_rsob_id
       -- AND ORG_ID                    = p_Org_Id
        AND application_id            = l_Application_Id;
BEGIN

   SAVEPOINT get_rsobs_Headers_PT;

   IF NOT FND_API.COMPATIBLE_API_CALL ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   X_return_status := FND_API.G_RET_STS_SUCCESS;

-- -------------------------------------------------------------------------
-- Obtain all sets of books associated to the Primary set of books ID
-- received from the caller.
-- -------------------------------------------------------------------------
   gl_mc_info.get_associated_sobs ( p_Set_Of_Books_Id,
                                    l_Application_Id,
                                    p_org_id,
                                    NULL,
                                    l_sob_list);

   l_row_count := l_sob_list.count;

-- -------------------------------------------------------------------------
-- Loop through all sets of books retrived and determine what the Primary
-- set of books currency has been defined to be.
-- -------------------------------------------------------------------------
   FOR Rec in 1..l_row_count LOOP

      IF l_sob_list(Rec).r_sob_type = 'P' then
         l_FROM_CURR :=  l_sob_list(Rec).r_sob_curr;
      END IF;

   END LOOP;

-- -------------------------------------------------------------------------
-- Loop through all the set of books retrieved if there were any defined.
-- -------------------------------------------------------------------------
   FOR Rec1 in 1..l_row_count LOOP

-- -------------------------------------------------------------------------
-- Check to make sure that the Reporting set of books is being checked and
-- not the Primary set of books.
-- -------------------------------------------------------------------------
      IF (l_sob_list(rec1).r_sob_type = 'R') THEN

         l_rsob_id := l_sob_list(rec1).r_sob_id;
         l_TO_CURR := l_sob_list(rec1).r_sob_curr;

-- -------------------------------------------------------------------------
-- Obtain the conversion type for the reporting set of books.
-- -------------------------------------------------------------------------
         OPEN c_conversion_type;
         FETCH c_conversion_type
          INTO l_Conversion_Type;
         CLOSE c_conversion_type;

-- -------------------------------------------------------------------------
-- Check to see if the conversion rate exists or not.
-- -------------------------------------------------------------------------
         l_rate_exists := gl_currency_api.rate_exists ( l_FROM_CURR,
                                                        l_TO_CURR,
                                                        l_Conversion_Date,
                                                        l_Conversion_Type
                                                      );

-- ------------------------------------------------------------------------
-- If the rate exists then obtain the rate to be inserted for the
-- reporting set of books.
-- ------------------------------------------------------------------------
         IF (l_rate_exists = 'Y') THEN
            l_Conversion_Rate := GL_CURRENCY_API.GET_RATE (l_FROM_CURR,
                                                           l_TO_CURR,
                                                           l_Conversion_Date,
                                                           l_Conversion_Type
                                                          );

-- -----------------------------------------------------------------------
-- insert the MRC History record for the appropriate MRC record
-- for the reporting set of books.
-- -----------------------------------------------------------------------
            IGC_CC_MC_HEADER_HST_PKG.Insert_Row (
                             l_api_version,
                             FND_API.G_FALSE,
                             FND_API.G_FALSE,
                             FND_API.G_VALID_LEVEL_FULL,
                             l_return_status,
                             X_msg_count,
                             X_msg_data,
                             l_row_id,
                             p_CC_Header_Id,
                             l_sob_list(rec1).r_sob_id,
                             p_CC_Version_num,
                             p_CC_Version_Action,
                             l_Conversion_Type,
                             l_Conversion_Date,
                             l_conversion_Rate
                            );

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

         END IF;  -- Rate exists

      END IF;  -- Reporting set of books

   END LOOP;  -- Loop for associated sets of books

-- ------------------------------------------------------------------------
-- Only commit the information if the caller has requested it to be.
-- ------------------------------------------------------------------------
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- ------------------------------------------------------------------------
-- Make sure that the cursor used is closed upon exit
-- ------------------------------------------------------------------------
   IF (c_conversion_type%ISOPEN) THEN
      CLOSE c_conversion_type;
   END IF;

   FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                              p_data  => X_msg_data);

   RETURN;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

       ROLLBACK TO get_rsobs_Headers_PT;
       X_return_status := FND_API.G_RET_STS_ERROR;
       IF (c_conversion_type%ISOPEN) THEN
          CLOSE c_conversion_type;
       END IF;
       FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                  p_data  => X_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       ROLLBACK TO get_rsobs_Headers_PT;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (c_conversion_type%ISOPEN) THEN
          CLOSE c_conversion_type;
       END IF;
       FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                  p_data  => X_msg_data);

    WHEN OTHERS THEN

       ROLLBACK TO get_rsobs_Headers_PT;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (c_conversion_type%ISOPEN) THEN
          CLOSE c_conversion_type;
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                   l_api_name);
       END if;

       FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                  p_data  => X_msg_data);

END get_rsobs_Headers;


/* ================================================================================
                         PROCEDURE Insert_Row => IGC_CC_MC_ACCT_LINE_HISTORY
   ===============================================================================*/

PROCEDURE get_rsobs_Acct_Lines(
   p_api_version               IN       NUMBER,
   p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN       NUMBER := FND_API.G_VALID_LEVEL_FULL,
   X_return_status             OUT NOCOPY      VARCHAR2,
   x_msg_count                 OUT NOCOPY      NUMBER,
   x_msg_data                  OUT NOCOPY      VARCHAR2,
   p_CC_Acct_Line_Id           IN       NUMBER,
   p_Set_Of_Books_Id           IN       NUMBER,
   l_Application_Id            IN       NUMBER,
   p_org_id                    IN       NUMBER,
   l_Conversion_Date           IN       DATE,
   p_CC_Acct_Func_Amt          IN       NUMBER,
   p_CC_Acct_Encmbrnc_Amt      IN       NUMBER,
   p_CC_Acct_Version_Num       IN       NUMBER,
   p_CC_Acct_Version_Action    IN       VARCHAR2,
   p_cc_func_withheld_amt      IN       NUMBER
) IS

   l_sob_list             gl_mc_info.r_sob_list := gl_mc_info.r_sob_list();
   l_row_count            NUMBER;
   l_FROM_CURR            varchar2(10);
   l_TO_CURR              varchar2(10);
   l_Conversion_Rate      Number;
   l_Conversion_Type      VARCHAR2(30);
   l_CC_Acct_Func_Amt     NUMBER;
   l_CC_Acct_Encmbrnc_Amt NUMBER;
   l_CC_Func_Withheld_Amt NUMBER;
   l_rsob_id             GL_ALC_LEDGER_RSHIPS_V.LEDGER_ID%TYPE;
   l_rate_exists          VARCHAR2(1);
   l_api_version          CONSTANT NUMBER   :=  1.0;
   l_api_name             VARCHAR2(30)      := 'GET_RSOBS_ACCT_LINES';
   l_return_status        VARCHAR2(1);
   l_row_id               VARCHAR2(18);

/* Commented below query and added one below during r12 MRC uptake for bug#6341012*/

     /* CURSOR c_conversion_type IS
     SELECT conversion_type
       FROM gl_mc_reporting_options
      WHERE primary_set_of_books_id   = p_Set_Of_Books_Id
        AND reporting_set_of_books_id = l_rsob_id
        AND ORG_ID                    = p_Org_Id
        AND application_id            = l_Application_Id; */
 CURSOR c_conversion_type IS
     SELECT ALC_DEFAULT_CONV_RATE_TYPE
       FROM GL_ALC_LEDGER_RSHIPS_V
      WHERE primary_ledger_id   = p_Set_Of_Books_Id
        AND ledger_id = l_rsob_id
        --AND ORG_ID                    = p_Org_Id
        AND application_id            = l_Application_Id;
BEGIN

   SAVEPOINT get_rsobs_Acct_Lines_PT;

   IF NOT FND_API.COMPATIBLE_API_CALL ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   X_return_status := FND_API.G_RET_STS_SUCCESS;

-- -------------------------------------------------------------------------
-- Obtain all sets of books associated to the Primary set of books ID
-- received from the caller.
-- -------------------------------------------------------------------------
   gl_mc_info.get_associated_sobs ( p_Set_Of_Books_Id,
                                    l_Application_Id,
                                    p_org_id,
                                    NULL,
                                    l_sob_list);

   l_row_count := l_sob_list.count;

-- -------------------------------------------------------------------------
-- Loop through all sets of books retrived and determine what the Primary
-- set of books currency has been defined to be.
-- -------------------------------------------------------------------------
   FOR Rec in 1..l_row_count LOOP

      IF (l_sob_list(Rec).r_sob_type = 'P') THEN
         l_FROM_CURR :=  l_sob_list(Rec).r_sob_curr;
      END IF;

   END LOOP;

-- -------------------------------------------------------------------------
-- Loop through all the set of books retrieved if there were any defined.
-- -------------------------------------------------------------------------
   FOR Rec1 in 1..l_row_count LOOP

-- -------------------------------------------------------------------------
-- Check to make sure that the Reporting set of books is being checked and
-- not the Primary set of books.
-- -------------------------------------------------------------------------
      IF (l_sob_list(rec1).r_sob_type = 'R') THEN

         l_rsob_id := l_sob_list(rec1).r_sob_id;
         l_TO_CURR := l_sob_list(rec1).r_sob_curr;

-- -------------------------------------------------------------------------
-- Obtain the conversion type for the reporting set of books.
-- -------------------------------------------------------------------------
         OPEN c_conversion_type;
         FETCH c_conversion_type
          INTO l_Conversion_Type;
         CLOSE c_conversion_type;

-- -------------------------------------------------------------------------
-- Check to see if the conversion rate exists or not.
-- -------------------------------------------------------------------------
         l_rate_exists := gl_currency_api.rate_exists ( l_FROM_CURR,
                                                        l_TO_CURR,
                                                        l_Conversion_Date,
                                                        l_Conversion_Type
                                                      );

-- ------------------------------------------------------------------------
-- If the rate exists then obtain the rate to be inserted for the
-- reporting set of books.
-- ------------------------------------------------------------------------
         IF (l_rate_exists = 'Y') THEN

            l_Conversion_Rate :=  GL_CURRENCY_API.GET_RATE (l_FROM_CURR,
                                                            l_TO_CURR,
                                                            l_Conversion_Date,
                                                            l_Conversion_Type
                                                           );


            l_CC_Acct_Func_Amt  :=  GL_CURRENCY_API.CONVERT_AMOUNT (l_FROM_CURR,
                                                                    l_TO_CURR,
                                                                    l_CONVERSION_DATE,
                                                                    l_CONVERSION_TYPE,
                                                                    p_CC_Acct_Func_Amt
                                                                   );

            l_CC_Acct_Encmbrnc_Amt := GL_CURRENCY_API.CONVERT_AMOUNT (l_FROM_CURR,
                                                                      l_TO_CURR,
                                                                      l_CONVERSION_DATE,
                                                                      l_CONVERSION_TYPE,
                                                                      p_CC_Acct_Encmbrnc_Amt
                                                                     );

            l_CC_Func_Withheld_Amt := GL_CURRENCY_API.CONVERT_AMOUNT (l_FROM_CURR,
                                                                      l_TO_CURR,
                                                                      l_CONVERSION_DATE,
                                                                      l_CONVERSION_TYPE,
                                                                      p_CC_Func_Withheld_Amt
                                                                     );

-- -----------------------------------------------------------------------
-- Insert the appropriate MRC history record for the reporting set of
-- books being processed.
-- -----------------------------------------------------------------------
            IGC_CC_MC_ACCT_LINE_HST_PKG.Insert_Row (
                             l_api_version,
                             FND_API.G_FALSE,
                             FND_API.G_FALSE,
                             FND_API.G_VALID_LEVEL_FULL,
                             l_return_status,
                             X_msg_count,
                             X_msg_data,
                             l_row_id,
                             p_CC_Acct_Line_Id,
                             l_sob_list(rec1).r_sob_id,
                             l_CC_Acct_Func_Amt,
                             l_CC_Acct_Encmbrnc_Amt,
                             p_CC_Acct_Version_Num,
                             p_CC_Acct_Version_Action,
                             l_Conversion_Type,
                             l_Conversion_Date,
                             l_conversion_Rate,
                             l_cc_func_withheld_amt
                            );

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

         END IF;  -- Rate exists

      END IF;  -- Reporting set of books

   END LOOP;  -- Loop for all associated sets of books.

-- ------------------------------------------------------------------------
-- Only commit the information if the caller has requested it to be.
-- ------------------------------------------------------------------------
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- ------------------------------------------------------------------------
-- Make sure that the cursor used is closed upon exit
-- ------------------------------------------------------------------------
   IF (c_conversion_type%ISOPEN) THEN
      CLOSE c_conversion_type;
   END IF;

   FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                              p_data  => X_msg_data);

   RETURN;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

       ROLLBACK TO get_rsobs_Acct_Lines_PT;
       X_return_status := FND_API.G_RET_STS_ERROR;
       IF (c_conversion_type%ISOPEN) THEN
          CLOSE c_conversion_type;
       END IF;
       FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                  p_data  => X_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       ROLLBACK TO get_rsobs_Acct_Lines_PT;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (c_conversion_type%ISOPEN) THEN
          CLOSE c_conversion_type;
       END IF;
       FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                  p_data  => X_msg_data);

    WHEN OTHERS THEN

       ROLLBACK TO get_rsobs_Acct_Lines_PT;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (c_conversion_type%ISOPEN) THEN
          CLOSE c_conversion_type;
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                   l_api_name);
       END if;

       FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                  p_data  => X_msg_data);

END get_rsobs_Acct_Lines;


/* ================================================================================
                         PROCEDURE Insert_Row => IGC_CC_MC_DET_PF_HISTORY
   ===============================================================================*/

PROCEDURE get_rsobs_DET_PF (
   p_api_version               IN       NUMBER,
   p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN       NUMBER := FND_API.G_VALID_LEVEL_FULL,
   X_return_status             OUT NOCOPY      VARCHAR2,
   x_msg_count                 OUT NOCOPY      NUMBER,
   x_msg_data                  OUT NOCOPY      VARCHAR2,
   p_CC_DET_PF_Line_Id         IN       NUMBER,
   p_Set_Of_Books_Id           IN       NUMBER,
   l_Application_Id            IN       NUMBER,
   p_org_id                    IN       NUMBER,
   l_Conversion_Date           IN       DATE,
   p_CC_Det_Pf_Func_Amt        IN       NUMBER,
   p_CC_Det_Pf_ENCMBRNC_AMT    IN       NUMBER,
   p_Det_PF_Version_Num        IN       NUMBER,
   p_Det_PF_Version_Action     IN       VARCHAR2
) IS

   l_sob_list                   gl_mc_info.r_sob_list := gl_mc_info.r_sob_list();
   l_row_count                  NUMBER;
   l_FROM_CURR                  varchar2(10);
   l_TO_CURR                    varchar2(10);
   l_Conversion_Rate            Number;
   l_Conversion_Type            VARCHAR2(30);
   l_CC_DET_PF_Func_Amt         NUMBER;
   l_CC_DET_PF_ENCMBRNC_AMT     NUMBER;
   l_rsob_id                   GL_ALC_LEDGER_RSHIPS_V.LEDGER_ID%TYPE;
   l_rate_exists                VARCHAR2(1);
   l_api_name                   VARCHAR2(30) := 'GET_RSOBS_DET_PF';
   l_api_version                CONSTANT NUMBER         :=  1.0;
   l_return_status              VARCHAR2(1);
   l_row_id                     VARCHAR2(18);
/* Commented below query and added one below during r12 MRC uptake for bug#6341012*/
     /* CURSOR c_conversion_type IS
     SELECT conversion_type
       FROM gl_mc_reporting_options
      WHERE primary_set_of_books_id   = p_Set_Of_Books_Id
        AND reporting_set_of_books_id = l_rsob_id
        AND ORG_ID                    = p_Org_Id
        AND application_id            = l_Application_Id; */
 CURSOR c_conversion_type IS
     SELECT ALC_DEFAULT_CONV_RATE_TYPE
       FROM GL_ALC_LEDGER_RSHIPS_V
      WHERE primary_ledger_id   = p_Set_Of_Books_Id
        AND ledger_id = l_rsob_id
       -- AND ORG_ID                    = p_Org_Id
        AND application_id            = l_Application_Id;
BEGIN

   SAVEPOINT get_rsobs_DET_PF_PT;

   IF NOT FND_API.COMPATIBLE_API_CALL ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   X_return_status := FND_API.G_RET_STS_SUCCESS;

-- -------------------------------------------------------------------------
-- Obtain all sets of books associated to the Primary set of books ID
-- received from the caller.
-- -------------------------------------------------------------------------
   gl_mc_info.get_associated_sobs ( p_Set_Of_Books_Id,
                                    l_Application_Id,
                                    p_org_id,
                                    NULL,
                                    l_sob_list);

   l_row_count := l_sob_list.count;

-- -------------------------------------------------------------------------
-- Loop through all sets of books retrived and determine what the Primary
-- set of books currency has been defined to be.
-- -------------------------------------------------------------------------
   FOR Rec in 1..l_row_count LOOP

      IF (l_sob_list(Rec).r_sob_type = 'P') THEN
         l_FROM_CURR :=  l_sob_list(Rec).r_sob_curr;
      END IF;

   END LOOP;

-- -------------------------------------------------------------------------
-- Loop through all the set of books retrieved if there were any defined.
-- -------------------------------------------------------------------------
   FOR Rec1 in 1..l_row_count LOOP

      IF (l_sob_list(rec1).r_sob_type = 'R') THEN
         l_rsob_id := l_sob_list(rec1).r_sob_id;
         l_TO_CURR := l_sob_list(rec1).r_sob_curr;

-- -------------------------------------------------------------------------
-- Obtain the conversion type for the reporting set of books.
-- -------------------------------------------------------------------------
         OPEN c_conversion_type;
         FETCH c_conversion_type
          INTO l_Conversion_Type;
         CLOSE c_conversion_type;

-- -------------------------------------------------------------------------
-- Check to see if the conversion rate exists or not.
-- -------------------------------------------------------------------------
         l_rate_exists := gl_currency_api.rate_exists (l_FROM_CURR,
                                                       l_TO_CURR,
                                                       l_Conversion_Date,
                                                       l_Conversion_Type
                                                      );

-- ------------------------------------------------------------------------
-- If the rate exists then obtain the rate to be inserted for the
-- reporting set of books.
-- ------------------------------------------------------------------------
         IF (l_rate_exists = 'Y') THEN

            l_Conversion_Rate := GL_CURRENCY_API.GET_RATE (l_FROM_CURR,
                                                           l_TO_CURR,
                                                           l_Conversion_Date,
                                                           l_Conversion_Type
                                                          );

            l_CC_DET_PF_Func_Amt := GL_CURRENCY_API.CONVERT_AMOUNT (l_FROM_CURR,
                                                                    l_TO_CURR,
                                                                    l_CONVERSION_DATE,
                                                                    l_CONVERSION_TYPE,
                                                                    p_CC_DET_PF_Func_AMT
                                                                   );

            l_CC_DET_PF_ENCMBRNC_AMT := GL_CURRENCY_API.CONVERT_AMOUNT (l_FROM_CURR,
                                                                        l_TO_CURR,
                                                                        l_CONVERSION_DATE,
                                                                        l_CONVERSION_TYPE,
                                                                        p_CC_DET_PF_ENCMBRNC_AMT
                                                                       );

-- -----------------------------------------------------------------------
-- Insert the appropriate MRC history record for the reporting set
-- of books being processed.
-- -----------------------------------------------------------------------
            IGC_CC_MC_DET_PF_HST_PKG.Insert_Row (
                             l_api_version,
                             FND_API.G_FALSE,
                             FND_API.G_FALSE,
                             FND_API.G_VALID_LEVEL_FULL,
                             l_return_status,
                             X_msg_count,
                             X_msg_data,
                             l_row_id,
                             p_CC_DET_PF_Line_Id,
                             l_sob_list(rec1).r_sob_id,
                             l_CC_DET_PF_Func_Amt,
                             l_CC_DET_PF_ENCMBRNC_AMT,
                             p_Det_PF_Version_Num,
                             p_Det_PF_Version_Action,
                             l_Conversion_Type,
                             l_Conversion_Date,
                             l_conversion_Rate
                            );

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

         END IF;  -- Rate exists

      END IF;  -- Reporting set of books

   END LOOP;  -- Loop for all associated sets of books

-- ------------------------------------------------------------------------
-- Only commit the information if the caller has requested it to be.
-- ------------------------------------------------------------------------
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END iF;

-- ------------------------------------------------------------------------
-- Make sure that the cursor used is closed upon exit
-- ------------------------------------------------------------------------
   IF (c_conversion_type%ISOPEN) THEN
      CLOSE c_conversion_type;
   END IF;

   FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                              p_data  => X_msg_data);

   RETURN;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO SAVEPOINT get_rsobs_DET_PF_PT;
       X_return_status := FND_API.G_RET_STS_ERROR;
       IF (c_conversion_type%ISOPEN) THEN
          CLOSE c_conversion_type;
       END IF;
       FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                  p_data  => X_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO SAVEPOINT get_rsobs_DET_PF_PT;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (c_conversion_type%ISOPEN) THEN
          CLOSE c_conversion_type;
       END IF;
       FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                  p_data  => X_msg_data);

    WHEN OTHERS THEN
       ROLLBACK TO SAVEPOINT get_rsobs_DET_PF_PT;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (c_conversion_type%ISOPEN) THEN
          CLOSE c_conversion_type;
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                   l_api_name);
       END if;

       FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                  p_data  => X_msg_data);

END get_rsobs_DET_PF;

END IGC_CC_MC_MAIN_HST_PVT;

/
