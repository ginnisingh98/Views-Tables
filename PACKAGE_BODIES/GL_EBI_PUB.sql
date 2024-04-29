--------------------------------------------------------
--  DDL for Package Body GL_EBI_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_EBI_PUB" AS
/* $Header: gleipub.pls 120.0.12010000.2 2010/01/28 12:17:15 sommukhe noship $ */

PROCEDURE process_currency_exc_rate_list(
  p_api_version            IN              VARCHAR2
 ,p_commit                 IN              VARCHAR2
 ,p_integration_id         IN              VARCHAR2
 ,p_lang_code              IN              VARCHAR2
 ,p_name_value_tbl         IN              gl_ebi_name_value_tbl
 ,p_daily_rates_tbl        IN              gl_ebi_daily_rates_tbl
 ,x_request_id             OUT NOCOPY      NUMBER
 ,x_return_status          OUT NOCOPY      VARCHAR2
 ,x_msg_count              OUT NOCOPY      NUMBER
 ,x_msg_data               OUT NOCOPY      VARCHAR2
 )
IS
  l_request_id                  NUMBER:=0;
  l_count                       NUMBER:=0;
  l_sorted_table                gl_ebi_daily_rates_tbl;
  l_param_name                  VARCHAR2(30):='AUTO_ADJUST_TO_DATE';
  l_auto_adjust_to_date         VARCHAR2(30):='FALSE';
BEGIN
  FND_MSG_PUB.initialize();
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(p_name_value_tbl IS NOT NULL AND p_name_value_tbl.COUNT > 0) THEN
      FOR i IN p_name_value_tbl.FIRST..p_name_value_tbl.LAST LOOP
        IF (UPPER(p_name_value_tbl(i).param_name) = UPPER(l_param_name))THEN
          l_auto_adjust_to_date := p_name_value_tbl(i).param_value;
        END IF;
      END LOOP;
  END IF;


  IF p_daily_rates_tbl IS NOT NULL AND p_daily_rates_tbl.COUNT >0 THEN
    FOR i IN p_daily_rates_tbl.FIRST..p_daily_rates_tbl.LAST LOOP
      l_count := 0;

      SELECT count(1) INTO l_count
      FROM GL_DAILY_RATES_INTERFACE
      WHERE FROM_CURRENCY = p_daily_rates_tbl(i).TO_CURRENCY
        AND TO_CURRENCY = p_daily_rates_tbl(i).FROM_CURRENCY
        AND FROM_CONVERSION_DATE = p_daily_rates_tbl(i).FROM_CONVERSION_DATE
        AND TO_CONVERSION_DATE = p_daily_rates_tbl(i).TO_CONVERSION_DATE
        AND USER_CONVERSION_TYPE = p_daily_rates_tbl(i).USER_CONVERSION_TYPE
        AND BATCH_NUMBER = p_integration_id;

      IF (l_count > 0) THEN
        UPDATE GL_DAILY_RATES_INTERFACE
        SET INVERSE_CONVERSION_RATE = p_daily_rates_tbl(i).CONVERSION_RATE
        WHERE FROM_CURRENCY = p_daily_rates_tbl(i).TO_CURRENCY
        AND TO_CURRENCY = p_daily_rates_tbl(i).FROM_CURRENCY
        AND FROM_CONVERSION_DATE = p_daily_rates_tbl(i).FROM_CONVERSION_DATE
        AND TO_CONVERSION_DATE = p_daily_rates_tbl(i).TO_CONVERSION_DATE
        AND USER_CONVERSION_TYPE = p_daily_rates_tbl(i).USER_CONVERSION_TYPE
        AND BATCH_NUMBER = p_integration_id;

      ELSE
        INSERT INTO GL_DAILY_RATES_INTERFACE(
             FROM_CURRENCY,
             TO_CURRENCY,
             FROM_CONVERSION_DATE,
             TO_CONVERSION_DATE,
             USER_CONVERSION_TYPE,
             CONVERSION_RATE,
             MODE_FLAG,
             INVERSE_CONVERSION_RATE,
             USER_ID,
             LAUNCH_RATE_CHANGE,
             ERROR_CODE,
             CONTEXT,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             USED_FOR_AB_TRANSLATION,
             ATTRIBUTE15,
             BATCH_NUMBER
            )
            VALUES(
             p_daily_rates_tbl(i).FROM_CURRENCY,
             p_daily_rates_tbl(i).TO_CURRENCY,
             p_daily_rates_tbl(i).FROM_CONVERSION_DATE,
             p_daily_rates_tbl(i).TO_CONVERSION_DATE,
             p_daily_rates_tbl(i).USER_CONVERSION_TYPE,
             p_daily_rates_tbl(i).CONVERSION_RATE,
             nvl(p_daily_rates_tbl(i).MODE_FLAG,'I'),
             p_daily_rates_tbl(i).INVERSE_CONVERSION_RATE,
             fnd_global.user_id,
             p_daily_rates_tbl(i).LAUNCH_RATE_CHANGE,
             p_daily_rates_tbl(i).ERROR_CODE,
             p_daily_rates_tbl(i).CONTEXT,
             p_daily_rates_tbl(i).ATTRIBUTE1,
             p_daily_rates_tbl(i).ATTRIBUTE2,
             p_daily_rates_tbl(i).ATTRIBUTE3,
             p_daily_rates_tbl(i).ATTRIBUTE4,
             p_daily_rates_tbl(i).ATTRIBUTE5,
             p_daily_rates_tbl(i).ATTRIBUTE6,
             p_daily_rates_tbl(i).ATTRIBUTE7,
             p_daily_rates_tbl(i).ATTRIBUTE8,
             p_daily_rates_tbl(i).ATTRIBUTE9,
             p_daily_rates_tbl(i).ATTRIBUTE10,
             p_daily_rates_tbl(i).ATTRIBUTE11,
             p_daily_rates_tbl(i).ATTRIBUTE12,
             p_daily_rates_tbl(i).ATTRIBUTE13,
             p_daily_rates_tbl(i).ATTRIBUTE14,
             p_daily_rates_tbl(i).USED_FOR_AB_TRANSLATION,
             p_daily_rates_tbl(i).ATTRIBUTE15,
             p_integration_id
            );
      END IF;
    END LOOP;
  END IF;

  IF UPPER(l_auto_adjust_to_date) = 'TRUE' THEN
    SELECT gl_ebi_daily_rates_obj(FROM_CURRENCY,
             TO_CURRENCY,
             FROM_CONVERSION_DATE,
             TO_CONVERSION_DATE,
             USER_CONVERSION_TYPE,
             CONVERSION_RATE,
             MODE_FLAG,
             INVERSE_CONVERSION_RATE,
             USER_ID,
             LAUNCH_RATE_CHANGE,
             ERROR_CODE,
             CONTEXT,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             USED_FOR_AB_TRANSLATION,
             ATTRIBUTE15)
             BULK COLLECT INTO l_sorted_table
    FROM GL_DAILY_RATES_INTERFACE
    WHERE BATCH_NUMBER = p_integration_id
    ORDER BY FROM_CURRENCY,TO_CURRENCY,USER_CONVERSION_TYPE,FROM_CONVERSION_DATE;

    IF l_sorted_table IS NOT NULL AND l_sorted_table.COUNT >0 THEN
      FOR i IN l_sorted_table.FIRST..l_sorted_table.LAST LOOP
        IF (i <>l_sorted_table.LAST) AND  (l_sorted_table(i).FROM_CURRENCY = l_sorted_table(i+1).FROM_CURRENCY
         AND l_sorted_table(i).TO_CURRENCY = l_sorted_table(i+1).TO_CURRENCY
         AND l_sorted_table(i).USER_CONVERSION_TYPE = l_sorted_table(i+1).USER_CONVERSION_TYPE) THEN

           UPDATE GL_DAILY_RATES_INTERFACE
           SET TO_CONVERSION_DATE = l_sorted_table(i+1).FROM_CONVERSION_DATE-1
           WHERE FROM_CURRENCY = l_sorted_table(i).FROM_CURRENCY
           AND TO_CURRENCY = l_sorted_table(i).TO_CURRENCY
           AND FROM_CONVERSION_DATE = l_sorted_table(i).FROM_CONVERSION_DATE
           AND TO_CONVERSION_DATE = l_sorted_table(i).TO_CONVERSION_DATE
           AND USER_CONVERSION_TYPE = l_sorted_table(i).USER_CONVERSION_TYPE
           AND BATCH_NUMBER = p_integration_id;

        END IF;
      END LOOP;
    END IF;
  END IF;

  l_request_id := fnd_request.submit_request('SQLGL', 'GLDRICCP', '', '', FALSE,p_integration_id,
                                        CHR(0), '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                    '');
  x_request_id := l_request_id;

  IF p_commit = FND_API.g_true THEN
    COMMIT;
  END IF;

  IF l_request_id = 0 THEN
    FND_MESSAGE.RETRIEVE(x_msg_data);
    RAISE FND_API.g_exc_error;
  END IF;


EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    x_msg_data := SQLERRM ||' at process_currency_exc_rate_list';
END process_currency_exc_rate_list;

PROCEDURE purge_currency_exc_rate_list(
  p_api_version            IN              VARCHAR2
 ,p_commit                 IN              VARCHAR2
 ,p_integration_id         IN              VARCHAR2
 ,p_lang_code              IN              VARCHAR2
 ,x_daily_rates_tbl        OUT NOCOPY      gl_ebi_daily_rates_tbl
 ,x_return_status          OUT NOCOPY      VARCHAR2
 ,x_msg_count              OUT NOCOPY      NUMBER
 ,x_msg_data               OUT NOCOPY      VARCHAR2
 )
IS

CURSOR c_get_err_rows(p_integration_id VARCHAR2) IS
  SELECT gl_ebi_daily_rates_obj(FROM_CURRENCY,
   TO_CURRENCY,
   FROM_CONVERSION_DATE,
   TO_CONVERSION_DATE,
   USER_CONVERSION_TYPE,
   CONVERSION_RATE,
   MODE_FLAG,
   INVERSE_CONVERSION_RATE,
   USER_ID,
   LAUNCH_RATE_CHANGE,
   ERROR_CODE,
   CONTEXT,
   ATTRIBUTE1,
   ATTRIBUTE2,
   ATTRIBUTE3,
   ATTRIBUTE4,
   ATTRIBUTE5,
   ATTRIBUTE6,
   ATTRIBUTE7,
   ATTRIBUTE8,
   ATTRIBUTE9,
   ATTRIBUTE10,
   ATTRIBUTE11,
   ATTRIBUTE12,
   ATTRIBUTE13,
   ATTRIBUTE14,
   USED_FOR_AB_TRANSLATION,
   ATTRIBUTE15)
  FROM GL_DAILY_RATES_INTERFACE
  WHERE
    BATCH_NUMBER = p_integration_id;

  l_err_msg     VARCHAR2(32000);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_get_err_rows(p_integration_id);
  FETCH c_get_err_rows BULK COLLECT INTO x_daily_rates_tbl;
  CLOSE c_get_err_rows;

  IF x_daily_rates_tbl IS NOT NULL AND x_daily_rates_tbl.COUNT >0 THEN
    x_return_status := FND_API.g_ret_sts_error;

    FOR i IN x_daily_rates_tbl.FIRST..x_daily_rates_tbl.LAST LOOP

      l_err_msg := 'From Currency-'||x_daily_rates_tbl(i).FROM_CURRENCY||' To Currency-'||
                    x_daily_rates_tbl(i).TO_CURRENCY||' Conversion Type-'||x_daily_rates_tbl(i).USER_CONVERSION_TYPE||
                    ' Failed. Reason-'|| x_daily_rates_tbl(i).ERROR_CODE;

      IF x_msg_data IS NULL THEN
        x_msg_data := l_err_msg || FND_GLOBAL.newline;
      ELSE
        x_msg_data := x_msg_data || l_err_msg || FND_GLOBAL.newline;
      END IF;

    END LOOP;

    DELETE FROM gl_daily_rates_interface WHERE batch_number = p_integration_id;

  END IF;

  IF p_commit = FND_API.g_true THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    x_msg_data := SQLERRM ||' at purge_currency_exc_rate_list';

    IF (c_get_err_rows%ISOPEN) THEN
      CLOSE c_get_err_rows;
    END IF;
END purge_currency_exc_rate_list;

PROCEDURE process_accounting_period_list(
  p_api_version            IN              VARCHAR2
 ,p_commit                 IN              VARCHAR2
 ,p_acct_period_tbl        IN              gl_ebi_acct_period_tbl
 ,x_return_status          OUT NOCOPY      VARCHAR2
 ,x_msg_count              OUT NOCOPY      NUMBER
 ,x_msg_data               OUT NOCOPY      VARCHAR2
 )

IS
 l_err_msg VARCHAR2(32000);
 l_ret_status VARCHAR2(10);
 l_ret_code NUMBER;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_acct_period_tbl IS NOT NULL AND p_acct_period_tbl.COUNT >0 THEN

    FOR i IN p_acct_period_tbl.FIRST..p_acct_period_tbl.LAST LOOP

      GL_PERIOD_STATUS_SYNC_PUB.period_status_sync(
         p_ledger_short_name    => p_acct_period_tbl(i).ledger_short_name
        ,p_start_date           => p_acct_period_tbl(i).start_date
        ,p_end_date             => p_acct_period_tbl(i).end_date
        ,x_return_status        => l_ret_status
        ,errbuf                 => l_err_msg
        ,retcode                => l_ret_code
        );

      IF l_ret_status <> FND_API.g_ret_sts_success THEN
        x_return_status := FND_API.g_ret_sts_error;
        IF x_msg_data IS NULL THEN
          x_msg_data := l_err_msg || FND_GLOBAL.newline;
        ELSE
          x_msg_data := x_msg_data || l_err_msg || FND_GLOBAL.newline;
        END IF;
      END IF;

    END LOOP;
  END IF;

  IF p_commit = FND_API.g_true THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    x_msg_data := SQLERRM ||' at process_accounting_period_list';
END process_accounting_period_list;

END GL_EBI_PUB;

/
