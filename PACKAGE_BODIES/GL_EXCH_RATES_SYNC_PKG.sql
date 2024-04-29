--------------------------------------------------------
--  DDL for Package Body GL_EXCH_RATES_SYNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_EXCH_RATES_SYNC_PKG" AS
/* $Header: glexrasb.pls 120.0.12010000.5 2009/02/05 11:43:25 sommukhe noship $ */

PROCEDURE get_cur_conv_rates(
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER,
    p_from_currency IN VARCHAR2 DEFAULT NULL,
    p_to_currency IN VARCHAR2 DEFAULT NULL,
    p_from_date IN DATE,
    p_to_date IN DATE DEFAULT SYSDATE,
    p_conversion_rate_type IN VARCHAR2 DEFAULT NULL,
    p_cur_conv_rates OUT NOCOPY GL_CUR_CONV_RATE_OBJ_TBL
)
IS
    --------------------------------------------------
    --------****Declaring Local Variables****---------
    --------------------------------------------------
    l_dir_rates GL_CUR_CONV_RATE_OBJ_TBL := GL_CUR_CONV_RATE_OBJ_TBL();
    l_cur_conv_rates GL_CUR_CONV_RATE_OBJ_TBL := GL_CUR_CONV_RATE_OBJ_TBL();
    l_cur_conv_inv_rates GL_CUR_CONV_RATE_OBJ_TBL := GL_CUR_CONV_RATE_OBJ_TBL();
    l_cr_rates GL_CUR_CONV_RATE_OBJ_TBL := GL_CUR_CONV_RATE_OBJ_TBL();
    l_dir_cr_rates GL_CUR_CONV_RATE_OBJ_TBL := GL_CUR_CONV_RATE_OBJ_TBL();
    l_inv_cr_rates GL_CUR_CONV_RATE_OBJ_TBL := GL_CUR_CONV_RATE_OBJ_TBL();
    l_pivot_currency gl_cross_rate_rules.pivot_currency%TYPE;
    l_description gl_cross_rate_rules.description%TYPE;
    l_contra_currency gl_daily_rates.from_currency%TYPE;
    l_conversion_type gl_daily_conversion_types.conversion_type%TYPE;
    l_to_date DATE;
    l_n_dir_cntr NUMBER(7);
    l_n_inv_cntr NUMBER(7);
    l_n_dir_cr_cntr NUMBER(7);
    l_n_inv_cr_cntr NUMBER(7);

    --Cursor to get the Pivot Currency for the given Conversion Type
    CURSOR c_pivot_curr IS
    SELECT pivot_currency,description
    FROM gl_cross_rate_rules
    WHERE conversion_type = l_conversion_type
    AND (pivot_currency = p_from_currency OR pivot_currency = p_to_currency);

    --Cursor to get the Contra Currency of Conversion Type for the Entered Parameters
    CURSOR c_con_curr IS
    SELECT cr_cur_tbl.from_currency
    FROM
        (SELECT DISTINCT from_currency from_currency
        FROM gl_cross_rate_rule_dtls
        WHERE conversion_type = l_conversion_type
        AND enabled_flag = 'Y')cr_cur_tbl
    WHERE (cr_cur_tbl.from_currency = p_from_currency OR cr_cur_tbl.from_currency = p_to_currency);

    --Cursor to fetch the Conversion Type
    CURSOR c_get_conv_type IS
    SELECT conversion_type
    FROM gl_daily_conversion_types
    WHERE user_conversion_type = p_conversion_rate_type;

    --Cursor to Fetch the Direct Rates and Inverse Rates for the Entered Parameters
    CURSOR c_get_rates(c_from_currency VARCHAR2,
                       c_to_currency VARCHAR2,
                       c_from_date DATE,
                       c_to_date DATE,
                       c_conversion_rate_type VARCHAR2) IS
    SELECT gldr.from_currency from_currency,
           gldr.to_currency to_currency,
           gldr.conversion_date conversion_date,
           gdct.user_conversion_type conversion_type,
           gldr.conversion_rate conversion_rate,
           1/conversion_rate inv_conv_rate,
           gldr.status_code status_code,
           gldr.rate_source_code rate_source_code,
           --decode(glcrs.pivot_currency,gldr.from_currency,gldr.from_currency,gldr.to_currency,gldr.to_currency,null) pivot_currency,
           null pivot_currency,
           --decode(glcrs.pivot_currency,gldr.from_currency,glcrs.description,gldr.to_currency,glcrs.description,null) description
           null description
    FROM gl_daily_rates gldr,
         gl_cross_rate_rules glcrs,
         gl_daily_conversion_types gdct
    WHERE gldr.conversion_date between c_from_date and c_to_date
    AND nvl2(c_conversion_rate_type,gldr.conversion_type,1) = nvl(c_conversion_rate_type,1)
    AND gldr.conversion_type = glcrs.conversion_type(+)
    AND gdct.conversion_type = gldr.conversion_type
    AND nvl2(c_from_currency,gldr.from_currency,1) = nvl(c_from_currency,1)
    AND nvl2(c_to_currency,gldr.to_currency,1) = nvl(c_to_currency,1);

    --Cursor to Fetch the Corss Rates for the Entered parameters
    CURSOR c_cr_rates(c_from_currency VARCHAR2,
                      c_to_currency VARCHAR2,
                      c_from_date DATE,
                      c_to_date DATE,
                      c_conversion_rate_type VARCHAR2,
                      c_contra_currency VARCHAR2) IS
    SELECT gldr.from_currency from_currency,
           gldr.to_currency to_currency,
           gldr.conversion_date conversion_date,
           gdct.user_conversion_type conversion_type,
           gldr.conversion_rate conversion_rate,
           1/conversion_rate inv_conv_rate,
           gldr.status_code status_code,
           gldr.rate_source_code rate_source_code,
           --decode(glcrs.pivot_currency,gldr.from_currency,gldr.from_currency,gldr.to_currency,gldr.to_currency,null) pivot_currency,
           l_pivot_currency pivot_currency,
           --decode(glcrs.pivot_currency,gldr.from_currency,glcrs.description,gldr.to_currency,glcrs.description,null) description
           l_description description
    FROM gl_daily_rates gldr,
         gl_cross_rate_rules glcrs,
         gl_daily_conversion_types gdct
    WHERE gldr.conversion_date between c_from_date and c_to_date
    AND nvl2(c_conversion_rate_type,gldr.conversion_type,1) = nvl(c_conversion_rate_type,1)
    AND gldr.conversion_type = glcrs.conversion_type
    AND gdct.conversion_type = gldr.conversion_type
    AND gldr.from_currency = c_contra_currency
    AND gldr.to_currency IN (SELECT DISTINCT from_currency
                             FROM gl_cross_rate_rule_dtls
                             WHERE nvl2(c_conversion_rate_type,conversion_type,1) = nvl(c_conversion_rate_type,1)
                             AND enabled_flag = 'Y');

   --Cursor to Fetch the Inverse cross rates for the Entered Parameters
   CURSOR c_inv_cr_rates(c_from_currency VARCHAR2,
                     c_to_currency VARCHAR2,
                     c_from_date DATE,
                     c_to_date DATE,
                     c_conversion_rate_type VARCHAR2,
                     c_contra_currency VARCHAR2) IS
   SELECT gldr.from_currency from_currency,
          gldr.to_currency to_currency,
          gldr.conversion_date conversion_date,
          gdct.user_conversion_type conversion_type,
          gldr.conversion_rate conversion_rate,
          1/conversion_rate inv_conv_rate,
          gldr.status_code status_code,
          gldr.rate_source_code rate_source_code,
          --decode(glcrs.pivot_currency,gldr.from_currency,gldr.from_currency,gldr.to_currency,gldr.to_currency,null) pivot_currency,
          l_pivot_currency pivot_currency,
          --decode(glcrs.pivot_currency,gldr.from_currency,glcrs.description,gldr.to_currency,glcrs.description,null) description
          l_description description
    FROM gl_daily_rates gldr,
         gl_cross_rate_rules glcrs,
         gl_daily_conversion_types gdct
    WHERE gldr.conversion_date between c_from_date and c_to_date
    AND nvl2(c_conversion_rate_type,gldr.conversion_type,1) = nvl(c_conversion_rate_type,1)
    AND gldr.conversion_type = glcrs.conversion_type
    AND gdct.conversion_type = gldr.conversion_type
    AND gldr.to_currency = c_contra_currency
    AND gldr.from_currency IN (SELECT DISTINCT from_currency
                               FROM gl_cross_rate_rule_dtls
                               WHERE nvl2(c_conversion_rate_type,conversion_type,1) = nvl(c_conversion_rate_type,1)
                               AND enabled_flag = 'Y');


BEGIN
    l_n_dir_cntr := 0;
    l_n_inv_cntr := 0;
    l_n_dir_cr_cntr := 0;
    l_n_inv_cr_cntr := 0;




            l_conversion_type := p_conversion_rate_type;


            fnd_file.put_line( fnd_file.log,'Fetching the Daily Rates for the entered Currencies ');

            IF p_to_date IS NULL THEN
                l_to_date := SYSDATE;
            ELSE
                l_to_date := p_to_date;
            END IF;

            --For the Direct Rates
            FOR rec_c_get_rates IN c_get_rates(p_from_currency,
                                               p_to_currency,
                                               p_from_date,
                                               l_to_date,
                                               p_conversion_rate_type)
            LOOP
                l_cur_conv_rates.EXTEND;
                l_n_dir_cntr := l_n_dir_cntr+1;
                l_cur_conv_rates(l_n_dir_cntr) := GL_CUR_CONV_RATE_OBJ(rec_c_get_rates.from_currency, rec_c_get_rates.to_currency,
                                                                       rec_c_get_rates.conversion_date, rec_c_get_rates.conversion_type,
                                                                       rec_c_get_rates.conversion_rate, rec_c_get_rates.inv_conv_rate,
                                                                       rec_c_get_rates.status_code, rec_c_get_rates.rate_source_code,
                                                                       rec_c_get_rates.pivot_currency, rec_c_get_rates.description);

            END LOOP;

            --For the Inverse Rates
            FOR rec_c_get_inv_rates IN c_get_rates(p_to_currency,
                                                   p_from_currency,
                                                   p_from_date,
                                                   l_to_date,
                                                   p_conversion_rate_type)
            LOOP
                l_cur_conv_inv_rates.EXTEND;
                l_n_inv_cntr := l_n_inv_cntr+1;
                l_cur_conv_inv_rates(l_n_inv_cntr) := GL_CUR_CONV_RATE_OBJ(rec_c_get_inv_rates.from_currency, rec_c_get_inv_rates.to_currency,
                                                                       rec_c_get_inv_rates.conversion_date, rec_c_get_inv_rates.conversion_type,
                                                                       rec_c_get_inv_rates.conversion_rate, rec_c_get_inv_rates.inv_conv_rate,
                                                                       rec_c_get_inv_rates.status_code, rec_c_get_inv_rates.rate_source_code,
                                                                       rec_c_get_inv_rates.pivot_currency, rec_c_get_inv_rates.description);

            END LOOP;

            l_dir_rates.EXTEND;
            l_dir_rates := l_cur_conv_rates MULTISET UNION ALL l_cur_conv_inv_rates;


            --Open the cursr for the Pivot Currency
            OPEN c_pivot_curr;
            FETCH c_pivot_curr INTO l_pivot_currency,l_description;

            --Open the cursr for the Contra Currency
            OPEN c_con_curr;
            FETCH c_con_curr INTO l_contra_currency;
            IF (c_con_curr%FOUND AND c_pivot_curr%FOUND) THEN

                --For Cross Rates
                FOR rec_c_cr_rates IN c_cr_rates(p_from_currency,
                                                 p_to_currency,
                                                 p_from_date,
                                                 l_to_date,
                                                 p_conversion_rate_type,
                                                 l_contra_currency)
                LOOP
                    l_dir_cr_rates.EXTEND;
                    l_n_dir_cr_cntr := l_n_dir_cr_cntr+1;
                    l_dir_cr_rates(l_n_dir_cr_cntr) := GL_CUR_CONV_RATE_OBJ(rec_c_cr_rates.from_currency, rec_c_cr_rates.to_currency,
                                                                            rec_c_cr_rates.conversion_date, rec_c_cr_rates.conversion_type,
                                                                            rec_c_cr_rates.conversion_rate, rec_c_cr_rates.inv_conv_rate,
                                                                            rec_c_cr_rates.status_code, rec_c_cr_rates.rate_source_code,
                                                                            rec_c_cr_rates.pivot_currency, rec_c_cr_rates.description);
                END LOOP;

                --For Inverse of Cross Rates
                FOR rec_c_inv_cr_rates IN c_inv_cr_rates(p_from_currency,
                                                         p_to_currency,
                                                         p_from_date,
                                                         l_to_date,
                                                         p_conversion_rate_type,
                                                         l_contra_currency)
                LOOP
                    l_inv_cr_rates.EXTEND;
                    l_n_inv_cr_cntr := l_n_inv_cr_cntr+1;
                    l_inv_cr_rates(l_n_inv_cr_cntr) := GL_CUR_CONV_RATE_OBJ(rec_c_inv_cr_rates.from_currency, rec_c_inv_cr_rates.to_currency,
                                                                            rec_c_inv_cr_rates.conversion_date, rec_c_inv_cr_rates.conversion_type,
                                                                            rec_c_inv_cr_rates.conversion_rate, rec_c_inv_cr_rates.inv_conv_rate,
                                                                            rec_c_inv_cr_rates.status_code, rec_c_inv_cr_rates.rate_source_code,
                                                                            rec_c_inv_cr_rates.pivot_currency, rec_c_inv_cr_rates.description);
                END LOOP;
                    fnd_file.put_line( fnd_file.log,'Assigning Cross Rates to the OUT Parameter');
                    l_cr_rates.EXTEND;
                    l_cr_rates := l_dir_cr_rates MULTISET UNION ALL l_inv_cr_rates;

                    --Assigning the Direct Rates and Cross Rates to the OUT parameter of Object Type.
                    p_cur_conv_rates := l_dir_rates MULTISET UNION ALL l_cr_rates;
		    CLOSE  c_con_curr;
		    CLOSE  c_pivot_curr;

              ELSE
                    --Assinging the Direct Rates to the OUT parameter if Cross Rate Records are not there.
                    p_cur_conv_rates := l_dir_rates;
                    fnd_file.put_line( fnd_file.log,'There Are No Cross Rates for the entered currencies');
		    CLOSE  c_con_curr;
		    CLOSE  c_pivot_curr;
              END IF;


END get_cur_conv_rates;

END GL_EXCH_RATES_SYNC_PKG;

/
