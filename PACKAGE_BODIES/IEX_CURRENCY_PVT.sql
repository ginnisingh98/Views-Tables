--------------------------------------------------------
--  DDL for Package Body IEX_CURRENCY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CURRENCY_PVT" AS
/* $Header: iexvcurb.pls 120.2 2005/08/19 14:03:39 jypark noship $ */
  TYPE CurrencyCodeType  IS TABLE OF VARCHAR2(15)  INDEX BY BINARY_INTEGER;
  TYPE PrecisionType     IS TABLE OF NUMBER(1)     INDEX BY BINARY_INTEGER;
  TYPE MauType           IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
--Begin-08/16/2005-jypark-fix gscc error
--  g_next_element            BINARY_INTEGER := 0;
  g_next_element            BINARY_INTEGER;
  g_currency_code_tab       CurrencyCodeType;
  g_precision_tab           PrecisionType;
--  PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
  PG_DEBUG NUMBER(2);
  g_mau_tab                 MauType;
--End-08/16/2005-jypark-fix gscc error

--
--
    CURSOR CurrencyCursor( cp_currency_code VARCHAR2 ) IS
    SELECT  precision,
            minimum_accountable_unit
    FROM    fnd_currencies
    WHERE   currency_code = cp_currency_code;
--

/*===========================================================================+
| PROCEDURE                                                                 |
|              Get_Currency_Details                                         |
|                                                                           |
| DESCRIPTION                                                               |
|              This PROCEDURE returns Currency Details Information          |
|                                                                           |
| SCOPE - PRIVATE                                                           |
|                                                                           |
| ARGUMENTS  : IN:                                                          |
|                  p_currency_code : Currency Code                          |
|              OUT:                                                         |
|                  x_precision     : Precision                              |
|                  x_mau           : Minimum Accountable Unit               |
|          IN/ OUT:                                                         |
|                                                                           |
| RETURNS    : NONE                                                         |
|                                                                           |
| NOTES                                                                     |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|    jypark          23-NOV-99 Created                                      |
|                                                                           |
+===========================================================================*/


  PROCEDURE Get_Currency_Details(
                           p_api_version               IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_validation_level          IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_currency_code             IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                           x_precision                 OUT NOCOPY NUMBER,
                           x_mau                       OUT NOCOPY NUMBER,
                           x_return_status             OUT NOCOPY VARCHAR2,
                           x_msg_count                 OUT NOCOPY NUMBER,
                           x_msg_data                  OUT NOCOPY VARCHAR2
  ) IS
    i BINARY_INTEGER := 0;
    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'Get_Currency_Details';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    l_currency_code   VARCHAR2(15) := p_currency_code;
  BEGIN
--  Standard begin of API savepoint
    SAVEPOINT	Get_Currency_Details_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    WHILE i < g_next_element
    LOOP
      EXIT WHEN g_currency_code_tab(i) = l_currency_code;
            i := i + 1;
        END LOOP;
--
        IF i = g_next_element
        THEN
            OPEN CurrencyCursor( l_currency_code );
            DECLARE
                l_Precision NUMBER;
                l_Mau       NUMBER;
            BEGIN
                FETCH CurrencyCursor
                INTO    l_Precision,
                        l_Mau;
                IF CurrencyCursor%NOTFOUND THEN
                    RAISE NO_DATA_FOUND;
                END IF;
                g_precision_tab(i)    := l_Precision;
                g_mau_tab(i)          := l_Mau;
            END;
            CLOSE CurrencyCursor;
            g_currency_code_tab(i) := l_currency_code;
            g_next_element     := i + 1;
        END IF;
        x_precision := g_precision_tab(i);
        x_mau       := g_mau_tab(i);

EXCEPTION
  WHEN GL_CURRENCY_API.NO_RATE THEN
    ROLLBACK TO Get_Currency_Details_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('SQLGL', 'GL_JE_INVALID_CONVERSION_INFO');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
    ROLLBACK TO Get_Currency_Details_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('SQLGL', 'GL INVALID CURRENCY CODE');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Get_Currency_Details_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Get_Currency_Details_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
 END;
--

/*===========================================================================+
| PROCEDURE                                                                 |
|              Get_Curr_Round_Amount                                        |
|                                                                           |
| DESCRIPTION                                                               |
|              Thist PROCEDURE return Currency Rounded Amount               |
|                                                                           |
| SCOPE - PRIVATE                                                           |
|                                                                           |
|                                                                           |
| ARGUMENTS  : IN:                                                          |
|                  p_amount        : Amount                                 |
|                  p_currency_code : Currency Code                          |
|              OUT:                                                         |
|                  x_rounded_amount : Rounded currency amount               |
|                                                                           |
|          IN/ OUT:                                                         |
| NOTES                                                                     |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|    jypark          23-NOV-99 Created                                      |
|                                                                           |
+===========================================================================*/
  PROCEDURE Get_Curr_Round_Amount (
                       p_api_version               IN  NUMBER  DEFAULT FND_API.G_MISS_NUM,
                       p_init_msg_list             IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
                       p_commit                    IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
                       p_validation_level          IN  NUMBER  DEFAULT FND_API.G_MISS_NUM,
                       p_amount                    IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                       p_currency_code             IN  VARCHAR2   DEFAULT g_functional_currency,
                       x_rounded_amount            OUT NOCOPY NUMBER,
                       x_return_status             OUT NOCOPY VARCHAR2,
                       x_msg_count                 OUT NOCOPY NUMBER,
                       x_msg_data                  OUT NOCOPY VARCHAR2
  ) IS
    l_precision NUMBER(1);
    l_mau       NUMBER;
    l_amount    NUMBER := p_amount;
    l_currency_code VARCHAR2(15) := p_currency_code;
    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'Get_Currency_Details';
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data	         VARCHAR2(100);
  BEGIN
--  Standard begin of API savepoint
    SAVEPOINT	Curr_Round_Amount_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Get_Currency_Details( p_api_version => 1.0,
                       p_init_msg_list => 'F',
                       p_commit => 'F',
                       p_currency_code => l_currency_code,
                       x_precision => l_precision,
                       x_mau => l_mau,
                       x_return_status => l_return_status,
                       x_msg_count => l_msg_count,
                       x_msg_data => l_msg_data
                      );


   IF l_mau IS NOT NULL
   THEN
     x_rounded_amount := ROUND( l_amount / l_mau) * l_mau;
   ELSE
     x_rounded_amount := ROUND( l_amount, l_precision);
   END IF;
EXCEPTION
  WHEN GL_CURRENCY_API.NO_RATE THEN
    ROLLBACK TO Curr_Round_Amount_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('SQLGL', 'GL_JE_INVALID_CONVERSION_INFO');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
    ROLLBACK TO Curr_Round_Amount_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('SQLGL', 'GL INVALID CURRENCY CODE');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Curr_Round_Amount_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Curr_Round_Amount_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
    END;

/*===========================================================================+
| PROCEDURE                                                                 |
|              Get_Functional_Amount                                        |
|                                                                           |
| DESCRIPTION                                                               |
|   This PROCEDURE returns the functional amount for a given foreign amount.|
|   The functional amount is rounded to the correct precision.              |
|                                                                           |
|                                                                           |
| SCOPE - PRIVATE                                                           |
|                                                                           |
| ARGUMENTS  : IN:                                                          |
|                  p_amount - the original foreign amount                   |
|                  p_exchange_rate - to use when converting to functional   |
|                                      amount                               |
|                one of:                                                    |
|                  p_currency_code - of the functional amount               |
|                  p_precision     - of the functional amount               |
|                  p_minimum_accountable_unit - of the functional amount    |
|              OUT:                                                         |
|                  x_amount_functional -                                    |
|                           l_amount * l_exchange_rate to correct rounding  |
|                           for currency                                    |
|                                                                           |
|          IN/ OUT:                                                         |
| NOTES                                                                     |
| EXCEPTIONS RAISED                                                         |
|    Oracle Error      If Currency Code, Precision and minimum accountable  |
|                      are all NULL                                         |
|                                                                           |
|    Oracle Error      If can not find information for Currency Code        |
|                      supplied                                             |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|    jypark          23-NOV-99 Created                                      |
|    acaraujo        09-FEB-00 Optional functional currency code            |
|                                                                           |
+===========================================================================*/


PROCEDURE Get_Functional_Amount(
			   p_api_version                 IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_init_msg_list               IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_commit                      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
			   p_validation_level            IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_amount                      IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_currency_code               IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                           p_exchange_rate               IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_precision                   IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_min_acc_unit                IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           x_functional_amount           OUT NOCOPY NUMBER,
                           x_return_status               OUT NOCOPY VARCHAR2,
                           x_msg_count                   OUT NOCOPY NUMBER,
                           x_msg_data                    OUT NOCOPY VARCHAR2
  ) IS

/*----------------------------------------------------------------------------*
 | PRIVATE CURSOR                                                             |
 |      curr_info                                                             |
 |                                                                            |
 | DESCRIPTION                                                                |
 |      Gets the precision and the minimum accountable unit for the currency  |
 |      Supplied                                                              |
 |                                                                            |
 *----------------------------------------------------------------------------*/

    CURSOR curr_info (cc FND_CURRENCIES.CURRENCY_CODE%TYPE) IS
        SELECT PRECISION,
               MINIMUM_ACCOUNTABLE_UNIT,
               CURRENCY_CODE
        FROM   FND_CURRENCIES
        WHERE  CURRENCY_CODE = cc;

/*---------------------------------------------------------------------------*
 | PRIVATE DATATYPES                                                         |
 |                                                                           |
 *---------------------------------------------------------------------------*/


    l_curr_rec       curr_info%ROWTYPE;
    l_loc_amount     NUMBER;
    l_amount         NUMBER := p_amount;
    l_currency_code  VARCHAR2(15) := p_currency_code;
    l_exchange_rate  NUMBER := p_exchange_rate;
    --l_precision      NUMBER(1) := p_precision; Removed by Andre Araujo 02/08/00
    l_precision      NUMBER := p_precision;
    l_min_acc_unit   NUMBER := p_min_acc_unit;

    l_invalid_params_exp EXCEPTION;
    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'Get_Functional_Amount';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    l_init_msg_list		VARCHAR2(1) := 'F';	-- Andre Araujo 02/08/00
    l_functional_currency	VARCHAR2(10);		-- Andre Araujo 02/08/00
    l_commit			VARCHAR2(1) := 'F';		-- Andre Araujo 02/08/00

  BEGIN

--  Standard begin of API savepoint
    SAVEPOINT	Functional_Amount_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*--------------------------------------------------------------------*
     | Validate Parameters                                                |
     *--------------------------------------------------------------------*/

-- Begin - Andre Araujo - Read functional currency if we do not get it
    IF (p_currency_code = FND_API.G_MISS_CHAR) OR  (p_currency_code = '-1') THEN
       IEX_CURRENCY_PVT.GET_FUNCT_CURR(p_api_version => l_api_version,
       		p_init_msg_list => l_init_msg_list,
       		p_commit => l_commit,
       		x_return_status => l_return_status,
       		x_msg_count => l_msg_count,
       		x_msg_data => l_msg_data,
       		x_functional_currency => l_functional_currency);

       	l_currency_code := l_functional_currency;
    END IF;

    -- Now that we are here lets get precision and Minimum account unit
    IF ((p_precision = -1) OR (p_min_acc_unit = -1)) OR
    	((p_precision = FND_API.G_MISS_NUM) OR (p_min_acc_unit = FND_API.G_MISS_NUM)) THEN
       IEX_CURRENCY_PVT.GET_CURRENCY_DETAILS
       	       (p_api_version => l_api_version,
       		p_init_msg_list => l_init_msg_list,
       		p_commit => l_commit,
       		x_return_status => l_return_status,
       		x_msg_count => l_msg_count,
       		x_msg_data => l_msg_data,
       		p_currency_code => l_functional_currency,
       		x_precision => l_precision,
       		x_mau => l_min_acc_unit);

    END IF;

-- End - Andre Araujo

    IF (((l_currency_code IS NULL) AND
         (l_precision IS NULL) AND
         (l_min_acc_unit IS NULL)) OR
        (l_amount IS NULL) ) THEN
      BEGIN

         /* fnd_message('STD-FUNCT-AMT-INV-PAR'); */

         RAISE l_invalid_params_exp;

      END;
    END IF;

    /*--------------------------------------------------------------------*
     | Only get currency info from database if not supplied as parameters |
     *--------------------------------------------------------------------*/


    IF ((l_precision IS NULL) AND (l_min_acc_unit IS NULL)) THEN
      BEGIN
         OPEN curr_info(l_currency_code);
         FETCH curr_info INTO l_curr_rec;
         CLOSE curr_info;

         IF (l_curr_rec.currency_code IS NULL) THEN

              /* fnd_message('STD-FUNCT-AMT-CURR-NF',
                             'CURR',
                             currency_code); */

              RAISE l_invalid_params_exp;

         END IF;

      END;
    ELSE
      l_curr_rec.precision := l_precision;
      l_curr_rec.minimum_accountable_unit := l_min_acc_unit;
    END IF;

    l_loc_amount := l_amount * NVL(l_exchange_rate, 1);



    /*-----------------*
     | Round correctly |
     *-----------------*/

    IF (l_curr_rec.minimum_accountable_unit IS NULL) THEN
       x_functional_amount := ROUND(l_loc_amount, l_curr_rec.precision);
    ELSE
       x_functional_amount := ROUND((l_loc_amount / l_curr_rec.minimum_accountable_unit)) *
               l_curr_rec.minimum_accountable_unit;
    END IF;

  EXCEPTION
    WHEN GL_CURRENCY_API.NO_RATE THEN
      ROLLBACK TO Functional_Amount_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('SQLGL', 'GL_JE_INVALID_CONVERSION_INFO');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
      ROLLBACK TO Functional_Amount_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('SQLGL', 'GL INVALID CURRENCY CODE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Functional_Amount_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Functional_Amount_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
  END Get_Functional_Amount;

/*===========================================================================+
| PROCEDURE                                                                 |
|              Get_Func_Amt_Rate                                            |
|                                                                           |
| DESCRIPTION                                                               |
|   This PROCEDURE returns the functional amount for a given foreign amount.|
|   The functional amount is rounded to the correct precision.              |
|                                                                           |
|                                                                           |
| SCOPE - PRIVATE                                                           |
|                                                                           |
| ARGUMENTS  : IN:                                                          |
|                  p_amount_original - the original foreign amount                   |
|                  p_exchange_rate - to use when converting to functional   |
|                                      amount                               |
|              OUT:                                                         |
|                  x_amount_functional -                                    |
|                           l_amount_original* l_exchange_rate to correct rounding  |
|                           for currency                                    |
|                                                                           |
|          IN/ OUT:                                                         |
| NOTES                                                                     |
| EXCEPTIONS RAISED                                                         |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|    jypark          01-MAR-2000 Created                                    |
|                                                                           |
+===========================================================================*/

  PROCEDURE Get_Func_Amt_Rate(
			   p_api_version                 IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_init_msg_list               IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_commit                      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
			   p_validation_level            IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_amount_original             IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_exchange_rate               IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           x_amount_functional           OUT NOCOPY NUMBER,
                           x_return_status               OUT NOCOPY VARCHAR2,
                           x_msg_count                   OUT NOCOPY NUMBER,
                           x_msg_data                    OUT NOCOPY VARCHAR2
  ) IS

/*---------------------------------------------------------------------------*
 | PRIVATE DATATYPES                                                         |
 |                                                                           |
 *---------------------------------------------------------------------------*/

    l_amount_functional     NUMBER;
    l_amount_original       NUMBER := p_amount_original;
    l_functional_currency   VARCHAR2(10);
    l_exchange_rate         NUMBER := p_exchange_rate;
    l_precision             NUMBER;
    l_min_acc_unit          NUMBER;

    l_invalid_params_exp    EXCEPTION;
    l_api_version CONSTANT  NUMBER :=  1.0;
    l_api_name    CONSTANT  VARCHAR2(30) :=  'Get_Fun_Amt_Rate';
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);

    l_init_msg_list	    VARCHAR2(1) := 'F';
    l_commit                VARCHAR2(1) := 'F';

  BEGIN

--  Standard begin of API savepoint
    SAVEPOINT	Func_Amt_Rate_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get functional currency
    IEX_CURRENCY_PVT.GET_FUNCT_CURR(p_api_version => l_api_version,
                 p_init_msg_list => l_init_msg_list,
                 p_commit => l_commit,
                 x_return_status => l_return_status,
                 x_msg_count => l_msg_count,
                 x_msg_data => l_msg_data,
                 x_functional_currency => l_functional_currency);

    -- Get precision and minimum account unit for functional currency
    IEX_CURRENCY_PVT.GET_CURRENCY_DETAILS
              (p_api_version => l_api_version,
               p_init_msg_list => l_init_msg_list,
               p_commit => l_commit,
               x_return_status => l_return_status,
               x_msg_count => l_msg_count,
               x_msg_data => l_msg_data,
               p_currency_code => l_functional_currency,
               x_precision => l_precision,
               x_mau => l_min_acc_unit);


    IF (((l_functional_currency IS NULL) AND
         (l_precision IS NULL) AND
         (l_min_acc_unit IS NULL)) OR
        (l_amount_original IS NULL) ) THEN
      BEGIN
         /* fnd_message('STD-FUNCT-AMT-INV-PAR'); */
         RAISE l_invalid_params_exp;
      END;
    END IF;

   l_amount_functional := l_amount_original * NVL(l_exchange_rate, 1);

   /*-----------------*
     | Round correctly |
    *-----------------*/

   IF (l_min_acc_unit IS NULL) THEN
       x_amount_functional := ROUND(l_amount_functional, l_precision);
   ELSE
       x_amount_functional := ROUND((l_amount_functional / l_min_acc_unit)) *
               l_min_acc_unit;
   END IF;


  EXCEPTION
    WHEN GL_CURRENCY_API.NO_RATE THEN
      ROLLBACK TO Func_Amt_Rate_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('SQLGL', 'GL_JE_INVALID_CONVERSION_INFO');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
      ROLLBACK TO Func_Amt_Rate_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('SQLGL', 'GL INVALID CURRENCY CODE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Func_Amt_Rate_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Func_Amt_Rate_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
  END Get_Func_Amt_Rate;

/*===========================================================================+
| PROCEDURE                                                                 |
|              Get_Func_Amt_Curr                                            |
|                                                                           |
| DESCRIPTION                                                               |
|   This PROCEDURE returns the functional amount for a given foreign amount |
|   and foreign currency and exchange date.                                 |
|   The functional amount is rounded to the correct precision.              |
|                                                                           |
|                                                                           |
| SCOPE - PRIVATE                                                           |
|                                                                           |
| ARGUMENTS  : IN:                                                          |
|                  p_amount_original - the original foreign amount          |
|                  p_currency_original - of the functional amount           |
|                                      amount                               |
|                  p_exchange_date - to use when converting to functional   |
|              OUT:                                                         |
|                  x_amount_functional -                                    |
|                           l_amount * l_exchange_rate to correct rounding  |
|                           for currency                                    |
|                                                                           |
|          IN/ OUT:                                                         |
| NOTES                                                                     |
| EXCEPTIONS RAISED                                                         |
|                                                                           |
|    Oracle Error      If can not find information for Currency Code        |
|                      supplied                                             |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|    jypark          01-MAR-2000 Created                                    |
|                                                                           |
+===========================================================================*/

  PROCEDURE Get_Func_Amt_Curr(
                           p_api_version                 IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_init_msg_list               IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_commit                      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_validation_level            IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_amount_original             IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_currency_original           IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                           p_exchange_date               IN  DATE DEFAULT FND_API.G_MISS_DATE,
                           x_amount_functional           OUT NOCOPY NUMBER,
                           x_return_status               OUT NOCOPY VARCHAR2,
                           x_msg_count                   OUT NOCOPY NUMBER,
                           x_msg_data                    OUT NOCOPY VARCHAR2
  ) IS

/*---------------------------------------------------------------------------*
 | PRIVATE DATATYPES                                                         |
 |                                                                           |
 *---------------------------------------------------------------------------*/

    l_amount_functional        NUMBER;
    l_amount_original          NUMBER := p_amount_original;
    l_currency_original        VARCHAR2(15) := p_currency_original;
    l_exchange_date            DATE := p_exchange_date;
    l_conversion_type          VARCHAR2(100);
    l_precision                NUMBER;
    l_min_acc_unit             NUMBER;

    l_invalid_params_exp       EXCEPTION;
    l_api_version     CONSTANT NUMBER :=  1.0;
    l_api_name        CONSTANT VARCHAR2(30) :=  'Get_Func_Amt_Curr';
    l_validation_level         NUMBER := 100;
    l_return_status            VARCHAR2(1);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(32767);

    l_init_msg_list            VARCHAR2(1) := 'F';
    l_currency_functional      VARCHAR2(10);
    l_commit                   VARCHAR2(1) := 'F';

  BEGIN

--  Standard begin of API savepoint
    SAVEPOINT Func_Amt_Curr_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get Functional Currency
    IEX_CURRENCY_PVT.GET_FUNCT_CURR(p_api_version => l_api_version,
         p_init_msg_list => l_init_msg_list,
         p_commit => l_commit,
         x_return_status => l_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data,
         x_functional_currency => l_currency_functional);

    -- Get Collections default conversion type
    l_conversion_type := fnd_profile.value('IEX_EXCHANGE_RATE_TYPE');

    -- Get precision and minimum account unit for functional currency
    IEX_CURRENCY_PVT.GET_CURRENCY_DETAILS
              (p_api_version => l_api_version,
               p_init_msg_list => l_init_msg_list,
               p_commit => l_commit,
               x_return_status => l_return_status,
               x_msg_count => l_msg_count,
               x_msg_data => l_msg_data,
               p_currency_code => l_currency_functional,
               x_precision => l_precision,
               x_mau => l_min_acc_unit);

    IF (((l_currency_functional IS NULL) AND
         (l_precision IS NULL) AND
         (l_min_acc_unit IS NULL)) OR
        (l_amount_original IS NULL) ) THEN
      BEGIN

         /* fnd_message('STD-FUNCT-AMT-INV-PAR'); */

         RAISE l_invalid_params_exp;

      END;
    END IF;

    -- Get functional amount
    Get_Convert_Amount_Curr(
        p_api_version => l_api_version,
        p_init_msg_list => l_init_msg_list,
        p_commit => l_commit,
        p_validation_level => l_validation_level,
        p_from_currency => l_currency_original,
        p_to_currency => l_currency_functional,
        p_conversion_date => l_exchange_date,
        p_conversion_type => l_conversion_type,
        p_amount_original => l_amount_original,
        x_amount_converted => l_amount_functional,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data);

    /*-----------------*
     | Round correctly |
     *-----------------*/

    IF (l_min_acc_unit IS NULL) THEN
       x_amount_functional := ROUND(l_amount_functional, l_precision);
    ELSE
       x_amount_functional := ROUND((l_amount_functional / l_min_acc_unit)) *
               l_min_acc_unit;
    END IF;


  EXCEPTION
    WHEN GL_CURRENCY_API.NO_RATE THEN
      ROLLBACK TO Func_Amt_Curr_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('SQLGL', 'GL_JE_INVALID_CONVERSION_INFO');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
      ROLLBACK TO Func_Amt_Curr_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('SQLGL', 'GL INVALID CURRENCY CODE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Func_Amt_Curr_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Func_Amt_Curr_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
  END Get_Func_Amt_Curr;

/*===========================================================================+
| PROCEDURE                                                                  |
|              Get_Convert_Amount_Curr                                      |
|                                                                           |
| DESCRIPTION                                                               |
|   This PROCEDURE takes from and to currencies, conversion date,            |
|   conversion type and amount and  returns the amount converted into the   |
|   appropriate currency.                                                   |
|                                                                           |
|                                                                           |
| SCOPE - PRIVATE                                                           |
|                                                                           |
|                                                                           |
| ARGUMENTS  : IN:                                                          |
|                  p_from_currency - From currency                          |
|                  p_to_currency - To currency                              |
|                  p_conversion_date - Conversion date                      |
|                  p_conversion_type - Conversion type                      |
|                  p_amount - the original foreign amount                   |
|              OUT:                                                         |
|                  x_amount_converted -                                     |
|                       the amount converted into the appropriate currency. |
|                                                                           |
|          IN/ OUT:                                                         |
|                                                                           |
| NOTES                                                                     |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|    jypark          23-NOV-99 Created                                      |
|                                                                           |
+===========================================================================*/

  PROCEDURE Get_Convert_Amount_Curr(
                           p_api_version               IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_validation_level          IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_from_currency             IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                           p_to_currency               IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                           p_conversion_date           IN  DATE DEFAULT FND_API.G_MISS_DATE,
                           p_conversion_type           IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                           p_amount_original           IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           x_amount_converted          OUT NOCOPY NUMBER,
                           x_return_status             OUT NOCOPY VARCHAR2,
                           x_msg_count                 OUT NOCOPY NUMBER,
                           x_msg_data                  OUT NOCOPY VARCHAR2
  ) AS
    l_from_currency VARCHAR2(15) := p_from_currency;
    l_to_currency VARCHAR2(15) := p_to_currency;
    l_conversion_date DATE := p_conversion_date;
    l_conversion_type VARCHAR2(30) := p_conversion_type;
    l_amount_original NUMBER := p_amount_original;

    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'Get_Convert_Amount_Curr';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);
  BEGIN
    --  Standard begin of API savepoint
    SAVEPOINT	Convert_Amount_Curr_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;


    x_amount_converted := gl_currency_api.convert_amount(x_from_currency => l_from_currency,
                            x_to_currency => l_to_currency,
                            x_conversion_date => l_conversion_date,
                            x_conversion_type => l_conversion_type,
                            x_amount => l_amount_original);

  EXCEPTION
    WHEN GL_CURRENCY_API.NO_RATE THEN
      ROLLBACK TO Convert_Amount_Curr_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('SQLGL', 'GL_JE_INVALID_CONVERSION_INFO');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
      ROLLBACK TO Convert_Amount_Curr_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('SQLGL', 'GL INVALID CURRENCY CODE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Convert_Amount_Curr_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Convert_Amount_Curr_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
  END;

/*===========================================================================+
| PROCEDURE                                                                  |
|              Get_Convert_Amount_Sob                                       |
|                                                                           |
| DESCRIPTION                                                               |
|   This PROCEDURE takes from and to currencies, conversion date,            |
|   conversion type and amount and  returns the amount converted into the   |
|   appropriate currency.                                                   |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
| SCOPE - PRIVATE                                                           |
|                                                                           |
|                                                                           |
| ARGUMENTS  : IN:                                                          |
|                  p_set_of_books_id - Set of books id                      |
|                  p_from_currency - From currency                          |
|                  p_conversion_date - Conversion date                      |
|                  p_conversion_type - Conversion type                      |
|                  p_amount - the original foreign amount                   |
|              OUT:                                                         |
|                  x_amount_converted -                                     |
|                       the amount converted into the appropriate currency. |
|                                                                           |
|          IN/ OUT:                                                         |
| NOTES                                                                     |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|    jypark          23-NOV-99 Created                                      |
|                                                                           |
+===========================================================================*/

  PROCEDURE Get_Convert_Amount_Sob(
					  p_api_version               IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
					  p_validation_level          IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_set_of_books_id           IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                           p_from_currency             IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                           p_conversion_date           IN  DATE DEFAULT FND_API.G_MISS_DATE,
                           p_conversion_type           IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                           p_amount_original           IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           x_amount_converted          OUT NOCOPY NUMBER,
                           x_return_status             OUT NOCOPY VARCHAR2,
                           x_msg_count                 OUT NOCOPY NUMBER,
                           x_msg_data                  OUT NOCOPY VARCHAR2
  ) IS
    l_set_of_books_id NUMBER(15) := p_set_of_books_id;
    l_from_currency VARCHAR2(15) := p_from_currency;
    l_conversion_date DATE := p_conversion_date;
    l_conversion_type VARCHAR2(30) := p_conversion_type;
    l_amount_original NUMBER := p_amount_original;

    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'Get_Convert_Amount_Sob';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);
BEGIN

--  Standard begin of API savepoint
    SAVEPOINT	Convert_Amount_Sob_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    x_amount_converted := gl_currency_api.convert_amount(x_set_of_books_id => p_set_of_books_id,
                            x_from_currency => p_from_currency,
                            x_conversion_date => p_conversion_date,
                            x_conversion_type => p_conversion_type,
                            x_amount => p_amount_original);

  EXCEPTION
    WHEN GL_CURRENCY_API.NO_RATE THEN
      ROLLBACK TO Convert_Amount_Sob_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('SQLGL', 'GL_JE_INVALID_CONVERSION_INFO');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
      ROLLBACK TO Convert_Amount_Sob_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('SQLGL', 'GL INVALID CURRENCY CODE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Convert_Amount_Sob_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Convert_Amount_Sob_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
  END;
/*===========================================================================+
| PROCEDURE                                                                  |
|              Get_Funct_Curr                                               |
|                                                                           |
| DESCRIPTION                                                               |
|   This PROCEDURE return functional currency of set of books                |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
| SCOPE - PRIVATE                                                           |
|                                                                           |
|                                                                           |
| ARGUMENTS  : IN:                                                          |
|                                                                           |
|              OUT:                                                         |
|                  x_functional_currency - Functional currency              |
|                                                                           |
|          IN/ OUT:                                                         |
| NOTES                                                                     |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|    jypark          23-NOV-99 Created                                      |
|                                                                           |
+===========================================================================*/
  PROCEDURE Get_Funct_Curr(
                           p_api_version               IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_validation_level          IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           x_functional_currency       OUT NOCOPY VARCHAR2,
                           x_return_status             OUT NOCOPY VARCHAR2,
                           x_msg_count                 OUT NOCOPY NUMBER,
                           x_msg_data                  OUT NOCOPY VARCHAR2
  ) IS

    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'Get_Funct_Curr';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);
 BEGIN
--  Standard begin of API savepoint
    SAVEPOINT	Funct_Curr_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;


--Begin-Bug#4558398-08/16/2005-jypark-remove getting functional currency code from constructor and put in procedure get_funct_curr
--     SELECT  currency_code
--     INTO    x_functional_currency
--     FROM    gl_sets_of_books
--     WHERE   set_of_books_id = g_set_of_books_id;

    SELECT  gll.currency_code,
            gll.ledger_id
    INTO    g_functional_currency,
            g_set_of_books_id
    FROM    ar_system_parameters    sp,
            gl_ledgers_public_v     gll
    WHERE   gll.ledger_id = sp.set_of_books_id;

    x_functional_currency := g_functional_currency;

  EXCEPTION
--    WHEN GL_CURRENCY_API.NO_RATE THEN
--      ROLLBACK TO Funct_Curr_PVT;
--      x_return_status := FND_API.G_RET_STS_ERROR;
--      FND_MESSAGE.SET_NAME('SQLGL', 'GL_JE_INVALID_CONVERSION_INFO');
--      FND_MSG_PUB.ADD;
--      FND_MSG_PUB.Count_And_Get(
--        p_encoded => FND_API.G_FALSE,
--        p_count => x_msg_count,
--        p_data  => x_msg_data);
--    WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
--      ROLLBACK TO Funct_Curr_PVT;
--      x_return_status := FND_API.G_RET_STS_ERROR;
--      FND_MESSAGE.SET_NAME('SQLGL', 'GL INVALID CURRENCY CODE');
--      FND_MSG_PUB.ADD;
--      FND_MSG_PUB.Count_And_Get(
--        p_encoded => FND_API.G_FALSE,
--        p_count => x_msg_count,
--        p_data  => x_msg_data);
--    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--      ROLLBACK TO Funct_Curr_PVT;
--      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--      FND_MSG_PUB.Count_And_Get(
--        p_encoded => FND_API.G_FALSE,
--        p_count => x_msg_count,
--        p_data  => x_msg_data);
--    WHEN OTHERS THEN
--      ROLLBACK TO Funct_Curr_PVT;
--      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--      FND_MSG_PUB.Count_And_Get(
--        p_encoded => FND_API.G_FALSE,
--        p_count => x_msg_count,
--        p_data  => x_msg_data);
   WHEN OTHERS THEN
   /* if there is no record or multiple org records then setting null */
     g_functional_currency := null;
     g_set_of_books_id := null;

--End-Bug#4558398-08/16/2005-jypark-remove getting functional currency code from constructor and put in procedure get_funct_curr
  END Get_Funct_Curr;
/*===========================================================================+
| PROCEDURE                                                                 |
|              Get_Format_Mask                                              |
|                                                                           |
| DESCRIPTION                                                               |
|              This Procedure returns Format Mask For Currency              |
|                                                                           |
| SCOPE - PRIVATE                                                           |
|                                                                           |
| ARGUMENTS  : IN:                                                          |
|                  p_currency_code : Currency Code                          |
|                  p_field_length  : Field Length                           |
|              OUT:                                                         |
|                  x_format mask   : Format Mask                            |
|                                                                           |
| NOTES                                                                     |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|    jypark          23-NOV-99 Created                                      |
|                                                                           |
+===========================================================================*/
  PROCEDURE Get_Format_Mask(
                           p_api_version               IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_validation_level          IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_currency_code             IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                           p_field_length              IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           x_format_mask               OUT NOCOPY VARCHAR2,
                           x_return_status             OUT NOCOPY VARCHAR2,
                           x_msg_count                 OUT NOCOPY NUMBER,
                           x_msg_data                  OUT NOCOPY VARCHAR2
  ) IS
    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'Get_Format_Mask';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    l_currency_code   VARCHAR2(15) := p_currency_code;
    l_field_length    NUMBER := p_field_length;
    l_format_mask     VARCHAR2(1000);

  BEGIN
--  Standard begin of API savepoint
    SAVEPOINT   Get_Format_Mask_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_format_mask := FND_CURRENCY.Get_Format_Mask(l_currency_code, l_field_length);

EXCEPTION
  WHEN GL_CURRENCY_API.NO_RATE THEN
    ROLLBACK TO Get_Format_Mask_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('SQLGL', 'GL_JE_INVALID_CONVERSION_INFO');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Get_Format_Mask_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
 END Get_Format_Mask;

/*===========================================================================+
| PROCEDURE                                                                 |
|              Get_Currency_Count                                           |
|                                                                           |
| DESCRIPTION                                                               |
|              This Procedure returns count of functional currency          |
               for which the mo profile has access.                         |
|                                                                           |
| SCOPE - PRIVATE                                                           |
|                                                                           |
| ARGUMENTS  : IN:                                                          |
|                  NULL                                                     |
|              RETURN :                                                     |
|                  Number                                                   |
|                                                                           |
| NOTES                                                                     |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|   lkkumar          31-May-2005 Created                                    |
|                                                                           |
+===========================================================================*/
 FUNCTION Get_Currency_Count Return Number IS
 cnt_currency Number;
 BEGIN
  SELECT  count(distinct gll.currency_code)
  INTO    cnt_currency
  FROM    ar_system_parameters    sp,
          gl_ledgers_public_v     gll
  WHERE   gll.ledger_id = sp.set_of_books_id;
  Return (cnt_currency);
 EXCEPTION WHEN OTHERS THEN
   Return (Null);
 END Get_Currency_count;


--

--
--
--
-- constructor section
--
--Begin-Bug#4558398-08/16/2005-jypark-remove getting functional currency code from constructor and put in procedure get_funct_curr
  BEGIN
--    SELECT  sob.currency_code,
--            sob.set_of_books_id
--    INTO    g_functional_currency,
--            g_set_of_books_id
--    FROM    ar_system_parameters    sp,
--            gl_sets_of_books        sob
--    WHERE   sob.set_of_books_id = sp.set_of_books_id;
--  EXCEPTION
--    WHEN OTHERS THEN
--            RAISE;
--Begin-Bug#4558398-08/16/2005-jypark-remove getting functional currency code from constructor and put in procedure get_funct_curr
--
  g_next_element            := 0;
  PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

END IEX_CURRENCY_PVT;

/
