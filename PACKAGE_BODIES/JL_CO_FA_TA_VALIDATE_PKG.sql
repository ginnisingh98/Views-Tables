--------------------------------------------------------
--  DDL for Package Body JL_CO_FA_TA_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_CO_FA_TA_VALIDATE_PKG" AS
/* $Header: jlcoftvb.pls 120.3 2006/09/20 17:54:29 abuissa ship $ */
----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   validate_status                                                      --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to validate technical appraisals                  --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--        p_appraisal_id - Appraisal identification number                --
--                                                                        --
-- HISTORY:                                                               --
--    07/15/98     Sujit Dalai    Created                                 --
--    09/27/98   Sujit Dalai   Changed the output printed to the log to   --
--                               provide a users with a more helpful text.--
--    10/21/98     Sujit Dalai     Changed the messages                   --
----------------------------------------------------------------------------

PROCEDURE validate_status ( ERRBUF  OUT NOCOPY VARCHAR2,
                            RETCODE OUT NOCOPY VARCHAR2,
                            p_appraisal_id  IN NUMBER
                          ) IS

  CURSOR c_appraisals IS
    SELECT apr.appraisal_id,
           apr.fiscal_year,
           cur.currency_code
    FROM   jl_co_fa_appraisals apr,
           fnd_currencies_active_v cur
    WHERE  apr.appraisal_id = nvl (p_appraisal_id, apr.appraisal_id)
      AND  apr.currency_code = cur.currency_code(+)
      AND  appraisal_status NOT IN ('V','P')
    FOR UPDATE OF appraisal_status;

  CURSOR c_assets(p_appr_id NUMBER) IS
    SELECT ad.asset_number,
           a.asset_number appr_asset_number,
           a.appraisal_value,
           a.status
    FROM   jl_co_fa_asset_apprs a,
           fa_additions ad
    WHERE  a.asset_number = ad.asset_number(+)
      AND  a.appraisal_id = p_appr_id
      AND  NVL(a.status, 'E') <> 'V'
    FOR UPDATE OF status;

  x_count1            NUMBER;
  x_status            VARCHAR2(1) := 'V';
  x_appraisal_status  VARCHAR2(1) := 'V';
  err_num             NUMBER;
  err_msg             VARCHAR2(200);

  BEGIN

    fnd_message.set_name('JL', 'JL_CO_FA_PARAMETER');
    fnd_file.put_line( FND_FILE.LOG, fnd_message.get);
    fnd_file.put_line(FND_FILE.LOG, '----------------------------------------');
    fnd_message.set_name('JL', 'JL_CO_FA_APPR_NUMBER');
    fnd_message.set_token('APPRAISAL_NUMBER', p_appraisal_id);
    fnd_file.put_line( 1, fnd_message.get);
    fnd_file.put_line(FND_FILE.LOG, '----------------------------------------');

    FOR rec_appraisal IN c_appraisals LOOP

      fnd_message.set_name('JL', 'JL_CO_FA_APPR_MESG');
      fnd_message.set_token('APPRAISAL_NUMBER', rec_appraisal.appraisal_id);
      fnd_file.put_line( 1, fnd_message.get);
                      /*Checking for the Fiscal Year */

      IF rec_appraisal.fiscal_year < 1990 THEN
        x_appraisal_status := 'F';
        fnd_message.set_name('JL', 'JL_CO_FA_LESS_THAN_1990');
        fnd_message.set_token('APPRAISAL_NUMBER', rec_appraisal.appraisal_id);
        fnd_file.put_line( fnd_file.LOG, fnd_message.get);
      END IF;

                 /* Checking for valid currency Code */

      IF rec_appraisal.currency_code IS NULL THEN

        IF x_appraisal_status = 'V' THEN
          x_appraisal_status := 'C';
        END IF;

          fnd_message.set_name('JL', 'JL_CO_FA_INVALID_CURRENCY_CODE');
          fnd_message.set_token('APPRAISAL_NUMBER', rec_appraisal.appraisal_id);
          fnd_file.put_line( FND_FILE.LOG, fnd_message.get);
       END IF;

           FOR rec_asset IN c_assets(rec_appraisal.appraisal_id) LOOP

                /* Checking for valid asset number */

             IF rec_asset.asset_number IS NULL THEN
               x_status := 'A';

               IF x_appraisal_status = 'V' THEN
                 x_appraisal_status := 'R';
               END IF;

               fnd_message.set_name('JL', 'JL_CO_FA_ASSET_NOT_FOUND');
               fnd_message.set_token('ASSET_NUMBER', rec_asset.appr_asset_number);
               fnd_message.set_token('APPRAISAL_NUMBER', rec_appraisal.appraisal_id);
               fnd_file.put_line(FND_FILE.LOG, fnd_message.get);
             END IF;

                     /* Checking for appraisal value */

             IF (rec_asset.appraisal_value < 0) THEN
               IF x_status = 'V' THEN
                 x_status := 'N';
               END IF;

               IF x_appraisal_status = 'V' THEN
                 x_appraisal_status := 'R';
               END IF;
                 fnd_message.set_name('JL', 'JL_CO_FA_NEGATIVE_VALUE');
                 fnd_message.set_token('APPRAISAL_NUMBER', rec_appraisal.appraisal_id);
                 fnd_message.set_token('ASSET_NUMBER', rec_asset.appr_asset_number);
                 fnd_file.put_line( FND_FILE.LOG, fnd_message.get);
              END IF;


            UPDATE jl_co_fa_asset_apprs
            SET    status = x_status
            WHERE  current of c_assets;

            x_status := 'V';

          END LOOP;


      UPDATE jl_co_fa_appraisals
      SET    appraisal_status = x_appraisal_status
      WHERE  current of c_appraisals;

      x_appraisal_status := 'V';
      fnd_file.put_line(FND_FILE.LOG, ' ');
    END LOOP;

    COMMIT WORK;

    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('JL', 'JL_CO_FA_GENERAL_ERROR');
        fnd_file.put_line( 1, fnd_message.get);
        err_num := SQLCODE;
        err_msg := substr(SQLERRM, 1, 200);
        RAISE_APPLICATION_ERROR( err_num, err_msg);

  END validate_status;
END jl_co_fa_ta_validate_pkg;

/
