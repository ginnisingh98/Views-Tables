--------------------------------------------------------
--  DDL for Package Body FEM_PARTY_PROFITABILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_PARTY_PROFITABILITY_PKG" as
-- $Header: femprfTB.pls 120.0 2005/06/06 19:52:36 appldev noship $



PROCEDURE Insert_Row(
                  x_Rowid               IN OUT NOCOPY    VARCHAR2,
                  x_PARTY_ID                      NUMBER,
 	          x_LAST_UPDATE_DATE              DATE,
	          x_LAST_UPDATED_BY               NUMBER,
	          x_CREATION_DATE                 DATE,
	          x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_PROFIT                        NUMBER,
                  x_PROFIT_PCT                    NUMBER,
                  x_RELATIONSHIP_EXPENSE          NUMBER,
                  x_TOTAL_EQUITY                  NUMBER,
                  x_TOTAL_GROSS_CONTRIB           NUMBER,
                  x_TOTAL_ROE                     NUMBER,
                  x_CONTRIB_AFTER_CPTL_CHG        NUMBER,
                  x_PARTNER_VALUE_INDEX           NUMBER,
                  x_ISO_CURRENCY_CD               VARCHAR2,
                  x_REVENUE1                      NUMBER,
                  x_REVENUE2                      NUMBER,
                  x_REVENUE3                      NUMBER,
                  x_REVENUE4                      NUMBER,
                  x_REVENUE5                      NUMBER,
                  x_REVENUE_TOTAL                 NUMBER,
                  x_EXPENSE1                      NUMBER,
                  x_EXPENSE2                      NUMBER,
                  x_EXPENSE3                      NUMBER,
                  x_EXPENSE4                      NUMBER,
                  x_EXPENSE5                      NUMBER,
                  x_EXPENSE_TOTAL                 NUMBER,
                  x_PROFIT1                       NUMBER,
                  x_PROFIT2                       NUMBER,
                  x_PROFIT3                       NUMBER,
                  x_PROFIT4                       NUMBER,
                  x_PROFIT5                       NUMBER,
                  x_PROFIT_TOTAL                  NUMBER,
                  x_CACC1                         NUMBER,
                  x_CACC2                         NUMBER,
                  x_CACC3                         NUMBER,
                  x_CACC4                         NUMBER,
                  x_CACC5                         NUMBER,
                  x_CACC_TOTAL                    NUMBER,
                  x_BALANCE1                      NUMBER,
                  x_BALANCE2                      NUMBER,
                  x_BALANCE3                      NUMBER,
                  x_BALANCE4                      NUMBER,
                  x_BALANCE5                      NUMBER,
                  x_ACCOUNTS1                     NUMBER,
                  x_ACCOUNTS2                     NUMBER,
                  x_ACCOUNTS3                     NUMBER,
                  x_ACCOUNTS4                     NUMBER,
                  x_ACCOUNTS5                     NUMBER,
                  x_TRANSACTION1                  NUMBER,
                  x_TRANSACTION2                  NUMBER,
                  x_TRANSACTION3                  NUMBER,
                  x_TRANSACTION4                  NUMBER,
                  x_TRANSACTION5                  NUMBER,
                  x_RATIO1                        NUMBER,
                  x_RATIO2                        NUMBER,
                  x_RATIO3                        NUMBER,
                  x_RATIO4                        NUMBER,
                  x_RATIO5                        NUMBER,
                  x_VALUE1                        NUMBER,
                  x_VALUE2                        NUMBER,
                  x_VALUE3                        NUMBER,
                  x_VALUE4                        NUMBER,
                  x_VALUE5                        NUMBER,
                  x_YTD1                          NUMBER,
                  x_YTD2                          NUMBER,
                  x_YTD3                          NUMBER,
                  x_YTD4                          NUMBER,
                  x_YTD5                          NUMBER,
                  x_LTD1                          NUMBER,
                  x_LTD2                          NUMBER,
                  x_LTD3                          NUMBER,
                  x_LTD4                          NUMBER,
                  x_LTD5                          NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM FEM_PARTY_PROFITABILITY
            WHERE PARTY_ID = x_PARTY_ID;


BEGIN


   INSERT INTO FEM_PARTY_PROFITABILITY(
           PARTY_ID,
           LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   CREATION_DATE,
	   CREATED_BY,
           LAST_UPDATE_LOGIN,
           PROFIT,
           PROFIT_PCT,
           RELATIONSHIP_EXPENSE,
           TOTAL_EQUITY,
           TOTAL_GROSS_CONTRIB,
           TOTAL_ROE,
           CONTRIB_AFTER_CPTL_CHG,
           PARTNER_VALUE_INDEX,
           ISO_CURRENCY_CD,
           REVENUE1,
           REVENUE2,
           REVENUE3,
           REVENUE4,
           REVENUE5,
           REVENUE_TOTAL,
           EXPENSE1,
           EXPENSE2,
           EXPENSE3,
           EXPENSE4,
           EXPENSE5,
           EXPENSE_TOTAL,
           PROFIT1,
           PROFIT2,
           PROFIT3,
           PROFIT4,
           PROFIT5,
           PROFIT_TOTAL,
           CACC1,
           CACC2,
           CACC3,
           CACC4,
           CACC5,
           CACC_TOTAL,
           BALANCE1,
           BALANCE2,
           BALANCE3,
           BALANCE4,
           BALANCE5,
           ACCOUNTS1,
           ACCOUNTS2,
           ACCOUNTS3,
           ACCOUNTS4,
           ACCOUNTS5,
           TRANSACTION1,
           TRANSACTION2,
           TRANSACTION3,
           TRANSACTION4,
           TRANSACTION5,
           RATIO1,
           RATIO2,
           RATIO3,
           RATIO4,
           RATIO5,
           VALUE1,
           VALUE2,
           VALUE3,
           VALUE4,
           VALUE5,
           YTD1,
           YTD2,
           YTD3,
           YTD4,
           YTD5,
           LTD1,
           LTD2,
           LTD3,
           LTD4,
           LTD5
          ) VALUES (
           x_PARTY_ID,
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
	   decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
	   decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
	   decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_PROFIT, FND_API.G_MISS_NUM, NULL,x_PROFIT),
           decode( x_PROFIT_PCT, FND_API.G_MISS_NUM, NULL,x_PROFIT_PCT),
           decode( x_RELATIONSHIP_EXPENSE, FND_API.G_MISS_NUM, NULL,x_RELATIONSHIP_EXPENSE),
           decode( x_TOTAL_EQUITY, FND_API.G_MISS_NUM, NULL,x_TOTAL_EQUITY),
           decode( x_TOTAL_GROSS_CONTRIB, FND_API.G_MISS_NUM, NULL,x_TOTAL_GROSS_CONTRIB),
           decode( x_TOTAL_ROE, FND_API.G_MISS_NUM, NULL,x_TOTAL_ROE),
           decode( x_CONTRIB_AFTER_CPTL_CHG, FND_API.G_MISS_NUM, NULL,x_CONTRIB_AFTER_CPTL_CHG),
           decode( x_PARTNER_VALUE_INDEX, FND_API.G_MISS_NUM, NULL,x_PARTNER_VALUE_INDEX),
           decode( x_ISO_CURRENCY_CD, FND_API.G_MISS_CHAR, NULL, x_ISO_CURRENCY_CD),
           decode( x_REVENUE1, FND_API.G_MISS_NUM, NULL, x_REVENUE1),
           decode( x_REVENUE2, FND_API.G_MISS_NUM, NULL, x_REVENUE2),
           decode( x_REVENUE3, FND_API.G_MISS_NUM, NULL, x_REVENUE3),
           decode( x_REVENUE4, FND_API.G_MISS_NUM, NULL, x_REVENUE4),
           decode( x_REVENUE5, FND_API.G_MISS_NUM, NULL, x_REVENUE5),
           decode( x_REVENUE_TOTAL, FND_API.G_MISS_NUM, NULL, x_REVENUE_TOTAL),
           decode( x_EXPENSE1, FND_API.G_MISS_NUM, NULL, x_EXPENSE1),
           decode( x_EXPENSE2, FND_API.G_MISS_NUM, NULL, x_EXPENSE2),
           decode( x_EXPENSE3, FND_API.G_MISS_NUM, NULL, x_EXPENSE3),
           decode( x_EXPENSE4, FND_API.G_MISS_NUM, NULL, x_EXPENSE4),
           decode( x_EXPENSE5, FND_API.G_MISS_NUM, NULL, x_EXPENSE5),
           decode( x_EXPENSE_TOTAL, FND_API.G_MISS_NUM, NULL, x_EXPENSE_TOTAL),
           decode( x_PROFIT1, FND_API.G_MISS_NUM, NULL, x_PROFIT1),
           decode( x_PROFIT2, FND_API.G_MISS_NUM, NULL, x_PROFIT2),
           decode( x_PROFIT3, FND_API.G_MISS_NUM, NULL, x_PROFIT3),
           decode( x_PROFIT4, FND_API.G_MISS_NUM, NULL, x_PROFIT4),
           decode( x_PROFIT5, FND_API.G_MISS_NUM, NULL, x_PROFIT5),
           decode( x_PROFIT_TOTAL, FND_API.G_MISS_NUM, NULL, x_PROFIT_TOTAL),
           decode( x_CACC1, FND_API.G_MISS_NUM, NULL, x_CACC1),
           decode( x_CACC2, FND_API.G_MISS_NUM, NULL, x_CACC2),
           decode( x_CACC3, FND_API.G_MISS_NUM, NULL, x_CACC3),
           decode( x_CACC4, FND_API.G_MISS_NUM, NULL, x_CACC4),
           decode( x_CACC5, FND_API.G_MISS_NUM, NULL, x_CACC5),
           decode( x_CACC_TOTAL, FND_API.G_MISS_NUM, NULL, x_CACC_TOTAL),
           decode( x_BALANCE1, FND_API.G_MISS_NUM, NULL, x_BALANCE1),
           decode( x_BALANCE2, FND_API.G_MISS_NUM, NULL, x_BALANCE2),
           decode( x_BALANCE3, FND_API.G_MISS_NUM, NULL, x_BALANCE3),
           decode( x_BALANCE4, FND_API.G_MISS_NUM, NULL, x_BALANCE4),
           decode( x_BALANCE5, FND_API.G_MISS_NUM, NULL, x_BALANCE5),
           decode( x_ACCOUNTS1, FND_API.G_MISS_NUM, NULL, x_ACCOUNTS1),
           decode( x_ACCOUNTS2, FND_API.G_MISS_NUM, NULL, x_ACCOUNTS2),
           decode( x_ACCOUNTS3, FND_API.G_MISS_NUM, NULL, x_ACCOUNTS3),
           decode( x_ACCOUNTS4, FND_API.G_MISS_NUM, NULL, x_ACCOUNTS4),
           decode( x_ACCOUNTS5, FND_API.G_MISS_NUM, NULL, x_ACCOUNTS5),
           decode( x_TRANSACTION1, FND_API.G_MISS_NUM, NULL, x_TRANSACTION1),
           decode( x_TRANSACTION2, FND_API.G_MISS_NUM, NULL, x_TRANSACTION2),
           decode( x_TRANSACTION3, FND_API.G_MISS_NUM, NULL, x_TRANSACTION3),
           decode( x_TRANSACTION4, FND_API.G_MISS_NUM, NULL, x_TRANSACTION4),
           decode( x_TRANSACTION5, FND_API.G_MISS_NUM, NULL, x_TRANSACTION5),
           decode( x_RATIO1, FND_API.G_MISS_NUM, NULL, x_RATIO1),
           decode( x_RATIO2, FND_API.G_MISS_NUM, NULL, x_RATIO2),
           decode( x_RATIO3, FND_API.G_MISS_NUM, NULL, x_RATIO3),
           decode( x_RATIO4, FND_API.G_MISS_NUM, NULL, x_RATIO4),
           decode( x_RATIO5, FND_API.G_MISS_NUM, NULL, x_RATIO5),
           decode( x_VALUE1, FND_API.G_MISS_NUM, NULL, x_VALUE1),
           decode( x_VALUE2, FND_API.G_MISS_NUM, NULL, x_VALUE2),
           decode( x_VALUE3, FND_API.G_MISS_NUM, NULL, x_VALUE3),
           decode( x_VALUE4, FND_API.G_MISS_NUM, NULL, x_VALUE4),
           decode( x_VALUE5, FND_API.G_MISS_NUM, NULL, x_VALUE5),
           decode( x_YTD1, FND_API.G_MISS_NUM, NULL, x_YTD1),
           decode( x_YTD2, FND_API.G_MISS_NUM, NULL, x_YTD2),
           decode( x_YTD3, FND_API.G_MISS_NUM, NULL, x_YTD3),
           decode( x_YTD4, FND_API.G_MISS_NUM, NULL, x_YTD4),
           decode( x_YTD5, FND_API.G_MISS_NUM, NULL, x_YTD5),
           decode( x_LTD1, FND_API.G_MISS_NUM, NULL, x_LTD1),
           decode( x_LTD2, FND_API.G_MISS_NUM, NULL, x_LTD2),
           decode( x_LTD3, FND_API.G_MISS_NUM, NULL, x_LTD3),
           decode( x_LTD4, FND_API.G_MISS_NUM, NULL, x_LTD4),
           decode( x_LTD5, FND_API.G_MISS_NUM, NULL, x_LTD5));

   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;

End Insert_Row;



PROCEDURE Delete_Row(
                  x_PARTY_ID                   NUMBER
 ) IS
 BEGIN
   DELETE FROM FEM_PARTY_PROFITABILITY
    WHERE PARTY_ID = x_PARTY_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                         VARCHAR2,
                  x_PARTY_ID                      NUMBER,
		  x_LAST_UPDATE_DATE              DATE,
		  x_LAST_UPDATED_BY               NUMBER,
		  x_CREATION_DATE                 DATE,
		  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_PROFIT                        NUMBER,
                  x_PROFIT_PCT                    NUMBER,
                  x_RELATIONSHIP_EXPENSE          NUMBER,
                  x_TOTAL_EQUITY                  NUMBER,
                  x_TOTAL_GROSS_CONTRIB           NUMBER,
                  x_TOTAL_ROE                     NUMBER,
                  x_CONTRIB_AFTER_CPTL_CHG        NUMBER,
                  x_PARTNER_VALUE_INDEX           NUMBER,
                  x_ISO_CURRENCY_CD               VARCHAR2,
                  x_REVENUE1                      NUMBER,
                  x_REVENUE2                      NUMBER,
                  x_REVENUE3                      NUMBER,
                  x_REVENUE4                      NUMBER,
                  x_REVENUE5                      NUMBER,
                  x_REVENUE_TOTAL                 NUMBER,
                  x_EXPENSE1                      NUMBER,
                  x_EXPENSE2                      NUMBER,
                  x_EXPENSE3                      NUMBER,
                  x_EXPENSE4                      NUMBER,
                  x_EXPENSE5                      NUMBER,
                  x_EXPENSE_TOTAL                 NUMBER,
                  x_PROFIT1                       NUMBER,
                  x_PROFIT2                       NUMBER,
                  x_PROFIT3                       NUMBER,
                  x_PROFIT4                       NUMBER,
                  x_PROFIT5                       NUMBER,
                  x_PROFIT_TOTAL                  NUMBER,
                  x_CACC1                         NUMBER,
                  x_CACC2                         NUMBER,
                  x_CACC3                         NUMBER,
                  x_CACC4                         NUMBER,
                  x_CACC5                         NUMBER,
                  x_CACC_TOTAL                    NUMBER,
                  x_BALANCE1                      NUMBER,
                  x_BALANCE2                      NUMBER,
                  x_BALANCE3                      NUMBER,
                  x_BALANCE4                      NUMBER,
                  x_BALANCE5                      NUMBER,
                  x_ACCOUNTS1                     NUMBER,
                  x_ACCOUNTS2                     NUMBER,
                  x_ACCOUNTS3                     NUMBER,
                  x_ACCOUNTS4                     NUMBER,
                  x_ACCOUNTS5                     NUMBER,
                  x_TRANSACTION1                  NUMBER,
                  x_TRANSACTION2                  NUMBER,
                  x_TRANSACTION3                  NUMBER,
                  x_TRANSACTION4                  NUMBER,
                  x_TRANSACTION5                  NUMBER,
                  x_RATIO1                        NUMBER,
                  x_RATIO2                        NUMBER,
                  x_RATIO3                        NUMBER,
                  x_RATIO4                        NUMBER,
                  x_RATIO5                        NUMBER,
                  x_VALUE1                        NUMBER,
                  x_VALUE2                        NUMBER,
                  x_VALUE3                        NUMBER,
                  x_VALUE4                        NUMBER,
                  x_VALUE5                        NUMBER,
                  x_YTD1                          NUMBER,
                  x_YTD2                          NUMBER,
                  x_YTD3                          NUMBER,
                  x_YTD4                          NUMBER,
                  x_YTD5                          NUMBER,
                  x_LTD1                          NUMBER,
                  x_LTD2                          NUMBER,
                  x_LTD3                          NUMBER,
                  x_LTD4                          NUMBER,
                  x_LTD5                          NUMBER
 ) IS
 BEGIN

    Update FEM_PARTY_PROFITABILITY
    SET
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             PROFIT = decode( x_PROFIT, FND_API.G_MISS_NUM, PROFIT,x_PROFIT),
             PROFIT_PCT = decode( x_PROFIT_PCT, FND_API.G_MISS_NUM, PROFIT_PCT,x_PROFIT_PCT),
             RELATIONSHIP_EXPENSE = decode( x_RELATIONSHIP_EXPENSE, FND_API.G_MISS_NUM, RELATIONSHIP_EXPENSE,x_RELATIONSHIP_EXPENSE),
             TOTAL_EQUITY = decode( x_TOTAL_EQUITY, FND_API.G_MISS_NUM, TOTAL_EQUITY,x_TOTAL_EQUITY),
             TOTAL_GROSS_CONTRIB = decode( x_TOTAL_GROSS_CONTRIB, FND_API.G_MISS_NUM, TOTAL_GROSS_CONTRIB,x_TOTAL_GROSS_CONTRIB),
             TOTAL_ROE = decode( x_TOTAL_ROE, FND_API.G_MISS_NUM, TOTAL_ROE,x_TOTAL_ROE),
             CONTRIB_AFTER_CPTL_CHG = decode( x_CONTRIB_AFTER_CPTL_CHG, FND_API.G_MISS_NUM, CONTRIB_AFTER_CPTL_CHG,x_CONTRIB_AFTER_CPTL_CHG),
             PARTNER_VALUE_INDEX = decode( x_PARTNER_VALUE_INDEX, FND_API.G_MISS_NUM, PARTNER_VALUE_INDEX,x_PARTNER_VALUE_INDEX),
             ISO_CURRENCY_CD = decode( x_ISO_CURRENCY_CD, FND_API.G_MISS_CHAR, ISO_CURRENCY_CD, x_ISO_CURRENCY_CD),
             REVENUE1 = decode( x_REVENUE1, FND_API.G_MISS_NUM, REVENUE1, x_REVENUE1),
             REVENUE2 = decode( x_REVENUE2, FND_API.G_MISS_NUM, REVENUE2, x_REVENUE2),
             REVENUE3 = decode( x_REVENUE3, FND_API.G_MISS_NUM, REVENUE3, x_REVENUE3),
             REVENUE4 = decode( x_REVENUE4, FND_API.G_MISS_NUM, REVENUE4, x_REVENUE4),
             REVENUE5 = decode( x_REVENUE5, FND_API.G_MISS_NUM, REVENUE5, x_REVENUE5),
             REVENUE_TOTAL = decode( x_REVENUE_TOTAL, FND_API.G_MISS_NUM, REVENUE_TOTAL, x_REVENUE_TOTAL),
             EXPENSE1 = decode( x_EXPENSE1, FND_API.G_MISS_NUM, EXPENSE1, x_EXPENSE1),
             EXPENSE2 = decode( x_EXPENSE2, FND_API.G_MISS_NUM, EXPENSE2, x_EXPENSE2),
             EXPENSE3 = decode( x_EXPENSE3, FND_API.G_MISS_NUM, EXPENSE3, x_EXPENSE3),
             EXPENSE4 = decode( x_EXPENSE4, FND_API.G_MISS_NUM, EXPENSE4, x_EXPENSE4),
             EXPENSE5 = decode( x_EXPENSE5, FND_API.G_MISS_NUM, EXPENSE5, x_EXPENSE5),
             EXPENSE_TOTAL = decode( x_EXPENSE_TOTAL, FND_API.G_MISS_NUM, EXPENSE_TOTAL, x_EXPENSE_TOTAL),
             PROFIT1 = decode( x_PROFIT1, FND_API.G_MISS_NUM, PROFIT1, x_PROFIT1),
             PROFIT2 = decode( x_PROFIT2, FND_API.G_MISS_NUM, PROFIT2, x_PROFIT2),
             PROFIT3 = decode( x_PROFIT3, FND_API.G_MISS_NUM, PROFIT3, x_PROFIT3),
             PROFIT4 = decode( x_PROFIT4, FND_API.G_MISS_NUM, PROFIT4, x_PROFIT4),
             PROFIT5 = decode( x_PROFIT5, FND_API.G_MISS_NUM, PROFIT5, x_PROFIT5),
             PROFIT_TOTAL = decode( x_PROFIT_TOTAL, FND_API.G_MISS_NUM, PROFIT_TOTAL, x_PROFIT_TOTAL),
             CACC1 = decode( x_CACC1, FND_API.G_MISS_NUM, CACC1, x_CACC1),
             CACC2 = decode( x_CACC2, FND_API.G_MISS_NUM, CACC2, x_CACC2),
             CACC3 = decode( x_CACC3, FND_API.G_MISS_NUM, CACC3, x_CACC3),
             CACC4 = decode( x_CACC4, FND_API.G_MISS_NUM, CACC4, x_CACC4),
             CACC5 = decode( x_CACC5, FND_API.G_MISS_NUM, CACC5, x_CACC5),
             CACC_TOTAL = decode( x_CACC_TOTAL, FND_API.G_MISS_NUM, CACC_TOTAL, x_CACC_TOTAL),
             BALANCE1 = decode( x_BALANCE1, FND_API.G_MISS_NUM, BALANCE1, x_BALANCE1),
             BALANCE2 = decode( x_BALANCE2, FND_API.G_MISS_NUM, BALANCE2, x_BALANCE2),
             BALANCE3 = decode( x_BALANCE3, FND_API.G_MISS_NUM, BALANCE3, x_BALANCE3),
             BALANCE4 = decode( x_BALANCE4, FND_API.G_MISS_NUM, BALANCE4, x_BALANCE4),
             BALANCE5 = decode( x_BALANCE5, FND_API.G_MISS_NUM, BALANCE5, x_BALANCE5),
             ACCOUNTS1 = decode( x_ACCOUNTS1, FND_API.G_MISS_NUM, ACCOUNTS1, x_ACCOUNTS1),
             ACCOUNTS2 = decode( x_ACCOUNTS2, FND_API.G_MISS_NUM, ACCOUNTS2, x_ACCOUNTS2),
             ACCOUNTS3 = decode( x_ACCOUNTS3, FND_API.G_MISS_NUM, ACCOUNTS3, x_ACCOUNTS3),
             ACCOUNTS4 = decode( x_ACCOUNTS4, FND_API.G_MISS_NUM, ACCOUNTS4, x_ACCOUNTS4),
             ACCOUNTS5 = decode( x_ACCOUNTS5, FND_API.G_MISS_NUM, ACCOUNTS5, x_ACCOUNTS5),
             TRANSACTION1 = decode( x_TRANSACTION1, FND_API.G_MISS_NUM, TRANSACTION1, x_TRANSACTION1),
             TRANSACTION2 = decode( x_TRANSACTION2, FND_API.G_MISS_NUM, TRANSACTION2, x_TRANSACTION2),
             TRANSACTION3 = decode( x_TRANSACTION3, FND_API.G_MISS_NUM, TRANSACTION3, x_TRANSACTION3),
             TRANSACTION4 = decode( x_TRANSACTION4, FND_API.G_MISS_NUM, TRANSACTION4, x_TRANSACTION4),
             TRANSACTION5 = decode( x_TRANSACTION5, FND_API.G_MISS_NUM, TRANSACTION5, x_TRANSACTION5),
             RATIO1 = decode( x_RATIO1, FND_API.G_MISS_NUM, RATIO1, x_RATIO1),
             RATIO2 = decode( x_RATIO2, FND_API.G_MISS_NUM, RATIO2, x_RATIO2),
             RATIO3 = decode( x_RATIO3, FND_API.G_MISS_NUM, RATIO3, x_RATIO3),
             RATIO4 = decode( x_RATIO4, FND_API.G_MISS_NUM, RATIO4, x_RATIO4),
             RATIO5 = decode( x_RATIO5, FND_API.G_MISS_NUM, RATIO5, x_RATIO5),
             VALUE1 = decode( x_VALUE1, FND_API.G_MISS_NUM, VALUE1, x_VALUE1),
             VALUE2 = decode( x_VALUE2, FND_API.G_MISS_NUM, VALUE2, x_VALUE2),
             VALUE3 = decode( x_VALUE3, FND_API.G_MISS_NUM, VALUE3, x_VALUE3),
             VALUE4 = decode( x_VALUE4, FND_API.G_MISS_NUM, VALUE4, x_VALUE4),
             VALUE5 = decode( x_VALUE5, FND_API.G_MISS_NUM, VALUE5, x_VALUE5),
             YTD1 = decode( x_YTD1, FND_API.G_MISS_NUM, YTD1, x_YTD1),
             YTD2 = decode( x_YTD2, FND_API.G_MISS_NUM, YTD2, x_YTD2),
             YTD3 = decode( x_YTD3, FND_API.G_MISS_NUM, YTD3, x_YTD3),
             YTD4 = decode( x_YTD4, FND_API.G_MISS_NUM, YTD4, x_YTD4),
             YTD5 = decode( x_YTD5, FND_API.G_MISS_NUM, YTD5, x_YTD5),
             LTD1 = decode( x_LTD1, FND_API.G_MISS_NUM, LTD1, x_LTD1),
             LTD2 = decode( x_LTD2, FND_API.G_MISS_NUM, LTD2, x_LTD2),
             LTD3 = decode( x_LTD3, FND_API.G_MISS_NUM, LTD3, x_LTD3),
             LTD4 = decode( x_LTD4, FND_API.G_MISS_NUM, LTD4, x_LTD4),
             LTD5 = decode( x_LTD5, FND_API.G_MISS_NUM, LTD5, x_LTD5)
     where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_PARTY_ID                      NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
		  x_LAST_UPDATED_BY               NUMBER,
		  x_CREATION_DATE                 DATE,
		  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_PROFIT                        NUMBER,
                  x_PROFIT_PCT                    NUMBER,
                  x_RELATIONSHIP_EXPENSE          NUMBER,
                  x_TOTAL_EQUITY                  NUMBER,
                  x_TOTAL_GROSS_CONTRIB           NUMBER,
                  x_TOTAL_ROE                     NUMBER,
                  x_CONTRIB_AFTER_CPTL_CHG        NUMBER,
                  x_PARTNER_VALUE_INDEX           NUMBER,
                  x_ISO_CURRENCY_CD               VARCHAR2,
                  x_REVENUE1                      NUMBER,
                  x_REVENUE2                      NUMBER,
                  x_REVENUE3                      NUMBER,
                  x_REVENUE4                      NUMBER,
                  x_REVENUE5                      NUMBER,
                  x_REVENUE_TOTAL                 NUMBER,
                  x_EXPENSE1                      NUMBER,
                  x_EXPENSE2                      NUMBER,
                  x_EXPENSE3                      NUMBER,
                  x_EXPENSE4                      NUMBER,
                  x_EXPENSE5                      NUMBER,
                  x_EXPENSE_TOTAL                 NUMBER,
                  x_PROFIT1                       NUMBER,
                  x_PROFIT2                       NUMBER,
                  x_PROFIT3                       NUMBER,
                  x_PROFIT4                       NUMBER,
                  x_PROFIT5                       NUMBER,
                  x_PROFIT_TOTAL                  NUMBER,
                  x_CACC1                         NUMBER,
                  x_CACC2                         NUMBER,
                  x_CACC3                         NUMBER,
                  x_CACC4                         NUMBER,
                  x_CACC5                         NUMBER,
                  x_CACC_TOTAL                    NUMBER,
                  x_BALANCE1                      NUMBER,
                  x_BALANCE2                      NUMBER,
                  x_BALANCE3                      NUMBER,
                  x_BALANCE4                      NUMBER,
                  x_BALANCE5                      NUMBER,
                  x_ACCOUNTS1                     NUMBER,
                  x_ACCOUNTS2                     NUMBER,
                  x_ACCOUNTS3                     NUMBER,
                  x_ACCOUNTS4                     NUMBER,
                  x_ACCOUNTS5                     NUMBER,
                  x_TRANSACTION1                  NUMBER,
                  x_TRANSACTION2                  NUMBER,
                  x_TRANSACTION3                  NUMBER,
                  x_TRANSACTION4                  NUMBER,
                  x_TRANSACTION5                  NUMBER,
                  x_RATIO1                        NUMBER,
                  x_RATIO2                        NUMBER,
                  x_RATIO3                        NUMBER,
                  x_RATIO4                        NUMBER,
                  x_RATIO5                        NUMBER,
                  x_VALUE1                        NUMBER,
                  x_VALUE2                        NUMBER,
                  x_VALUE3                        NUMBER,
                  x_VALUE4                        NUMBER,
                  x_VALUE5                        NUMBER,
                  x_YTD1                          NUMBER,
                  x_YTD2                          NUMBER,
                  x_YTD3                          NUMBER,
                  x_YTD4                          NUMBER,
                  x_YTD5                          NUMBER,
                  x_LTD1                          NUMBER,
                  x_LTD2                          NUMBER,
                  x_LTD3                          NUMBER,
                  x_LTD4                          NUMBER,
                  x_LTD5                          NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM FEM_PARTY_PROFITABILITY
         WHERE rowid = x_Rowid
         FOR UPDATE of PARTY_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (    ( Recinfo.PARTY_ID = x_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID = NULL )
                AND (  x_PARTY_ID = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE = NULL )
                AND (  x_LAST_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY = NULL )
                AND (  x_LAST_UPDATED_BY = NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE = NULL )
                AND (  x_CREATION_DATE = NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY = NULL )
                AND (  x_CREATED_BY = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN = NULL )
                AND (  x_LAST_UPDATE_LOGIN = NULL )))
       AND (    ( Recinfo.PROFIT = x_PROFIT)
            OR (    ( Recinfo.PROFIT = NULL )
                AND (  x_PROFIT = NULL )))
       AND (    ( Recinfo.PROFIT_PCT = x_PROFIT_PCT)
            OR (    ( Recinfo.PROFIT_PCT = NULL )
                AND (  x_PROFIT_PCT = NULL )))
       AND (    ( Recinfo.RELATIONSHIP_EXPENSE = x_RELATIONSHIP_EXPENSE)
            OR (    ( Recinfo.RELATIONSHIP_EXPENSE = NULL )
                AND (  x_RELATIONSHIP_EXPENSE = NULL )))
       AND (    ( Recinfo.TOTAL_EQUITY = x_TOTAL_EQUITY)
            OR (    ( Recinfo.TOTAL_EQUITY = NULL )
                AND (  x_TOTAL_EQUITY = NULL )))
       AND (    ( Recinfo.TOTAL_GROSS_CONTRIB = x_TOTAL_GROSS_CONTRIB)
            OR (    ( Recinfo.TOTAL_GROSS_CONTRIB = NULL )
                AND (  x_TOTAL_GROSS_CONTRIB = NULL )))
       AND (    ( Recinfo.TOTAL_ROE = x_TOTAL_ROE)
            OR (    ( Recinfo.TOTAL_ROE = NULL )
                AND (  x_TOTAL_ROE = NULL )))
       AND (    ( Recinfo.CONTRIB_AFTER_CPTL_CHG = x_CONTRIB_AFTER_CPTL_CHG)
            OR (    ( Recinfo.CONTRIB_AFTER_CPTL_CHG = NULL )
                AND (  x_CONTRIB_AFTER_CPTL_CHG = NULL )))
       AND (    ( Recinfo.PARTNER_VALUE_INDEX = x_PARTNER_VALUE_INDEX)
            OR (    ( Recinfo.PARTNER_VALUE_INDEX = NULL )
                AND (  x_PARTNER_VALUE_INDEX = NULL )))
       AND (   (  Recinfo.ISO_CURRENCY_CD = x_ISO_CURRENCY_CD)
            OR (    ( Recinfo.ISO_CURRENCY_CD = NULL )
                AND (  x_ISO_CURRENCY_CD = NULL )))
       AND (    ( Recinfo.REVENUE1 = x_REVENUE1)
            OR (    ( Recinfo.REVENUE1 = NULL )
                AND (  x_REVENUE1 = NULL )))
       AND (    ( Recinfo.REVENUE2 = x_REVENUE2)
            OR (    ( Recinfo.REVENUE2 = NULL )
                AND (  x_REVENUE2 = NULL )))
       AND (    ( Recinfo.REVENUE3 = x_REVENUE3)
            OR (    ( Recinfo.REVENUE3 = NULL )
                AND (  x_REVENUE3 = NULL )))
       AND (    ( Recinfo.REVENUE4 = x_REVENUE4)
            OR (    ( Recinfo.REVENUE4 = NULL )
                AND (  x_REVENUE4 = NULL )))
       AND (    ( Recinfo.REVENUE5 = x_REVENUE5)
            OR (    ( Recinfo.REVENUE5 = NULL )
                AND (  x_REVENUE5 = NULL )))
       AND (    ( Recinfo.REVENUE_TOTAL = x_REVENUE_TOTAL)
            OR (    ( Recinfo.REVENUE_TOTAL = NULL )
                AND (  x_REVENUE_TOTAL = NULL )))
       AND (    ( Recinfo.EXPENSE1 = x_EXPENSE1)
            OR (    ( Recinfo.EXPENSE1 = NULL )
                AND (  x_EXPENSE1 = NULL )))
       AND (    ( Recinfo.EXPENSE2 = x_EXPENSE2)
            OR (    ( Recinfo.EXPENSE2 = NULL )
                AND (  x_EXPENSE2 = NULL )))
       AND (    ( Recinfo.EXPENSE3 = x_EXPENSE3)
            OR (    ( Recinfo.EXPENSE3 = NULL )
                AND (  x_EXPENSE3 = NULL )))
       AND (    ( Recinfo.EXPENSE4 = x_EXPENSE4)
            OR (    ( Recinfo.EXPENSE4 = NULL )
                AND (  x_EXPENSE4 = NULL )))
       AND (    ( Recinfo.EXPENSE5 = x_EXPENSE5)
            OR (    ( Recinfo.EXPENSE5 = NULL )
                AND (  x_EXPENSE5 = NULL )))
       AND (    ( Recinfo.EXPENSE_TOTAL = x_EXPENSE_TOTAL)
            OR (    ( Recinfo.EXPENSE_TOTAL = NULL )
                AND (  x_EXPENSE_TOTAL = NULL )))
       AND (    ( Recinfo.PROFIT1 = x_PROFIT1)
            OR (    ( Recinfo.PROFIT1 = NULL )
                AND (  x_PROFIT1 = NULL )))
       AND (    ( Recinfo.PROFIT2 = x_PROFIT2)
            OR (    ( Recinfo.PROFIT2 = NULL )
                AND (  x_PROFIT2 = NULL )))
       AND (    ( Recinfo.PROFIT3 = x_PROFIT3)
            OR (    ( Recinfo.PROFIT3 = NULL )
                AND (  x_PROFIT3 = NULL )))
       AND (    ( Recinfo.PROFIT4 = x_PROFIT4)
            OR (    ( Recinfo.PROFIT4 = NULL )
                AND (  x_PROFIT4 = NULL )))
       AND (    ( Recinfo.PROFIT5 = x_PROFIT5)
            OR (    ( Recinfo.PROFIT5 = NULL )
                AND (  x_PROFIT5 = NULL )))
       AND (    ( Recinfo.PROFIT_TOTAL = x_PROFIT_TOTAL)
            OR (    ( Recinfo.PROFIT_TOTAL = NULL )
                AND (  x_PROFIT_TOTAL = NULL )))
       AND (    ( Recinfo.CACC1 = x_CACC1)
            OR (    ( Recinfo.CACC1 = NULL )
                AND (  x_CACC1 = NULL )))
       AND (    ( Recinfo.CACC2 = x_CACC2)
            OR (    ( Recinfo.CACC2 = NULL )
                AND (  x_CACC2 = NULL )))
       AND (    ( Recinfo.CACC3 = x_CACC3)
            OR (    ( Recinfo.CACC3 = NULL )
                AND (  x_CACC3 = NULL )))
       AND (    ( Recinfo.CACC4 = x_CACC4)
            OR (    ( Recinfo.CACC4 = NULL )
                AND (  x_CACC4 = NULL )))
       AND (    ( Recinfo.CACC5 = x_CACC5)
            OR (    ( Recinfo.CACC5 = NULL )
                AND (  x_CACC5 = NULL )))
       AND (    ( Recinfo.CACC_TOTAL = x_CACC_TOTAL)
            OR (    ( Recinfo.CACC_TOTAL = NULL )
                AND (  x_CACC_TOTAL = NULL )))
       AND (    ( Recinfo.BALANCE1 = x_BALANCE1)
            OR (    ( Recinfo.BALANCE1 = NULL )
                AND (  x_BALANCE1 = NULL )))
       AND (    ( Recinfo.BALANCE2 = x_BALANCE2)
            OR (    ( Recinfo.BALANCE2 = NULL )
                AND (  x_BALANCE2 = NULL )))
       AND (    ( Recinfo.BALANCE3 = x_BALANCE3)
            OR (    ( Recinfo.BALANCE3 = NULL )
                AND (  x_BALANCE3 = NULL )))
       AND (    ( Recinfo.BALANCE4 = x_BALANCE4)
            OR (    ( Recinfo.BALANCE4 = NULL )
                AND (  x_BALANCE4 = NULL )))
       AND (    ( Recinfo.BALANCE5 = x_BALANCE5)
            OR (    ( Recinfo.BALANCE5 = NULL )
                AND (  x_BALANCE5 = NULL )))
       AND (    ( Recinfo.ACCOUNTS1 = x_ACCOUNTS1)
            OR (    ( Recinfo.ACCOUNTS1 = NULL )
                AND (  x_ACCOUNTS1 = NULL )))
       AND (    ( Recinfo.ACCOUNTS2 = x_ACCOUNTS2)
            OR (    ( Recinfo.ACCOUNTS2 = NULL )
                AND (  x_ACCOUNTS2 = NULL )))
       AND (    ( Recinfo.ACCOUNTS3 = x_ACCOUNTS3)
            OR (    ( Recinfo.ACCOUNTS3 = NULL )
                AND (  x_ACCOUNTS3 = NULL )))
       AND (    ( Recinfo.ACCOUNTS4 = x_ACCOUNTS4)
            OR (    ( Recinfo.ACCOUNTS4 = NULL )
                AND (  x_ACCOUNTS4 = NULL )))
       AND (    ( Recinfo.ACCOUNTS5 = x_ACCOUNTS5)
            OR (    ( Recinfo.ACCOUNTS5 = NULL )
                AND (  x_ACCOUNTS5 = NULL )))
       AND (    ( Recinfo.TRANSACTION1 = x_TRANSACTION1)
            OR (    ( Recinfo.TRANSACTION1 = NULL )
                AND (  x_TRANSACTION1 = NULL )))
       AND (    ( Recinfo.TRANSACTION2 = x_TRANSACTION2)
            OR (    ( Recinfo.TRANSACTION2 = NULL )
                AND (  x_TRANSACTION2 = NULL )))
       AND (    ( Recinfo.TRANSACTION3 = x_TRANSACTION3)
            OR (    ( Recinfo.TRANSACTION3 = NULL )
                AND (  x_TRANSACTION3 = NULL )))
       AND (    ( Recinfo.TRANSACTION4 = x_TRANSACTION4)
            OR (    ( Recinfo.TRANSACTION4 = NULL )
                AND (  x_TRANSACTION4 = NULL )))
       AND (    ( Recinfo.TRANSACTION5 = x_TRANSACTION5)
            OR (    ( Recinfo.TRANSACTION5 = NULL )
                AND (  x_TRANSACTION5 = NULL )))
       AND (    ( Recinfo.RATIO1 = x_RATIO1)
            OR (    ( Recinfo.RATIO1 = NULL )
                AND (  x_RATIO1 = NULL )))
       AND (    ( Recinfo.RATIO2 = x_RATIO2)
            OR (    ( Recinfo.RATIO2 = NULL )
                AND (  x_RATIO2 = NULL )))
       AND (    ( Recinfo.RATIO3 = x_RATIO3)
            OR (    ( Recinfo.RATIO3 = NULL )
                AND (  x_RATIO3 = NULL )))
       AND (    ( Recinfo.RATIO4 = x_RATIO4)
            OR (    ( Recinfo.RATIO4 = NULL )
                AND (  x_RATIO4 = NULL )))
       AND (    ( Recinfo.RATIO5 = x_RATIO5)
            OR (    ( Recinfo.RATIO5 = NULL )
                AND (  x_RATIO5 = NULL )))
       AND (    ( Recinfo.VALUE1 = x_VALUE1)
            OR (    ( Recinfo.VALUE1 = NULL )
                AND (  x_VALUE1 = NULL )))
       AND (    ( Recinfo.VALUE2 = x_VALUE2)
            OR (    ( Recinfo.VALUE2 = NULL )
                AND (  x_VALUE2 = NULL )))
       AND (    ( Recinfo.VALUE3 = x_VALUE3)
            OR (    ( Recinfo.VALUE3 = NULL )
                AND (  x_VALUE3 = NULL )))
       AND (    ( Recinfo.VALUE4 = x_VALUE4)
            OR (    ( Recinfo.VALUE4 = NULL )
                AND (  x_VALUE4 = NULL )))
       AND (    ( Recinfo.VALUE5 = x_VALUE5)
            OR (    ( Recinfo.VALUE5 = NULL )
                AND (  x_VALUE5 = NULL )))
       AND (    ( Recinfo.YTD1 = x_YTD1)
            OR (    ( Recinfo.YTD1 = NULL )
                AND (  x_YTD1 = NULL )))
       AND (    ( Recinfo.YTD2 = x_YTD2)
            OR (    ( Recinfo.YTD2 = NULL )
                AND (  x_YTD2 = NULL )))
       AND (    ( Recinfo.YTD3 = x_YTD3)
            OR (    ( Recinfo.YTD3 = NULL )
                AND (  x_YTD3 = NULL )))
       AND (    ( Recinfo.YTD4 = x_YTD4)
            OR (    ( Recinfo.YTD4 = NULL )
                AND (  x_YTD4 = NULL )))
       AND (    ( Recinfo.YTD5 = x_YTD5)
            OR (    ( Recinfo.YTD5 = NULL )
                AND (  x_YTD5 = NULL )))
       AND (    ( Recinfo.LTD1 = x_LTD1)
            OR (    ( Recinfo.LTD1 = NULL )
                AND (  x_LTD1 = NULL )))
       AND (    ( Recinfo.LTD2 = x_LTD2)
            OR (    ( Recinfo.LTD2 = NULL )
                AND (  x_LTD2 = NULL )))
       AND (    ( Recinfo.LTD3 = x_LTD3)
            OR (    ( Recinfo.LTD3 = NULL )
                AND (  x_LTD3 = NULL )))
       AND (    ( Recinfo.LTD4 = x_LTD4)
            OR (    ( Recinfo.LTD4 = NULL )
                AND (  x_LTD4 = NULL )))
       AND (    ( Recinfo.LTD5 = x_LTD5)
            OR (    ( Recinfo.LTD5 = NULL )
                AND (  x_LTD5 = NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END FEM_PARTY_PROFITABILITY_PKG;

/
