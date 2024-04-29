--------------------------------------------------------
--  DDL for Package Body AS_FORECAST_ACTUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_FORECAST_ACTUAL_PKG" AS
/* $Header: asxtfab.pls 115.32 2003/01/13 21:55:19 geliu ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_FORECAST_ACTUAL_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxtfab.pls';
g_line_error NUMBER := 0;
g_next_line  VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(10);/*for chr='\n'*/
g_temp_blob  BLOB;

PROCEDURE Insert_Row(
          p_SALESFORCE_ID in  NUMBER,
          p_SALES_GROUP_ID in NUMBER,
          p_PERIOD_NAME  in  VARCHAR2,
          p_CURRENCY_CODE in VARCHAR2,
          p_ALLOCATED_BUDGET_AMOUNT in NUMBER,
          p_ACTUAL_REVENUE_AMOUNT in  NUMBER,
          p_CREATED_BY in NUMBER,
          p_CREATION_DATE in  DATE,
          p_LAST_UPDATED_BY in NUMBER,
          p_LAST_UPDATE_DATE  in DATE,
          p_LAST_UPDATE_LOGIN in NUMBER,
          p_REQUEST_ID in   NUMBER,
          p_PROGRAM_APPLICATION_ID in NUMBER,
          p_PROGRAM_ID in  NUMBER,
          p_PROGRAM_UPDATE_DATE in  DATE,
          p_SECURITY_GROUP_ID in  NUMBER,
          p_forecast_category_id in  NUMBER,
          p_credit_type_id in  NUMBER)
 IS
BEGIN
   INSERT INTO AS_FORECAST_ACTUALS(
           FORECAST_ACTUAL_ID,
           SALESFORCE_ID,
           SALES_GROUP_ID,
           PERIOD_NAME,
           CURRENCY_CODE,
           ALLOCATED_BUDGET_AMOUNT,
           ACTUAL_REVENUE_AMOUNT,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           FORECAST_CATEGORY_ID,
           FORECAST_CREDIT_TYPE_ID
          ) VALUES (
           AS_FORECAST_ACTUALS_S.NEXTVAL,
           decode( p_SALESFORCE_ID, FND_API.G_MISS_NUM, NULL, 0, NULL, p_SALESFORCE_ID),
           decode( p_SALES_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_SALES_GROUP_ID),
           decode( p_PERIOD_NAME, FND_API.G_MISS_CHAR, NULL, p_PERIOD_NAME),
           decode( p_CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL, p_CURRENCY_CODE),
           round(decode( p_ALLOCATED_BUDGET_AMOUNT, FND_API.G_MISS_NUM, 0, NULL, 0, p_ALLOCATED_BUDGET_AMOUNT),4),
           round(decode( p_ACTUAL_REVENUE_AMOUNT, FND_API.G_MISS_NUM, 0, NULL, 0, p_ACTUAL_REVENUE_AMOUNT),4),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, -1, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, SYSDATE, p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, -1, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, SYSDATE, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, -1, p_LAST_UPDATE_LOGIN),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_PROGRAM_UPDATE_DATE),
           decode( p_forecast_category_id, FND_API.G_MISS_NUM, NULL,p_forecast_category_id),
           decode( p_credit_type_id, FND_API.G_MISS_NUM, NULL,p_credit_type_id));
/*           decode( p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_SECURITY_GROUP_ID));--bug#1799322*/
End Insert_Row;

PROCEDURE Update_Row(
          p_FORECAST_ACTUAL_ID in   NUMBER,
          p_CURRENCY_CODE in   VARCHAR2,
          p_ALLOCATED_BUDGET_AMOUNT in   NUMBER,
          p_ACTUAL_REVENUE_AMOUNT in   NUMBER,
          p_LAST_UPDATED_BY in   NUMBER,
          p_LAST_UPDATE_DATE  in  DATE,
          p_LAST_UPDATE_LOGIN in   NUMBER,
          p_REQUEST_ID in   NUMBER,
          p_PROGRAM_APPLICATION_ID in    NUMBER,
          p_PROGRAM_ID in   NUMBER,
          p_PROGRAM_UPDATE_DATE in    DATE,
          p_SECURITY_GROUP_ID in  NUMBER
          )
 IS
 BEGIN
 Update AS_FORECAST_ACTUALS
    SET
              CURRENCY_CODE = decode( p_CURRENCY_CODE, FND_API.G_MISS_CHAR, CURRENCY_CODE, p_CURRENCY_CODE),
              ALLOCATED_BUDGET_AMOUNT = round(decode( p_ALLOCATED_BUDGET_AMOUNT, FND_API.G_MISS_NUM, ALLOCATED_BUDGET_AMOUNT, NULL, 0, p_ALLOCATED_BUDGET_AMOUNT),4),
              ACTUAL_REVENUE_AMOUNT = round(decode( p_ACTUAL_REVENUE_AMOUNT, FND_API.G_MISS_NUM, ACTUAL_REVENUE_AMOUNT, NULL, 0, p_ACTUAL_REVENUE_AMOUNT),4),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, SYSDATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID)
    where FORECAST_ACTUAL_ID = p_FORECAST_ACTUAL_ID;

  /* SECURITY_GROUP_ID = decode( p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, SECURITY_GROUP_ID, p_SECURITY_GROUP_ID)--bug#1799322*/

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_FORECAST_ACTUAL_ID in NUMBER)
 IS
 BEGIN
   DELETE FROM AS_FORECAST_ACTUALS
    WHERE FORECAST_ACTUAL_ID = p_FORECAST_ACTUAL_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_FORECAST_ACTUAL_ID in   NUMBER,
          p_SALESFORCE_ID in    NUMBER,
          p_SALES_GROUP_ID in   NUMBER,
          p_PERIOD_NAME in   VARCHAR2,
          p_CURRENCY_CODE in   VARCHAR2,
          p_ALLOCATED_BUDGET_AMOUNT in   NUMBER,
          p_ACTUAL_REVENUE_AMOUNT in   NUMBER,
          p_CREATED_BY in    NUMBER,
          p_CREATION_DATE in    DATE,
          p_LAST_UPDATED_BY in   NUMBER,
          p_LAST_UPDATE_DATE  in  DATE,
          p_LAST_UPDATE_LOGIN in   NUMBER,
          p_REQUEST_ID in   NUMBER,
          p_PROGRAM_APPLICATION_ID in    NUMBER,
          p_PROGRAM_ID in   NUMBER,
          p_PROGRAM_UPDATE_DATE in    DATE,
          p_SECURITY_GROUP_ID in  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM AS_FORECAST_ACTUALS
        WHERE FORECAST_ACTUAL_ID =  p_FORECAST_ACTUAL_ID
        FOR UPDATE of FORECAST_ACTUAL_ID NOWAIT;
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
           (      Recinfo.FORECAST_ACTUAL_ID = p_FORECAST_ACTUAL_ID)
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = p_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  p_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
                AND (  p_PROGRAM_APPLICATION_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_ID = p_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID IS NULL )
                AND (  p_PROGRAM_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
                AND (  p_PROGRAM_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.SALESFORCE_ID = p_SALESFORCE_ID)
            OR (    ( Recinfo.SALESFORCE_ID IS NULL )
                AND (  p_SALESFORCE_ID IS NULL )))
       AND (    ( Recinfo.SALES_GROUP_ID = p_SALES_GROUP_ID)
            OR (    ( Recinfo.SALES_GROUP_ID IS NULL )
                AND (  p_SALES_GROUP_ID IS NULL )))
       AND (    ( Recinfo.PERIOD_NAME = p_PERIOD_NAME)
            OR (    ( Recinfo.PERIOD_NAME IS NULL )
                AND (  p_PERIOD_NAME IS NULL )))
       AND (    ( Recinfo.CURRENCY_CODE = p_CURRENCY_CODE)
            OR (    ( Recinfo.CURRENCY_CODE IS NULL )
                AND (  p_CURRENCY_CODE IS NULL )))
       AND (    ( Recinfo.ALLOCATED_BUDGET_AMOUNT = p_ALLOCATED_BUDGET_AMOUNT)
            OR (    ( Recinfo.ALLOCATED_BUDGET_AMOUNT IS NULL )
                AND (  p_ALLOCATED_BUDGET_AMOUNT IS NULL )))
       AND (    ( Recinfo.ACTUAL_REVENUE_AMOUNT = p_ACTUAL_REVENUE_AMOUNT)
            OR (    ( Recinfo.ACTUAL_REVENUE_AMOUNT IS NULL )
                AND (  p_ACTUAL_REVENUE_AMOUNT IS NULL )))
       AND (    ( Recinfo.SECURITY_GROUP_ID = p_SECURITY_GROUP_ID)
            OR (    ( Recinfo.SECURITY_GROUP_ID IS NULL )
                AND (  p_SECURITY_GROUP_ID IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

PROCEDURE Upload_Data(
          p_period_set_name         IN VARCHAR2,
          p_line_number             IN NUMBER,
          p_SALESFORCE_NUMBER       IN NUMBER,
          p_SALES_GROUP_NUMBER      IN NUMBER,
          p_PERIOD_NAME             IN VARCHAR2,
          p_CURRENCY_CODE           IN VARCHAR2,
          p_ALLOCATED_BUDGET_AMOUNT IN NUMBER,
          p_ACTUAL_REVENUE_AMOUNT   IN NUMBER,
          p_CREATED_BY              IN NUMBER,
          p_CREATION_DATE           IN DATE,
          p_LAST_UPDATED_BY         IN NUMBER,
          p_LAST_UPDATE_DATE        IN DATE,
          p_LAST_UPDATE_LOGIN       IN NUMBER,
          p_REQUEST_ID              IN NUMBER,
          p_PROGRAM_APPLICATION_ID  IN NUMBER,
          p_PROGRAM_ID              IN NUMBER,
          p_PROGRAM_UPDATE_DATE     IN DATE,
          p_SECURITY_GROUP_ID       IN NUMBER,
          p_filehandle              IN UTL_FILE.FILE_TYPE,
          p_forecast_category_name  IN VARCHAR2,
          p_credit_type_name        IN VARCHAR2)

 IS
 -- Define the local variables
    l_forecast_actual_id  NUMBER  := 0;
    l_errcnt              NUMBER := 0; -- number of errors in this row
    l_errflag             BOOLEAN := FALSE;
    l_salesforce_id       NUMBER;
    l_sales_group_id      NUMBER;
    l_forecast_category_id NUMBER;
    l_credit_type_id      NUMBER;
    l_log_file            VARCHAR2(60);
    l_filepath            VARCHAR2(60) := '';  -- check utl_file dir
    l_log_msg             VARCHAR2(255):= '';
    l_header              VARCHAR2(100):='';
    l_period_start_date   DATE;
    l_period_end_date     DATE;

BEGIN
   -- Validate period name
   BEGIN
    Chk_Valid_PeriodName(
       p_period_name => p_period_name
     , p_period_set_name => p_period_set_name
     , p_filehandle => p_filehandle
     , x_period_flag => l_errflag
     , x_start_date => l_period_start_date
     , x_end_date   => l_period_end_date );

    IF NOT l_errflag THEN
       l_errcnt := l_errcnt + 1;
       fnd_message.set_name('ASF','ASF_FRCSTACT_LOG_PERIOD');
       fnd_message.set_token('PERIOD_NAME',p_period_name);
       l_log_msg := l_log_msg || fnd_message.get ;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
           APP_EXCEPTION.RAISE_EXCEPTION;
   END;

   -- Validate Forecast Category
   BEGIN
     Get_ForecastCategoryId (
       p_name => UPPER(p_forecast_category_name)
     , p_filehandle => p_filehandle
     , p_start_date => l_period_start_date
     , p_end_date   => l_period_end_date
     , x_forecast_category_id => l_forecast_category_id ) ;

    IF NVL(l_forecast_category_id,0) = 0 THEN
       l_errcnt := l_errcnt + 1;
       fnd_message.set_name('ASF','ASF_FRCSTACT_LOG_FRCSTCAT');
       fnd_message.set_token('FORECASTCATEGORY',p_forecast_category_name);
       l_log_msg := l_log_msg || fnd_message.get ;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
           APP_EXCEPTION.RAISE_EXCEPTION;
   END;

   -- Validate Credit Type
   BEGIN
    Get_CreditTypeId(
       p_name => UPPER(p_credit_type_name)
     , p_filehandle => p_filehandle
     , x_credit_type_id => l_credit_type_id );

    IF NVL(l_credit_type_id,0) = 0 THEN
       l_errcnt := l_errcnt + 1;
       fnd_message.set_name('ASF','ASF_FRCSTACT_LOG_CREDITTYPE');
       fnd_message.set_token('CREDITTYPE',p_credit_type_name);
       l_log_msg := l_log_msg || fnd_message.get ;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
           APP_EXCEPTION.RAISE_EXCEPTION;
   END;

   -- Validate Sales group
   BEGIN
     Get_SalesGroupId (
        p_sales_group_number => p_sales_group_number
      , p_filehandle => p_filehandle
      , p_start_date => l_period_start_date
      , p_end_date   => l_period_end_date
      , x_sales_group_id => l_sales_group_id
      ) ;

     IF NVL(l_sales_group_id,0) = 0 THEN
       l_errcnt := l_errcnt + 1;
       fnd_message.set_name('ASF','ASF_FRCSTACT_LOG_SLSGRP');
       fnd_message.set_token('SALESGROUP',p_sales_group_number);
       l_log_msg := l_log_msg || fnd_message.get ;
     END IF;

     EXCEPTION
        WHEN OTHERS THEN
           APP_EXCEPTION.RAISE_EXCEPTION;
   END;  -- sales group id

   -- Validate Salesforce
   BEGIN
     IF NVL(p_salesforce_number, 0) = 0 THEN  -- valid
        l_salesforce_id := NULL;
     ELSE
       IF NVL(l_sales_group_id,0) <> 0 THEN  -- cannot validate without sales group
        Get_SalesForceId (
           p_salesforce_number => p_salesforce_number
         , p_filehandle => p_filehandle
         , p_start_date => l_period_start_date
         , p_end_date   => l_period_end_date
         , p_sales_group_id => l_sales_group_id
         , x_salesforce_id  => l_salesforce_id
        ) ;

       IF NVL(l_salesforce_id,0) = 0 THEN
         l_errcnt := l_errcnt + 1;
         fnd_message.set_name('ASF','ASF_FRCSTACT_LOG_SLSPERSON');
         fnd_message.set_token('SALESPERSON',p_salesforce_number);
         l_log_msg := l_log_msg || fnd_message.get ;
       END IF;
      END IF;  -- sales group
     END IF;
     EXCEPTION
        WHEN OTHERS THEN
          APP_EXCEPTION.RAISE_EXCEPTION;
   END;  -- sales force

   -- Validate currency
   BEGIN
    Chk_Valid_Currency(
       p_currency_code => p_currency_code
     , p_filehandle => p_filehandle
     , x_currency_flag => l_errflag);

    IF NOT l_errflag THEN
       l_errcnt := l_errcnt + 1;
       fnd_message.set_name('ASF','ASF_FRCSTACT_LOG_CURR');
       fnd_message.set_token('CURRENCY',p_currency_code);
       l_log_msg := l_log_msg || fnd_message.get ;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
           APP_EXCEPTION.RAISE_EXCEPTION;
   END;


   -- All validations done. No errors in this row, all ID's valid. Process row.
   IF l_errcnt=0 THEN
   -- Retrieve forecast_actual_id for a unique combination of this record
     BEGIN
      IF l_salesforce_id IS NOT NULL THEN
        SELECT forecast_actual_id
        INTO l_forecast_actual_id
        FROM   AS_FORECAST_ACTUALS
        WHERE SALESFORCE_ID = l_salesforce_id
          AND SALES_GROUP_ID = l_sales_group_id
          AND FORECAST_CATEGORY_ID = l_forecast_category_id
          AND FORECAST_CREDIT_TYPE_ID = l_credit_type_id
          AND PERIOD_NAME =  p_period_name;
      ELSE
        SELECT forecast_actual_id
        INTO l_forecast_actual_id
        FROM   AS_FORECAST_ACTUALS
        WHERE SALES_GROUP_ID = l_sales_group_id
          AND FORECAST_CATEGORY_ID = l_forecast_category_id
          AND FORECAST_CREDIT_TYPE_ID = l_credit_type_id
          AND PERIOD_NAME =  p_period_name
          AND SALESFORCE_ID IS NULL;
      END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN OTHERS THEN
           APP_EXCEPTION.RAISE_EXCEPTION;
     END;

     IF NVL(l_forecast_actual_id,0) = 0 THEN
       INSERT_ROW(
         l_salesforce_id
       , l_sales_group_id
       , p_period_name
       , p_currency_code
       , p_allocated_budget_amount
       , p_actual_revenue_amount
       , p_created_by
       , SYSDATE
       , p_last_updated_by
       , SYSDATE
       , p_last_update_login
       , p_request_id
       , p_program_application_id
       , p_program_id
       , SYSDATE
       , p_security_group_id
       , l_forecast_category_id
       , l_credit_type_id);

     ELSE  -- update existing row
       UPDATE_ROW(
         l_forecast_actual_id
       , p_currency_code
       , p_allocated_budget_amount
       , p_actual_revenue_amount
       , p_last_updated_by
       , SYSDATE
       , p_last_update_login
       , p_request_id
       , p_program_application_id
       , p_program_id
       , SYSDATE
       , p_security_group_id);

      END IF;  -- if forecast actual ID is obtained

   ELSE  -- error in validating IDs
       fnd_message.set_name('ASF','ASF_FRCSTACT_LOG_LINE');
       fnd_message.set_token('LINE',p_line_number);
       l_log_msg := fnd_message.get||l_log_msg;
       UTL_FILE.PUT_LINE(p_filehandle, l_log_msg) ;
       l_log_msg := l_log_msg;
       create_loglob(l_log_msg
                   ,null
                   ,'W'
                   ,FALSE);
       g_line_error := g_line_error + 1;
   END IF;  -- no errors in this row, all ID's valid

   EXCEPTION
     WHEN OTHERS THEN
       APP_EXCEPTION.RAISE_EXCEPTION;
END Upload_Data;

FUNCTION Get_LogDir(p_data_file IN VARCHAR2) RETURN VARCHAR2 IS
l_token  VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(44);
l_slash VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(47);
l_logdir VARCHAR2(2000) := '';
l_pos    number := 0;
BEGIN
    -- use first entry of utl_file_dir as the DIR
    -- if there is no entry then do not even construct file names
      select trim(value)
        into l_logdir
        from v$parameter
       where name = 'utl_file_dir';

      l_pos := instr(l_logdir, l_token);
       if ( l_logdir is null ) then
         raise no_data_found;
         return l_logdir;
      elsif (l_pos > 0) then
        return trim(substr(l_logdir,1,l_pos-1));
      else
        return l_logdir;
      end if;
END Get_LogDir ;


FUNCTION Get_LogFileName (p_data_file IN VARCHAR2)
RETURN VARCHAR2
IS
  l_log_date  VARCHAR2(10);
  l_decimal VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(46);
  l_underscore VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(95);
  l_filename VARCHAR2(100):= '';
BEGIN
     -- Form the log filename using data filename and current date/time.
    l_log_date := TO_CHAR(SYSDATE,'MMDDYY');
    if (instr(p_data_file,l_decimal) > 0) then
        l_filename := substr(p_data_file, 1, instr(p_data_file,l_decimal)-1) ||l_underscore|| l_log_date || '.log' ;
    else
        l_filename := p_data_file||l_underscore|| l_log_date || '.log' ;
    end if;
    return l_filename;
END Get_LogFileName ;

PROCEDURE Chk_Valid_PeriodName (
       p_period_name IN VARCHAR2
     , p_period_set_name IN VARCHAR2
     , p_filehandle IN UTL_FILE.FILE_TYPE
     , x_period_flag OUT NOCOPY BOOLEAN
     , x_start_date  OUT NOCOPY DATE
     , x_end_date    OUT NOCOPY DATE )
IS
  l_period_name VARCHAR2(50);
  l_exception   VARCHAR2(500);
BEGIN
  x_period_flag := FALSE;

  SELECT period_name, start_date, end_date
    INTO l_period_name, x_start_date, x_end_date
    FROM gl_periods
    WHERE period_name = p_period_name
      AND period_set_name = p_period_set_name;
  IF l_period_name = p_period_name THEN
     x_period_flag := TRUE;
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    l_period_name := '';
    x_period_flag := FALSE;
WHEN OTHERS THEN
    IF (UTL_FILE.IS_OPEN(p_filehandle)) THEN
        UTL_FILE.PUT_LINE(p_filehandle, 'Oracle error while checking period name: '||sqlerrm);
    END IF;
    l_exception := 'Oracle error while checking period name: '||sqlerrm;
     create_loglob(l_exception
                   ,null
                   ,'W'
                   ,FALSE);
END Chk_Valid_PeriodName;

PROCEDURE Chk_Valid_Currency (
       p_currency_code IN VARCHAR2
     , p_filehandle IN UTL_FILE.FILE_TYPE
     , x_currency_flag OUT NOCOPY BOOLEAN )
IS
  l_currency_code VARCHAR2(30);
  l_exception   VARCHAR2(500);
BEGIN
  x_currency_flag := FALSE;

  SELECT currency_code
    INTO l_currency_code
    FROM fnd_currencies
    WHERE currency_code = p_currency_code;
  IF l_currency_code = p_currency_code THEN
     x_currency_flag := TRUE;
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    l_currency_code := '';
WHEN OTHERS THEN
    IF (UTL_FILE.IS_OPEN(p_filehandle)) THEN
        UTL_FILE.PUT_LINE(p_filehandle, 'Oracle error while checking Currency: '||sqlerrm);
    END IF;
     l_exception := 'Oracle error while checking Currency: '||sqlerrm;
     create_loglob(l_exception
                   ,null
                   ,'W'
                   ,FALSE);
END Chk_Valid_Currency;

PROCEDURE Get_CreditTypeId (
       p_name IN VARCHAR2
     , p_filehandle IN UTL_FILE.FILE_TYPE
     , x_credit_type_id   OUT NOCOPY NUMBER ) IS
l_exception VARCHAR2(500);
BEGIN
  SELECT sales_credit_type_id
    INTO x_credit_type_id
    FROM aso_i_sales_credit_types_v
    WHERE
         enabled_flag = 'Y'
     AND UPPER(name) = p_name
     AND rownum = 1;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    x_credit_type_id := 0;
WHEN OTHERS THEN
    IF (UTL_FILE.IS_OPEN(p_filehandle)) THEN
        UTL_FILE.PUT_LINE(p_filehandle, 'Oracle error while validating Credit Type: '||sqlerrm);
    END IF;
     l_exception := 'Oracle error while validating Credit Type: '||sqlerrm;
     create_loglob(l_exception
                   ,null
                   ,'W'
                   ,FALSE);
END Get_CreditTypeId;

PROCEDURE Get_ForecastCategoryId (
       p_name IN VARCHAR2
     , p_filehandle IN UTL_FILE.FILE_TYPE
     , p_start_date IN DATE
     , p_end_date   IN DATE
     , x_forecast_category_id   OUT NOCOPY NUMBER ) IS
     l_exception VARCHAR2(500);
BEGIN

  SELECT forecast_category_id
    INTO x_forecast_category_id
    FROM as_forecast_categories
    WHERE
         UPPER(forecast_category_name) = p_name
     AND ((start_date_active <= p_end_date) OR (start_date_active IS NULL))
     AND ((end_date_active >= p_start_date) OR (end_date_active IS NULL))
     AND rownum = 1 ;

EXCEPTION
WHEN NO_DATA_FOUND THEN
    x_forecast_category_id := 0;
WHEN OTHERS THEN
    IF (UTL_FILE.IS_OPEN(p_filehandle)) THEN
        UTL_FILE.PUT_LINE(p_filehandle, 'Oracle error while validating Forecast Category: '||sqlerrm);
    END IF;
     l_exception := 'Oracle error while validating Forecast Category: '||sqlerrm;
     create_loglob(l_exception
                   ,null
                   ,'W'
                   ,FALSE);
END Get_ForecastCategoryId;

PROCEDURE Get_SalesGroupId (
       p_sales_group_number IN NUMBER
     , p_filehandle IN UTL_FILE.FILE_TYPE
     , p_start_date IN DATE
     , p_end_date   IN DATE
     , x_sales_group_id    OUT NOCOPY NUMBER ) IS
     l_exception VARCHAR2(500);
BEGIN
  SELECT jgb.group_id
    INTO x_sales_group_id
    FROM
        jtf_rs_groups_b jgb
      , jtf_rs_group_usages jgu
    WHERE
         jgb.group_number = p_sales_group_number
     AND ((jgb.start_date_active <= p_end_date) OR (jgb.start_date_active IS NULL))
     AND ((jgb.end_date_active >= p_start_date) OR (jgb.end_date_active IS NULL))
     AND jgu.usage = 'SALES'
     AND jgu.group_id = jgb.group_id
     AND rownum = 1;

EXCEPTION
WHEN NO_DATA_FOUND THEN
    x_sales_group_id := 0;
WHEN OTHERS THEN
    IF (UTL_FILE.IS_OPEN(p_filehandle)) THEN
        UTL_FILE.PUT_LINE(p_filehandle, 'Oracle error while checking Sales Group ID: '||sqlerrm);
    END IF;
     l_exception := 'Oracle error while checking Sales Group ID: '||sqlerrm;
     create_loglob(l_exception
                   ,null
                   ,'W'
                   ,FALSE);
END Get_SalesGroupId;

PROCEDURE Get_SalesForceId (
       p_salesforce_number IN NUMBER
     , p_filehandle IN UTL_FILE.FILE_TYPE
     , p_start_date IN DATE
     , p_end_date   IN DATE
     , p_sales_group_id   IN NUMBER
     , x_salesforce_id    OUT NOCOPY NUMBER
) IS
     l_file_handle UTL_FILE.FILE_TYPE;
     l_exception VARCHAR2(500);
BEGIN

  SELECT res.resource_id
    INTO x_salesforce_id
    FROM
         jtf_rs_group_members mem
       , jtf_rs_resource_extns res
       , jtf_rs_role_relations rrel
       , jtf_rs_roles_b roleb
    WHERE
         res.resource_number = p_salesforce_number
     AND roleb.role_type_code in ('SALES','TELESALES','FIELDSALES','PRM')
     AND rrel.role_resource_type = 'RS_GROUP_MEMBER'
     AND rrel.role_id = roleb.role_id
     AND (rrel.start_date_active <= p_end_date
         OR rrel.start_date_active IS NULL)
     AND (rrel.end_date_active >= p_start_date
         OR rrel.end_date_active IS NULL)
     AND rrel.delete_flag <> 'Y'
     AND (roleb.member_flag = 'Y'
         OR (NVL(roleb.member_flag,'N') ='N' and roleb.manager_flag='Y'))
     AND mem.group_id = p_sales_group_id
     AND mem.resource_id = res.resource_id
     AND mem.group_member_id = rrel.role_resource_id
     AND mem.delete_flag <> 'Y'
     AND rownum = 1 ;

EXCEPTION
WHEN NO_DATA_FOUND THEN
    x_salesforce_id := 0;
WHEN OTHERS THEN
    IF (UTL_FILE.IS_OPEN(p_filehandle)) THEN
        UTL_FILE.PUT_LINE(p_filehandle, 'Oracle error while checking Sales ForceId: '||sqlerrm);
        UTL_FILE.PUT_LINE(p_filehandle, 'SalespersonNumber:'||p_salesforce_number||'SalesGroupId: '||p_sales_group_id||' StartDate: '||p_start_date||' EndDate:'||p_end_date);
    END IF;
     l_exception := 'Oracle error while checking Sales ForceId: '||sqlerrm||g_next_line||'SalespersonNumber:'||p_salesforce_number||'SalesGroupId: '||p_sales_group_id||' StartDate: '||p_start_date||' EndDate:'||p_end_date;
     create_loglob(l_exception
                   ,null
                   ,'W'
                   ,FALSE);

END Get_SalesForceId;

Procedure  Read_Lob(p_file_id                 IN NUMBER
                         , p_CREATED_BY              IN NUMBER
                         , p_LAST_UPDATED_BY         IN NUMBER
                         , p_LAST_UPDATE_LOGIN       IN NUMBER
                         , p_PROGRAM_APPLICATION_ID  IN NUMBER)
IS
   l_lob_loc        BLOB;
   l_lob_len        NUMBER;
   l_file_handle    UTL_FILE.FILE_TYPE; /*File Handle given to the Utl_file call*/
   l_lob_data       VARCHAR2(1000);/*this variable stores blob data*/
   l_filepath       VARCHAR2(200) := '';/*has the dir path of log file*/
   l_file_name      VARCHAR2(200) := '';/*has the client file name*/
   l_log_file       VARCHAR2(200) := '';/*has the log file name*/
   l_amount_var     Integer := 200;/*Number of bytes to be read from blob*/
   l_offset_var     Integer := 1; /*Offset given to the dbms_lob.read call*/
   l_string_param   VARCHAR2(200) := '';
   l_period_name    VARCHAR2(25) := '';
   l_salesgrp_id    VARCHAR2(25) := '';
   l_salesforce_id  VARCHAR2(25) := '';
   l_budget_amt     NUMBER := 0;
   l_revenue_amt    NUMBER := 0;
   lv_budget_amt     VARCHAR2(25) := '';
   lv_revenue_amt    VARCHAR2(25) := '';
   l_currency_code  VARCHAR2(25) := '';
   l_line_data      VARCHAR2(100) := '';
   l_decimal         VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(46);/*for chr='.'*/
   l_token           VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(34);/*for chr='"'*/
   l_comma           VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(44); /*for chr=','*/
   l_period_set_name VARCHAR2(50) := FND_PROFILE.VALUE('AS_FORECAST_CALENDAR');
   lv_amount_var     NUMBER := 0;
   l_temp_string     VARCHAR2(100) := '';
   l_header          VARCHAR2(100):='';
   l_footer          VARCHAR2(100):='';
   l_string VARCHAR2(100) := '';
   l_counter NUMBER;
   l_line_number  NUMBER := 0;
   l_line_counter NUMBER := 0;
   l_forecast_category_name  VARCHAR2(100);
   l_credit_type_name        VARCHAR2(300);
   l_valid BOOLEAN := TRUE;
   l_exception VARCHAR2(500) := '';
BEGIN
    SELECT  DBMS_LOB.GETLENGTH(file_data), file_data, file_name
      INTO l_lob_len, l_lob_loc, l_file_name
      FROM FND_LOBS
     WHERE file_id = p_file_id;

   IF SQL%NOTFOUND THEN
      raise NO_DATA_FOUND;
   END IF;
   l_filepath := '';
   l_filepath := Get_LogDir(l_filepath);
   l_log_file := Get_LogFileName(l_file_name);

     create_loglob(null
                   ,null
                   ,'W'
                   ,TRUE);
    if (UTL_FILE.IS_OPEN(l_file_handle)) then
       UTL_FILE.FCLOSE(l_file_handle);
    end if;

  begin
     l_file_handle := UTL_FILE.FOPEN(l_filepath, l_log_file, 'w');
  exception
  when others then
      create_loglob(sqlerrm
                   ,p_file_id
                   ,'W'
                   ,FALSE);
  end;
     fnd_message.set_name('ASF','ASF_FRCSTACT_LOG_HDR');
     fnd_message.set_token('DATETIME',to_Char(sysdate, 'DD-MON-RR HH24:MI:SS'));
     fnd_message.set_token('USER',p_created_by);
     fnd_message.set_token('FILENAME', l_file_name);
     l_header := fnd_message.get;
     UTL_FILE.PUT_LINE(l_file_handle, l_header);
     UTL_FILE.NEW_LINE(l_file_handle, 1);

     create_loglob(l_header
                   ,p_file_id
                   ,'W'
                   ,FALSE);
   if (l_lob_len > l_amount_var) then
        lv_amount_var := l_amount_var;
   else
        lv_amount_var := l_lob_len;
   End if;

   while(l_lob_len > 0)
   LOOP
     DBMS_LOB.READ(l_lob_loc, lv_amount_var, l_offset_var, l_lob_data);
     l_string_param :=  utl_raw.cast_to_varchar2(l_lob_data);
	while(length(l_string_param) > 0 )
     Loop
        l_line_data := '';
        if (instr(l_string_param, g_next_line) >0) then
          l_line_data := substr(l_string_param, 1, instr(l_string_param, g_next_line)-1);
          l_line_data := rtrim(l_line_data, g_next_line);
       elsif ((instr(l_string_param, l_token, 1, 16) > 0) and (instr(l_string_param, l_token, 1, 17) = 0)) then
          l_line_data := substr(l_string_param, 1, instr(l_string_param, l_token, 1, 16));
          l_string_param := l_string_param ||g_next_line;
      end if;
l_valid := true;

if ( length(trim(l_line_data)) = length(g_next_line)) then
    l_valid := false;
    l_line_number := l_line_number + 1;
end if;

/*The following If condition is for parsing the last line of the file and/or concatinating the truncated lines.*/
        if (nvl(length(l_line_data),0) <= 0) then
            if (length(l_temp_string) > 0) then
                l_string := concat(l_temp_string, l_string_param);
                if (instr(l_string, l_token, 1, 16) > 0) then
                  l_line_data := l_string;
                  l_temp_string := '';
                end if;
             else
              l_temp_string  := '';
              l_temp_string := l_string_param;
              l_string_param := '';
            end if;
        end if;

	  if ((length(l_line_data) > 0) and (l_valid))then
       	       if (length(l_temp_string) > 0) then
                l_line_data := concat(l_temp_string, l_line_data);
                l_temp_string := '';
            end if;

             for l_counter in 1..8
             loop
             begin
                if (l_counter = 1) then
                    begin
                    l_period_name :=  trim(substr(l_line_data, 2,instr(l_line_data, l_token, 2)-2));
                   exception
                   when others then
                        l_period_name := null;
                    end;
                elsif (l_counter = 2) then
                   begin
                   l_forecast_category_name :=  trim(substr(l_line_data, 2,instr(l_line_data, l_token, 2)-2));
                   exception
                   when others then
                        l_forecast_category_name := null;
                    end;
                elsif (l_counter = 3) then
                   begin
                   l_credit_type_name :=  trim(substr(l_line_data, 2,instr(l_line_data, l_token, 2)-2));
                   exception
                   when others then
                        l_credit_type_name := null;
                    end;
                elsif (l_counter = 4) then
                   begin
                     l_salesgrp_id :=  to_number(substr(l_line_data, 2,instr(l_line_data, l_token, 2)-2));
                   exception
                   when others then
                        l_salesgrp_id := null;
                    end;
                elsif (l_counter = 5) then
                  begin
                    l_salesforce_id := to_number(substr(l_line_data, 2,instr(l_line_data, l_token, 2)-2));
                    exception
                   when others then
                    l_salesforce_id := null;
                    end;
                elsif (l_counter = 6) then
                  begin
                    lv_budget_amt :=  substr(l_line_data, 2,instr(l_line_data, l_token, 2)-2);
                    while(instr(lv_budget_amt,l_comma) > 0)
                    loop
                       lv_budget_amt := concat(substr(lv_budget_amt,1,instr(lv_budget_amt,l_comma)-1), substr(lv_budget_amt,instr(lv_budget_amt,l_comma)+1));
                    end loop;
                    l_budget_amt := to_number(lv_budget_amt);
                  exception
                  when others then
                    l_budget_amt := null;
                 end;
               elsif (l_counter = 7) then
                 begin
                    lv_revenue_amt  :=  substr(l_line_data, 2,instr(l_line_data, l_token, 2)-2);
                    while(instr(lv_revenue_amt,l_comma) > 0)
                    loop
                       lv_revenue_amt := concat(substr(lv_revenue_amt,1,instr(lv_revenue_amt,l_comma)-1), substr(lv_revenue_amt,instr(lv_revenue_amt,l_comma)+1));
                    end loop;
                    l_revenue_amt := to_number(lv_revenue_amt);
                   exception
                   when others then
                    l_revenue_amt := null;
                 end;
                elsif (l_counter = 8) then
                begin
                    l_currency_code:= trim(substr(l_line_data, 2,instr(l_line_data, l_token, 2)-2));
                 exception
                 when others then
                    l_currency_code := null;
                 end;

                end if;
              exception
              when others then
                fnd_message.set_name('ASF','ASF_FRCSTACT_LOG_LINE');
                fnd_message.set_token('LINE',l_line_number);
                UTL_FILE.PUT_LINE(l_file_handle, fnd_message.get||sqlerrm) ;
                l_exception := fnd_message.get||sqlerrm;
                create_loglob(l_exception
                              ,null
                              ,'W'
                              ,FALSE);

                g_line_error := g_line_error + 1;
              end;
                l_line_data := substr(l_line_data, instr(l_line_data, l_token,2)+2);
             end loop;
          l_line_number := l_line_number + 1;
          l_line_counter:= l_line_counter+ 1;
         begin
         Upload_Data(l_period_set_name
                     ,l_line_number
                     ,l_salesforce_id
                     ,l_salesgrp_id
                     ,l_period_name
                     ,l_currency_code
                     ,l_budget_amt
                     ,l_revenue_amt
                     ,p_CREATED_By
                     ,sysdate
                     ,p_LAST_UPDATED_BY
                     ,sysdate
                     ,p_LAST_UPDATE_LOGIN
                     ,null
                     ,p_PROGRAM_APPLICATION_ID
                     ,null
                     ,sysdate
                     ,null
                     ,l_file_handle
                     ,l_forecast_category_name
                     ,l_credit_type_name);
       exception
       when others then
          UTL_FILE.PUT_LINE(l_file_handle, 'Oracle error(s) occured at '|| l_line_number ||' while Uploading : '||sqlerrm) ;
          l_exception := 'Oracle error(s) occured at '|| l_line_number ||' while Uploading : '||sqlerrm;
          create_loglob(l_exception
                   ,null
                   ,'W'
                   ,FALSE);
       end;
      if (l_line_counter >= 50) then
        commit;
        l_line_counter := 0;
      end if;
  end if;
        l_string_param := substr(l_string_param, instr(l_string_param, g_next_line)+1);
 End loop;
     l_lob_len   := l_lob_len - lv_amount_var; --to get the remaining part of the blob.
     l_offset_var := l_offset_var + lv_amount_var; --to set a pointer to determine till what point the blob is read.

     if ((l_lob_len > 0) and (l_lob_len < lv_amount_var)) Then
         lv_amount_var := l_lob_len;
     End if;
     l_lob_data   := '';
END LOOP;
fnd_message.set_name('ASF','ASF_FRCSTACT_LOG_FOOTER');
fnd_message.set_token('DATETIME',to_Char(sysdate, 'DD-MON-RR HH24:MI:SS'));
fnd_message.set_token('LINE',l_line_number);
fnd_message.set_token('ERROR',g_line_error);
l_footer := fnd_message.get;
UTL_FILE.NEW_LINE(l_file_handle, 1);
UTL_FILE.PUT_LINE(l_file_handle, l_footer ) ;
l_footer := l_footer;
      create_loglob(l_footer
                   ,null
                   ,'W'
                   ,FALSE);

      create_loglob(null
                   ,p_file_id
                   ,'C'
                   ,FALSE);
--delete_lob(p_file_id, l_file_handle);/*Commented because the internal lob is rewritten with log content.*/
commit;
UTL_FILE.FCLOSE(l_file_handle);   -- close data file
l_line_number := 0;
g_line_error := 0;
Exception
When others then
  IF (UTL_FILE.IS_OPEN(l_file_handle) = false) THEN
      l_file_handle := UTL_FILE.FOPEN(l_filepath, l_log_file, 'a');
  END IF;
  UTL_FILE.PUT_LINE(l_file_handle, 'Oracle error(s) occured at '|| l_line_number ||' while processing : '||sqlerrm);
  UTL_FILE.FCLOSE(l_file_handle);   -- close data file
  l_exception := 'Oracle error(s) occured at '|| l_line_number ||' while processing : '||sqlerrm;
   create_loglob(l_exception
                   ,null
                   ,'W'
                   ,FALSE);
   create_loglob(null
                ,p_file_id
                ,'C'
                ,FALSE);
 End Read_lob;

/*Deleting the blob*/
PROCEDURE Delete_lob(p_file_id IN NUMBER
                    ,p_filehandle IN UTL_FILE.FILE_TYPE) IS
   l_doc_id NUMBER := 0;
   l_datatype NUMBER := 6;
   CURSOR doc_id_cur IS
    SELECT document_id
      FROM Fnd_Documents_tl
     WHERE Media_Id = p_file_id;

BEGIN
    FOR i IN doc_id_cur
    LOOP
        EXIT when doc_id_cur%NOTFOUND;
               if (l_doc_id is null) then
           raise NO_DATA_FOUND;
        end if;
        l_doc_id := i.document_id;
   END LOOP;
   begin
   FND_DOCUMENTS_PKG.DELETE_ROW( l_doc_id, l_datatype, NULL);
   exception
   when others then
     UTL_FILE.PUT_LINE(p_filehandle,'Error while deleting Fnd_documents: '||sqlerrm);
   End ;
   begin
   DELETE FND_LOBS WHERE FILE_ID = p_file_id;
   exception
   when others then
     UTL_FILE.PUT_LINE(p_filehandle,'Error while deleting lob: '||sqlerrm);
   End ;
  end;
/*Lob is deleted*/
/*Creating the log lob by accumlating the temporary lob
p_log_string- String that needs to go in blob.
p_file_id-Blob ID to which the temp log needs to be copied at the end.
p_op_type-takes in 'C' or 'W'. C- to copy the temp blob to internal blob.
                                W- to write to the temp blob
p_exists- boolean value determines whether to create a new temporary blob.(True creates a new one)
*/
PROCEDURE Create_Loglob( p_log_string IN VARCHAR2
                        ,p_file_id    IN NUMBER
                        ,p_op_type    IN VARCHAR2
                        ,p_exists     IN BOOLEAN)
IS
/*The following variables are for temporary blob */
   dest_lob_loc BLOB;
   l_temp_amt_var Integer := 200;
   l_temp_offset  Integer := 1;
   l_temp_amt_var1 Integer := 200;
   l_temp_offset1 Integer := 1;
   l_temp_logdata  VARCHAR2(1000);
   l_temp_param    VARCHAR2(1000);
   l_strlen     NUMBER := 0;
   l_log_string VARCHAR2(1000);
 BEGIN
   /*Creating a temporary blob*/
    IF (p_exists) THEN
       DBMS_LOB.CREATETEMPORARY(g_temp_blob, true);
    END IF;

   IF (p_op_type = 'W') THEN
  /*Write to the temp lob*/
    l_log_string := p_log_string||g_next_line;
    l_strlen := length(l_log_string);
    IF(l_temp_amt_var > l_strlen) THEN
       DBMS_LOB.WRITEAPPEND(g_temp_blob, l_strlen,utl_raw.cast_to_raw(l_log_string));

       l_temp_offset := l_temp_offset + l_strlen;
    ELSE
        WHILE(l_strlen > 0)
        LOOP
           DBMS_LOB.WRITEAPPEND(g_temp_blob, l_temp_amt_var, utl_raw.cast_to_raw(l_log_string));
           l_temp_offset := l_temp_offset + l_temp_amt_var;
           l_strlen := l_strlen - l_temp_amt_var;
           if ((l_strlen > 0) and (l_strlen < l_temp_amt_var)) Then
               l_temp_amt_var := l_strlen;
           End if;
        END LOOP;
        l_temp_offset := 1;
        l_temp_amt_var := 200;
    END IF;
 ELSIF (p_op_type = 'C') THEN
        SELECT  file_data, dbms_lob.getlength(file_data)
          INTO dest_lob_loc, l_temp_amt_var1
          FROM FND_LOBS
         WHERE file_id = p_file_id
         FOR Update;
     dbms_lob.erase(dest_lob_loc, l_temp_amt_var1);
     l_temp_amt_var1 := dbms_lob.getlength(g_temp_blob);
     dbms_lob.copy(dest_lob_loc, g_temp_blob, l_temp_amt_var1);
     commit;
     dbms_lob.freetemporary(g_temp_blob);
 END IF;
exception
     when others then
     dbms_lob.freetemporary(g_temp_blob);
End Create_Loglob;

End AS_FORECAST_ACTUAL_PKG;

/
