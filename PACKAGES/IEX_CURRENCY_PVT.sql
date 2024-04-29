--------------------------------------------------------
--  DDL for Package IEX_CURRENCY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_CURRENCY_PVT" AUTHID CURRENT_USER AS
/* $Header: iexvcurs.pls 120.1 2005/05/31 14:16:15 lkkumar noship $ */
  G_functional_CURRENCY fnd_currencies.currency_code%TYPE;
  G_SET_OF_BOOKS_ID  NUMBER(15);
  G_PKG_NAME        CONSTANT VARCHAR2(30)   :='IEX_CURRENCY_PVT';
  G_FILE_NAME       CONSTANT VARCHAR2(12) :='iexvcurs.pls';

  G_APPL_ID         NUMBER := FND_GLOBAL.Prog_Appl_Id;
  G_LOGIN_ID        NUMBER := FND_GLOBAL.Conc_Login_Id;
  G_PROGRAM_ID      NUMBER := FND_GLOBAL.Conc_Program_Id;
  G_USER_ID         NUMBER := FND_GLOBAL.User_Id;
  G_REQUEST_ID      NUMBER := FND_GLOBAL.Conc_Request_Id;

/*===========================================================================+
| PROCEDURE                                                                 |
|              Get_Currency_Details                                         |
|                                                                           |
| DESCRIPTION                                                               |
|              Get Currency Details Information                             |
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
  );

/*===========================================================================+
| PROCEDURE                                                                 |
|              Get_Curr_Round_Amount                                        |
|                                                                           |
| DESCRIPTION                                                               |
|              This PROCEDURE return Currency Rounded Amount                |
|                                                                           |
|                                                                           |
| SCOPE - PRIVATE                                                           |
|                                                                           |
|                                                                           |
| ARGUMENTS  : IN:                                                          |
|                  p_amount        : Amount                                 |
|                  p_currency_code : Currency Code                          |
|              OUT:                                                         |
|                  x_rounded_amount : Rounded currency amount               |
|          IN/ OUT:                                                         |
|                                                                           |
| NOTES                                                                     |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|    jypark          23-NOV-99 Created                                      |
|                                                                           |
+===========================================================================*/
  PROCEDURE Get_Curr_Round_Amount (
                       p_api_version               IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                       p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
				   p_validation_level          IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                       p_amount                    IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                       p_currency_code             IN  VARCHAR2   DEFAULT g_functional_currency,
                       x_rounded_amount            OUT NOCOPY NUMBER,
                       x_return_status             OUT NOCOPY VARCHAR2,
                       x_msg_count                 OUT NOCOPY NUMBER,
                       x_msg_data                  OUT NOCOPY VARCHAR2
  );

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
|                  x_functional_amount -                                    |
|                           l_amount * l_exchange_rate to correct rounding  |
|                           for currency                                    |
|                                                                           |
|          IN/ OUT:                                                         |
|                                                                           |
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
|                                                                           |
+===========================================================================*/
  PROCEDURE Get_functional_Amount(
                           p_api_version               IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
					  p_validation_level          IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_amount                      IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_currency_code               IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                           p_exchange_rate               IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_precision                   IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           p_min_acc_unit                IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
                           x_functional_amount           OUT NOCOPY NUMBER,
                           x_return_status             OUT NOCOPY VARCHAR2,
                           x_msg_count                 OUT NOCOPY NUMBER,
                           x_msg_data                  OUT NOCOPY VARCHAR2
  );

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
|                  p_amount_original - the original foreign amount          |
|                  p_exchange_rate - to use when converting to functional   |
|                                      amount                               |
|              OUT:                                                         |
|                  x_amount_functional -                                    |
|                           l_amount * l_exchange_rate to correct rounding  |
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
  );

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
  );


/*===========================================================================+
| PROCEDURE                                                                 |
|              Get_Convert_Amount_Curr                                      |
|                                                                           |
| DESCRIPTION                                                               |
|   This PROCEDURE takes from and to currencies, conversion date,           |
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
|                  p_amount_original - the original foreign amount          |
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
  );

/*===========================================================================+
| PROCEDURE                                                                 |
|              Get_Convert_Amount_Sob                                       |
|                                                                           |
| DESCRIPTION                                                               |
|   This PROCEDURE takes from and to currencies, conversion date,           |
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
|                                                                           |
| NOTES                                                                     |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|    jypark          23-NOV-99 Created                                      |
|                                                                           |
+===========================================================================*/
  PROCEDURE get_convert_amount_sob(
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
  );

/*===========================================================================+
| PROCEDURE                                                                 |
|              Get_Funct_Curr                                               |
|                                                                           |
| DESCRIPTION                                                               |
|   This PROCEDURE return functional currency of set of books               |
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
|          IN/ OUT:                                                         |
|                                                                           |
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
  );
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
  );
/*===========================================================================+
| PROCEDURE                                                                 |
|              Get_Currency_Count                                              |
|                                                                           |
| DESCRIPTION                                                               |
|              This Procedure returns count of functional currency to       |
               which the mo profile has access.                             |
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
 FUNCTION Get_Currency_Count Return Number;

END IEX_CURRENCY_PVT;

 

/
