--------------------------------------------------------
--  DDL for Package Body JE_ES_MODELO_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_ES_MODELO_EXT_PKG" 
-- $Header: jeesmodeloextb.pls 120.18.12010000.25 2010/03/03 14:11:21 rsaini ship $
AS

  G_LE_TRN         VARCHAR2(150);
  G_LE_NAME        VARCHAR2(150);
  G_CURRENCY_CODE  VARCHAR2(150);
  G_CUR_PRECISION  NUMBER;
  G_FROM_DATE      DATE;
  G_TO_DATE        DATE;

  G_DEBUG         BOOLEAN := TRUE;
  G_LINENO        VARCHAR2 (20) ;  -- DEBUG LINE NO

  PROCEDURE get_vendor_address ( p_party_site_id   IN         NUMBER
                                , x_postal_code    OUT NOCOPY VARCHAR2
                                , x_city           OUT NOCOPY VARCHAR2
                                , x_address_detail OUT NOCOPY VARCHAR2
                                , x_country        OUT NOCOPY VARCHAR2
                                )
  IS

  /** author: brathod
      Modified following cursor to refer ap_supplier_sites_all to retrieve supplier address.
      Cursor was wrongly refering to hz_party_sites_all and hz_locations as
      jg_zz_vat_trx_details.billing_tp_address_id (value passed in parameter p_party_site_id) is actually a
      supplier_site_id and not party_site_id.  Please refer bug#5031773
 */
  CURSOR c_get_address IS
     SELECT DECODE(p_modelo,'415',DECODE(SUBSTR(assa.country, 1, 25)
                  , 'ES',SUBSTR(assa.zip,1,5)
                  , '99'||FT.eu_code)
		  , DECODE(assa.country
                  , 'ES',SUBSTR(assa.zip,1,2)||'   '
                  , '99'||FT.territory_code||' ') ) POSTCODE
          , assa.city                               CITY
          , SUBSTR(assa.address_line1,1,35)||' '||
            SUBSTR(assa.address_line2,1,35)||' '||
            SUBSTR(assa.address_line3,1,35)              ADDRESS_DETAIL
          , assa.country
     FROM  ap_supplier_sites_all assa
          , fnd_territories    FT
     WHERE  assa.vendor_site_id     = p_party_site_id
     AND    assa.country(+)        = FT.territory_code;

  BEGIN
    OPEN   c_get_address ;
    FETCH  c_get_address INTO x_postal_code, x_city, x_address_detail, x_country;
    CLOSE  c_get_address ;
  END;


  PROCEDURE get_customer_address ( p_customer_address_id   IN         NUMBER
                                 , x_postal_code          OUT NOCOPY VARCHAR2
                                 , x_city                 OUT NOCOPY VARCHAR2
                                 , x_address_detail       OUT NOCOPY VARCHAR2
                                 )
  IS

  CURSOR c_get_address IS
     SELECT DECODE(HL.country
            , 'ES', SUBSTR(HL.postal_code,1,2)||'000'
            , '99'||FT.eu_code)                   postal_code
          , SUBSTR(HL.town_or_city,1,24)          city
          , SUBSTR(HL.address_line_1,1,2)  ||
            SUBSTR(HL.address_line_2,1,23) ||
            LPAD(SUBSTR(HL.address_line_3,1,length(HL.address_line_3) -
            NVL(LENGTH(LTRIM(TRANSLATE(HL.address_line_3, '123456789','000000000'),'0')),0)),5,'0') address_detail
      FROM  hz_cust_acct_sites_all HCAS
          , hz_party_sites         HPS
          , hr_locations           HL
          , fnd_territories        FT
          , hz_cust_site_uses_all  HCSU
      WHERE  HCAS.cust_acct_site_id       = p_customer_address_id
      AND    HPS.party_site_id            = HCAS.party_site_id
      AND    HL.location_id               = HPS.location_id
      AND    HL.country(+)                = FT.territory_code
      AND    HCSU.cust_acct_site_id       = HCAS.cust_acct_site_id
      AND    UPPER(HCSU.site_use_code)    = 'LEGAL'
      AND    HCAS.bill_to_flag            IN ('P','Y')
      AND    HCAS.status                  = 'A'
      AND    HCSU.primary_flag            = 'Y'  ;

  BEGIN
    OPEN   c_get_address ;
    FETCH  c_get_address INTO x_postal_code, x_city, x_address_detail ;
    CLOSE  c_get_address ;
  END;
  --
  --
  PROCEDURE get_customer_address2 ( p_customer_address_id  IN         NUMBER
                                  , x_postal               OUT NOCOPY VARCHAR2
				  , x_post_code            OUT NOCOPY VARCHAR2
                                  , x_city                 OUT NOCOPY VARCHAR2
                                  , x_street_type          OUT NOCOPY VARCHAR2
                                  , x_street               OUT NOCOPY VARCHAR2
                                  , x_number               OUT NOCOPY VARCHAR2
                                  , x_country              OUT NOCOPY VARCHAR2
                                  )
  IS

  CURSOR c_get_address IS
   SELECT DECODE(HL.country
                  , 'ES', SUBSTR(HL.postal_code,1,2)||'   '
                  , '99'||FT.territory_code||' ')                            codigo_postal
          , SUBSTR(HL.postal_code,1,5)                   post_code
          , SUBSTR(HL.city,1,24)                         ref_catastral
          , SUBSTR(HL.address1,1,2)                        sigla
          , SUBSTR(HL.address2,1,25)                       via_publica
          , SUBSTR(HL.address3||'Z',1,INSTR(HL.address3||'Z',
                      LTRIM(HL.address3||'Z','1234567890')) - 1) numero
          , HL.country
      FROM  hz_cust_acct_sites_all HCAS
          , hz_party_sites         HPS
          , hz_locations           HL
          , fnd_territories        FT
          , hz_cust_site_uses_all  HCSU
      WHERE  HCAS.cust_acct_site_id       = p_customer_address_id
      AND    HPS.party_site_id            = HCAS.party_site_id
      AND    HL.location_id               = HPS.location_id
      AND    HL.country(+)                = FT.territory_code
      AND    HCSU.cust_acct_site_id       = HCAS.cust_acct_site_id
      AND    UPPER(HCSU.site_use_code)    = 'LEGAL'
      AND    HCAS.bill_to_flag            IN ('P','Y')
      AND    HCAS.status                  = 'A'
      AND    HCSU.primary_flag            = 'Y'  ;


  BEGIN
    OPEN   c_get_address ;
    FETCH  c_get_address
    INTO   x_postal
         , x_post_code
         , x_city
         , x_street_type
         , x_street
         , x_number
         , x_country;
    CLOSE  c_get_address ;
  END get_customer_address2 ;

  -- Modelo 347


 PROCEDURE arrenda ( p_vat_rep_entity_id IN VARCHAR2
                   , p_customer_id       IN NUMBER
                   , p_customer_name     IN VARCHAR2
                   , p_cust_tax_reg_num  IN VARCHAR2
                   , p_tipo              IN VARCHAR2)  -- Bug 8485057
 IS
   CURSOR arrenda
   IS
          /* Bug 8485057: Address information in GDF cols replaced with core HL table columns,
             added more address details and the new property_location_code*/
          SELECT   SUM(DECODE(JZVTD.TAX_LINE_NUMBER, '1', NVL(JZVTD.taxable_amt_funcl_curr, 0),0)) +
                   SUM(NVL(JZVTD.tax_amt_funcl_curr, 0))   trx_line_amt
                   /* total transaction amount was wrong, trx_line_amt calculation changed to consider
                      the total transaction amount only once, not for each tax line
                      SUM( NVL(JZVTD.taxable_amt_funcl_curr,JZVTD.taxable_amt ) )
                      + SUM( NVL(JZVTD.tax_amt_funcl_curr,JZVTD.tax_amt ) ) trx_line_amt */
                   /* removed, causing wrong number of records retrieved
                      ,   NVL(JZVTD.tax_rate_id,0)                tax_rate_id */
               ,   SUBSTR(HL.postal_code,1,5)              postcode
               ,   SUBSTR(HL.global_attribute2,1,25)       land_registry
               ,   HL.town_or_city                         city
               ,   SUBSTR(HL.address_line_1,1,2)           address1
               ,   SUBSTR(HL.address_line_2,1,25)          address2
               ,   SUBSTR(HL.address_line_3||'Z',1,INSTR(HL.address_line_3||'Z',
                             LTRIM(HL.address_line_3||'Z','1234567890')) - 1) address3
               ,   SUBSTR(hl.loc_information15,1,3)        stairs
               ,   SUBSTR(hl.loc_information16,1,3)        floor
               ,   SUBSTR(hl.loc_information17,1,3)        door
               ,   SUBSTR(hl.loc_information13,1,3)        number_type
               ,   SUBSTR(hl.loc_information18,1,3)        qualifier
               ,   SUBSTR(hl.loc_information14,1,3)        block
               ,   SUBSTR(hl.loc_information19,1,3)        portal
               ,   SUBSTR(hl.loc_information20,1,40)       complement
               ,   SUBSTR(hl.town_or_city,1,30)            locality
               ,   SUBSTR(hl.postal_code,1,5)              municipality_code
                -- Property location code:
               ,   DECODE (HL.country,
                            'ES', DECODE(NVL(HL.global_attribute2, 'N'),
                                  -- 3 Property in Spain without a land registry reference
                                  'N', 3,
                                  -- 2 Property in the Basque or Navarra Community
                                  DECODE (SUBSTR(HL.postal_code,1,2),
                                  '01', 2,
                                  '48', 2,
                                  '20', 2,
                                  '31', 2,
                                  -- 1 Property with land registry in Spain except 2
                                  1)),
                            -- 4 Property located outside Spain
                            4) property_location_code
          FROM     jg_zz_vat_rep_status    JZVRS
               ,   jg_zz_vat_trx_details   JZVTD
               ,   hz_cust_acct_sites_all HCAS
               ,   hz_party_sites         HPS
               ,   hr_locations           HL
            --   ,   fnd_territories        FT  -- Bug 8485057: not necessary
               ,   hz_cust_site_uses_all  HCSU
               ,   zx_lines_det_factors   ZXDF
               ,   ra_customer_trx        TRX
          WHERE    JZVRS.vat_reporting_entity_id  = P_VAT_REP_ENTITY_ID
          AND      JZVRS.reporting_status_id      = JZVTD.reporting_status_id
          AND      JZVTD.extract_source_ledger    = 'AR'
          AND      JZVRS.source                 = 'AR'
          AND      HCAS.cust_acct_site_id       = JZVTD.billing_tp_address_id
          AND      HPS.party_site_id            = HCAS.party_site_id
        /* Bug 8485057 section commented out, location is not the same as the customer's legal site, this validation can be done at the LOV level */
        --     AND      HL.location_id               = HPS.location_id
        --    AND      HL.country(+)                = FT.territory_code
          AND      HCSU.cust_acct_site_id       = HCAS.cust_acct_site_id
          AND      UPPER(HCSU.site_use_code)    = 'LEGAL'
          AND      HCAS.bill_to_flag            IN ('P','Y')
          AND      HCAS.status                  = 'A'
          AND      HCSU.primary_flag            = 'Y'
          AND      JZVTD.billing_trading_partner_id = p_customer_id
          AND      JZVTD.trx_date               BETWEEN G_FROM_DATE AND G_TO_DATE
          AND      SUBSTR(NVL(JZVTD.tax_rate_vat_trx_type_code,'QQQ'),1,3) <> 'RET_AR' -- tax_rate_vat_trx_type_code
          -- Bug 8485057 verify invoice_report_type directly from Trx Tax Lines
          AND      SUBSTR(ZXDF.trx_business_category, INSTR(zxdf.trx_business_category,'MOD')+3,
                     DECODE(INSTR(zxdf.trx_business_category,'/',1,3),0,length(zxdf.trx_business_category),
                     INSTR(zxdf.trx_business_category,'/',1,3) - (INSTR(zxdf.trx_business_category,'MOD')+3)))
                   IN ('347PR','415_347PR')
          AND      JZVTD.trx_id = ZXDF.trx_id
          AND      JZVTD.trx_line_id = ZXDF.trx_line_id
          AND      JZVTD.trx_id = TRX.customer_trx_id
          AND      HL.location_id = TO_NUMBER(TRX.global_attribute2)
          AND      TRX.global_attribute_category in ('JE.ES.ARXTWMAI.MODELO415_347PR','JE.ES.ARXTWMAI.MODELO347PR')
          -- Bug 8485057 transaction code (tipo) filter
          AND      DECODE( INSTR(ZXDF.trx_business_category,'/',1,3),0,'B',
                   SUBSTR(ZXDF.trx_business_category,length(ZXDF.trx_business_category),1)) = p_tipo
          GROUP BY  --  NVL(JZVTD.tax_rate_id,0),
                      SUBSTR(HL.postal_code,1,5)
                  ,   SUBSTR(HL.global_attribute2,1,25)
                  ,   HL.town_or_city
                  ,   SUBSTR(HL.address_line_1,1,2)
                  ,   SUBSTR(HL.address_line_2,1,25)
                  ,   SUBSTR(HL.address_line_3||'Z',1,INSTR(HL.address_line_3||'Z',
                      LTRIM(HL.address_line_3||'Z','1234567890')) - 1)
                  ,   SUBSTR(hl.loc_information15,1,3)
                  ,   SUBSTR(hl.loc_information16,1,3)
                  ,   SUBSTR(hl.loc_information17,1,3)
                  ,   SUBSTR(hl.loc_information13,1,3)
                  ,   SUBSTR(hl.loc_information18,1,3)
                  ,   SUBSTR(hl.loc_information14,1,3)
                  ,   SUBSTR(hl.loc_information19,1,3)
                  ,   SUBSTR(hl.loc_information20,1,40)
                  ,   SUBSTR(hl.town_or_city,1,30)
                  ,   SUBSTR(hl.postal_code,1,5)
                  ,   DECODE (HL.country,
                            'ES', DECODE(NVL(HL.global_attribute2, 'N'),
                                  'N', 3,
                                  DECODE (SUBSTR(HL.postal_code,1,2),
                                  '01', 2,
                                  '48', 2,
                                  '20', 2,
                                  '31', 2,
                                  1)),
                            4);

    BEGIN
       -- dbms_output.put_line ('Inside arrenda');

       FOR arrenda_rec IN arrenda LOOP

         /* IF LENGTH(arrenda_rec.postcode) = 2  -- i.e. the code is '99' only
         THEN
           arrenda_rec.postcode := '99958';
         END IF; */

         /**
           author:Brathod
           As no such currency conversion found in R11i code
           SELECT DECODE( G_CURRENCY_CODE, 'EUR', (arrenda_rec.trx_line_amt*100), arrenda_rec.trx_line_amt)
           INTO   arrenda_rec.trx_line_amt
           FROM   DUAL;
	       */

	      IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'inserting with tipo 3: p_cust_tax_reg_num=' ||p_cust_tax_reg_num); END IF;

         -- dbms_output.put_line ('inserting ');
         INSERT INTO JG_ZZ_VAT_TRX_GT
           ( jg_info_v1    -- tipo
           , jg_info_v6    -- p_tipo to link the arrenda record to its 'tipo' pair
           , jg_info_n2    -- importe       -- sum_trx_line_amt
           , jg_info_v11   -- nombre        -- cust name   (Bug 8485057 switched nif to v11)
           , jg_info_v12   -- nif           -- cust tax ref (Bug 8485057 switched nombre to v12)
           , jg_info_v25   -- sigla         -- address1
           , jg_info_v2    -- municipio     -- city (corrected)
           , jg_info_v18   -- codigo_postal -- postcode
           , jg_info_v27   -- fin_ind       -- 'S'
           , jg_info_v26    -- via_publica   -- address2,
           , jg_info_v20    -- numero        -- address3
           , jg_info_n4    -- comentario    -- Bug 8485057: 1 marks if record should not be listed in the magnetic format
           , jg_info_v21   -- flag_arrenda  -- 'Y'
           , jg_info_v3    -- escalera      -- loc_information15
           , jg_info_v4    -- piso          -- loc_information16
           , jg_info_v5    -- puerta        -- loc_information17
           , jg_info_v8    -- number type       -- loc_information13
           , jg_info_v9    -- number qualifier  -- loc_information18
           , jg_info_v10   -- block             -- loc_information14
           , jg_info_v28   -- portal            -- loc_information19
           , jg_info_v29   -- complement        -- loc_information20
           , jg_info_v19   -- ref_catastral     -- land_registry (corrected)
           , jg_info_v7    -- property location code
           , jg_info_v22   -- p_print_year      -- p_tax_calender_year
           , jg_info_v23   -- legal entity name
           )
         VALUES
           ('3'
           , p_tipo                         -- to link the arrenda record to its pair
           , arrenda_rec.trx_line_amt       -- importe
           , p_cust_tax_reg_num             -- Bug 8485057 switch nif to jg_info_v11 to make delete procedure work
           , p_customer_name                -- Bug 8485057 switch nombre to jg_info_v12
           , arrenda_rec.address1           --v_sg
           , arrenda_rec.city               --v_municipio
           , arrenda_rec.postcode           --v_codigo_postal,
           , 'S'                            --fin_ind
           , arrenda_rec.address2           --v_via_publica,
           , arrenda_rec.address3           --v_numero,
           , NULL                           --comentario
           ,'Y'                             --flag_arrenda,
           , arrenda_rec.stairs             --v_escalera,
           , arrenda_rec.floor              --v_piso,
           , arrenda_rec.door               --v_puerta,
           , arrenda_rec.number_type
           , arrenda_rec.qualifier
           , arrenda_rec.block
           , arrenda_rec.portal
           , arrenda_rec.complement
           , arrenda_rec.land_registry      --v_ref_catastral
           , arrenda_rec.property_location_code
           , p_tax_year
           , g_le_trn                       -- legal entity name
           );

       END LOOP;


  END;

  -- Modelo 349

  Procedure JGZZVEFT
  IS

    CURSOR C_Spa_Pay_Mag_Ext
    IS
    /*SELECT  SUBSTR(jg_info_v11,1,2)                C_CODIGO_PAIS             -- TAX REG NUM
         ,  RPAD(SUBSTR(jg_info_v11,3,12),15,' ')  C_NIF_OPERADOR            -- -do-
         ,  RPAD(jg_info_v12,40,' ')               C_NOMBRE                  -- cust name
         ,  UPPER(jg_info_v1)                      C_CLAVE_OPERACION
         ,  jg_info_n12                            C_BASE_IMPONIBLE
         ,  jg_info_n10                            C_RUNNING_TOTAL
         ,  jg_info_n11                            C_FORMERLY_DECL_AMOUNT
         ,  jg_info_v15                            C_YEAR
         ,  jg_info_v16                            C_PERIOD
         ,  jg_info_v17                            C_OPERACION_TRIANGULAR
         ,  rowid                                  row_id
    FROM    JG_ZZ_VAT_TRX_GT
    ORDER BY  rpad(jg_info_v12,40,'A')
           ,  jg_info_v1,jg_info_v15, jg_info_v16 desc;*/ -- Bug 5525421
 /** This query is used to find out the report level information of the following 1. summ of correction amount
    2. sum non correction amount 3. number of correction records and 4. number of non correction records
    This information will be displayed on the header line of the report. */
    SELECT  jg_info_v22                     YEAR_CAB
         ,  jg_info_v26                     LE_TRN
         ,  SUBSTR(jg_info_v11,1,2)         C_CODIGO_PAIS             -- TAX REG NUM
         ,  RPAD(SUBSTR(jg_info_v11,3,12),15,' ') C_NIF_OPERADOR            -- -do-
         ,  RPAD(jg_info_v12,40,' ')              C_NOMBRE                  -- cust name
         ,  UPPER(jg_info_v1)               C_CLAVE_OPERACION
         ,  jg_info_v15                     C_YEAR
         ,  jg_info_v16                     C_PERIOD
         ,  SUM(NVL(jg_info_n12,0))          C_BASE_IMPONIBLE
         ,  SUM(jg_info_n11)                C_FORMERLY_DECL_AMOUNT
	 ,  SUM(jg_info_n10)                 C_RUNNING_TOTAL
         ,  jg_info_v23                     SIGN
         ,  jg_info_v18                     POST_CODE
         ,  jg_info_v17                     OPERACION_TRIANGULAR
    FROM    JG_ZZ_VAT_TRX_GT                JZVTG
    WHERE   NVL(JZVTG.jg_info_v30, 'X') <>'H'
    AND	    jg_info_v27	 = DECODE(P_DISPLAY_PERIOD,'OA',jg_info_v27,P_DISPLAY_PERIOD) -- Modified for Bug 7486406
    GROUP BY jg_info_v21
         ,   jg_info_v22
         ,   SUBSTR(jg_info_v11,1,2)
         ,   RPAD(SUBSTR(jg_info_v11,3,12),15,' ')
         ,   Jg_info_v12
         ,   jg_info_v1
         ,   jg_info_v15
         ,   jg_info_v16
         ,   jg_info_v17
         ,   jg_info_v18
         ,   jg_info_v23
         ,  jg_info_v26
    ORDER BY  rpad(jg_info_v12,40,'A')
           , jg_info_v1
	   , NVL(jg_info_v15,0)
           , NVL(jg_info_v16,'A');

    ln_base_imponible               NUMBER := 0;
    ln_base_imponible_dup           NUMBER := 0;
    ln_base_imponible_imp           NUMBER := 0;
    ln_running_total                NUMBER := 0;
    ln_formerly_decl_amount         NUMBER := 0;
    ln_corr_taxable_amount          NUMBER := 0;
    ln_imp_1                        NUMBER := 0;
    ln_imp_2                        NUMBER := 0;
    ln_cuenta_1                     NUMBER := 0;
    ln_cuenta_2                     NUMBER := 0;
    ln_cuenta_3_4                   NUMBER := 0;

    ln_grp_imp_1                    NUMBER := 0;
    ln_grp_imp_2                    NUMBER := 0;
    ln_grp_cuenta_1                 NUMBER := 0;
    ln_grp_cuenta_2                 NUMBER := 0;
    ln_grp_cuenta_3_4               NUMBER := 0;

    lc_clave_operacion              VARCHAR2(5);
    lc_cur_derive_type              VARCHAR2(5);
    lc_source_ledger                VARCHAR2(30);

  BEGIN

         -- Call to common routine to fetch legal entity info.
         BEGIN
           SELECT DECODE(curr.derive_type,'EURO','343','349')
           INTO lc_cur_derive_type
           FROM fnd_currencies curr
           WHERE currency_code = g_currency_code;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
            lc_cur_derive_type := '349' ;
         END;

         FOR c_spa_mag_rec IN C_Spa_Pay_Mag_Ext LOOP


            --  Note that while inserting the correction we insert a small 'a','e' or 't'
            --  so that the order by in the report works fine */

            lc_clave_operacion := c_spa_mag_rec.c_clave_operacion;

            --
            -- Computation logic for running total and formerly_declared_amount should be inserted here
            --
            ln_running_total        := c_spa_mag_rec.c_running_total;
            ln_formerly_decl_amount := c_spa_mag_rec.c_formerly_decl_amount;
            ln_base_imponible       := c_spa_mag_rec.c_base_imponible;

	    --
            ln_corr_taxable_amount := ln_formerly_decl_amount + ln_base_imponible ;
            --
            -- CF_BASE_IMPON_DUPFormula return Number is
            -- and CF_BASE_IMPONIBLEFormula return VARCHAR2 is
            --
            BEGIN

               IF lc_cur_derive_type = '343' /* i.e. functional Currency = EURO */
               THEN
                 ln_base_imponible_imp  := ln_base_imponible * 100;
                 ln_base_imponible_dup  := (ln_base_imponible + ln_formerly_decl_amount) * 100;
               ELSE
                 ln_base_imponible_imp  := ln_base_imponible;
                 ln_base_imponible_dup  :=  ln_base_imponible + ln_formerly_decl_amount;
               END IF;
               --srw.message('1000', 'CP Base Imponible...' || to_char(:cp_base_imponible));

            END;

            -- End of CF_BASE_IMPON_DUPFormula

            -- CF_IMP_1Formula

            IF c_spa_mag_rec.c_year IS NOT NULL AND c_spa_mag_rec.c_period IS NOT NULL THEN
                ln_cuenta_3_4 := 1;
                ln_cuenta_1   := 0;
                ln_imp_2      := ln_base_imponible_dup;
		ln_imp_1      := 0;
            END IF;

            IF ( lc_clave_operacion = 'E' OR
                 lc_clave_operacion = 'T' OR
                 lc_clave_operacion = 'A') THEN

               IF  (c_spa_mag_rec.c_year IS NULL AND c_spa_mag_rec.c_period IS NULL ) THEN  -- Not a correction record
                  ln_cuenta_1   := 1;
                  ln_cuenta_3_4 := 0;
                  ln_imp_2      := 0;
                  ln_imp_1      := ln_base_imponible_dup;
               ELSE
                  ln_imp_1      := 0;
               END IF;
            END IF;

            -- End of CF_IMP_1Formula

            ln_grp_imp_1      := ln_grp_imp_1      + ln_imp_1 ;
            ln_grp_imp_2      := ln_grp_imp_2      + ln_imp_2 ;
            ln_grp_cuenta_1   := ln_grp_cuenta_1   + ln_cuenta_1;
            ln_grp_cuenta_2   := ln_grp_cuenta_2   + ln_cuenta_2;
            ln_grp_cuenta_3_4 := ln_grp_cuenta_3_4 + ln_cuenta_3_4;

            ln_imp_1      := 0;
            ln_imp_1      := 0;
            ln_cuenta_1   := 0;
            ln_cuenta_2   := 0;
            ln_cuenta_3_4 := 0;

         END LOOP;

         UPDATE  JG_ZZ_VAT_TRX_GT
         SET     jg_info_N1 = ln_grp_cuenta_1
              ,  jg_info_N2 = ln_grp_imp_1
              ,  jg_info_N3 = ln_grp_cuenta_3_4
              ,  jg_info_N4 = ln_grp_imp_2
         WHERE   jg_info_v30 = 'H' ;

  END;

  -- Modelo 340
  -- BUG 8946271
  FUNCTION getKeyID (countryCode IN VARCHAR2) RETURN NUMBER IS
      l_key_id   NUMBER;
  BEGIN

    -- The report should check for first 2 characters of NIF. If it is 'ES' key_id
    -- should be 1, if it is one of the EU member countries then it should be 2,
    -- otherwise 6.
    if countryCode = 'ES' THEN
          l_key_id := 1;
    elsif countryCode in ('AT','BE','BG','CY','CZ','DE','DK','EE','EL','ES','FI','FR','GB','GR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK') THEN
          l_key_id := 2;
    else
          l_key_id := 6;
    end if;

    return (l_key_id);

  END getKeyID;

  function format_amount ( p_amount IN NUMBER ) return Char is
    lv_decimal_separator varchar2 (1);
  begin

  /* Get the decimal separator from the profile */
  lv_decimal_separator := substr(fnd_profile.value('ICX_NUMERIC_CHARACTERS'),1,1);  -- Bug 5525421

  -- lv_decimal_separator := '.';
   /** author: brathod
       date  : 22/05/2006
       Forward porting bug: 4771261 for 11i bug:4748029
   */
   /* If c_base_imponible has no decimals */  -- Bug 4748029

    if  instr(to_char(p_amount),lv_decimal_separator,1,1) = 0 then -- Bug 4748029
      RETURN((lpad(to_char(p_amount),11,'0')||'00'));  -- Bug 4748029
    end if;

    /* If c_base_imponible has decimals */     -- Bug 4748029
    if instr(p_amount,lv_decimal_separator,1,1) >0 then -- Bug 4748029
      RETURN(lpad(substr(p_amount ,1,instr(to_char(p_amount),lv_decimal_separator,1,1)-1),11,'0')||
                  rpad(substr(p_amount,instr(to_char(p_amount),lv_decimal_separator,1,1)+1,2),2,'0')) ; -- Bug 4748029
    end if;
  end;

  -- Modelo 415

  FUNCTION CF_POSTCODEFormula ( p_postcode IN VARCHAR2 ) return VARCHAR2 is
  BEGIN

    IF NVL(LENGTH(p_postcode), 0) = 2  /* i.e. '99' with no country code as territory unknown */
    THEN
      RETURN(p_postcode||'958'); /* 958 is default European country code for 'unknown' */
    ELSE
      RETURN(p_postcode);
    END IF;

    RETURN NULL;
  END;

  FUNCTION AP415_GROSS_AMOUNTFormula ( p_vendor_id     IN NUMBER
                                     , p_gross_amount  IN NUMBER )
                                      return Number is
     v_prepay_applied number;

  BEGIN

     SELECT  SUM(ROUND(DECODE( NVL(JZVTD.taxable_amt_funcl_curr,0)
                              ,0 , JZVTD.taxable_amt
                              ,    JZVTD.taxable_amt_funcl_curr
                              ))
                 -  NVL(AID.prepay_amount_remaining, 0 )* -1
                )
     INTO    V_PREPAY_APPLIED
     FROM    jg_zz_vat_trx_details      JZVTD
            ,jg_zz_vat_rep_status       JZVRS
            ,ap_invoice_distributions   AID
     WHERE   JZVRS.reporting_status_id        = JZVTD.reporting_status_id
     AND     JZVTD.billing_trading_partner_id = p_vendor_id
     AND     JZVTD.trx_type_mng               = 'PREPAYMENT'
     --AND     JZVTD.posted_flag                IN ('P','Y')  /** author: brathod; Removed posted_flag checking as it is not relevent in R12 */
     AND     JZVTD.trx_line_type              = 'ITEM'
     AND     NVL(JZVTD.reverse_flag, 'N')     <> 'Y'
     AND     AID.invoice_distribution_id      =  JZVTD.trx_line_id
     AND     AID.invoice_id                   =  JZVTD.trx_id
     AND     AID.prepay_amount_remaining      IS NOT NULL
     AND     JZVTD.invoice_report_type        IN ('415'
                                                 ,'415_347'
                                                 ,'415_347PR')
     AND     JZVRS.vat_reporting_entity_id = P_VAT_REP_ENTITY_ID
     /**
      author: brathod
      date: 18/05/2006
      Commented only period based filtering and added AND condition to also consider year
      filtering for ANNUAL reports
      -- JZVRS.tax_calendar_period     = P_TAX_PERIOD
     */
     AND     (  (P_REPORT_NAME = 'JEESPMOR' AND JZVRS.tax_calendar_period     --= P_TAX_PERIOD
                                                                      in (
              SELECT RPS1.tax_calendar_period
              FROM JG_ZZ_VAT_REP_STATUS RPS1,
                   (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
                           min(period_start_date) period_start_date
                    From JG_ZZ_VAT_REP_STATUS
                    Where vat_reporting_entity_id = p_vat_rep_entity_id
                    And tax_calendar_period = p_tax_period) RPS2,
                   (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
                          min(period_end_date) period_end_date
                    From JG_ZZ_VAT_REP_STATUS
                    Where vat_reporting_entity_id = p_vat_rep_entity_id
                    And tax_calendar_period = p_tax_period_to) RPS3
              WHERE RPS1.vat_reporting_entity_id = p_vat_rep_entity_id
                AND RPS2.vat_reporting_entity_id = RPS1.vat_reporting_entity_id
                AND RPS3.vat_reporting_entity_id = RPS2.vat_reporting_entity_id
                AND trunc(RPS1.period_start_date) >=
                               trunc(RPS2.period_start_date)
                AND trunc(RPS1.period_end_date) <= trunc(RPS3.period_end_date)
              GROUP by RPS1.tax_calendar_period
                                                                         ))
             OR (P_REPORT_NAME = 'JEESAMOR' AND JZVRS.tax_calendar_year       = P_TAX_YEAR )
             )
     ;
     --Bug 1064230 - prepayment amount already accounted for
     RETURN( p_gross_amount - NVL(v_prepay_applied,0));


  RETURN NULL; EXCEPTION
    WHEN OTHERS THEN
      RETURN(p_gross_amount);

  END;

  FUNCTION AP347_GROSS_AMOUNTFormula ( p_vendor_id      IN NUMBER
                                     , p_property_flag  IN VARCHAR2
                                     , p_gross_amt      IN NUMBER
                                     , p_tipo           IN VARCHAR2) -- Bug 8485057
                                      return Number is
     v_prepay_applied number;

  BEGIN

     SELECT  SUM(ROUND(DECODE( NVL(JZVTD.taxable_amt_funcl_curr,0)
                              ,0 , JZVTD.taxable_amt
                              ,    JZVTD.taxable_amt_funcl_curr
                              )
                 , g_cur_precision)
                )
     INTO    V_PREPAY_APPLIED
     FROM    jg_zz_vat_trx_details      JZVTD
            ,jg_zz_vat_rep_status       JZVRS
            ,ap_invoice_distributions   AID
            ,ap_invoice_distributions   PRE
            ,hz_parties                 HP
            ,ap_invoices_all            API
	        ,zx_lines_det_factors       ZXDF
     WHERE   JZVRS.reporting_status_id        = JZVTD.reporting_status_id
     AND     JZVTD.billing_trading_partner_id = p_vendor_id
     AND     JZVTD.trx_type_mng               = 'PREPAYMENT'
     --AND     JZVTD.posted_flag                IN ('P','Y')  /** author:brathod; Removed posted_flag checking as it is not relevent in R12 */
     AND     AID.invoice_Id                    =  JZVTD.trx_id
     AND     PRE.invoice_distribution_id      =  AID.invoice_distribution_id
     AND     PRE.posted_flag                  IN ('P','Y')
     AND     PRE.line_type_lookup_code        <> 'AWT'
     AND     HP.party_id                      =  JZVTD.billing_trading_partner_id
     AND     NVL(hp.party_type, 'XXX')        <> 'EMPLOYEE'
     AND     DECODE( INSTR(ZXDF.trx_business_category,'PR'), 0, 'N', 'Y') = p_property_flag
     -- Bug 8485057 verify invoice_report_type directly from Invoice
     AND     SUBSTR(ZXDF.trx_business_category, INSTR(ZXDF.trx_business_category,'MOD')+3,
               DECODE(INSTR(ZXDF.trx_business_category,'/',1,3),0,length(ZXDF.trx_business_category),
                 INSTR(ZXDF.trx_business_category,'/',1,3) - (INSTR(ZXDF.trx_business_category,'MOD')+3)))
             IN ( '347', '347PR', '415_347', '415_347PR')
     -- Bug 8485057 added filter by tipo (transaction code)
     AND     DECODE( INSTR(ZXDF.trx_business_category,'/',1,3),0,'A',
         substr(ZXDF.trx_business_category,length(ZXDF.trx_business_category),1)) = p_tipo
     AND     JZVTD.trx_id = API.invoice_id
     AND     jzvtd.trx_id = zxdf.trx_id
     AND     jzvtd.trx_line_id = zxdf.trx_line_id
     AND     JZVRS.vat_reporting_entity_id = P_VAT_REP_ENTITY_ID
     /**
      author: brathod
      date  : 18/05/2006
      Commented only period based filtering and added AND condition to also consider year
      filtering for ANNUAL reports
      -- JZVRS.tax_calendar_period     = P_TAX_PERIOD
     */
     AND     (  (P_REPORT_NAME = 'JEESPMOR' AND JZVRS.tax_calendar_period     --= P_TAX_PERIOD
                                                                      in (
              SELECT RPS1.tax_calendar_period
              FROM JG_ZZ_VAT_REP_STATUS RPS1,
                   (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
                           min(period_start_date) period_start_date
                    From JG_ZZ_VAT_REP_STATUS
                    Where vat_reporting_entity_id = p_vat_rep_entity_id
                    And tax_calendar_period = p_tax_period) RPS2,
                   (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
                          min(period_end_date) period_end_date
                    From JG_ZZ_VAT_REP_STATUS
                    Where vat_reporting_entity_id = p_vat_rep_entity_id
                    And tax_calendar_period = p_tax_period_to) RPS3
              WHERE RPS1.vat_reporting_entity_id = p_vat_rep_entity_id
                AND RPS2.vat_reporting_entity_id = RPS1.vat_reporting_entity_id
                AND RPS3.vat_reporting_entity_id = RPS2.vat_reporting_entity_id
                AND trunc(RPS1.period_start_date) >=
                               trunc(RPS2.period_start_date)
                AND trunc(RPS1.period_end_date) <= trunc(RPS3.period_end_date)
              GROUP by RPS1.tax_calendar_period
                                                                         ))
             OR (P_REPORT_NAME = 'JEESAMOR' AND JZVRS.tax_calendar_year       = P_TAX_YEAR )
             );
     --Bug 1064230 - prepayment amount already accounted for
     RETURN( p_gross_amt - NVL(v_prepay_applied,0));


  RETURN NULL; EXCEPTION
    WHEN OTHERS THEN
      RETURN( p_gross_amt );

  END;

  FUNCTION AR347_GROSS_AMOUNTFormula ( p_customer_id      IN NUMBER,
                                       p_tipo             IN VARCHAR) -- Bug 8485057
  RETURN NUMBER is

     v_arrenda_amount number;

  BEGIN

    /**
    author: brathod
    Commented to use jg_zz_vat_trx_detail instead of JG_ZZ_VAT_TRX_GT
    SELECT SUM(ROUND(DECODE( NVL(JVGT.jg_info_n8,0)
                      ,0 , JVGT.jg_info_n6
                      ,    JVGT.jg_info_n8
                      )
                , g_cur_precision)
               )
     INTO   v_arrenda_amount
     FROM   JG_ZZ_VAT_TRX_GT    JVGT
          , hz_cust_acct_sites_all HCAS
          , hz_party_sites         HPS
          , hz_locations           HL
          , fnd_territories        FT
          , hz_cust_site_uses_all  HCSU
     WHERE  JVGT.jg_info_n3              = p_customer_id
     AND    HCAS.cust_acct_site_id       = JVGT.jg_info_n2
     AND    HPS.party_site_id            = HCAS.party_site_id
     AND    HL.location_id               = HPS.location_id
     AND    HL.country(+)                = FT.territory_code
     AND    HCSU.cust_acct_site_id       = HCAS.cust_acct_site_id
     AND    UPPER(HCSU.site_use_code)    = 'LEGAL'
     AND    HCAS.bill_to_flag            = 'Y'
     AND    HCAS.status                  = 'A'
     AND    JVGT.jg_info_d5              IS NOT NULL
     AND    NVL(JVGT.jg_info_v25, 'N')   = 'N'           -- posted_flag
     AND    JVGT.jg_info_v31             <> 'DEBIT'      -- invoice_type_lookup_code
     AND    HCSU.primary_flag            = 'Y'
     AND    SUBSTR(NVL(JVGT.jg_info_v31,'QQQQQQ'),1,3) <> 'RET' -- tax_rate_vat_trx_type_code
     AND    JVGT.jg_info_v11      IN ('347'
           ,'347PR');*/

     /**
     author: brathod
     1.  Add code below to use jg_zz_vat_trx_detail instead of JG_ZZ_VAT_TRX_GT
     2.  Commented TCA related tables as they are not required to fetch the amount and directly joined HCSU with JVGT*
     */

     SELECT /* Bug 8485057: total transaction amount was wrong, trx_line_amt calculation changed to consider
               the total transaction amount only once, not for each tax line */
            SUM(DECODE(JZVTD.TAX_LINE_NUMBER, '1', NVL(JZVTD.taxable_amt_funcl_curr, 0),0))
		+ SUM(NVL(JZVTD.tax_amt_funcl_curr, 0))
     INTO  v_arrenda_amount
     FROM   jg_zz_vat_trx_details JZVTD, jg_zz_vat_rep_status JZVRS
          , hz_cust_site_uses_all  HCSU
          , zx_lines_det_factors ZXDF -- Bug 8485057
     WHERE  JZVTD.billing_trading_partner_id = p_customer_id
     AND    HCSU.cust_acct_site_id       =   JZVTD.billing_tp_address_id
     AND    UPPER(HCSU.site_use_code)    = 'LEGAL'
     AND    JZVTD.extract_source_ledger = 'AR'
     AND    JZVTD.event_class_code not in ('DEBIT_MEMO', 'APP', 'ADJ')
    -- AND   JZVTD.accounting_date IS NOT NULL --bug5557860
    -- AND   JZVTD.posted_flag = 'Y'   /** author: brathod; removed posted_flag checking as it is not relevent in R12*/
     AND   HCSU.primary_flag            = 'Y'
     AND   SUBSTR(NVL(JZVTD.tax_rate_vat_trx_type_code,'QQQQQQ'),1,3) <> 'RET' -- tax_rate_vat_trx_type_code
    -- Bug 8485057 verify invoice_report_type directly from Trx Tax Lines
     AND     SUBSTR(ZXDF.trx_business_category, INSTR(ZXDF.trx_business_category,'MOD')+3,
               DECODE(INSTR(ZXDF.trx_business_category,'/',1,3),0,length(ZXDF.trx_business_category),
                 INSTR(ZXDF.trx_business_category,'/',1,3) - (INSTR(ZXDF.trx_business_category,'MOD')+3)))
             IN ( '347PR', '415_347PR')
    AND     JZVTD.trx_id = ZXDF.trx_id
    AND     JZVTD.trx_line_id = ZXDF.trx_line_id
    -- Bug 8485057 added filter by tipo (transaction code)
    AND     DECODE( INSTR(ZXDF.trx_business_category,'/',1,3),0,'B',
            substr(ZXDF.trx_business_category,length(ZXDF.trx_business_category),1)) = p_tipo

     /**
       author: brathod
       date  : 18/05/2006
       Added AND condition to consider year and period based filtering
     */
     AND     JZVRS.VAT_REPORTING_ENTITY_ID = P_VAT_REP_ENTITY_ID
     AND     JZVRS.source                 = 'AR'
     AND     JZVRS.reporting_status_id      = JZVTD.reporting_status_id
     AND     (  (P_REPORT_NAME = 'JEESPMOR' AND JZVRS.tax_calendar_period     --= P_TAX_PERIOD
                                                                      in (
              SELECT RPS1.tax_calendar_period
              FROM JG_ZZ_VAT_REP_STATUS RPS1,
                   (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
                           min(period_start_date) period_start_date
                    From JG_ZZ_VAT_REP_STATUS
                    Where vat_reporting_entity_id = p_vat_rep_entity_id
                    And tax_calendar_period = p_tax_period) RPS2,
                   (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
                          min(period_end_date) period_end_date
                    From JG_ZZ_VAT_REP_STATUS
                    Where vat_reporting_entity_id = p_vat_rep_entity_id
                    And tax_calendar_period = p_tax_period_to) RPS3
              WHERE RPS1.vat_reporting_entity_id = p_vat_rep_entity_id
                AND RPS2.vat_reporting_entity_id = RPS1.vat_reporting_entity_id
                AND RPS3.vat_reporting_entity_id = RPS2.vat_reporting_entity_id
                AND trunc(RPS1.period_start_date) >=
                               trunc(RPS2.period_start_date)
                AND trunc(RPS1.period_end_date) <= trunc(RPS3.period_end_date)
              GROUP by RPS1.tax_calendar_period
                                                                         ))
             OR (P_REPORT_NAME = 'JEESAMOR' AND JZVRS.tax_calendar_year       = P_TAX_YEAR ));
     --  GROUP BY ROUND( NVL(JZVTD.taxable_amt_funcl_curr,JZVTD.taxable_amt ) , 2);

     --Bug 1064230 - prepayment amount already accounted for
     RETURN( NVL(v_arrenda_amount,0));


  RETURN NULL; EXCEPTION
    WHEN OTHERS THEN
      RETURN( 0 );

  END AR347_GROSS_AMOUNTFormula;

  /* Bug 8485057 Calculate the cash amount received for the selected transaction.
  The cash receipt must have the payment method specified by the customer in the profile option. */
  FUNCTION AR347_CASH_RECEIVEDFormula ( p_customer_id           IN NUMBER,
                                        p_tipo                  IN VARCHAR,
                                        p_property_rental_flag  IN VARCHAR)
  RETURN NUMBER is
     v_cash_received_amount number;

  BEGIN
    /* Note to developers: the following select statements are identical, except for the ZXDF.trx_business_category
       values ('347PR','415_347PR') or ('347','415_347'). All changes must be applied to both statements. */
    IF p_property_rental_flag = 'Y'
    THEN
      SELECT SUM(NVL(DECODE(CR.type,'MISC', 0
                              ,DECODE(RA.status,'APP',RA.AMOUNT_APPLIED,0)),0))
             / COUNT(JZVTD.trx_id)
      INTO   v_cash_received_amount
      FROM   jg_zz_vat_trx_details JZVTD, jg_zz_vat_rep_status JZVRS
           , hz_cust_site_uses_all  HCSU
           , zx_lines_det_factors ZXDF
           , ar_receivable_applications_all RA, ar_cash_receipts_all CR
      WHERE  JZVTD.billing_trading_partner_id = p_customer_id
      AND    HCSU.cust_acct_site_id       =   JZVTD.billing_tp_address_id
      AND    UPPER(HCSU.site_use_code)    = 'LEGAL'
      AND    JZVTD.extract_source_ledger = 'AR'
      AND    JZVTD.event_class_code not in ('DEBIT_MEMO', 'APP', 'ADJ')
      AND    HCSU.primary_flag            = 'Y'
      AND    SUBSTR(NVL(JZVTD.tax_rate_vat_trx_type_code,'QQQQQQ'),1,3) <> 'RET'
             -- Bug 8485057 verify invoice_report_type directly from Trx Tax Lines
      AND    SUBSTR(ZXDF.trx_business_category, INSTR(ZXDF.trx_business_category,'MOD')+3,
               DECODE(INSTR(ZXDF.trx_business_category,'/',1,3),0,length(ZXDF.trx_business_category),
                 INSTR(ZXDF.trx_business_category,'/',1,3) - (INSTR(ZXDF.trx_business_category,'MOD')+3)))
             IN ('347PR','415_347PR')
      AND    JZVTD.trx_id = ZXDF.trx_id
      AND    JZVTD.trx_line_id = ZXDF.trx_line_id
             -- Bug 8485057 filter by tipo (transaction code)
      AND    DECODE( INSTR(ZXDF.trx_business_category,'/',1,3),0,'B',
               substr(ZXDF.trx_business_category,length(ZXDF.trx_business_category),1)) = p_tipo
      AND    JZVRS.VAT_REPORTING_ENTITY_ID = P_VAT_REP_ENTITY_ID
      AND    JZVRS.source                 = 'AR'
      AND    JZVRS.reporting_status_id      = JZVTD.reporting_status_id
      AND    (  (P_REPORT_NAME = 'JEESPMOR' AND JZVRS.tax_calendar_period in (
              SELECT RPS1.tax_calendar_period
              FROM JG_ZZ_VAT_REP_STATUS RPS1,
                   (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
                           min(period_start_date) period_start_date
                    From JG_ZZ_VAT_REP_STATUS
                    Where vat_reporting_entity_id = p_vat_rep_entity_id
                    And tax_calendar_period = p_tax_period) RPS2,
                   (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
                          min(period_end_date) period_end_date
                    From JG_ZZ_VAT_REP_STATUS
                    Where vat_reporting_entity_id = p_vat_rep_entity_id
                    And tax_calendar_period = p_tax_period_to) RPS3
              WHERE RPS1.vat_reporting_entity_id = p_vat_rep_entity_id
                AND RPS2.vat_reporting_entity_id = RPS1.vat_reporting_entity_id
                AND RPS3.vat_reporting_entity_id = RPS2.vat_reporting_entity_id
                AND trunc(RPS1.period_start_date) >=
                               trunc(RPS2.period_start_date)
                AND trunc(RPS1.period_end_date) <= trunc(RPS3.period_end_date)
              GROUP by RPS1.tax_calendar_period
                                                                         ))
             OR (P_REPORT_NAME = 'JEESAMOR' AND JZVRS.tax_calendar_year       = P_TAX_YEAR ))
      AND RA.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
      AND JZVTD.trx_id = RA.APPLIED_CUSTOMER_TRX_ID
      AND CR.RECEIPT_METHOD_ID = fnd_profile.value('JEES_MOD347_RECEIPT_METHOD');
    ELSE
      SELECT SUM(NVL(DECODE(CR.type,'MISC', 0
                              ,DECODE(RA.status,'APP',RA.AMOUNT_APPLIED,0)),0))
             / COUNT(JZVTD.trx_id)
      INTO   v_cash_received_amount
      FROM   jg_zz_vat_trx_details JZVTD, jg_zz_vat_rep_status JZVRS
           , hz_cust_site_uses_all  HCSU
           , zx_lines_det_factors ZXDF
           , ar_receivable_applications_all RA, ar_cash_receipts_all CR
      WHERE  JZVTD.billing_trading_partner_id = p_customer_id
      AND    HCSU.cust_acct_site_id       =   JZVTD.billing_tp_address_id
      AND    UPPER(HCSU.site_use_code)    = 'LEGAL'
      AND    JZVTD.extract_source_ledger = 'AR'
      AND    JZVTD.event_class_code not in ('DEBIT_MEMO', 'APP', 'ADJ')
      AND    HCSU.primary_flag            = 'Y'
      AND    SUBSTR(NVL(JZVTD.tax_rate_vat_trx_type_code,'QQQQQQ'),1,3) <> 'RET'
             -- Bug 8485057 verify invoice_report_type directly from Trx Tax Lines
      AND    SUBSTR(ZXDF.trx_business_category, INSTR(ZXDF.trx_business_category,'MOD')+3,
               DECODE(INSTR(ZXDF.trx_business_category,'/',1,3),0,length(ZXDF.trx_business_category),
                 INSTR(ZXDF.trx_business_category,'/',1,3) - (INSTR(ZXDF.trx_business_category,'MOD')+3)))
             IN ('347','415_347')
      AND    JZVTD.trx_id = ZXDF.trx_id
      AND    JZVTD.trx_line_id = ZXDF.trx_line_id
             -- Bug 8485057 filter by tipo (transaction code)
      AND    DECODE( INSTR(ZXDF.trx_business_category,'/',1,3),0,'B',
                substr(ZXDF.trx_business_category,length(ZXDF.trx_business_category),1)) = p_tipo
      AND    JZVRS.VAT_REPORTING_ENTITY_ID = P_VAT_REP_ENTITY_ID
      AND    JZVRS.source                 = 'AR'
      AND    JZVRS.reporting_status_id      = JZVTD.reporting_status_id
      AND    (  (P_REPORT_NAME = 'JEESPMOR' AND JZVRS.tax_calendar_period in (
              SELECT RPS1.tax_calendar_period
              FROM JG_ZZ_VAT_REP_STATUS RPS1,
                   (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
                           min(period_start_date) period_start_date
                    From JG_ZZ_VAT_REP_STATUS
                    Where vat_reporting_entity_id = p_vat_rep_entity_id
                    And tax_calendar_period = p_tax_period) RPS2,
                   (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
                          min(period_end_date) period_end_date
                    From JG_ZZ_VAT_REP_STATUS
                    Where vat_reporting_entity_id = p_vat_rep_entity_id
                    And tax_calendar_period = p_tax_period_to) RPS3
              WHERE RPS1.vat_reporting_entity_id = p_vat_rep_entity_id
                AND RPS2.vat_reporting_entity_id = RPS1.vat_reporting_entity_id
                AND RPS3.vat_reporting_entity_id = RPS2.vat_reporting_entity_id
                AND trunc(RPS1.period_start_date) >=
                               trunc(RPS2.period_start_date)
                AND trunc(RPS1.period_end_date) <= trunc(RPS3.period_end_date)
              GROUP by RPS1.tax_calendar_period
                                                                         ))
             OR (P_REPORT_NAME = 'JEESAMOR' AND JZVRS.tax_calendar_year       = P_TAX_YEAR ))
       AND RA.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
       AND JZVTD.trx_id = RA.APPLIED_CUSTOMER_TRX_ID
       AND CR.RECEIPT_METHOD_ID = fnd_profile.value('JEES_MOD347_RECEIPT_METHOD');
     END IF;

     RETURN( NVL(v_cash_received_amount,0));

    RETURN NULL;
    EXCEPTION
    WHEN OTHERS THEN
      RETURN( 0 );

  END AR347_CASH_RECEIVEDFormula;

  /* Bug 8485057 mark records (jg_info_n4 = 1) that do not satisfy the minimum amount parameter.
     Transaction codes(Tipos) A, B are subject to minimum amount. Tipos F,G are not.
       Note that there might be a record tipo '3' corresponding to the tipo passed as parameter and
       that should also be deleted */
  PROCEDURE MOD347_MIN_AMOUNT ( p_tipo IN VARCHAR2 ) IS

  BEGIN
    UPDATE JG_ZZ_VAT_TRX_GT JZVTG
    SET    JZVTG.jg_info_n4 = 1
    WHERE JZVTG.jg_info_v11  IN (
               SELECT    JZVTG1.jg_info_v11
               FROM     JG_ZZ_VAT_TRX_GT JZVTG1
               WHERE    JZVTG1.jg_info_v1= p_tipo
               AND      NVL(JZVTG.jg_info_n4,0) <> 1  -- record was not 'marked'
               GROUP BY JZVTG1.jg_info_v11,JZVTG1.jg_info_v1
               HAVING   SUM(NVL(NVL(JZVTG1.jg_info_n2,JZVTG1.jg_info_n1),0)) <= NVL(P_MIN_VALUE,0))  -- 347-AP,415-AP   ln_sum_trx_line_amt
    AND (JZVTG.jg_info_v1 = p_tipo OR (JZVTG.jg_info_v1 = '3' AND JZVTG.jg_info_v6 = p_tipo))
    AND NVL(JZVTG.jg_info_n4,0) <> 1;

  END MOD347_MIN_AMOUNT;

  /* Bug 8485057 update records that do not satisfy the minimum cash amount received parameter
     Transaction codes(Tipos) B, F are subject to minimum amount. Tipos A,G are not. */
  PROCEDURE MOD347_MIN_CASH_AMOUNT ( p_tipo IN VARCHAR2 ) IS

  BEGIN
    UPDATE JG_ZZ_VAT_TRX_GT JZVTG
    SET    JZVTG.jg_info_n6 = 0   -- Cash amount received does not meet the minimum
    WHERE  JZVTG.jg_info_v11  IN
              (SELECT   JZVTG1.jg_info_v11
               FROM     JG_ZZ_VAT_TRX_GT JZVTG1
               WHERE    JZVTG1.jg_info_v1= p_tipo  -- Tipo
               AND      NVL(JZVTG1.jg_info_n4,0) <> 1
               GROUP BY JZVTG1.jg_info_v11,JZVTG1.jg_info_v1
               HAVING   SUM(NVL(JZVTG1.jg_info_n6,0)) <= NVL(P_MIN_CASH_AMOUNT_VALUE,0))
    AND JZVTG.jg_info_v1 = p_tipo
    AND NVL(JZVTG.jg_info_n4,0) <> 1
    AND NVL(JZVTG.jg_info_n6,0) <> 0;

  END MOD347_MIN_CASH_AMOUNT;


  -- Set extract dates for the 340
  PROCEDURE set_dates IS
    l_from  varchar2(2);
    l_to    varchar2(2);
  BEGIN

    IF p_340_period = '1T' THEN
       l_from := '01';
       l_to := '03';
    ELSIF p_340_period = '2T' THEN
       l_from := '04';
       l_to := '06';
    ELSIF p_340_period = '3T' THEN
       l_from := '07';
       l_to := '09';
    ELSIF p_340_period = '4T' THEN
       l_from := '10';
       l_to := '12';
    ELSE
       l_from := p_340_period;
       l_to := p_340_period;
    END IF;

    SELECT to_date ('01'||l_from||p_tax_year, 'DDMMYYYY'),
           last_day(to_date ('01'||l_to||p_tax_year, 'DDMMYYYY'))
    INTO   p_340_start_date,
           p_340_end_date
    FROM   dual;

  END set_dates;

  FUNCTION before_Report
  RETURN BOOLEAN
  IS


     /**
     author: brathod
       Introduced place holder $MODELO_TABLE_LIST$ which can contain additional table required by specific modelo reports
       For  MODELO=415 and SOURCE=AP value will be AP_SUPPLIER_SITES APSS to add a filter in MODELO_415 AP report
       For  MODELO=347 and SOURCE=AP value will be AP_SUPPLIERS APS, AP_SUPPLIER_SITES APSS to add filter in MODELO_347 AP report
     */

     C_JGZZ_MODELO_GENRIC_QUERY CONSTANT VARCHAR2 (32000) :=
     '
     SELECT	/*+ NO_REWRITE */
             $TAX_REGISTRATION_NUM$                             TAX_REGISTRATION_NUM
          ,  substr(billing_tp_name,1,80)                       CUSTOMER_NAME
--          ,  JZVTD.billing_tp_address_id                        CUSTOMER_ADDRESS_ID
          ,  $ADDRESS_ID$   CUSTOMER_ADDRESS_ID
          ,  DECODE( JZVTD.extract_source_ledger
                    , ''AP'' , JZVTD.bill_from_party_id
                    , JZVTD.billing_trading_partner_id )        BILLING_TRADING_PARTNER_ID
         ,  SUM(DECODE(JZVTD.extract_source_ledger
                      ,''AP'',DECODE(JZVTD.OFFSET_FLAG,
                               ''N'',nvl(JZVTD.taxable_amt_funcl_curr,JZVTD.taxable_amt)*(JZVTD.tax_recovery_rate/100)
			       ,0)
		                  , ''AR'',DECODE(JZVTD.TAX_LINE_NUMBER, ''1'', NVL(JZVTD.taxable_amt_funcl_curr, 0),0)
		))
		+
		SUM(DECODE(JZVTD.extract_source_ledger
		                ,''AP'', DECODE(NVL(JZVTD.tax_amt_funcl_curr,0)
		                                , 0, JZVTD.tax_amt,
                                    JZVTD.tax_amt_funcl_curr)
                    , ''AR'', NVL(JZVTD.tax_amt_funcl_curr, 0)
                                    ) )
		SUM_TAXABLE_AMT
         ,  SUM(DECODE(JZVTD.extract_source_ledger
                      ,''AP'',DECODE(JZVTD.OFFSET_FLAG,
                               ''N'',nvl(JZVTD.taxable_amt_funcl_curr,JZVTD.taxable_amt)*(JZVTD.tax_recovery_rate/100)
			       ,0)
		                  , ''AR'',DECODE(JZVTD.TAX_LINE_NUMBER, ''1'', NVL(JZVTD.taxable_amt_funcl_curr, 0),0)
		))
		+
		SUM(DECODE(JZVTD.extract_source_ledger
		                ,''AP'', DECODE(NVL(JZVTD.tax_amt_funcl_curr,0)
		                                , 0, JZVTD.tax_amt,
                                    JZVTD.tax_amt_funcl_curr)
                    , ''AR'', NVL(JZVTD.tax_amt_funcl_curr, 0)
                                    ) )
		SUM_TRX_LINE_AMT
          /**
          author: brathod;
          Commented as correction_flag is not relevent for Spain transactions
          ,  SUM(DECODE(NVL( JZVTD.correction_flag,''N'')
                        ,''N'', NVL( JZVTD.taxable_amt, 0)
                        , 0))                                   NCORRECTION_AMOUNT
          ,  SUM(DECODE(NVL( JZVTD.correction_flag,''N'')
                        ,''Y'', NVL( JZVTD.taxable_amt, 0)
                        , 0))                                   CORRECTION_AMOUNT
          */
          ,  SUM(DECODE(JZVTD.es_correction_period,null,
                        DECODE(JZVTD.extract_source_ledger,''AP'',
                              DECODE(JZVTD.OFFSET_FLAG,''N'',
		                   nvl(JZVTD.taxable_amt_funcl_curr,JZVTD.taxable_amt)*(JZVTD.tax_recovery_rate/100)
                                     ,0),
                               NVL( JZVTD.taxable_amt, 0)
                               )
                         ,0)
                 )   NCORRECTION_AMOUNT
          ,  SUM(DECODE(JZVTD.es_correction_period , null,
                        0,
                        DECODE(JZVTD.extract_source_ledger,''AP'',
                               DECODE(JZVTD.OFFSET_FLAG,''N'',
				nvl(JZVTD.taxable_amt_funcl_curr,JZVTD.taxable_amt)*(JZVTD.tax_recovery_rate/100)                                      ,0)
                               ,NVL( JZVTD.taxable_amt, 0)
                               )
                        )
                  )      CORRECTION_AMOUNT
             $CORRECTION_TRX_SEL_COL$
             $PROPERTY_FLAG_SEL_COL$
             $TRANS_CODE_SEL_COL$
             $TRANSMISSION_PROPERTY_AMT$
       FROM     jg_zz_vat_rep_status    JZVRS
            ,   jg_zz_vat_trx_details   JZVTD
                $MODELO_TABLE_LIST$
       WHERE    JZVRS.vat_reporting_entity_id  = $P_VAT_REP_ENTITY_ID$
       --AND   JZVRS.reporting_status_id      = JZVTD.reporting_status_id
       AND     JZVTD.reporting_status_id in (SELECT DISTINCT JZRS.reporting_status_id JZRS
				     FROM jg_zz_vat_rep_status JZRS
				     WHERE JZRS.vat_reporting_entity_id = $P_VAT_REP_ENTITY_ID$
				     AND   JZRS.source IN ( ''AP'', ''AR'' ))
       AND      JZVTD.extract_source_ledger    IN ( ''AP'', ''AR'' )
       AND      JZVRS.source                   IN ( ''AP'', ''AR'' )
       /**
        author: brathod
        date  : 18/5/2006
        Commented date based filtering and introduced conditional filtering based on report type.
        AND      JZVTD.tax_invoice_date    BETWEEN $PERIOD_FROM_DATE$
                                          AND     $PERIOD_TO_DATE$

       */
       AND      $FILTER_KEY$ $FILTER_OPER$ $FILTER_VALUE$
       $MODELO_SPECIFIC_FILTERS$
       GROUP BY $TAX_REGISTRATION_NUM$
              , substr(billing_tp_name,1,80)
              ,  $ADDRESS_ID$
              , DECODE( JZVTD.extract_source_ledger
                      , ''AP'' , JZVTD.bill_from_party_id
                      , JZVTD.billing_trading_partner_id )
              --,NVL(JZVTD.taxable_amt_funcl_curr,JZVTD.taxable_amt)
              $CORRECTION_TRX_GRP_COL$ $PROPERTY_FLAG_GRP_COL$ $TRANS_CODE_GRP_COL$ $MODELO_SPECIFIC_GRP_FILTER$
              ';


      C_MOD415_AP_FILTER CONSTANT VARCHAR2(4000) :=
    ' AND    JZVTD.extract_source_ledger        =  ''AP''
      AND    JZVRS.source = ''AP''
      AND    JZVTD.trx_line_type                <> ''AWT''
      /** author:brathod; removed posted_flag checking as it is not relevent in R12*/
      --AND    JZVTD.posted_flag                  IN (''P'',''Y'')
      AND    JZVTD.trx_line_class <> ''DEBIT''
      --AND    NVL(JZVTD.billing_tp_tax_reporting_flag, ''N'') = ''Y''
     -- AND    JZVTD.invoice_report_type          IN ( ''415''
    --                                            , ''415_347''
    --                                               , ''415_347PR''
    --                                               )
     /** author: brathod
      Added following conditions to check for TAX_REPORTING_SITE_FLAG
      */
      AND   JZVTD.BILLING_TRADING_PARTNER_ID =  APSS.VENDOR_ID
      AND   APSS.TAX_REPORTING_SITE_FLAG     =  ''Y''
      AND   APSS.ORG_ID                      = $P_ORG_ID$
      -- FH: Added for Modelo Project
      AND     jzvtd.trx_id = api.invoice_id
      AND     jzvtd.trx_id = zxdf.trx_id
      AND     jzvtd.trx_line_id = zxdf.trx_line_id
      AND     nvl(substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3),substr(JZVTD.invoice_report_type,1,3 )) = ''415''';

      C_MOD415_AR_FILTER constant VARCHAR2(4000) :=
      '      AND    JZVTD.extract_source_ledger        = ''AR''
      AND	JZVRS.source = ''AR''
      AND    JZVTD.trx_line_type                <> ''AWT''
      -- AND    JZVTD.accounting_date              IS NOT NULL --bug5557860
      --AND    JZVTD.posted_flag                  = ''N''   /** author:brathod; removed posted_flag checking as it is not relevent in R12 */
      --AND    JZVTD.tax_rate_vat_trx_type_code   <> ''DEBIT''
      AND    JZVTD.trx_line_class <> ''DEBIT''
      AND    SUBSTR(NVL(JZVTD.tax_rate_vat_trx_type_code,''QQQQQQ''),1,6) <> ''RET_AR''
--      AND    JZVTD.invoice_report_type          IN ( ''415''
--                                                   , ''415_347''
--                                                   , ''415_347PR''
--                                                   )
      AND JZVTD.BILLING_TRADING_PARTNER_ID  =   hzca.cust_account_id
      AND hzca.cust_account_id  = hzcas.cust_account_id
      AND  hzcsu.cust_acct_site_id  = hzcas.cust_acct_site_id
      AND upper(hzcsu.site_use_code) = ''LEGAL''
      AND hzcsu.primary_flag         = ''Y''
      AND hzcsu.status               = ''A''
      AND hzcsu.ORG_ID               = $P_ORG_ID$
-- FH: Added for modelo project
      AND     nvl(substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3),substr(JZVTD.invoice_report_type,1,3 )) = ''415''
      AND     jzvtd.trx_id = zxdf.trx_id
      AND     jzvtd.trx_line_id = zxdf.trx_line_id'
      ;

      C_MOD347_AP_FILTER CONSTANT VARCHAR2(4000) :=
      'AND    JZVTD.extract_source_ledger           =  ''AP''
       AND	  JZVRS.source = ''AP''
       AND    JZVTD.trx_line_type                   <> ''AWT''
       AND    JZVTD.trx_line_class                  <>  ''EXPENSE REPORT''
       AND    JZVTD.applied_from_line_id         IS NULL
       AND    SUBSTR(NVL(JZVTD.tax_rate_vat_trx_type_code,''QQQQQQ''),1,3) <> ''RET''
       -- Bug 8485057 verify invoice_report_type directly from Trx Tax Lines
       AND    SUBSTR(zxdf.trx_business_category, INSTR(zxdf.trx_business_category,''MOD'')+3,
              DECODE(INSTR(zxdf.trx_business_category,''/'',1,3),0,length(zxdf.trx_business_category),
                 INSTR(zxdf.trx_business_category,''/'',1,3) - (INSTR(zxdf.trx_business_category,''MOD'')+3)))
                 IN ( ''347'', ''415_347'', ''347PR'', ''415_347PR'')
       AND    JZVTD.trx_id = API.invoice_id
       AND    JZVTD.trx_id = ZXDF.trx_id
       AND    JZVTD.trx_line_id = ZXDF.trx_line_id
      /** author: brathod
      Added following conditions to check for FEDERAL_REPORTABLE_FLAG and TAX_REPORTING_SITE_FLAG
      */
      AND   JZVTD.BILLING_TRADING_PARTNER_ID       =   APS.VENDOR_ID
      AND   APS.VENDOR_ID                          =  APSS.VENDOR_ID
      AND   NVL(APS.FEDERAL_REPORTABLE_FLAG,''Y'')  =  ''Y''
      AND   APSS.TAX_REPORTING_SITE_FLAG            =  ''Y''
      AND   APSS.ORG_ID                             = $P_ORG_ID$';

      C_MOD347_AR_FILTER CONSTANT VARCHAR2(4000) :=
      '  AND    JZVTD.extract_source_ledger        =  ''AR''
         AND    JZVRS.source = ''AR''
      -- AND    JZVTD.accounting_date              IS NOT NULL --bug5557860
      -- AND    JZVTD.posted_flag                  = ''N'' /** author:brathod; removed posted_flag checking as it is not relevent in R12*/
      -- AND    JZVTD.tax_rate_vat_trx_type_code   <> ''DEBIT''
         AND    JZVTD.trx_line_class <> ''DEBIT''
      -- AND    NVL(JZVTD.billing_tp_tax_reporting_flag, ''N'') = ''Y''
         AND    SUBSTR(NVL(JZVTD.tax_rate_vat_trx_type_code,''QQQQQQ''),1,3) <> ''RET''
         -- Bug 8485057 verify invoice_report_type directly from Trx Tax Lines
         AND    SUBSTR(ZXDF.trx_business_category, INSTR(ZXDF.trx_business_category,''MOD'')+3,
                    DECODE(INSTR(ZXDF.trx_business_category,''/'',1,3),0,length(ZXDF.trx_business_category),
                    INSTR(ZXDF.trx_business_category,''/'',1,3) - (INSTR(ZXDF.trx_business_category,''MOD'')+3)))
                  IN ( ''347'', ''415_347'', ''347PR'', ''415_347PR'')
         AND    JZVTD.trx_id = ZXDF.trx_id
         AND    JZVTD.trx_line_id = ZXDF.trx_line_id
         AND    JZVTD.trx_id = TRX.customer_trx_id
	       AND    JZVTD.BILLING_TRADING_PARTNER_ID  =   hzca.cust_account_id
         AND    hzca.cust_account_id  = hzcas.cust_account_id
         AND    hzcsu.cust_acct_site_id  = hzcas.cust_acct_site_id
 	       AND    upper(hzcsu.site_use_code) = ''LEGAL''
	       AND    hzcsu.primary_flag         = ''Y''
	       AND    hzcsu.status               = ''A''
         AND    hzcsu.ORG_ID               = $P_ORG_ID$';

      C_MOD349_AP_FILTER CONSTANT VARCHAR2(4000) :=
      '      AND    JZVTD.extract_source_ledger        = ''AP''
      AND	JZVRS.source = ''AP''
      --AND    JZVTD.TAX_RATE_REGISTER_TYPE_CODE       = ''TAX'' --JZVTD.tax_rate_vat_trx_type_code
      --AND    JZVTD.tax_recoverable_flag         = ''Y''
      AND    JZVTD.invoice_report_type          IN ( ''349'')';

      C_MOD349_AR_FILTER  VARCHAR2(4000) :=
      '      AND    JZVTD.extract_source_ledger        = ''AR''
      AND	JZVRS.source = ''AR''
      AND    JZVTD.TAX_RATE_REGISTER_TYPE_CODE  = ''TAX'' --JZVTD.tax_rate_vat_trx_type_code
      --AND    JZVTD.tax_recoverable_flag         = ''Y'' /** author:brathod; commented as no such check found in R11i */
      AND    JZVTD.invoice_report_type          IN ( ''349'')';

      C_CORRECTION_TRX_SEL_COLS CONSTANT VARCHAR2(4000) :=
      ',   JZVTD.es_correction_year                CORRECTION_YEAR
       ,   JZVTD.es_correction_period              CORRECTION_PERIOD
       ,   DECODE( JZVTD.triangulation,''Y'',''X'',NULL) TRIANGULATION
       ,   DECODE(TO_CHAR(JZVTD.TRX_DATE, ''MM''),''01'',''1T'',''02'',''1T'',''03'',''1T'',
                                               ''04'',''2T'',''05'',''2T'',''06'',''2T'',
                                               ''07'',''3T'',''08'',''3T'',''09'',''3T'',
                                               ''10'',''4T'',''11'',''4T'',''12'',''4T'') TRX_PERIOD '; -- Bug 5525421

      C_CORRECTION_TRX_GRP_COLS CONSTANT VARCHAR2(4000) :=
      ',   JZVTD.es_correction_year
       ,   JZVTD.es_correction_period
       ,   DECODE( JZVTD.triangulation,''Y'',''X'',NULL)
       ,   DECODE(TO_CHAR(JZVTD.TRX_DATE, ''MM''),''01'',''1T'',''02'',''1T'',''03'',''1T'',
                                               ''04'',''2T'',''05'',''2T'',''06'',''2T'',
                                               ''07'',''3T'',''08'',''3T'',''09'',''3T'',
                                               ''10'',''4T'',''11'',''4T'',''12'',''4T'')
       order by  TRX_PERIOD';  -- Bug 5525421

      C_CORRECTION_TRX_NULL_COLS CONSTANT VARCHAR2(4000) :=
      ',   NULL   correction_year
       ,   NULL   correction_period
       ,   NULL   triangulation
       ,   NULL   trx_period   ';

      C_347_SEL_COL  VARCHAR2(4000) :=
      ', DECODE (INSTR(zxdf.trx_business_category,''PR''),
                       0,''N'',''Y'')       PROPERTY_RETAIL_FLAG';

      C_NULL_SEL_COL  VARCHAR2(4000) :=
      ', NULL    PROPERTY_RETAIL_FLAG      ';

      /*  Updated filter to include P_MIN_VALUE parameter instead of hardcoded 0 value */
      C_MOD347415_GRP_FILTER CONSTANT VARCHAR2(1000) :=
      'HAVING  SUM(DECODE(NVL(JZVTD.taxable_amt_funcl_curr , 0)
                    , 0 ,JZVTD.taxable_amt
                    , JZVTD.taxable_amt_funcl_curr     )) >= $P_MIN_VALUE$ '; --0

      --
      lc_vat_code_details     VARCHAR2(240);
      lc_func_curr_code       VARCHAR2(240);
      lc_rep_legal_entity     VARCHAR2(240);
      lc_trx_num              VARCHAR2(240);
      ln_rep_legal_entity_id  NUMBER;
      ld_period_start_date    DATE;
      ld_period_end_date      DATE;
      lc_prev_vat_code        VARCHAR2(400) :='';
      lc_count                NUMBER        := 0;
      lc_reporting_mode       VARCHAR2(240);
      --
      lc_taxpayer_id          jg_zz_vat_trx_details.billing_tp_taxpayer_id%TYPE;
      lc_company_name         xle_registrations.registered_name%TYPE;
      lc_registration_number  xle_registrations.registration_number%TYPE;
      lc_country              hr_locations.country%TYPE;
      lc_address1             hr_locations.address_line_1%TYPE;
      lc_address2             hr_locations.address_line_2%TYPE;
      lc_address3             hr_locations.address_line_3%TYPE;
      lc_address4             hz_locations.address4%TYPE;
      lc_city                 hr_locations.town_or_city%TYPE;
      lc_postal_code          hr_locations.postal_code%TYPE;
      lc_postal_code1          hr_locations.postal_code%TYPE;
      lc_contact              hz_parties.party_name%TYPE;
      lc_phone_number         hz_contact_points.phone_number%TYPE;
      -- Added for Glob-006 ER
      l_province                      VARCHAR2(120);
      l_comm_num                      VARCHAR2(30);
      l_vat_reg_num                   VARCHAR2(50);

      --
      lc_jgzz_modelo_query            VARCHAR2(32000);
      lc_jgzz_modelo_query1           VARCHAR2(32000);
      -- Added for Modelo 340
      lc_jgzz_mod_query_340           VARCHAR2(32000);
      lc_jgzz_mod_query_340_exp       VARCHAR2(32000);
      lc_jgzz_mod_query_340_tax       VARCHAR2(1000);
      --
      lc_clave_operation              JG_ZZ_VAT_TRX_GT.jg_info_v11%TYPE;
      lc_tax_registration_number      JG_ZZ_VAT_TRX_GT.jg_info_v11%TYPE;
      lc_customer_name                JG_ZZ_VAT_TRX_GT.jg_info_v11%TYPE;
      lc_customer_address_id          JG_ZZ_VAT_TRX_GT.jg_info_v11%TYPE;
      lc_billing_trading_partner_id   JG_ZZ_VAT_TRX_GT.jg_info_v11%TYPE;
      ln_sum_taxable_amt              JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_sum_trx_line_amt             JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_ncorrection_amount           JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_correction_amount            JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      lc_correction_year              JG_ZZ_VAT_TRX_GT.jg_info_v11%TYPE;
      lc_correction_period            JG_ZZ_VAT_TRX_GT.jg_info_v11%TYPE;
      lc_triangulation                JG_ZZ_VAT_TRX_GT.jg_info_v11%TYPE;
      lc_trx_period		      VARCHAR2(2);
      lc_print_year		      NUMBER;
      lc_print_period		      VARCHAR2(2);
      lc_property_retail_flag         JG_ZZ_VAT_TRX_GT.jg_info_v11%TYPE;
      lc_address_detail               JG_ZZ_VAT_TRX_GT.jg_info_v11%TYPE;
      --
      ln_base_imponiable    NUMBER;
      ln_running_total      NUMBER;
      ln_formerly_decl_amt  NUMBER;
      ln_arrenda_amount     NUMBER;
      --
      lc_sign               VARCHAR2(1);
      --
      lc_codigo_postal      VARCHAR2(150);
      lc_ref_catastral      VARCHAR2(150);
      lc_street_type        VARCHAR2(150);
      lc_street             VARCHAR2(150);
      lc_number             VARCHAR2(150);
      lc_escalera           VARCHAR2(150);
      lc_piso               VARCHAR2(150);
      lc_puerta             VARCHAR2(150);
      --Added for Modelo 347
      ln_transmission_property_amt NUMBER;
      ln_cash_received_amount      NUMBER;
      -- Added for Modelo 340
      lc_key_id                     JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      lc_foreign_taxpayer_id        jg_zz_vat_trx_details.billing_tp_taxpayer_id%TYPE;
      lc_book_type		    VARCHAR2(1);
      lc_transaction_code	    VARCHAR2(1);
      ld_invoice_date		    JG_ZZ_VAT_TRX_GT.jg_info_d1%TYPE;
      ld_trx_date		    JG_ZZ_VAT_TRX_GT.jg_info_d1%TYPE;
      lc_doc_seq		    JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      lc_intra_type		    VARCHAR2(1);
      lc_key_declared		    VARCHAR2(1);
      lc_trx_deadline		    JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      lc_desc_of_goods	 	    JG_ZZ_VAT_TRX_GT.jg_info_v11%TYPE;
      ln_taxable_amt		    JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_tax_amt		    JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_inv_total_amt		    JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_deductable_amt		    JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_tax_rate                   JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_trx_line_number            JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_trx_line_id                JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_trx_id                     JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_reporting_status_id        JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_line_count                 JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_surcharge_amount           JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_surcharge_rate             JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_ar_tax_amt		    JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;
      ln_ar_tax_rate                JG_ZZ_VAT_TRX_GT.jg_info_n11%TYPE;


      TYPE c_modelo_ext_type IS REF CURSOR ;
      c_modelo_ext    c_modelo_ext_type;
      --
      lc_misc               VARCHAR2(1000);
      --
      -- Cursor for Modelo 340
      TYPE c_modelo_340_type IS REF CURSOR ;
      c_modelo_340    c_modelo_340_type;

      -- Cursor for Modelo 340 AR Surcharge processing
      TYPE c_modelo_340_artax_type IS REF CURSOR ;
      c_modelo_340_artax    c_modelo_340_artax_type;

     Cursor C_End_Date(cp_tax_registration varchar2)  Is
     Select max(JZVRS.period_end_date) period_end_date
     FROM jg_zz_vat_rep_status JZVRS
     WHERE JZVRS.vat_reporting_entity_id = p_vat_rep_entity_id
       AND JZVRS.tax_registration_number = cp_tax_registration
       AND JZVRS.tax_calendar_period = p_tax_period_to
     Group by JZVRS.tax_registration_number;

     Cursor C_TAX_PERIODS Is
        SELECT RPS1.tax_calendar_period tax_calendar_period
        FROM JG_ZZ_VAT_REP_STATUS RPS1,
                   (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
                           min(period_start_date) period_start_date
                    From JG_ZZ_VAT_REP_STATUS
                    Where vat_reporting_entity_id = p_vat_rep_entity_id
                    And tax_calendar_period = p_tax_period) RPS2,
                   (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
                          min(period_end_date) period_end_date
                    From JG_ZZ_VAT_REP_STATUS
                    Where vat_reporting_entity_id = p_vat_rep_entity_id
                    And tax_calendar_period = p_tax_period_to) RPS3
        WHERE RPS1.vat_reporting_entity_id = p_vat_rep_entity_id
          AND RPS2.vat_reporting_entity_id = RPS1.vat_reporting_entity_id
          AND RPS3.vat_reporting_entity_id = RPS2.vat_reporting_entity_id
          AND trunc(RPS1.period_start_date) >=
                               trunc(RPS2.period_start_date)
          AND trunc(RPS1.period_end_date) <= trunc(RPS3.period_end_date)
        GROUP by RPS1.tax_calendar_period;
        l_period_string varchar2(2000) := NULL;
        l_period_count number := 0;

  BEGIN

      -- dbms_output.put_line ('Executing before_report');
     fnd_file.put_line(FND_FILE.LOG,'Executing before_report');
      -- dbms_output.put_line ('Calling funct_curr_legal');

     If p_tax_Period is not null Then
        If G_DEBUG Then
           fnd_file.put_line(FND_FILE.LOG,'Fetching periods in a string');
        End If;
        For C_Tax_Periods_Rec in C_Tax_Periods Loop
           If l_period_count = 0 Then
              l_period_string := '(''' || C_Tax_Periods_Rec.tax_calendar_period ||'''';
           Else
              l_period_string :=  l_period_string || ', ''' ||
                                  C_Tax_Periods_Rec.tax_calendar_Period ||'''';
           End If;
           l_period_count := l_period_count + 1;
        End Loop;
        l_period_string := l_period_string || ')';
     End If;
     IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'jg_zz_common_pkg.funct_curr_legal'); END IF;

     jg_zz_common_pkg.funct_curr_legal( lc_func_curr_code
                                     , lc_rep_legal_entity
                                     , ln_rep_legal_entity_id
                                     , lc_taxpayer_id
                                     , p_vat_rep_entity_id
                                     , p_tax_period
                                     , p_tax_year
                                     );
     -- dbms_output.put_line ('jg_zz_common_pkg.tax_registration');
     IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'jg_zz_common_pkg.tax_registration'); END IF;

     BEGIN
     jg_zz_common_pkg.tax_registration( x_tax_registration    => lc_trx_num
                                     , x_period_start_date   => ld_period_start_date
                                     , x_period_end_date     => ld_period_end_date
                                     , x_status              => lc_reporting_mode
                                     , pn_vat_rep_entity_id  => p_vat_rep_entity_id
                                     , pv_period_name        => p_tax_period
                                     , pn_period_year        => p_tax_year
                                     , pv_source             => P_SOURCE
                                      );
     If p_tax_period_to is not null Then
        If G_DEBUG THEN
           fnd_file.put_line(FND_FILE.LOG,'Getting the Period End ');
        End If;
        If C_End_Date%IsOpen Then
              Close C_End_Date;
        End IF;

        Open   C_End_Date(lc_trx_num);
        Fetch C_End_Date into ld_period_end_date;
        Close C_End_Date;
     End If;

     EXCEPTION
        WHEN OTHERS THEN
        NULL;
     END;
     -- dbms_output.put_line ('jg_zz_common_pkg.tax_registration');
     IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'jg_zz_common_pkg.company_detail'); END IF;

      jg_zz_common_pkg.company_detail(x_company_name            => lc_company_name
                                  ,x_registration_number    => lc_registration_number
                                  ,x_country                => lc_country
                                  ,x_address1               => lc_address1
                                  ,x_address2               => lc_address2
                                  ,x_address3               => lc_address3
                                  ,x_address4               => lc_address4
                                  ,x_city                   => lc_city
                                  ,x_postal_code            => lc_postal_code
                                  ,x_contact                => lc_contact
                                  ,x_phone_number           => lc_phone_number
                                  ,x_province               => l_province
                                  ,x_comm_number            => l_comm_num
                                  ,x_vat_reg_num            => l_vat_reg_num
                                  ,pn_legal_entity_id       => ln_rep_legal_entity_id
                                  ,p_vat_reporting_entity_id => P_VAT_REP_ENTITY_ID);



	IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'JG_ZZ_VAT_REP_UTILITY.get_period_status'); END IF;

	-- Fetch the reporting mode only if the report name is not null
	IF P_REPORT_NAME IS NOT NULL and p_tax_year is not null
          AND p_modelo <> '340' THEN
		lc_reporting_mode :=  JG_ZZ_VAT_REP_UTILITY.get_period_status(pn_vat_reporting_entity_id => p_vat_rep_entity_id
								   ,pv_tax_calendar_period => p_tax_period
								   ,pv_tax_calendar_year => p_tax_year
								   ,pv_source => P_SOURCE
							           ,pv_report_name => P_REPORT_NAME||':'||P_MODELO);
        ELSE
	        lc_reporting_mode := NULL;
	END IF;

     G_CURRENCY_CODE :=   lc_func_curr_code;
    /* bug 5729082 start */
    IF P_REPORT_NAME = 'JEESAMOR' AND P_MODELO = '347' THEN
      G_LE_TRN        :=   lc_taxpayer_id;
    ELSE
      G_LE_TRN        :=   lc_trx_num;
    End IF;
   /* end bug 5729082 */

     G_LE_NAME       :=   lc_rep_legal_entity;
     G_FROM_DATE     :=   ld_period_start_date;
     G_TO_DATE       :=   ld_period_end_date;
     -- dbms_output.put_line ('SELECT precision INTO G_CUR_PRECISION');
     IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'SELECT precision INTO G_CUR_PRECISION'); END IF;

     BEGIN
      SELECT precision
      INTO G_CUR_PRECISION
      FROM fnd_currencies curr
      WHERE currency_code = g_currency_code;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
     END;
     -- dbms_output.put_line ('P_REPORT_NAME:'||P_REPORT_NAME);
     IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'P_REPORT_NAME:'||P_REPORT_NAME); END IF;

     IF P_REPORT_NAME = 'JEESAMOR' AND P_MODELO = '347' THEN
     /* Header record information */
        lc_address1 := SUBSTR( lc_address1, 1,2);
        lc_address2 := SUBSTR( lc_address2, 1,20);
        lc_address3 := LPAD(SUBSTR(lc_address3,1,
                      NVL(LENGTH(lc_address3), 0) -
                      NVL(NVL(LENGTH(LTRIM(TRANSLATE(lc_address3,'123456789','000000000'),'0')), 0),0)),5,'0');
        lc_city    := SUBSTR(lc_city,1,30); -- Bug 8485057 changed from 12 to 30 char
        lc_postal_code := SUBSTR(lc_postal_code,1,5);
        lc_company_name := SUBSTR(lc_company_name,1,40);

     ELSIF P_REPORT_NAME = 'JEESAMOR' AND P_MODELO = '415' THEN
        lc_address1 := SUBSTR( lc_address1, 1,2);
        lc_address2 := SUBSTR( lc_address2, 1,25);
        lc_address3 := LPAD(SUBSTR(lc_address3,1,
                      NVL(LENGTH(lc_address3), 0) -
                      NVL(NVL(LENGTH(LTRIM(TRANSLATE(lc_address3,'123456789','000000000'),'0')), 0),0)),5,'0');
        lc_postal_code := SUBSTR(lc_postal_code,1,5);
        lc_company_name := SUBSTR(lc_company_name,1,40);
        lc_city    := SUBSTR(lc_city,1,24);
     END IF;
     -- dbms_output.put_line ('BEFORE INSERT HEADER');
     IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'BEFORE INSERT HEADER'); END IF;

     INSERT INTO JG_ZZ_VAT_TRX_GT
       (jg_info_v1  -- curr_code
       ,jg_info_v2  -- entity_name
       ,jg_info_v3  -- taxpayer_id
       ,jg_info_v4  -- company_name
       ,jg_info_v5  -- registration_number
       ,jg_info_v26 -- country
       ,jg_info_v27 -- address1
       ,jg_info_v28 -- address2
       ,jg_info_v29 -- address3
       ,jg_info_v31 -- address4
       ,jg_info_v32 -- city
       ,jg_info_v6  -- postal_code
       ,jg_info_v7  -- contact
       ,jg_info_v33 -- phone_number
       ,jg_info_v8  -- reporting mode
       ,jg_info_v9  -- P_TAX_YEAR
       ,jg_info_v10 -- P_TAX_PERIOD
       ,jg_info_v11 -- P_MODELO
       ,jg_info_v35 -- P_SOURCE
       ,jg_info_v12 -- P_CONTACT_TEL
       ,jg_info_v13 -- P_CONTACT_NAME
       ,jg_info_v14 -- P_TAX_OFFICE  -- Bug 8485057 Note: not printed in Modelo 347 magnetic format
       ,jg_info_v15 -- P_CONTACT_TEL_CODE
       ,jg_info_v16 -- P_REFERENCE_NUMBER
       ,jg_info_v17 -- P_MAIN_ACTIVITY
       ,jg_info_v18 -- P_MAIN_ACTIVITY_CD
       ,jg_info_v19 -- P_SECOND_ACTIVITY
       ,jg_info_v20 -- P_SECOND_ACTIVITY_CD
       ,jg_info_v21 -- P_TOTAL_PURCHASES
       ,jg_info_v22 -- P_TOTAL_SALES
       ,jg_info_v23 -- P_TAX_OFF_REG_CODES
       ,jg_info_v24 -- P_MEDIUM
       ,jg_info_v25 -- P_FORMAT_TYPE
       ,jg_info_v34 -- P_PRV_REFERENCE_NUMBER
       ,jg_info_n6  -- P_MIN_VALUE
       ,jg_info_d1 -- ld_period_start_date
       ,jg_info_d2 -- ld_period_end_date
       ,jg_info_v30 -- Header record indicator
       ,jg_info_v36 -- P_PERIOD
       ,jg_info_v37 -- P_ELEC_CODE
       ,jg_info_v38 -- P_SUBSTITUTION
       ,jg_info_n7  -- P_MIN_CASH_AMOUNT_VALUE Bug 8485057
       )
     VALUES
       (lc_func_curr_code
       ,lc_rep_legal_entity
       ,lc_taxpayer_id
       ,lc_company_name
       ,lc_trx_num
       ,lc_country
       ,lc_address1
       ,lc_address2
       ,lc_address3
       ,lc_address4
       ,lc_city
       ,lc_postal_code
       ,lc_contact
       ,lc_phone_number
       ,lc_reporting_mode
       ,P_TAX_YEAR
       ,P_TAX_PERIOD || ' - ' || P_TAX_PERIOD_TO
       ,P_MODELO
       ,P_SOURCE
       ,P_CONTACT_TEL
       ,P_CONTACT_NAME
       ,P_TAX_OFFICE
       ,P_CONTACT_TEL_CODE
       ,P_REFERENCE_NUMBER
       ,P_MAIN_ACTIVITY
       ,P_MAIN_ACTIVITY_CD
       ,P_SECOND_ACTIVITY
       ,P_SECOND_ACTIVITY_CD
       ,P_TOTAL_PURCHASES
       ,P_TOTAL_SALES
       ,P_TAX_OFF_REG_CODES
       ,P_MEDIUM
       ,P_FORMAT_TYPE
       ,P_PRV_REFERENCE_NUMBER
       ,P_MIN_VALUE
       ,ld_period_start_date
       ,ld_period_end_date
       ,'H'
       ,P_340_PERIOD
       ,P_ELEC_CODE
       ,P_SUBSTITUTION
       ,P_MIN_CASH_AMOUNT_VALUE);

    -- dbms_output.put_line ('AFTER INSERT HEADER');
    IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'AFTER INSERT HEADER'); END IF;

    /**
      author: brathod
      date  : 23/05/2006
      User has requested "Generic Extract".  Hence no need to apply report specific filters.
      Only reporting entity related information is populated in JG_ZZ_VAT_TRX_GT global temp table.
      Returning control from here to continue with xml data template query processing
    */

    IF (P_REPORT_NAME IS NULL) THEN
       return (true);
    END IF;

    /**
      Control will not come here if GENERIC EXTRACT is executed
    */

 -- Separate existing processing for all other Modelos.
 -- Modelo 340 processing will be in its own part.
 IF P_MODELO <> 340 THEN

    -- Process if Period Report run from AP or if Annual
    IF ( P_REPORT_NAME = 'JEESPMOR' AND P_SOURCE = 'AP')
       OR P_REPORT_NAME = 'JEESAMOR' THEN

       --
       -- Build query to fetch ap extract for modelo from JG
       --

       lc_jgzz_modelo_query  := C_JGZZ_MODELO_GENRIC_QUERY;
       --
       /**
        author : brathod
        date   : 18/5/2006
        Commented following code to remove date filtering.
        lc_jgzz_modelo_query :=
               REPLACE( lc_jgzz_modelo_query
                      , '$PERIOD_FROM_DATE$'
                      , 'TO_DATE('''||TO_CHAR(ld_period_start_date, 'DD/MM/YYYY')||''',''DD/MM/YYYY'')' );

        lc_jgzz_modelo_query :=
               REPLACE( lc_jgzz_modelo_query
                      , '$PERIOD_TO_DATE$'
                      , 'TO_DATE('''||TO_CHAR(ld_period_end_date, 'DD/MM/YYYY')||''',''DD/MM/YYYY'')' );

          :: Introduced conditional filtering ::
          Based on report type, FILTER_KEY and FILTER_VALUE will have following values
          For, Periodic Report Filter_Key = TAX_CALENDAR_PERIOD and Filter_Value = P_TAX_PERIOD
               Annual   Report Filter_Key = TAX_CALENDAR_YEAR   and Filter_Value = P_TAX_YEAR

       */
        declare
          lv_filter_key varchar2 (150) ;
          lv_filter_value varchar2 (2000);
          lv_filter_oper varchar2(2);
        begin
          if p_report_name = 'JEESPMOR' then
            lv_filter_key := ' JZVTD.trx_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date
		       AND JZVRS.TAX_CALENDAR_PERIOD'; --5444803
--	    lv_filter_key := ' JZVRS.TAX_CALENDAR_PERIOD'; --5444803
            lv_filter_value := l_period_string; --p_tax_period;
            lv_filter_oper := 'In';
          elsif p_report_name = 'JEESAMOR' then
            lv_filter_key := 'JZVTD.trx_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date
		       AND JZVRS.TAX_CALENDAR_YEAR';  --Bug 5525421
            lv_filter_value := p_tax_year;
            lv_filter_oper := '=';
          end if;

        lc_jgzz_modelo_query :=
               REPLACE( lc_jgzz_modelo_query
                      , '$FILTER_KEY$'
                      , lv_filter_key
                      );

        lc_jgzz_modelo_query :=
               REPLACE( lc_jgzz_modelo_query
                      , '$FILTER_OPER$'
                      , lv_filter_oper
                      );

         lc_jgzz_modelo_query :=
               REPLACE( lc_jgzz_modelo_query
                      , '$FILTER_VALUE$'
                      , lv_filter_value
                      );
        end;

         lc_jgzz_modelo_query :=
               REPLACE( lc_jgzz_modelo_query
                      , '$P_VAT_REP_ENTITY_ID$'
                      , TO_CHAR(P_VAT_REP_ENTITY_ID)
                      );

       IF p_modelo = '347' THEN

          --
          -- Replace Place Holder with Modelo 347 - AP Specific Values
          --
          /** author: brathod
            $MODELO_TABLE_LIST$ will have value ", AP_SUPPLIER_SITES APSS , AP_SUPPLIERS APS" [please note comma (,)at begining]
            as modelo 347 report needs to filter records based on FEDERAL_REPORTABLE_FLAG for suppliers
            and TAX_REPORTING_SITE_FLAG for supplier sites

          */
          -- Bug 8485057 added AP_INVOICES_ALL to retrieve the actual current invoice_report_type
          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$MODELO_TABLE_LIST$'
                    ,', AP_SUPPLIER_SITES_ALL APSS, AP_SUPPLIERS APS, AP_INVOICES_ALL API, ZX_LINES_DET_FACTORS ZXDF ' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$ADDRESS_ID$'
                    ,'APSS.VENDOR_SITE_ID' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TAX_REGISTRATION_NUM$'
            --        ,'JZVTD.billing_tp_tax_reg_num' );  /* Commented for bug 5729082 */
                      ,'JZVTD.billing_tp_taxpayer_id');   /* added for bug 5729082 */

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$CORRECTION_TRX_SEL_COL$'
                    , C_CORRECTION_TRX_NULL_COLS );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$CORRECTION_TRX_GRP_COL$'
                    , '' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$MODELO_SPECIFIC_FILTERS$'
                    , C_MOD347_AP_FILTER );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$P_ORG_ID$'
                    , P_ORG_ID );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$MODELO_SPECIFIC_GRP_FILTER$'
                    , '');
                 -- Bug 8485057 Minimum amount checked in MOD347_MIN_AMOUNT procedure
                 --   , C_MOD347415_GRP_FILTER );

          -- Bug 8485057, select Transaction Code, default A for AP transactions
          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANS_CODE_SEL_COL$'
                    , ', DECODE( INSTR(zxdf.trx_business_category,''/'',1,3),0,''A'',
         substr(zxdf.trx_business_category,length(zxdf.trx_business_category),1)) TIPO');

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANS_CODE_GRP_COL$'
                    , ', DECODE( INSTR(zxdf.trx_business_category,''/'',1,3),0,''A'',
         substr(zxdf.trx_business_category,length(zxdf.trx_business_category),1))');

          /* Bug 8485057: property rental flag cannot be in the main query, incorrect number of records
          are returned, replaced with NULL */
          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$PROPERTY_FLAG_SEL_COL$'
                    ,C_NULL_SEL_COL);
                  --  , C_347_SEL_COL );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$PROPERTY_FLAG_GRP_COL$'
                    ,'');
                 --   , lc_misc );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANSMISSION_PROPERTY_AMT$'
                    , ', NULL TRANSMISSION_PROPERTY_AMT');

          IF G_DEBUG THEN
            fnd_file.put_line(FND_FILE.LOG,'1.3. bEFORE Merge subquery to include expense reports');
          END IF;

          --
          -- Remove semi colon to merge union select
          --
          lc_jgzz_modelo_query := REPLACE( lc_jgzz_modelo_query, ';', '');

          --
          -- Merge subquery to include expense reports
          --

          lc_jgzz_modelo_query1 :=
           'UNION
           /** author: brathod
            added two tables AP_SUPPLIER_SITES APSS , AP_SUPPLIERS APS
            as modelo 347 report needs to filter records based on FEDERAL_REPORTABLE_FLAG for suppliers
            and TAX_REPORTING_SITE_FLAG for supplier sites
          */
           SELECT /*+ NO_REWRITE */
                   NVL(JZVTD.merchant_party_taxpayer_id,
                         JZVTD.billing_tp_taxpayer_id)                      TAX_REGISTRATION_NUM
                ,  NVL(JZVTD.billing_tp_name,JZVTD.merchant_party_name)     CUSTOMER_NAME
                ,  APSS.VENDOR_SITE_ID                            CUSTOMER_ADDRESS_ID
                ,  JZVTD.bill_from_party_id                                 BILLING_TRADING_PARTNER_ID
                , SUM (ROUND (DECODE (JZVTD.taxable_amt_funcl_curr,
                          0, JZVTD.taxable_amt,
                          NULL, JZVTD.taxable_amt,
                          JZVTD.taxable_amt_funcl_curr)
                /** author:brathod
                  +
                  NVL (DECODE (alc.base_amount,
                          0, alc.amount,
                          NULL, alc.amount,
                          alc.base_amount), 0)
                */
                ))                             SUM_TAXABLE_AMT
                , 0  SUM_TRX_LINE_AMT
                , 0  NCORRECTION_AMOUNT
                , 0  CORRECTION_AMOUNT
                , NULL
                , NULL
                , NULL
                , NULL
              /*  , DECODE (INSTR(API.trx_business_category,''PR''),
                          0,''N'',''Y'')       PROPERTY_RETAIL_FLAG */
                , NULL
                , DECODE( INSTR(zxdf.trx_business_category,''/'',1,3),0,''A'',
                    substr(zxdf.trx_business_category,length(zxdf.trx_business_category),1)) TIPO
                , NULL TRANSMISSION_PROPERTY_AMT
             FROM     jg_zz_vat_rep_status    JZVRS
                  ,   jg_zz_vat_trx_details   JZVTD
                  ,   ap_suppliers            aps
                  ,   ap_supplier_sites_all   apss
                  ,   ap_invoices_all              API
                  ,   zx_lines_det_factors    zxdf
	     /**
             author:brathod
                  ,   ap_invoice_distributions_all AID
                  ,   ap_invoice_distributions_all ALC
             WHERE    AID.invoice_distribution_id    = JZVTD.trx_line_id
             AND      ALC.invoice_distribution_id    = AID.charge_applicable_to_dist_id
             */
             WHERE    JZVRS.vat_reporting_entity_id  = $P_VAT_REP_ENTITY_ID$
             AND      JZVRS.reporting_status_id      = JZVTD.reporting_status_id
             AND      JZVRS.source                   = ''AP''
             AND      JZVTD.extract_source_ledger    =  ''AP''
             AND      JZVTD.merchant_party_name      IS NOT NULL
             AND      JZVTD.trx_line_type                NOT IN (''AWT'',''TAX'',''PREPAY'')
            --AND      JZVTD.posted_flag                  IN (''P'',''Y'') /** author:brathod; Removed posted_flag checking as it is not relevent in R12 */
            --AND      JZVTD.tax_rate_vat_trx_type_code   = ''EXPENSE REPORT''
             AND      JZVTD.trx_line_class = ''EXPENSE REPORT''
             --AND      NVL(JZVTD.billing_tp_tax_reporting_flag, ''N'') = ''Y''
             AND      JZVTD.applied_from_line_id         IS NULL
             /*  Commented and added period based filtering
             AND      JZVTD.start_expense_date           BETWEEN $PERIOD_FROM_DATE$ AND $PERIOD_TO_DATE$
             */
             AND      $FILTER_KEY$ $FILTER_OPER$ $FILTER_VALUE$
             -- Bug 8485057 verify invoice_report_type directly from Invoice
             AND      SUBSTR(zxdf.trx_business_category, INSTR(zxdf.trx_business_category,''MOD'')+3,
                        DECODE(INSTR(zxdf.trx_business_category,''/'',1,3),0,length(zxdf.trx_business_category),
                        INSTR(zxdf.trx_business_category,''/'',1,3) - (INSTR(zxdf.trx_business_category,''MOD'')+3)))
                      IN ( ''347'', ''347PR'', ''415_347'', ''415_347PR'')
             AND      JZVTD.trx_id = API.invoice_id
             AND      jzvtd.trx_id = zxdf.trx_id
             AND      jzvtd.trx_line_id = zxdf.trx_line_id
             AND      JZVTD.BILLING_TRADING_PARTNER_ID       =   APS.VENDOR_ID
             AND      APS.VENDOR_ID         =   APSS.VENDOR_ID
             AND      NVL(APS.FEDERAL_REPORTABLE_FLAG ,''Y'')   = ''Y''
	       AND      APSS.TAX_REPORTING_SITE_FLAG   = ''Y''
	       AND      APSS.ORG_ID          = $P_ORG_ID$
             GROUP BY NVL(JZVTD.merchant_party_taxpayer_id,
                         JZVTD.billing_tp_taxpayer_id)
                    , NVL(JZVTD.billing_tp_name,JZVTD.merchant_party_name)
                    , APSS.VENDOR_SITE_ID
                    , JZVTD.bill_from_party_id
                --    , DECODE (INSTR(API.trx_business_category,''PR''),
                --          0,''N'',''Y'')
                    , DECODE( INSTR(zxdf.trx_business_category,''/'',1,3),0,''A'',
                          substr(zxdf.trx_business_category,length(zxdf.trx_business_category),1))
                    ';

        /**
        author : brathod
        date   : 18/5/2006
        Commented following code to remove date filtering.
        lc_jgzz_modelo_query :=
               REPLACE( lc_jgzz_modelo_query
                      , '$PERIOD_FROM_DATE$'
                      , 'TO_DATE('''||TO_CHAR(ld_period_start_date, 'DD/MM/YYYY')||''',''DD/MM/YYYY'')' );

        lc_jgzz_modelo_query :=
               REPLACE( lc_jgzz_modelo_query
                      , '$PERIOD_TO_DATE$'
                      , 'TO_DATE('''||TO_CHAR(ld_period_end_date, 'DD/MM/YYYY')||''',''DD/MM/YYYY'')' );

          :: Introduced conditional filtering ::
          Based on report type, FILTER_KEY and FILTER_VALUE will have following values
          For, Periodic Report Filter_Key = TAX_CALENDAR_PERIOD and Filter_Value = P_TAX_PERIOD
               Annual   Report Filter_Key = TAX_CALENDAR_YEAR   and Filter_Value = P_TAX_YEAR

       */
        declare
          lv_filter_key varchar2 (150) ;
          lv_filter_value varchar2 (2000);
          lv_filter_oper varchar2(2);
        begin
          if p_report_name = 'JEESPMOR' then
            lv_filter_key := ' JZVTD.trx_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date
				AND JZVRS.TAX_CALENDAR_PERIOD'; --5444803
            lv_filter_value := l_period_string;  --p_tax_period;
            lv_filter_oper := 'In';
          elsif p_report_name = 'JEESAMOR' then
            lv_filter_key := 'JZVTD.trx_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date
		       AND JZVRS.TAX_CALENDAR_YEAR'; --Bug 5525421
            lv_filter_value := p_tax_year;
            lv_filter_oper := '=';
          end if;
		 fnd_file.put_line(FND_FILE.LOG,'lv_filter_key :='||lv_filter_key);
           lc_jgzz_modelo_query1 :=
             REPLACE( lc_jgzz_modelo_query1
                    , '$FILTER_KEY$'
                    , lv_filter_key );

           lc_jgzz_modelo_query1 :=
             REPLACE( lc_jgzz_modelo_query1
                    , '$FILTER_OPER$'
                    , lv_filter_oper );

           lc_jgzz_modelo_query1 :=
             REPLACE( lc_jgzz_modelo_query1
                    , '$FILTER_VALUE$'
                    , lv_filter_value );
        end;

            lc_jgzz_modelo_query1 :=
           REPLACE( lc_jgzz_modelo_query1
           , '$P_VAT_REP_ENTITY_ID$'
           , TO_CHAR(P_VAT_REP_ENTITY_ID) );

           lc_jgzz_modelo_query1 :=
           REPLACE( lc_jgzz_modelo_query1
           , '$P_ORG_ID$'
           , P_ORG_ID);


          lc_jgzz_modelo_query := lc_jgzz_modelo_query || lc_jgzz_modelo_query1;

          IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'1.4. After Merge subquery to inclue expense reports'); END IF;


       ELSIF p_modelo = '415' THEN

          --
          -- Replace Place Holder with Modelo 415 - AP Specific Values
          --
          -- dbms_output.put_line ('Applying palce holders for 415');
         /** author: brathod
            $MODELO_TABLE_LIST$ will have value ", AP_SUPPLIER_SITES APSS" [please note comma (,)at begining]
            as modelo 415 report needs to filter records based on TAX_REPORTING_SITE_FLAG for supplier sites only
          */
          -- FH Added AP_INVOICES_ALL to table list for Modelo project
          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$MODELO_TABLE_LIST$'
                    ,', AP_SUPPLIER_SITES_ALL APSS, AP_INVOICES_ALL API,  ZX_LINES_DET_FACTORS ZXDF' );

          -- FH: Added Transaction Code for modelo project --
       lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANS_CODE_SEL_COL$'
                    ,', decode(substr(zxdf.trx_business_category,length(zxdf.trx_business_category)-1,1),''/'',
         substr(zxdf.trx_business_category,length(zxdf.trx_business_category),1),
         ''A'') TRANSACTION_CODE' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANS_CODE_GRP_COL$'
                    , ', decode(substr(zxdf.trx_business_category,length(zxdf.trx_business_category)-1,1),''/'',
         substr(zxdf.trx_business_category,length(zxdf.trx_business_category),1),
         ''A'') ' );

           lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$ADDRESS_ID$'
                    ,'APSS.VENDOR_SITE_ID' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TAX_REGISTRATION_NUM$'
            --        ,'JZVTD.billing_tp_tax_reg_num' );  /* Commented for bug 5729082 */
                      ,'JZVTD.billing_tp_taxpayer_id');   /* added for bug 5729082 */

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$CORRECTION_TRX_SEL_COL$'
                    , C_CORRECTION_TRX_NULL_COLS );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$CORRECTION_TRX_GRP_COL$'
                    , '' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$MODELO_SPECIFIC_FILTERS$'
                    , C_MOD415_AP_FILTER );

	  lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$P_ORG_ID$'
                    , P_ORG_ID );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$MODELO_SPECIFIC_GRP_FILTER$'
                    , C_MOD347415_GRP_FILTER );

          /** author:brathod
          Added following code to use p_min_value parameter */
          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$P_MIN_VALUE$'
                    , 0); -- FH Moved min value processing to the xml file nvl(p_min_value,0));

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$PROPERTY_FLAG_SEL_COL$'
                    , C_NULL_SEL_COL );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$PROPERTY_FLAG_GRP_COL$'
                    , '' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANSMISSION_PROPERTY_AMT$'
                    , ', NULL TRANSMISSION_PROPERTY_AMT');

         -- dbms_output.put_line ('Completed applying place holders for 415');

       ELSIF p_modelo = '349' THEN

          --
          -- Replace Place Holder with Modelo 349 - AP Specific Values
          --
          /**
            author: brathod
            Relacing place holder $MODELO_TABLE_LIST$ with blank space as for 349 AP report it is not used
          */
          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$MODELO_TABLE_LIST$'
                    ,' ' );


          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$ADDRESS_ID$'
                    ,'NULL' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TAX_REGISTRATION_NUM$'
                    ,'JZVTD.billing_tp_taxpayer_id' ) ;

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$CORRECTION_TRX_SEL_COL$'
                    , C_CORRECTION_TRX_SEL_COLS );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$CORRECTION_TRX_GRP_COL$'
                    , C_CORRECTION_TRX_GRP_COLS );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$MODELO_SPECIFIC_FILTERS$'
                    , C_MOD349_AP_FILTER );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
             , '$MODELO_SPECIFIC_GRP_FILTER$'
             , '' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$PROPERTY_FLAG_SEL_COL$'
                    , C_NULL_SEL_COL );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$PROPERTY_FLAG_GRP_COL$'
                    , '' );
          --FH: Added TRANS_CODE_SEL_COL and TRANS_CODE_GRP_COL for modelo project
          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANS_CODE_SEL_COL$'
                    ,', NULL TRANSACTION_CODE' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANS_CODE_GRP_COL$'
                    , '' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANSMISSION_PROPERTY_AMT$'
                    , ', NULL TRANSMISSION_PROPERTY_AMT');

       END IF;

       --
       -- Insert AP Transactions in Global Temporary Table
       --

       -- INSERT INTO JG_TEMP_TABLE values (Lc_jgzz_modelo_query); -- debug

       IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'1.5. Open the Dynamic Query: '||lc_jgzz_modelo_query ); END IF;

       OPEN c_modelo_ext FOR lc_jgzz_modelo_query ;  -- opencur
       LOOP

          IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'1.6. Fetch from the Dynamic Query'); END IF;
          G_LINENO := '1.6.1';
          FETCH  c_modelo_ext
          INTO   lc_tax_registration_number
                ,lc_customer_name
                ,lc_customer_address_id
                ,lc_billing_trading_partner_id
                ,ln_sum_taxable_amt
                ,ln_sum_trx_line_amt
                ,ln_ncorrection_amount
                ,ln_correction_amount
                ,lc_correction_year
                ,lc_correction_period
                ,lc_triangulation
		    ,lc_trx_period  -- bug 5525421
                ,lc_property_retail_flag
                ,lc_clave_operation
                ,ln_transmission_property_amt; --FH: Added tipo (transaction code)

           EXIT WHEN c_modelo_ext%NOTFOUND;
             IF G_DEBUG THEN
                fnd_file.put_line(FND_FILE.LOG,G_LINENO);
                fnd_file.put_line(FND_FILE.LOG,'lc_tax_registration_number='||lc_tax_registration_number);
                fnd_file.put_line(FND_FILE.LOG,'lc_clave_operation='||lc_clave_operation);
             END IF;

             G_LINENO := '1.6.2';
             IF    P_MODELO = '415' THEN

               -- ln_sum_taxable_amt  will have the gross amt for AP
               -- Assign NULL to ln_sum_trx_line_amt
               ln_sum_trx_line_amt := NULL;

               get_vendor_address ( p_party_site_id  => lc_customer_address_id
                                  , x_postal_code    => lc_postal_code
                                  , x_city           => lc_city
                                  , x_address_detail => lc_address_detail
                                  , x_country        => lc_country
                                  );



               lc_clave_operation         := lc_clave_operation;
               lc_tax_registration_number := SUBSTR( lc_tax_registration_number,1,9);
               lc_customer_name           := SUBSTR(lc_customer_name,1,40);
               lc_address_detail          := SUBSTR(lc_address_detail,1,32);

                G_LINENO := '1.6.2.1';

               IF G_DEBUG THEN
                 fnd_file.put_line(FND_FILE.LOG,'lc_address_detail='||lc_address_detail);
                 fnd_file.put_line(FND_FILE.LOG,'lc_postal_code='||lc_postal_code);
                 fnd_file.put_line(FND_FILE.LOG,'lc_city='||lc_city);
               END IF;

                G_LINENO := '1.6.2.2';

               ln_sum_taxable_amt         :=
               AP415_GROSS_AMOUNTFormula ( p_vendor_id    => lc_billing_trading_partner_id
                                         , p_gross_amount => ln_sum_taxable_amt );


             ELSIF    P_MODELO = '347' THEN

                 G_LINENO := '1.6.2.3';
                 -- ln_sum_taxable_amt  will have the gross amt for AP
                 -- Assign NULL to ln_sum_trx_line_amt
                 ln_sum_trx_line_amt := NULL;

                 -- Bug 8485057 this value is now selected from the record
                 -- lc_clave_operation := 'A' ;
                 G_LINENO := '1.6.2.4';
                 get_vendor_address ( p_party_site_id  => lc_customer_address_id
                                    , x_postal_code    => lc_postal_code
                                    , x_city           => lc_city
                                    , x_address_detail => lc_address_detail
                                    , x_country        => lc_country
                                    );
                  IF G_DEBUG THEN
                    fnd_file.put_line(FND_FILE.LOG,G_LINENO);
                    fnd_file.put_line(FND_FILE.LOG,'lc_customer_address_id='||lc_customer_address_id);
                    fnd_file.put_line(FND_FILE.LOG,'lc_address_detail='||lc_address_detail);
                    fnd_file.put_line(FND_FILE.LOG,'lc_country='||lc_country);
                  END IF;

                G_LINENO := '1.6.2.5';

                /* Bug 8485057: added p_tipo as a parameter */
                ln_sum_taxable_amt :=
                AP347_GROSS_AMOUNTFormula ( p_vendor_id      => lc_billing_trading_partner_id
                                          , p_property_flag  => lc_property_retail_flag
                                          , p_gross_amt      => ln_sum_taxable_amt
                                          , p_tipo           => lc_clave_operation);

               IF G_DEBUG THEN
                    fnd_file.put_line(FND_FILE.LOG,G_LINENO);
                    fnd_file.put_line(FND_FILE.LOG,'ln_sum_taxable_amt='||ln_sum_taxable_amt);
                  END IF;

                G_LINENO := '1.6.2.6';

             ELSIF P_MODELO = '349' THEN

                G_LINENO := '1.6.2.7';
                IF P_REPORT_NAME = 'JEESAMOR' THEN
                  G_LINENO := '1.6.2.7.1';
                  ln_running_total           := 0;
                  ln_formerly_decl_amt       := 0;
                  lc_tax_registration_number := SUBSTR( lc_tax_registration_number,1,14);
                  lc_customer_name           := SUBSTR(lc_customer_name,1,40);
		      lc_print_year := P_TAX_YEAR;  -- Bug 5525421
		      lc_print_period := lc_trx_period; -- Bug 5525421
                  G_LINENO := '1.6.2.7.2';

		      -- Bug 5525421

                  IF lc_correction_year IS NULL AND lc_correction_period IS NULL THEN --Not a Correction

                     G_LINENO := '1.6.2.7.2.1';
                     lc_clave_operation         := 'A';
                     ln_base_imponiable         := ln_ncorrection_amount;
                     ln_running_total           := ln_ncorrection_amount;

                  ELSIF lc_correction_year IS NOT NULL AND lc_correction_period IS NOT NULL THEN --IS a Correction
                     G_LINENO := '1.6.2.7.2.2';
                     lc_clave_operation         := 'a';
                     lc_correction_year    := lc_correction_year; --SUBSTR(lc_correction_year,3,2);
                     ln_base_imponiable    := ln_correction_amount;
                     ln_formerly_decl_amt  := 0;
                     G_LINENO := '1.6.2.7.2.3';
                    -- SELECT DECODE(lc_triangulation,'X','T','E')  --Bug 5525421: No traingulation for AP.
                    -- INTO   lc_clave_operation
                    -- FROM   DUAL ;
                     G_LINENO := '1.6.2.7.2.4';
                     IF lc_clave_operation IN ('1','2') THEN
                          lc_sign := ' ';
                     ELSE
                          IF ln_base_imponiable < 0 THEN
                             lc_sign := '-' ;
                          ELSE
                             lc_sign := '+' ;
                          END IF;
                     END IF;
                     G_LINENO := '1.6.2.7.2.5';

		         begin
                       SELECT NVL(jg_info_n10,0) -- running total
                       INTO   ln_formerly_decl_amt
                       FROM   JG_ZZ_VAT_TRX_GT  M349
                       WHERE  RTRIM(jg_info_v11)      = RTRIM(lc_tax_registration_number)
                       AND    RTRIM(jg_info_v12)      = RTRIM(lc_customer_name)
                       AND    jg_info_n13             = lc_correction_year -- correction year
                       AND    jg_info_v27             = lc_correction_period -- correction period
                  --   AND    RTRIM(jg_info_v21)      = RTRIM(lc_correction_year) --Bug 5525421
                       AND    UPPER(jg_info_v1)       ='A';

		         exception
                       when no_data_found then
                       ln_formerly_decl_amt :=0;
		         end;

                    G_LINENO := '1.6.2.7.2.6';
                     --
                     -- update running total
                     --
		     -- As per R11i logic this update should happend after the insert. Hence moving this to after insert.

		    /* UPDATE JG_ZZ_VAT_TRX_GT
                     SET    jg_info_n10  = ln_formerly_decl_amt + ln_ncorrection_amount
                     WHERE  RTRIM(jg_info_v15)    = RTRIM(lc_correction_year) --RTRIM(SUBSTR(lc_correction_year,3,2))
                     AND    RTRIM(jg_info_v16)    = RTRIM(lc_correction_period)
                     AND    jg_info_v14           IS NOT NULL
                     AND    jg_info_v15           IS NOT NULL
                     AND    RTRIM(jg_info_v12)    = RTRIM(lc_tax_registration_number)
                     AND    RTRIM(jg_info_v13)    = RTRIM(lc_customer_name)
                     AND    UPPER(jg_info_v11)    ='A'; */ --Bug 5525421

                      G_LINENO := '1.6.2.7.2.7';
                  END IF;

                  G_LINENO := '1.6.2.7.3';
                 -- JGZZVEFT();  --Bug 5525421 This procedure should call only once i.e. after inserting AP and AR data in to temp table.
                  G_LINENO := '1.6.2.7.4';

                 END IF;
                G_LINENO := '1.6.2.8';
             END IF;

             G_LINENO := '1.6.3';

          INSERT INTO JG_ZZ_VAT_TRX_GT
            ( jg_info_v1    -- lc_clave_operation                                   lc_clave_operation
            , jg_info_v6    -- lc_country Bug 8485057
            , jg_info_v11   -- c_modelo_rec.tax_registration_number                 lc_tax_registration_number
            , jg_info_v12   -- c_modelo_rec.customer_name                           lc_customer_name
            , jg_info_v13   -- c_modelo_rec.customer_address_id                     lc_customer_address_id
            , jg_info_v14   -- c_modelo_rec.billing_trading_partner_id              lc_billing_trading_partner
            , jg_info_n1    -- c_modelo_rec.sum_taxable_amt    -- 347-AP, 415-AP    ln_sum_taxable_amt
            , jg_info_n2    -- c_modelo_rec.sum_trx_line_amt    -- 347-AR,415-AR    ln_sum_trx_line_amt
            , jg_info_n3    -- c_modelo_rec.ncorrection_amount  -- 349              ln_ncorrection_amount
            , jg_info_n4    -- c_modelo_rec.correction_amount   -- 349              ln_correction_amount
            , jg_info_v15   -- c_modelo_rec.correction_year                         lc_correction_year
            , jg_info_v16   -- c_modelo_rec.correction_period                       lc_correction_period
            , jg_info_v17   -- c_modelo_rec.triangulation                           lc_triangulation
            , jg_info_v21   -- c_modelo_rec.property_retail_flag                    lc_property_retail_flag
            , jg_info_v18   -- lc_postal_code                                       lc_postal_code
            , jg_info_v19   -- lc_city                                              lc_city
            , jg_info_v20   -- lc_address_detail                                    lc_address_detail
            , jg_info_n10   -- ln_running_total                                     ln_running_total
            , jg_info_n11   -- ln_formerly_decl_amt                                 ln_formerly_decl_amt
            , jg_info_n12   -- ln_base_imponiable                                   ln_base_imponiable
            , jg_info_v22   -- p_print_year --p_tax_calender_year                   P_TAX_YEAR
            , jg_info_v23   -- legal entity name                                    G_LE_NAME
            , jg_info_v26   -- G_LE_TRN -- 347                                      G_LE_TRN
            , jg_info_v24   -- lc_sign                                              lc_sign
            , jg_info_v25   -- p_tax_office -- 347                                  p_tax_office
            , jg_info_n13   -- lc_print_year   --Bug 5525421
	      , jg_info_v27   -- lc_print_period  --Bug 5525421
            )
          VALUES
            ( lc_clave_operation
            , lc_country
            , lc_tax_registration_number
            , lc_customer_name
            , lc_customer_address_id
            , lc_billing_trading_partner_id
            , ln_sum_taxable_amt
            , ln_sum_trx_line_amt
            , ln_ncorrection_amount
            , ln_correction_amount
            , lc_correction_year
            , lc_correction_period
            , lc_triangulation
            , lc_property_retail_flag
            , lc_postal_code
            , lc_city
            , lc_address_detail
            , ln_running_total
            , ln_formerly_decl_amt
            , ln_base_imponiable
            , P_TAX_YEAR
            , G_LE_NAME
            , G_LE_TRN
            , lc_sign
            , p_tax_office
            , lc_print_year    --Bug 5525421
	    , lc_print_period  --Bug 5525421
            );

      IF G_DEBUG THEN
         fnd_file.put_line(FND_FILE.LOG,G_LINENO);
      END IF;

		----Bug 5525421 Updation should haapend only after insertintg the correction reocrd.

		IF P_MODELO = '349' THEN
		  IF P_REPORT_NAME = 'JEESAMOR' THEN
			IF lc_correction_year IS NOT NULL AND lc_correction_period IS NOT NULL THEN --IS a Correction

		UPDATE JG_ZZ_VAT_TRX_GT
                     SET    jg_info_n10  = ln_formerly_decl_amt + ln_ncorrection_amount
                     WHERE  RTRIM(jg_info_v15)    = RTRIM(lc_correction_year) --RTRIM(SUBSTR(lc_correction_year,3,2))
                     AND    RTRIM(jg_info_v16)    = RTRIM(lc_correction_period)
                     AND    jg_info_v14           IS NOT NULL
                     AND    jg_info_v15           IS NOT NULL
                     AND    RTRIM(jg_info_v12)    = RTRIM(lc_tax_registration_number)
                     AND    RTRIM(jg_info_v13)    = RTRIM(lc_customer_name)
                     AND    UPPER(jg_info_v11)    ='A';

			END IF;
	            END IF;
	        END IF;

            G_LINENO := '1.6.4';

       END LOOP;

       G_LINENO := '1.7';
       CLOSE c_modelo_ext; -- closecur
       G_LINENO := '1.8';

    END IF;


    G_LINENO := '2';

    IF ( P_REPORT_NAME = 'JEESPMOR' AND P_SOURCE = 'AR')
       OR P_REPORT_NAME = 'JEESAMOR' THEN

       G_LINENO := '2.1';

       --
       -- Build query to fetch ap extract for modelo from JG
       --
       lc_jgzz_modelo_query  := C_JGZZ_MODELO_GENRIC_QUERY;
       --
       /**
        author : brathod
        date   : 18/5/2006
        Commented following code to remove date filtering.
        REPLACE( lc_jgzz_modelo_query
                    , '$PERIOD_FROM_DATE$'
                    , 'TO_DATE('''||TO_CHAR(ld_period_start_date, 'DD/MM/YYYY')||''',''DD/MM/YYYY'')' );

       lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$PERIOD_TO_DATE$'
                    , 'TO_DATE('''||TO_CHAR(ld_period_end_date, 'DD/MM/YYYY')||''',''DD/MM/YYYY'')' );

        :: Introduced conditional filtering ::
        Based on report type, FILTER_KEY and FILTER_VALUE will have following values
        For, Periodic Report Filter_Key = TAX_CALENDAR_PERIOD and Filter_Value = P_TAX_PERIOD
             Annual   Report Filter_Key = TAX_CALENDAR_YEAR   and Filter_Value = P_TAX_YEAR

       */
      G_LINENO := '2.2';

        declare
          lv_filter_key   varchar2 (150) ;
          lv_filter_value varchar2 (2000);
          lv_filter_oper varchar2(2);
        begin
          if p_report_name = 'JEESPMOR' then
            lv_filter_key := ' JZVTD.trx_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date
			       AND JZVRS.TAX_CALENDAR_PERIOD'; --5444803
--            lv_filter_key := 'JZVRS.TAX_CALENDAR_PERIOD'; --5444803
            lv_filter_value := l_period_string; --p_tax_period;
            lv_filter_oper := 'In';
          elsif p_report_name = 'JEESAMOR' then
            lv_filter_key := 'JZVTD.trx_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date
		       AND JZVRS.TAX_CALENDAR_YEAR';  -- Bug 5525421
            lv_filter_value := p_tax_year;
            lv_filter_oper := '=';
          end if;

          lc_jgzz_modelo_query :=
                 REPLACE( lc_jgzz_modelo_query
                        , '$FILTER_KEY$'
                        , lv_filter_key
                        );

          lc_jgzz_modelo_query :=
                 REPLACE( lc_jgzz_modelo_query
                        , '$FILTER_OPER$'
                        , lv_filter_oper
                        );

           lc_jgzz_modelo_query :=
                 REPLACE( lc_jgzz_modelo_query
                        , '$FILTER_VALUE$'
                        , lv_filter_value
                        );
        end;

       lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$P_VAT_REP_ENTITY_ID$'
                    , TO_CHAR(P_VAT_REP_ENTITY_ID) );

      G_LINENO := '2.3';

      /**
      author: brathod
      Relacing place holder $MODELO_TABLE_LIST$ with blank space as for AR report its not in use

      lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$MODELO_TABLE_LIST$'
                    ,' ' );
       */

       IF P_MODELO = '347' THEN  -- Modelo 347

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
              , '$MODELO_TABLE_LIST$'
              ,' , hz_cust_site_uses_all  hzcsu ,hz_cust_acct_sites_all hzcas ,hz_cust_accounts hzca, ra_customer_trx_all trx, zx_lines_det_factors zxdf ');

	  lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    ,'$ADDRESS_ID$'
                    ,'hzcsu.cust_acct_site_id' );
          --
          -- Replace Place Holder with Modelo 347 - AR Specific Values
          --
          G_LINENO := '2.3.1';
          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                        , '$TAX_REGISTRATION_NUM$'
          --              ,'JZVTD.billing_tp_tax_reg_num' );      /* Commented for bug 5729082 */
                          , 'JZVTD.billing_tp_taxpayer_id');    /* Added for bug 5729082 */

          lc_jgzz_modelo_query :=
              REPLACE( lc_jgzz_modelo_query
                        , '$CORRECTION_TRX_SEL_COL$'
                        , C_CORRECTION_TRX_NULL_COLS );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                        , '$CORRECTION_TRX_GRP_COL$'
                        , '' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                        , '$MODELO_SPECIFIC_FILTERS$'
                        , C_MOD347_AR_FILTER );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$P_ORG_ID$'
                    , P_ORG_ID );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                        , '$MODELO_SPECIFIC_GRP_FILTER$'
                        , '');
                        -- Bug 8485057 min amount is now checked in the xml
                        --, C_MOD347415_GRP_FILTER );

          -- Bug 8485057, select Transaction Code, default B for AR transactions
          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANS_CODE_SEL_COL$'
                    , ', DECODE( INSTR(zxdf.trx_business_category,''/'',1,3),0,''B'',
         substr(zxdf.trx_business_category,length(trx_business_category),1)) TIPO');

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANS_CODE_GRP_COL$'
                    , ', DECODE( INSTR(zxdf.trx_business_category,''/'',1,3),0,''B'',
         substr(zxdf.trx_business_category,length(zxdf.trx_business_category),1))');

                   lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANSMISSION_PROPERTY_AMT$'
                    , ', SUM(DECODE(JZVTD.extract_source_ledger
                      ,''AR'',DECODE(NVL(trx.global_attribute12, ''N''),
                                  ''Y'', DECODE (JZVTD.TAX_LINE_NUMBER, ''1'', NVL(JZVTD.taxable_amt_funcl_curr, 0),0),0)
                      ,0 )) +
		             SUM(DECODE(JZVTD.extract_source_ledger
		                  ,''AR'',DECODE(NVL(trx.global_attribute12, ''N''),''Y'', NVL(JZVTD.tax_amt_funcl_curr, 0),0)
                      ,0 ))  TRANSMISSION_PROPERTY_AMT');

          G_LINENO := '2.3.2';
          /**
          author:brathod
          Added following code to use p_min_value parameter
          */
          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$P_MIN_VALUE$'
                    , nvl(p_min_value,0));

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$PROPERTY_FLAG_SEL_COL$'
                  --  , C_347_SEL_COL );
                    , C_NULL_SEL_COL );

         /* lc_misc := C_347_SEL_COL ;

          lc_misc := REPLACE( lc_misc, 'PROPERTY_RETAIL_FLAG','');

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$PROPERTY_FLAG_GRP_COL$'
                    , lc_misc ); */

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$PROPERTY_FLAG_GRP_COL$'
                    , '' );

       ELSIF P_MODELO = '415' THEN  -- Modelo 415

          --
          -- Replace Place Holder with Modelo 415 - AR Specific Values
          --
-- FH: Added ZX table for modelo project
          lc_jgzz_modelo_query :=
            REPLACE( lc_jgzz_modelo_query
                    , '$MODELO_TABLE_LIST$'
                    ,' , hz_cust_site_uses_all  hzcsu ,hz_cust_acct_sites_all hzcas ,hz_cust_accounts hzca, ZX_LINES_DET_FACTORS zxdf ' );

          G_LINENO := '2.3.3';
          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                        , '$TAX_REGISTRATION_NUM$'
            --        ,'JZVTD.billing_tp_tax_reg_num' );  /* Commented for bug 5729082 */
                      ,'JZVTD.billing_tp_taxpayer_id');   /* added for bug 5729082 */

-- FH: Added Transaction Code for modelo project --
       lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANS_CODE_SEL_COL$'
                    ,', decode(substr(zxdf.trx_business_category,length(zxdf.trx_business_category)-1,1),''/'',
         substr(zxdf.trx_business_category,length(zxdf.trx_business_category),1),
         ''B'') TRANSACTION_CODE' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANS_CODE_GRP_COL$'
                    , ', decode(substr(zxdf.trx_business_category,length(zxdf.trx_business_category)-1,1),''/'',
         substr(zxdf.trx_business_category,length(zxdf.trx_business_category),1),
         ''B'') ');

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$ADDRESS_ID$'
                    ,'hzcsu.cust_acct_site_id' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                        , '$CORRECTION_TRX_SEL_COL$'
                        , C_CORRECTION_TRX_NULL_COLS );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                        , '$CORRECTION_TRX_GRP_COL$'
                        , '' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                        , '$MODELO_SPECIFIC_FILTERS$'
                        , C_MOD415_AR_FILTER );

         lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$P_ORG_ID$'
                    , P_ORG_ID );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                        , '$MODELO_SPECIFIC_GRP_FILTER$'
                        , C_MOD347415_GRP_FILTER);

            /**
          author:brathod
          Added following code to use p_min_value parameter
          */
          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$P_MIN_VALUE$'
                    , 0); --FH: Moved Min value processing to the xml file nvl(p_min_value,0));

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$PROPERTY_FLAG_SEL_COL$'
                    , C_NULL_SEL_COL );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$PROPERTY_FLAG_GRP_COL$'
                    , '' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANSMISSION_PROPERTY_AMT$'
                    , ', NULL TRANSMISSION_PROPERTY_AMT');

          G_LINENO := '2.3.4';

       ELSIF P_MODELO = '349' THEN  -- Modelo 349
          --
          -- Replace Place Holder with Modelo 349 - AR Specific Values
          --

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$MODELO_TABLE_LIST$'
                    ,' ' );

          G_LINENO := '2.3.5';
          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                        , '$TAX_REGISTRATION_NUM$'
                        ,'JZVTD.billing_tp_taxpayer_id' ) ;

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$ADDRESS_ID$'
                    ,'NULL' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                        , '$CORRECTION_TRX_SEL_COL$'
                        , C_CORRECTION_TRX_SEL_COLS );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                        , '$CORRECTION_TRX_GRP_COL$'
                        , C_CORRECTION_TRX_GRP_COLS );

--FH: Added TRANS_CODE_SEL_COL and TRANS_CODE_GRP_COL for modelo project
           lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANS_CODE_SEL_COL$'
                    ,', NULL TRANSACTION_CODE' );

         lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANS_CODE_GRP_COL$'
                    , '' );

         lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$TRANSMISSION_PROPERTY_AMT$'
                    , ', NULL TRANSMISSION_PROPERTY_AMT');

          /**
            author: brathod
            If the report is Annual Modelo AR (349) - JEESVEFT, then adding extract filtering
            conditions to support multi period reporting.
          */
          if p_report_name = 'JEESAMOR' then -- Annual Report

            declare

              ld_start_date     gl_periods.start_date%type;
              ld_end_date       gl_periods.end_date%type;
              lv_tax_calendar   jg_zz_vat_rep_entities.tax_calendar_name%type;

              /** Fetch the tax accounting calendar from Reporting Entity Setup */
              cursor c_get_tax_calendar
              is
              select tax_calendar_name
              from   jg_zz_vat_rep_entities
              where  vat_reporting_entity_id = p_vat_rep_entity_id;

              /**
                Derrive start date and end date using period range parameters P_FROM_PERIOD and P_TO_PERIOD
              */
              cursor c_get_start_end_dates
              is
              select min(start_date), max(end_date)
              from   gl_periods
              where  period_set_name = lv_tax_calendar
              and    period_name in (P_FROM_PERIOD, P_TO_PERIOD);

            begin

              open  c_get_tax_calendar;
              fetch c_get_tax_calendar into lv_tax_calendar;
              close c_get_tax_calendar;

              open  c_get_start_end_dates;
              fetch c_get_start_end_dates  into ld_start_date, ld_end_date;
              close c_get_start_end_dates;

            /** Append the filter conditions for multi period reporting */
	    --Bug 5525421 Commented. Not required these filters.
             /**   C_MOD349_AR_FILTER := C_MOD349_AR_FILTER || ' AND JZVRS.PERIOD_START_DATE >= ''' || ld_start_date || ''''
                                                       || ' AND JZVRS.PERIOD_END_DATE   <= ''' || ld_end_date || ''''
                                                       || ' AND JZVRS.TAX_CALENDAR_NAME = '''  || lv_tax_calendar  || ''''; */
           end;

          end if;

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                        , '$MODELO_SPECIFIC_FILTERS$'
                        , C_MOD349_AR_FILTER );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                        , '$MODELO_SPECIFIC_GRP_FILTER$'
                        , '' );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$PROPERTY_FLAG_SEL_COL$'
                    , C_NULL_SEL_COL );

          lc_jgzz_modelo_query :=
             REPLACE( lc_jgzz_modelo_query
                    , '$PROPERTY_FLAG_GRP_COL$'
                    , '' );
          G_LINENO := '2.3.6';

       END IF;
       G_LINENO := '2.4';
       -- Insert AR Transations into Global Temp Table
      IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'Modelo SQL Statement: '||lc_jgzz_modelo_query); END IF;

       OPEN c_modelo_ext FOR lc_jgzz_modelo_query ;
       LOOP
          FETCH  c_modelo_ext
          INTO   lc_tax_registration_number
                ,lc_customer_name
                ,lc_customer_address_id
                ,lc_billing_trading_partner_id
                ,ln_sum_taxable_amt
                ,ln_sum_trx_line_amt
                ,ln_ncorrection_amount
                ,ln_correction_amount
                ,lc_correction_year
                ,lc_correction_period
                ,lc_triangulation
	            	,lc_trx_period  -- Bug 5525421
                ,lc_property_retail_flag
                ,lc_clave_operation --FH: Added for modelo project
                ,ln_transmission_property_amt
                ;
          IF G_DEBUG THEN
	    fnd_file.put_line(FND_FILE.LOG,'lc_customer_name='||lc_customer_name||',lc_customer_address_id='||lc_customer_address_id);
	  END IF;

          EXIT WHEN c_modelo_ext%NOTFOUND;

          IF P_MODELO = '415' THEN
             G_LINENO := '2.4.1';
             -- ln_sum_trx_line_amt will have the gross amt for AR
             -- Assign NULL to ln_sum_taxable_amt
             ln_sum_taxable_amt := NULL;
             G_LINENO := '2.4.2';
             get_customer_address ( p_customer_address_id => lc_customer_address_id
                                  , x_postal_code         => lc_postal_code
                                  , x_city                => lc_city
                                  , x_address_detail      => lc_address_detail
                                  );

              G_LINENO := '2.4.3';
             lc_clave_operation         := lc_clave_operation;
             lc_tax_registration_number := SUBSTR( lc_tax_registration_number,1,9);
             lc_customer_name           := SUBSTR(lc_customer_name,1,40);
             lc_address_detail          := SUBSTR(lc_address_detail,1,32);
              G_LINENO := '2.4.4';

          ELSIF    P_MODELO = '347' THEN

                -- Bug 8485057 this value is now selected from the record
                -- lc_clave_operation := 'B' ;
                IF G_DEBUG THEN
                  fnd_file.put_line(FND_FILE.LOG,G_LINENO);
                  fnd_file.put_line(FND_FILE.LOG,'lc_clave_operation: '||lc_clave_operation);
                  fnd_file.put_line(FND_FILE.LOG,'ln_sum_trx_line_amt  :='||ln_sum_trx_line_amt);
                  -- fnd_file.put_line(FND_FILE.LOG,'ln_sum_taxable_amt  :='||ln_sum_taxable_amt);
                  -- fnd_file.put_line(FND_FILE.LOG,'ln_transmission_property_amt='||ln_transmission_property_amt);
                END IF;

                G_LINENO := '2.4.5';
                get_customer_address2
                    ( p_customer_address_id  =>  lc_customer_address_id
                    , x_postal               =>  lc_postal_code
		    , x_post_code            =>  lc_postal_code1
                    , x_city                 =>  lc_city
                    , x_street_type          =>  lc_street_type -- sigla
                    , x_street               =>  lc_street      --via_publica
                    , x_number               =>  lc_number
                    , x_country              =>  lc_country
                    );
                G_LINENO := '2.4.6';

                ln_arrenda_amount :=  AR347_GROSS_AMOUNTFormula
                                       ( p_customer_id    => lc_billing_trading_partner_id
                                       , p_tipo           => lc_clave_operation);

                IF G_DEBUG THEN
                  fnd_file.put_line(FND_FILE.LOG,G_LINENO||'After AR347_GROSS_AMOUNT');
                  fnd_file.put_line(FND_FILE.LOG,'ln_arrenda_amount  :='||ln_arrenda_amount);
                END IF;

                G_LINENO := '2.4.7';
                -- dbms_output.put_line ('ln_sum_trx_line_amt='||ln_sum_trx_line_amt||', ln_arrenda_amount =' || ln_arrenda_amount );
                IF nvl(ln_arrenda_amount,0) <> 0 THEN

                  G_LINENO := '2.4.7.1';
                  ln_sum_trx_line_amt := ln_sum_trx_line_amt - ln_arrenda_amount ;

                  -- fnd_file.put_line(FND_FILE.LOG,G_LINENO);
                  -- fnd_file.put_line(FND_FILE.LOG,'new ln_sum_trx_line_amt  :='||ln_sum_trx_line_amt);

                  /* Bug 8485057: check any cash received for this customer, tipo and property rental */
                  ln_cash_received_amount := AR347_CASH_RECEIVEDFormula ( p_customer_id    => lc_billing_trading_partner_id
                                       , p_tipo           => lc_clave_operation
                                       , p_property_rental_flag => 'Y' );

                  IF G_DEBUG THEN
                    fnd_file.put_line(FND_FILE.LOG,'ln_cash_received_amount  :='||ln_cash_received_amount);
                    --fnd_file.put_line(FND_FILE.LOG,'receipt method:= '||fnd_profile.value('JEES_MOD347_RECEIPT_METHOD'));
                  END IF;

                  /* Bug 8485057 Transmission of property transactions are always different than property rental transactions */
                  INSERT INTO JG_ZZ_VAT_TRX_GT
                     ( jg_info_v1    -- lc_clave_operation
                     , jg_info_n2    -- ln_arrenda_amount
                     , jg_info_n6    -- ln_cash_received_amount
                     , jg_info_v11   -- lc_tax_registration_number
                     , jg_info_v12   -- c_modelo_rec.customer_name
                     , jg_info_v13   -- c_modelo_rec.customer_address_id
                     , jg_info_v14   -- c_modelo_rec.billing_trading_partner_id
                     , jg_info_v21   -- c_modelo_rec.property_retail_flag (flag_arrenda)
                     , jg_info_v18   -- lc_postal_code
                     , jg_info_v19   -- lc_city
                     , jg_info_v20   -- lc_number
                     , jg_info_v25   -- lc_street_type
                     , jg_info_v26   -- lc_street
                     , jg_info_v27   -- fin_id
                     , jg_info_v22   -- p_print_year --p_tax_calendar_year
                     , jg_info_v23   -- legal entity TRN
		     , jg_info_v6    -- lc_country
		     , jg_info_v28   -- lc_postal_code1
                     )
                  VALUES
                     ( lc_clave_operation
                     , ln_arrenda_amount
                     , ln_cash_received_amount
                     , lc_tax_registration_number
                     , lc_customer_name
                     , lc_customer_address_id
                     , lc_billing_trading_partner_id
                     , 'Y'
                     , lc_postal_code
                     , lc_city
                     , lc_number
                     , lc_street_type
                     , lc_street
                     , 'S'
                     , p_tax_year
                     , G_LE_TRN
		     , lc_country
		     , lc_postal_code1
                     ) ;
                  G_LINENO := '2.4.7.2';
                   arrenda ( p_vat_rep_entity_id => p_vat_rep_entity_id
                           , p_customer_id       => lc_billing_trading_partner_id
                           , p_customer_name     => lc_customer_name
                           , p_cust_tax_reg_num  => lc_tax_registration_number
                           , p_tipo              => lc_clave_operation);

                  G_LINENO := '2.4.7.3';

                END IF;
                G_LINENO := '2.4.8';
                IF ln_sum_trx_line_amt >0
                THEN
                  G_LINENO := '2.4.8.1';

                  IF G_DEBUG THEN
                    fnd_file.put_line(FND_FILE.LOG,G_LINENO);
                    fnd_file.put_line(FND_FILE.LOG,'ln_sum_trx_line_amt: '||ln_sum_trx_line_amt );
                    fnd_file.put_line(FND_FILE.LOG,'lc_clave_operation: '||lc_clave_operation );
                  END IF;

                  /* Bug 8485057: check any cash received for this customer, tipo and no property rental */
                  ln_cash_received_amount := AR347_CASH_RECEIVEDFormula
                                       ( p_customer_id    => lc_billing_trading_partner_id
                                       , p_tipo           => lc_clave_operation
                                       , p_property_rental_flag => 'N' );

                  IF G_DEBUG THEN
                    fnd_file.put_line(FND_FILE.LOG,'ln_cash_received_amount  :='||ln_cash_received_amount);
                    -- fnd_file.put_line(FND_FILE.LOG,'receipt method:= '||fnd_profile.value('JEES_MOD347_RECEIPT_METHOD'));
                  END IF;

                  INSERT INTO JG_ZZ_VAT_TRX_GT
                    ( jg_info_v1    -- lc_clave_operation
                    , jg_info_n2    -- ln_sum_trx_line_amt
                    , jg_info_n5    -- ln_transmission_property_amt
                    , jg_info_n6    -- ln_cash_received_amount
                    , jg_info_v11   -- lc_tax_registration_number
                    , jg_info_v12   -- c_modelo_rec.customer_name
                    , jg_info_v13   -- c_modelo_rec.customer_address_id
                    , jg_info_v14   -- c_modelo_rec.billing_trading_partner_id
                    , jg_info_v21   -- c_modelo_rec.property_retail_flag -- flag_arrenda
                    , jg_info_v18   -- lc_postal_code
                    , jg_info_v19   -- lc_city           -- x_ref_catastral
                    , jg_info_v20   -- lc_number -- x_numero
                    , jg_info_v25   -- lc_street_type
                    , jg_info_v26   -- lc_street
                    , jg_info_v27   -- fin_id -- 'S'
                    , jg_info_v22   -- p_print_year --p_tax_calender_year
                    , jg_info_v23   -- legal entity TRN
		    , jg_info_v6    -- lc_country
		    , jg_info_v28   -- lc_postal_code1
                   )
                  VALUES
                    ( lc_clave_operation
                    , ln_sum_trx_line_amt
                    , ln_transmission_property_amt
                    , ln_cash_received_amount
                    , lc_tax_registration_number
                    , lc_customer_name
                    , lc_customer_address_id
                    , lc_billing_trading_partner_id
                    , 'N'
                    , lc_postal_code
                    , lc_city
                    , lc_number
                    , lc_street_type
                    , lc_street
                    , 'S'
                    , p_tax_year
                    , G_LE_TRN
		    , lc_country
		    , lc_postal_code1
                    ) ;
                   G_LINENO := '2.4.8.2';

                   -- fnd_file.put_line(FND_FILE.LOG,G_LINENO||'Inseted into JG_ZZ_VAT_TRX_GT');

                 end if;
                 G_LINENO := '2.4.9';
             ELSIF P_MODELO = '349' THEN
                G_LINENO := '2.4.10';
                IF P_REPORT_NAME = 'JEESAMOR' THEN
                  G_LINENO := '2.4.10.1';
                  ln_running_total           := 0;
                  ln_formerly_decl_amt       := 0;
                  lc_tax_registration_number := SUBSTR( lc_tax_registration_number,1,14);
                  lc_customer_name           := SUBSTR(lc_customer_name,1,40);
		  lc_print_year := P_TAX_YEAR;  --Bug 5525421
		  lc_print_period := lc_trx_period;  --Bug 5525421
                  G_LINENO := '2.4.10.2';

                  IF lc_correction_year IS NULL AND lc_correction_period IS NULL THEN --Not a Correction

                    ln_base_imponiable         := ln_ncorrection_amount;
                    ln_running_total           := ln_ncorrection_amount;
                     G_LINENO := '2.4.10.2.1';
                     SELECT DECODE(lc_triangulation,'X','T','E')
                     INTO   lc_clave_operation
                     FROM   DUAL ;
                     G_LINENO := '2.4.10.2.2';

                  ELSIF lc_correction_year IS NOT NULL AND lc_correction_period IS NOT NULL THEN --IS a Correction
                     G_LINENO := '2.4.10.2.3';
                     ln_formerly_decl_amt  := 0;
                     lc_correction_year    := lc_correction_year; --SUBSTR(lc_correction_year,3,2);
                     ln_base_imponiable    := ln_correction_amount;
                    G_LINENO := '2.4.10.2.4';
                     SELECT DECODE(lc_triangulation,'X','t','e')  -- Bug 5525421
                     INTO   lc_clave_operation
                     FROM   DUAL ;
                     G_LINENO := '2.4.10.2.5';
                     IF lc_clave_operation IN ('1','2') THEN
                          lc_sign := ' ';
                     ELSE
                          IF ln_base_imponiable < 0 THEN
                             lc_sign := '-' ;
                          ELSE
                             lc_sign := '+' ;
                          END IF;
                     END IF;
                     G_LINENO := '2.4.10.2.6';

		     begin
                       SELECT NVL(jg_info_n10,0) -- running total
                       INTO   ln_formerly_decl_amt
                       FROM   JG_ZZ_VAT_TRX_GT  M349
                       WHERE  RTRIM(jg_info_v11)      = RTRIM(lc_tax_registration_number)
                       AND    RTRIM(jg_info_v12)   = RTRIM(lc_customer_name)
                       AND    jg_info_n13          = lc_correction_year -- correction year     -- Bug 5525421
                       AND    jg_info_v27          = lc_correction_period -- correction period -- Bug 5525421
                      -- AND    RTRIM(jg_info_v21)      = RTRIM(lc_correction_year) -- Bug 5525421
                       AND    UPPER(jg_info_v1)    =  upper(DECODE(lc_triangulation,'X','T','E'));

                     exception
                       when no_data_found then
                       ln_formerly_decl_amt :=0;
  		     end;
                     G_LINENO := '2.4.10.2.7';
                     --
                     -- update running total
                     -- -- Bug 5525421 As per R11i logic this update should happend after the insert. Hence moving this to after insert.
                  /*   UPDATE JG_ZZ_VAT_TRX_GT
                     SET    jg_info_n10  = ln_formerly_decl_amt + ln_ncorrection_amount
                     WHERE  RTRIM(jg_info_v15)    = RTRIM(lc_correction_year)--RTRIM(SUBSTR(lc_correction_year,3,2))
                     AND    RTRIM(jg_info_v16)    = RTRIM(lc_correction_period)
                     AND    jg_info_v15           IS NOT NULL
                     AND    jg_info_v16           IS NOT NULL
                     AND    RTRIM(jg_info_v12)    = RTRIM(lc_tax_registration_number)
                     AND    RTRIM(jg_info_v13)    = RTRIM(lc_customer_name)
                     AND    UPPER(jg_info_v11)    = upper(DECODE(lc_triangulation,'X','T','E')); */
                     G_LINENO := '2.4.10.2.8';
                  END IF;
                  G_LINENO := '2.4.10.3 ';
                 -- JGZZVEFT(); -- Bug 5525421
                  G_LINENO := '2.4.10.4';
                END IF;
                G_LINENO := '2.4.11';
          END IF;
             G_LINENO := '2.5';

          IF  P_MODELO <> '347' THEN
              G_LINENO := '2.5.1';
             INSERT INTO JG_ZZ_VAT_TRX_GT
               ( jg_info_v1    -- lc_clave_operation
               , jg_info_v11   -- c_modelo_rec.tax_registration_number
               , jg_info_v12   -- c_modelo_rec.customer_name
               , jg_info_v13   -- c_modelo_rec.customer_address_id
               , jg_info_v14   -- c_modelo_rec.billing_trading_partner_id
               , jg_info_n1    -- c_modelo_rec.sum_taxable_amt     -- 347-AP, 415-AP
               , jg_info_n2    -- c_modelo_rec.sum_trx_line_amt    -- 347-AR, 415-AR
               , jg_info_n3    -- c_modelo_rec.ncorrection_amount  -- 349
               , jg_info_n4    -- c_modelo_rec.correction_amount   -- 349
               , jg_info_v15   -- c_modelo_rec.correction_year
               , jg_info_v16   -- c_modelo_rec.correction_period
               , jg_info_v17   -- c_modelo_rec.triangulation
               , jg_info_v21   -- c_modelo_rec.property_retail_flag
               , jg_info_v18   -- lc_postal_code
               , jg_info_v19   -- lc_city           -- x_ref_catastral
               , jg_info_v20   -- lc_address_detail -- x_numero
               , jg_info_n10   -- ln_running_total
               , jg_info_n11   -- ln_formerly_decl_amt
               , jg_info_n12   -- ln_base_imponiable
               , jg_info_v22   -- p_print_year --p_tax_calender_year
               , jg_info_v23   -- legal entity name
               , jg_info_v26   -- G_LE_TRN -- 347
               , jg_info_v24   -- lc_sign
               , jg_info_v25   -- p_tax_office -- 347
	       , jg_info_n13   -- lc_prtint_year -- Bug 5525421
	       , jg_info_v27   -- lc_print_period -- Bug 5525421
               )
             VALUES
               ( lc_clave_operation
               , lc_tax_registration_number
               , lc_customer_name
               , lc_customer_address_id
               , lc_billing_trading_partner_id
               , ln_sum_taxable_amt
               , ln_sum_trx_line_amt
               , ln_ncorrection_amount
               , ln_correction_amount
               , lc_correction_year
               , lc_correction_period
               , lc_triangulation
               , lc_property_retail_flag
               , lc_postal_code
               , lc_city
               , lc_address_detail
               , ln_running_total
               , ln_formerly_decl_amt
               , ln_base_imponiable
               , P_TAX_YEAR
               , G_LE_NAME
               , G_LE_TRN
               , lc_sign
               , p_tax_office
	       , lc_print_year  -- Bug 5525421
	       , lc_print_period -- Bug 5525421
               );

		  -- Bug 5525421 The updating should happend only after inserting the correction record.

		  IF P_MODELO = '349' THEN
		    IF P_REPORT_NAME = 'JEESAMOR' THEN
			IF lc_correction_year IS NOT NULL AND lc_correction_period IS NOT NULL THEN --IS a Correction

		         UPDATE JG_ZZ_VAT_TRX_GT
                     SET    jg_info_n10  = ln_formerly_decl_amt + ln_ncorrection_amount
                     WHERE  RTRIM(jg_info_v15)    = RTRIM(lc_correction_year)--RTRIM(SUBSTR(lc_correction_year,3,2))
                     AND    RTRIM(jg_info_v16)    = RTRIM(lc_correction_period)
                     AND    jg_info_v15           IS NOT NULL
                     AND    jg_info_v16           IS NOT NULL
                     AND    RTRIM(jg_info_v12)    = RTRIM(lc_tax_registration_number)
                     AND    RTRIM(jg_info_v13)    = RTRIM(lc_customer_name)
                     AND    UPPER(jg_info_v11)    = upper(DECODE(lc_triangulation,'X','T','E'));

			END IF;
	          END IF;
	        END IF;

            END IF;
            G_LINENO := '2.5.2';
       END LOOP;
       G_LINENO := '2.5.3';
       CLOSE c_modelo_ext; -- closecur
       G_LINENO := '2.5.4';
    END IF;

    -- Bug 5525421 This procedure should call only once i.e after iserting all AP  and  AR records in to temp table.
	IF P_MODELO = '349' THEN
	  IF P_REPORT_NAME = 'JEESAMOR' THEN
		    JGZZVEFT();
	  END IF;
	END IF;
    G_LINENO := '2.6';


ELSE

   IF G_DEBUG THEN
     fnd_file.put_line(FND_FILE.LOG,'Modelo 340 AP Processing ...');
      fnd_file.put_line(FND_FILE.LOG,'Driving Date ...'||p_driving_date);
   END IF;

   G_LINENO := '2.5.5';

   -- 260974
   -- Declaration of base 340 query
   lc_jgzz_mod_query_340 :=
   'SELECT  decode(substrb(jzvtd.billing_tp_tax_reg_num,1,2),''ES'',
                   jzvtd.billing_tp_taxpayer_id)                                      DECLARED_NIF,
             substrb(jzvtd.billing_tp_name,1,40)                                      DECLARED_NAME,
             je_es_modelo_ext_pkg.getKeyID(substrb(jzvtd.billing_tp_tax_reg_num,1,2)) KEY_ID,  -- BUG 8946271
             decode(substrb(jzvtd.billing_tp_tax_reg_num,1,2),''ES'',null,
                    substrb(jzvtd.billing_tp_taxpayer_id,1,17))                       FISCAL_ID,
             decode(substr(api.document_sub_type,1,6), ''MOD340'', substr(api.document_sub_type,8,1),
             decode(substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3)
               ,''347'',''R'',''415'',''S'',''349'',''R''))                           BOOK_TYPE,
             decode( instr(zxdf.user_defined_fisc_class,''NONE'',7,1),7,'' '', substr(zxdf.user_defined_fisc_class,7,1) )     TRANSACTION_CODE,
             jzvtd.trx_date                                                           ISSUE_DATE,
             jzvtd.tax_invoice_date                                                   TRANSACTION_DATE,
             jzvtd.trx_number                                                         INVOICE_IDENT,
             jzvtd.doc_seq_value                                                      REGISTER_NUMBER,
             decode(substr(api.document_sub_type,1,8),''MOD340/U'',
                    substr(api.document_sub_type,9,1))                                INTRA_TYPE,
             decode(substr(api.document_sub_type,1,8), ''MOD340/U'',''D''
                ,decode(substr(zxdf.trx_business_category,
                (instr(zxdf.trx_business_category,''MOD'',1,1)+3),3),''349'',''D''))       KEY_OF_DECLARED,
             api.global_attribute10                                                   TRANSACTION_DEADLINE,
             decode(substr(api.document_sub_type,1,8)
                    ,''MOD340/U'',substrb(jzvtd.TRX_LINE_DESCRIPTION,1,35)
                    ,decode(substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3)
                    ,''349'',substrb(jzvtd.TRX_LINE_DESCRIPTION,1,35)))               DESC_OF_GOODS,
             SUM(DECODE(jzvtd.OFFSET_FLAG,''N'',
                   nvl(JZVTD.taxable_amt_funcl_curr,JZVTD.taxable_amt)*(JZVTD.tax_recovery_rate/100)
			,0))                     TAXABLE_AMOUNT,
             SUM(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt ))                        TAX_AMOUNT,
             SUM(DECODE(jzvtd.OFFSET_FLAG,''N'',
                   nvl(JZVTD.taxable_amt_funcl_curr,JZVTD.taxable_amt)*(JZVTD.tax_recovery_rate/100),0)) +
             SUM(nvl(DECODE(jzvtd.tax_amt_funcl_curr,
                          0, jzvtd.tax_amt ,
                          NULL, jzvtd.tax_amt,
                          jzvtd.tax_amt_funcl_curr), 0))                             INV_TOTAL_AMOUNT,
             SUM(decode(jzvtd.tax_recoverable_flag, ''Y'',
                    nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt )))                   DEDUCTABLE_AMOUNT,
             jzvtd.tax_rate                                                          TAX_RATE,
             APSS.VENDOR_SITE_ID
    FROM    jg_zz_vat_trx_details jzvtd, jg_zz_vat_rep_status  jzvrs
          , AP_SUPPLIER_SITES_ALL APSS, AP_SUPPLIERS APS, AP_INVOICES_ALL API,
	    zx_lines_det_factors zxdf
    WHERE   (substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3) in (''347'',''349'',''415'')
             OR substr(jzvtd.document_sub_type,1,6) = ''MOD340'')
    AND       nvl(jzvtd.document_sub_type,''X'') <> ''MOD340_EXCL''
    AND     JZVRS.vat_reporting_entity_id  = $P_VAT_REP_ENTITY_ID$
    AND     JZVTD.reporting_status_id in (SELECT DISTINCT JZRS.reporting_status_id JZRS
    			                  FROM  jg_zz_vat_rep_status JZRS
     				          WHERE JZRS.vat_reporting_entity_id = $P_VAT_REP_ENTITY_ID$
                                          AND   JZRS.source = ''AP'' )
    AND     $FILTER_KEY$ $FILTER_OPER$ $FILTER_VALUE$
            $340_PERIOD_KEY$ $340_PERIOD_KEY_FROM$ $340_PERIOD_OPER$ $340_PERIOD_KEY_TO$
    AND     JZVTD.trx_line_type <> ''AWT''
    AND     JZVTD.trx_line_class <> ''EXPENSE REPORT''
    AND     JZVTD.applied_from_line_id IS NULL
    AND     JZVTD.extract_source_ledger =  ''AP''
    AND     JZVRS.source =  ''AP''
    AND     JZVTD.BILLING_TRADING_PARTNER_ID =  APS.VENDOR_ID
    AND     APS.VENDOR_ID =  APSS.VENDOR_ID
    AND     NVL(APS.FEDERAL_REPORTABLE_FLAG,''Y'')=  ''Y''
    AND     APSS.TAX_REPORTING_SITE_FLAG =  ''Y''
    AND     APSS.ORG_ID =  $P_ORG_ID$
    AND     jzvtd.trx_id = api.invoice_id
    AND     jzvtd.trx_id = zxdf.trx_id
    AND     jzvtd.trx_line_id = zxdf.trx_line_id
    GROUP BY decode(substrb(jzvtd.billing_tp_tax_reg_num,1,2),''ES'',
      jzvtd.billing_tp_taxpayer_id),
      substrb(jzvtd.billing_tp_name,1,40),
      je_es_modelo_ext_pkg.getKeyID(substrb(jzvtd.billing_tp_tax_reg_num,1,2)),
      decode(substrb(jzvtd.billing_tp_tax_reg_num,1,2),''ES'',null,
             substrb(jzvtd.billing_tp_taxpayer_id,1,17)),
      decode(substr(api.document_sub_type,1,6), ''MOD340'', substr(api.document_sub_type,8,1),
      decode(substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3)
         ,''347'',''R'',''415'',''S'',''349'',''R'')),
      decode( instr(zxdf.user_defined_fisc_class,''NONE'',7,1),7,'' '', substr(zxdf.user_defined_fisc_class,7,1) ),
      jzvtd.trx_date, jzvtd.tax_invoice_date, jzvtd.trx_number, jzvtd.doc_seq_value,
      decode(substr(api.document_sub_type,1,8),''MOD340/U'',
         substr(api.document_sub_type,9,1)),
      decode(substr(api.document_sub_type,1,8), ''MOD340/U'',''D''
        ,decode(substr(zxdf.trx_business_category,
        (instr(zxdf.trx_business_category,''MOD'',1,1)+3),3),''349'',''D'')),
      api.global_attribute10,
      decode(substr(api.document_sub_type,1,8)
        ,''MOD340/U'',substrb(jzvtd.TRX_LINE_DESCRIPTION,1,35)
        ,decode(substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3)
        ,''349'',substrb(jzvtd.TRX_LINE_DESCRIPTION,1,35))),
      jzvtd.tax_rate, APSS.VENDOR_SITE_ID ';

  lc_jgzz_mod_query_340_exp :=
  'UNION SELECT decode(substrb(jzvtd.billing_tp_tax_reg_num,1,2),''ES'',
             NVL(JZVTD.merchant_party_taxpayer_id, JZVTD.billing_tp_taxpayer_id))     DECLARED_NIF,
             substrb(NVL(JZVTD.billing_tp_name,JZVTD.merchant_party_name),1,40)       DECLARED_NAME,
             je_es_modelo_ext_pkg.getKeyID(substrb(jzvtd.billing_tp_tax_reg_num,1,2)) KEY_ID, --BUG 8946271
             decode(substrb(jzvtd.billing_tp_tax_reg_num,1,2),''ES'',null,
                    substrb(jzvtd.billing_tp_taxpayer_id,1,17))                       FISCAL_ID,
             decode(substr(api.document_sub_type,1,6), ''MOD340'', substr(api.document_sub_type,8,1),
             decode(substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3)
               ,''347'',''R'',''415'',''S'',''349'',''R''))                           BOOK_TYPE,
             decode( instr(zxdf.user_defined_fisc_class,''NONE'',7,1),7,'' '', substr(zxdf.user_defined_fisc_class,7,1) ) TRANSACTION_CODE,
             jzvtd.trx_date                                                           ISSUE_DATE,
             jzvtd.tax_invoice_date                                                   TRANSACTION_DATE,
             jzvtd.trx_number                                                         INVOICE_IDENT,
             jzvtd.doc_seq_value                                                      REGISTER_NUMBER,
             decode(substr(api.document_sub_type,1,8),''MOD340/U'',
                    substr(api.document_sub_type,9,1))                                INTRA_TYPE,
             decode(substr(api.document_sub_type,1,8), ''MOD340/U'',''D''
                ,decode(substr(zxdf.trx_business_category,
                (instr(zxdf.trx_business_category,''MOD'',1,1)+3),3),''349'',''D''))       KEY_OF_DECLARED,
             api.global_attribute10                                                   TRANSACTION_DEADLINE,
             decode(substr(api.document_sub_type,1,8)
                    ,''MOD340/U'',substrb(jzvtd.TRX_LINE_DESCRIPTION,1,35)
                    ,decode(substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3)
                    ,''349'',substrb(jzvtd.TRX_LINE_DESCRIPTION,1,35)))               DESC_OF_GOODS,
             SUM(DECODE(jzvtd.OFFSET_FLAG,''N'',
                   nvl(JZVTD.taxable_amt_funcl_curr,JZVTD.taxable_amt)*(JZVTD.tax_recovery_rate/100),0))                     TAXABLE_AMOUNT,
             SUM(nvl(DECODE(jzvtd.tax_amt_funcl_curr,
                          0, jzvtd.tax_amt ,
                          NULL, jzvtd.tax_amt,
                          jzvtd.tax_amt_funcl_curr), 0))                              TAX_AMOUNT,
             SUM(DECODE(jzvtd.OFFSET_FLAG,''N'',
                   nvl(JZVTD.taxable_amt_funcl_curr,JZVTD.taxable_amt)*(JZVTD.tax_recovery_rate/100)
		   ,0)) +
             SUM(nvl(DECODE(jzvtd.tax_amt_funcl_curr,
                          0, jzvtd.tax_amt ,
                          NULL, jzvtd.tax_amt,
                          jzvtd.tax_amt_funcl_curr), 0))                             INV_TOTAL_AMOUNT,
             SUM(decode(jzvtd.tax_recoverable_flag, ''Y'',
                    nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt )))                   DEDUCTABLE_AMOUNT,
             jzvtd.tax_rate                                                          TAX_RATE,
             APSS.VENDOR_SITE_ID
     FROM    jg_zz_vat_trx_details jzvtd, jg_zz_vat_rep_status  jzvrs
             , AP_SUPPLIER_SITES_ALL APSS, AP_SUPPLIERS APS, AP_INVOICES_ALL API,
	    zx_lines_det_factors zxdf
     WHERE   (substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3) in (''347'',''349'',''415'')
             OR substr(jzvtd.document_sub_type,1,6) = ''MOD340'')
     AND       nvl(jzvtd.document_sub_type,''X'') <> ''MOD340_EXCL''
     AND     JZVRS.vat_reporting_entity_id = $P_VAT_REP_ENTITY_ID$
     AND     JZVRS.reporting_status_id = JZVTD.reporting_status_id
     AND     JZVTD.extract_source_ledger = ''AP''
     AND     JZVRS.source = ''AP''
     AND     $FILTER_KEY$ $FILTER_OPER$ $FILTER_VALUE$
             $340_PERIOD_KEY$ $340_PERIOD_KEY_FROM$ $340_PERIOD_OPER$ $340_PERIOD_KEY_TO$
     AND     JZVTD.trx_line_type NOT IN (''AWT'',''TAX'',''PREPAY'')
     AND     JZVTD.trx_line_class = ''EXPENSE REPORT''
     AND     JZVTD.applied_from_line_id IS NULL
     AND     JZVTD.extract_source_ledger =  ''AP''
     AND     JZVRS.source =  ''AP''
     AND     JZVTD.BILLING_TRADING_PARTNER_ID =  APS.VENDOR_ID
     AND     APS.VENDOR_ID =  APSS.VENDOR_ID
     AND     NVL(APS.FEDERAL_REPORTABLE_FLAG,''Y'')=  ''Y''
     AND     APSS.TAX_REPORTING_SITE_FLAG = ''Y''
     AND     APSS.ORG_ID = $P_ORG_ID$
     AND     jzvtd.trx_id = api.invoice_id
     AND     jzvtd.trx_id = zxdf.trx_id
     AND     jzvtd.trx_line_id = zxdf.trx_line_id
     GROUP BY decode(substrb(jzvtd.billing_tp_tax_reg_num,1,2),''ES'',
       NVL(JZVTD.merchant_party_taxpayer_id,
       JZVTD.billing_tp_taxpayer_id)),
       substrb(NVL(JZVTD.billing_tp_name,JZVTD.merchant_party_name),1,40),
      je_es_modelo_ext_pkg.getKeyID(substrb(jzvtd.billing_tp_tax_reg_num,1,2)),
      decode(substrb(jzvtd.billing_tp_tax_reg_num,1,2),''ES'',null,
             substrb(jzvtd.billing_tp_taxpayer_id,1,17)),
       decode(substr(api.document_sub_type,1,6), ''MOD340'', substr(api.document_sub_type,8,1),
       decode(substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3)
               ,''347'',''R'',''415'',''S'',''349'',''R'')),
       decode( instr(zxdf.user_defined_fisc_class,''NONE'',7,1),7,'' '', substr(zxdf.user_defined_fisc_class,7,1) ),
       jzvtd.trx_date, jzvtd.tax_invoice_date, jzvtd.trx_number, jzvtd.doc_seq_value,
       decode(substr(api.document_sub_type,1,8),''MOD340/U'', substr(api.document_sub_type,9,1)),
       decode(substr(api.document_sub_type,1,8), ''MOD340/U'',''D''
                ,decode(substr(zxdf.trx_business_category,
                (instr(zxdf.trx_business_category,''MOD'',1,1)+3),3),''349'',''D'')),
       api.global_attribute10,
       decode(substr(api.document_sub_type,1,8)
         ,''MOD340/U'',substrb(jzvtd.TRX_LINE_DESCRIPTION,1,35)
         ,decode(substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3)
         ,''349'',substrb(jzvtd.TRX_LINE_DESCRIPTION,1,35))),
       jzvtd.tax_rate, APSS.VENDOR_SITE_ID ';

  lc_jgzz_mod_query_340 := lc_jgzz_mod_query_340 || lc_jgzz_mod_query_340_exp;

        -- Date processing for query
        declare
          lv_filter_key varchar2 (150) ;
          lv_filter_value varchar2 (2000);
          lv_filter_oper varchar2(2);

        begin

  -- ****************************************************************************
  -- ****  For Period report restricts by start / end dates
  -- ****  AND by PERIOD
  -- ****************************************************************************
          if p_report_name = 'JEESPMOR' then

            lv_filter_key := ' JZVTD.trx_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date
		       AND JZVRS.TAX_CALENDAR_PERIOD';
           if p_driving_date = 'GL' then

            lv_filter_key :=
            REPLACE( lv_filter_key
                    ,'trx_date'
                    ,'gl_date'
                    );
            end if;
            lv_filter_value := l_period_string;
            lv_filter_oper := 'In';

            lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_KEY$'
                      , ' ' );

            lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_KEY_FROM$'
                      , ' ' );

            lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_OPER$'
                      , ' ' );

            lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_KEY_TO$'
                      , ' ' );

  -- ****************************************************************************
  -- ****  For Annual report restricts by start / end dates
  -- ****  AND by TAX CALENDAR YEAR
  -- ****************************************************************************
          elsif p_report_name = 'JEESAMOR' then

            -- Original modelo processing
            lv_filter_key := 'JZVTD.trx_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date
		       AND JZVRS.TAX_CALENDAR_YEAR';
           if p_driving_date = 'GL' then

            lv_filter_key :=
            REPLACE( lv_filter_key
                    ,'trx_date'
                    ,'gl_date'
                    );
            end if;
            lv_filter_value := p_tax_year;
            lv_filter_oper := '=';

            -- Set start and end dates, specific to 340
            set_dates;

            fnd_file.put_line(FND_FILE.LOG,'**** start '||p_340_start_date||' end '||p_340_end_date);

           if p_driving_date = 'GL' then
             lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_KEY$'
                      , 'AND JZVTD.gl_date BETWEEN  ' );

            else--if p_driving_date ='TRX'
              lc_jgzz_mod_query_340 :=
	                   REPLACE( lc_jgzz_mod_query_340
	                          , '$340_PERIOD_KEY$'
                      , 'AND JZVTD.trx_date BETWEEN  ' );
             end if;

            lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_KEY_FROM$'
                      ,'''' || p_340_start_date ||'''');
                      -- , p_340_start_date );

            lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_OPER$'
                      , 'AND' );

            lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_KEY_TO$'
                      ,'''' || p_340_end_date ||'''');

          end if;

        lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$FILTER_KEY$'
                      , lv_filter_key
                      );

        lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$FILTER_OPER$'
                      , lv_filter_oper
                      );

         lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$FILTER_VALUE$'
                      , lv_filter_value
                      );

        end;

         lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$P_VAT_REP_ENTITY_ID$'
                      , TO_CHAR(P_VAT_REP_ENTITY_ID)
                      );

         lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$P_ORG_ID$'
                      , P_ORG_ID );

IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'2.5.6.1 Open the AP Dynamic Query for 340 : '||lc_jgzz_mod_query_340 ); END IF;


       OPEN c_modelo_340 FOR lc_jgzz_mod_query_340 ;
       LOOP

          G_LINENO := '2.5.5.1';

  -- ****************************************************************************
  -- ****  Fetches from main query into variables
  -- ****
  -- ****************************************************************************
          FETCH  c_modelo_340
          INTO   lc_tax_registration_number
                ,lc_customer_name
                ,lc_key_id
		,lc_foreign_taxpayer_id
		,lc_book_type
		,lc_transaction_code
		,ld_invoice_date
		,ld_trx_date
		,lc_trx_num
		,lc_doc_seq
		,lc_intra_type
		,lc_key_declared
	        ,lc_trx_deadline
		,lc_desc_of_goods
		,ln_taxable_amt
		,ln_tax_amt
		,ln_inv_total_amt
		,ln_deductable_amt
		,ln_tax_rate
                ,lc_customer_address_id
                ;

           EXIT WHEN c_modelo_340%NOTFOUND;

             G_LINENO := '2.5.5.2';

               get_vendor_address ( p_party_site_id  => lc_customer_address_id
                                  , x_postal_code    => lc_postal_code
                                  , x_city           => lc_city
                                  , x_address_detail => lc_address_detail
                                  , x_country        => lc_country
                                  );


               lc_tax_registration_number := SUBSTR( lc_tax_registration_number,1,9);
               lc_address_detail          := SUBSTR(lc_address_detail,1,40);

                G_LINENO := '2.5.5.3';

               IF G_DEBUG THEN
                 fnd_file.put_line(FND_FILE.LOG,'lc_trx_num='||lc_trx_num);
                 fnd_file.put_line(FND_FILE.LOG,'lc_address_detail='||lc_address_detail);
                 fnd_file.put_line(FND_FILE.LOG,'lc_postal_code='||lc_postal_code);
                 fnd_file.put_line(FND_FILE.LOG,'lc_city='||lc_city);
               END IF;

                G_LINENO := '2.5.5.4';

            -- Insert payables record
            INSERT INTO JG_ZZ_VAT_TRX_GT
            ( jg_info_v1
            , jg_info_v20   -- p_tax_year
            , jg_info_v2    -- lc_taxpayer_id
            , jg_info_v3    -- lc_company_name
            , jg_info_v4    -- c_modelo_340.lc_tax_registration_number
            , jg_info_v5    -- c_modelo_340.lc_customer_name
            , jg_info_v6    -- lc_country
            , jg_info_v7    -- c_modelo_340.lc_key_id
            , jg_info_v8    -- c_modelo_340.lc_foreign_taxpayer_id
            , jg_info_v9    -- c_modelo_340.lc_book_type
            , jg_info_v10   -- c_modelo_340.lc_transaction_code
            , jg_info_d1    -- c_modelo_340.ld_invoice_date
            , jg_info_d2    -- c_modelo_340.ld_trx_date
            , jg_info_n1    -- c_modelo_340.ln_tax_rate
            , jg_info_n2    -- c_modelo_340.ln_taxable_amt
            , jg_info_n3    -- c_modelo_340.ln_tax_amt
            , jg_info_n4    -- c_modelo_340.ln_inv_total_amt
            , jg_info_v11   -- c_modelo_340.lc_trx_num
            , jg_info_v12   -- c_modelo_340.lc_doc_seq
            , jg_info_n7    -- c_modelo_340.ln_deductable_amt
            , jg_info_v13   -- c_modelo_340.c_intra_type
            , jg_info_v14   -- c_modelo_340.lc_key_declared
            , jg_info_v15   -- lc_country
            , jg_info_v16   -- lc_trx_deadline
            , jg_info_v17   -- c_modelo_340.lc_desc_of_goods
            , jg_info_v21   -- lc_address_detail
            , jg_info_v22   -- lc_city
            , jg_info_v23   -- lc_postal_code
            )
          VALUES
            ( '340'
            , p_tax_year
            , lc_taxpayer_id
            , lc_company_name
            , lc_tax_registration_number
            , lc_customer_name
            , lc_country
            , lc_key_id
            , lc_foreign_taxpayer_id
            , lc_book_type
            , lc_transaction_code
            , ld_invoice_date
            , ld_trx_date
            , ln_tax_rate
            , ln_taxable_amt
            , ln_tax_amt
            , ln_inv_total_amt
            , lc_trx_num
            , lc_doc_seq
            , ln_deductable_amt
            , lc_intra_type
            , lc_key_declared
            , lc_country
            , lc_trx_deadline
            , lc_desc_of_goods
            , lc_address_detail
            , lc_city
            , lc_postal_code
            );

        END LOOP;

                G_LINENO := '2.5.5.4';

        IF c_modelo_340%ISOPEN THEN
          CLOSE c_modelo_340;
        END IF;

   IF G_DEBUG THEN
     fnd_file.put_line(FND_FILE.LOG,'Modelo 340 AP Processing Complete');
     fnd_file.put_line(FND_FILE.LOG,'Modelo 340 AR Processing ...');
   END IF;

   lc_jgzz_mod_query_340 :=
   'SELECT  decode(substrb(jzvtd.billing_tp_tax_reg_num,1,2),''ES'',
                  jzvtd.billing_tp_taxpayer_id)                                      DECLARED_NIF,
            substrb(jzvtd.billing_tp_name,1,40)                                      DECLARED_NAME,
            je_es_modelo_ext_pkg.getKeyID(substrb(jzvtd.billing_tp_tax_reg_num,1,2)) KEY_ID,   --BUG 8946271
            decode(substrb(jzvtd.billing_tp_tax_reg_num,1,2),''ES'',null,
                   substrb(jzvtd.billing_tp_taxpayer_id,1,17))                       FISCAL_ID,
            decode(substr(zxdf.document_sub_type,1,6), ''MOD340'', substr(zxdf.document_sub_type,8,1),
            decode(substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3)
                ,''347'',''E'',''415'',''F'',''349'',''E''))                         BOOK_TYPE,
            decode( instr(zxdf.user_defined_fisc_class,''NONE'',7,1),7,'' '', substr(zxdf.user_defined_fisc_class,7,1) ) TRANSACTION_CODE,
            jzvtd.trx_date                                                           ISSUE_DATE,
            to_date(trx.global_attribute13,''YYYY/MM/DD HH24:MI:SS'')                TRANSACTION_DATE,
            jzvtd.trx_number                                                         INVOICE_IDENT,
            jzvtd.doc_seq_value                                                      REGISTER_NUMBER,
            decode(substr(zxdf.document_sub_type,1,8),''MOD340/U'',
                   substr(zxdf.document_sub_type,9,1))                               INTRA_TYPE,
            decode(substr(zxdf.document_sub_type,1,8), ''MOD340/U'',''R''
              ,decode(substr(zxdf.trx_business_category,
                (instr(zxdf.trx_business_category,''MOD'',1,1)+3),3),''349'',''R''))      KEY_OF_DECLARED,
            trx.global_attribute10                                                   TRANSACTION_DEADLINE,
            decode(substr(zxdf.document_sub_type,1,8)
                   ,''MOD340/U'',substrb(jzvtd.TRX_LINE_DESCRIPTION,1,35)
                   ,decode(substr(jzvtd.invoice_report_type,1,3),
                          ''349'',substrb(jzvtd.TRX_LINE_DESCRIPTION,1,35)))         DESC_OF_GOODS,
            jzvtd.trx_line_number,
            jzvtd.trx_line_id,
            jzvtd.trx_id,
            jzvtd.reporting_status_id,
            DECODE(NVL(jzvtd.taxable_amt_funcl_curr , 0)
                          , 0 , jzvtd.taxable_amt
                              , jzvtd.taxable_amt_funcl_curr)                      TAXABLE_AMOUNT,
            hzcsu.cust_acct_site_id
    FROM    jg_zz_vat_trx_details jzvtd, jg_zz_vat_rep_status  jzvrs
            , hz_cust_site_uses_all  hzcsu ,hz_cust_acct_sites_all hzcas ,hz_cust_accounts hzca
            , ZX_LINES_DET_FACTORS zxdf, ra_customer_trx_all trx
    WHERE   (substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3) in (''347'',''349'',''415'')
            OR substr(zxdf.document_sub_type,1,6) = ''MOD340'')
    AND       nvl(zxdf.document_sub_type,''X'') <> ''MOD340_EXCL''
    AND     JZVRS.vat_reporting_entity_id  = $P_VAT_REP_ENTITY_ID$
    AND     JZVTD.reporting_status_id in (SELECT DISTINCT JZRS.reporting_status_id JZRS
    			                  FROM  jg_zz_vat_rep_status JZRS
     				          WHERE JZRS.vat_reporting_entity_id = $P_VAT_REP_ENTITY_ID$
                                          AND   JZRS.source = ''AR'' )
    AND     $FILTER_KEY$ $FILTER_OPER$ $FILTER_VALUE$
            $340_PERIOD_KEY$ $340_PERIOD_KEY_FROM$ $340_PERIOD_OPER$ $340_PERIOD_KEY_TO$
    AND     JZVTD.extract_source_ledger =  ''AR''
    AND     JZVRS.source = ''AR''
    AND     JZVTD.trx_line_class <> ''DEBIT''
    AND     SUBSTR(NVL(JZVTD.tax_rate_vat_trx_type_code,''QQQQQQ''),1,3) <> ''RET''
    AND     JZVTD.BILLING_TRADING_PARTNER_ID  =   hzca.cust_account_id
    AND     hzca.cust_account_id  = hzcas.cust_account_id
    AND     hzcsu.cust_acct_site_id  = hzcas.cust_acct_site_id
    AND     upper(hzcsu.site_use_code) = ''LEGAL''
    AND     hzcsu.primary_flag = ''Y''
    AND     hzcsu.status = ''A''
    AND     hzcsu.ORG_ID = $P_ORG_ID$
    AND     jzvtd.trx_id = zxdf.trx_id
    AND     jzvtd.trx_line_id = zxdf.trx_line_id
    AND     jzvtd.trx_id = trx.customer_trx_id
    GROUP BY decode(substrb(jzvtd.billing_tp_tax_reg_num,1,2),''ES'',
                  jzvtd.billing_tp_taxpayer_id),
            substrb(jzvtd.billing_tp_name,1,40),
            je_es_modelo_ext_pkg.getKeyID(substrb(jzvtd.billing_tp_tax_reg_num,1,2)),
            decode(substrb(jzvtd.billing_tp_tax_reg_num,1,2),''ES'',null,
                   substrb(jzvtd.billing_tp_taxpayer_id,1,17)),
            decode(substr(zxdf.document_sub_type,1,6), ''MOD340'', substr(zxdf.document_sub_type,8,1),
            decode(substr(zxdf.trx_business_category,(instr(zxdf.trx_business_category,''MOD'',1,1)+3),3)
                ,''347'',''E'',''415'',''F'',''349'',''E''))  ,
            decode( instr(zxdf.user_defined_fisc_class,''NONE'',7,1),7,'' '', substr(zxdf.user_defined_fisc_class,7,1) ),
            jzvtd.trx_date,
            to_date(trx.global_attribute13,''YYYY/MM/DD HH24:MI:SS''),
            jzvtd.trx_number,
            jzvtd.doc_seq_value,
            decode(substr(zxdf.document_sub_type,1,8),''MOD340/U'',
                   substr(zxdf.document_sub_type,9,1)),
            decode(substr(zxdf.document_sub_type,1,8), ''MOD340/U'',''R''
              ,decode(substr(zxdf.trx_business_category,
                (instr(zxdf.trx_business_category,''MOD'',1,1)+3),3),''349'',''R'')),
            trx.global_attribute10,
            decode(substr(zxdf.document_sub_type,1,8)
                   ,''MOD340/U'',substrb(jzvtd.TRX_LINE_DESCRIPTION,1,35)
                   ,decode(substr(jzvtd.invoice_report_type,1,3),
                          ''349'',substrb(jzvtd.TRX_LINE_DESCRIPTION,1,35))),
            jzvtd.trx_line_number,
            jzvtd.trx_line_id,
            jzvtd.trx_id,
            jzvtd.reporting_status_id,
            DECODE(NVL(jzvtd.taxable_amt_funcl_curr , 0)
                           , 0 , jzvtd.taxable_amt
                               , jzvtd.taxable_amt_funcl_curr),
            hzcsu.cust_acct_site_id ';

  -- TAX LINE AMOUNTS QUERY
  lc_jgzz_mod_query_340_tax :=
  'SELECT  sum(nvl(DECODE(tax_amt_funcl_curr,
                          0, tax_amt ,
                          NULL, tax_amt,
                          tax_amt_funcl_curr), 0))    TAX_AMOUNT,
           tax_rate
   FROM    jg_zz_vat_trx_details
   WHERE   trx_line_id = :p_trx_line_id
   AND     trx_id = :p_trx_id
   AND     extract_source_ledger = ''AR''
   AND     reporting_status_id = :p_reporting_status_id
   AND     SUBSTR(NVL(tax_rate_vat_trx_type_code,''QQQQQQ''),1,3) <> ''RET''
   GROUP BY tax_rate
   ORDER BY tax_rate desc ';

          G_LINENO := '2.5.6';

        -- Date processing for query
        declare
          lv_filter_key varchar2 (150) ;
          lv_filter_value varchar2 (2000);
          lv_filter_oper varchar2(2);

        begin

          -- For Period report restricts by start / end dates AND by PERIOD
          if p_report_name = 'JEESPMOR' then

            lv_filter_key := ' JZVTD.trx_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date
		       AND JZVRS.TAX_CALENDAR_PERIOD'; --5444803
          if p_driving_date = 'GL' then

            lv_filter_key :=
            REPLACE( lv_filter_key
                    ,'trx_date'
                    ,'gl_date'
                    );
            end if;
            lv_filter_value := l_period_string;
            lv_filter_oper := 'In';

            lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_KEY$'
                      , ' ' );

            lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_KEY_FROM$'
                      , ' ' );

            lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_OPER$'
                      , ' ' );

            lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_KEY_TO$'
                      , ' ' );

          -- For Annual report restricts by start / end dates AND by TAX CALENDAR YEAR
          elsif p_report_name = 'JEESAMOR' then

            -- Original modelo processing
            lv_filter_key := 'JZVTD.trx_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date
		       AND JZVRS.TAX_CALENDAR_YEAR';  --Bug 5525421
            if p_driving_date = 'GL' then

            lv_filter_key :=
            REPLACE( lv_filter_key
                    ,'trx_date'
                    ,'gl_date'
                    );
            end if;
            lv_filter_value := p_tax_year;
            lv_filter_oper := '=';

            -- Set start and end dates, specific to 340
            set_dates;

           if p_driving_date = 'GL' then
             lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_KEY$'
                      , 'AND JZVTD.gl_date BETWEEN  ' );

            else --if p_driving_date ='TRX'
              lc_jgzz_mod_query_340 :=
	                   REPLACE( lc_jgzz_mod_query_340
	                          , '$340_PERIOD_KEY$'
                      , 'AND JZVTD.trx_date BETWEEN  ' );
             end if;

            lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_KEY_FROM$'
                      ,'''' || p_340_start_date ||'''');
                      -- , p_340_start_date );

            lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_OPER$'
                      , 'AND' );

            lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$340_PERIOD_KEY_TO$'
                      ,'''' || p_340_end_date ||'''');

          end if;

        lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$FILTER_KEY$'
                      , lv_filter_key
                      );

        lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$FILTER_OPER$'
                      , lv_filter_oper
                      );

         lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$FILTER_VALUE$'
                      , lv_filter_value
                      );

        end;

         lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$P_VAT_REP_ENTITY_ID$'
                      , TO_CHAR(P_VAT_REP_ENTITY_ID)
                      );

         lc_jgzz_mod_query_340 :=
               REPLACE( lc_jgzz_mod_query_340
                      , '$P_ORG_ID$'
                      , P_ORG_ID );

          G_LINENO := '2.5.6.1';
IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'2.5.6.1 Open the AR Dynamic Query for 340: '||lc_jgzz_mod_query_340 ); END IF;
       OPEN c_modelo_340 FOR lc_jgzz_mod_query_340 ;  -- opencur
       LOOP

          IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'2.5.5. Fetch from 340 AR Query'); END IF;

          G_LINENO := '2.5.6.2';

          FETCH  c_modelo_340
          INTO   lc_tax_registration_number
                ,lc_customer_name
                ,lc_key_id
		,lc_foreign_taxpayer_id
		,lc_book_type
		,lc_transaction_code
		,ld_invoice_date
		,ld_trx_date
		,lc_trx_num
		,lc_doc_seq
		,lc_intra_type
		,lc_key_declared
	        ,lc_trx_deadline
		,lc_desc_of_goods
                ,ln_trx_line_number
                ,ln_trx_line_id
                ,ln_trx_id
                ,ln_reporting_status_id
		,ln_taxable_amt
                ,lc_customer_address_id
                ;

           EXIT WHEN c_modelo_340%NOTFOUND;

           G_LINENO := '2.5.6.3';

                get_customer_address2
                    ( p_customer_address_id  =>  lc_customer_address_id
                    , x_postal               =>  lc_postal_code
		    , x_post_code            =>  lc_postal_code1
                    , x_city                 =>  lc_city
                    , x_street_type          =>  lc_street_type -- sigla
                    , x_street               =>  lc_street      --via_publica
                    , x_number               =>  lc_number
                    , x_country              =>  lc_country     -- new for 340
                    );

               lc_tax_registration_number := SUBSTR( lc_tax_registration_number,1,9);
               lc_address_detail          := SUBSTR(lc_street_type || lc_number || lc_street,1,40);

                G_LINENO := '2.5.6.4';

               IF G_DEBUG THEN
                 fnd_file.put_line(FND_FILE.LOG,'lc_trx_num='||lc_trx_num);
                 fnd_file.put_line(FND_FILE.LOG,'lc_address_detail='||lc_address_detail);
                 fnd_file.put_line(FND_FILE.LOG,'lc_street_type='||lc_street_type);
                 fnd_file.put_line(FND_FILE.LOG,'lc_postal_code='||lc_postal_code);
                 fnd_file.put_line(FND_FILE.LOG,'lc_city='||lc_city);
                 fnd_file.put_line(FND_FILE.LOG,'lc_country='||lc_country);
               END IF;

                G_LINENO := '2.5.6.5';

                -- AR Tax calculation. This processes any sucharge amounts.

                -- Reset variables impacted by tax calculations
                ln_line_count := 0;
                ln_tax_amt := 0;
                ln_tax_rate := 0;
                -- Set the inv total to taxable, then add tax during tax processing
                ln_inv_total_amt  := ln_taxable_amt;
                ln_surcharge_amount := 0;
                ln_surcharge_rate := 0;

                OPEN c_modelo_340_artax FOR lc_jgzz_mod_query_340_tax USING
                  ln_trx_line_id,
                  ln_trx_id,
                  ln_reporting_status_id;

                 LOOP
                   FETCH c_modelo_340_artax INTO ln_ar_tax_amt, ln_ar_tax_rate;
                   EXIT WHEN c_modelo_340_artax%NOTFOUND;

                   ln_line_count := ln_line_count + 1;

                   IF ln_line_count = 1 THEN -- First row / greater amount is tax
                     ln_tax_amt := ln_ar_tax_amt;
                     ln_inv_total_amt := ln_inv_total_amt + ln_ar_tax_amt;
                     ln_tax_rate   := ln_ar_tax_rate;
                  ELSE -- Second tax is surcharge
                     ln_surcharge_amount := ln_ar_tax_amt;
                     ln_surcharge_rate := ln_ar_tax_rate;
                     ln_inv_total_amt := ln_inv_total_amt + ln_ar_tax_amt;
                  END IF;

                END LOOP;

               G_LINENO := '2.5.6.6';

               IF G_DEBUG THEN
                fnd_file.put_line(FND_FILE.LOG, 'Processed transaction: '||lc_trx_num);
                fnd_file.put_line(FND_FILE.LOG, 'Tax Amount: '||ln_tax_amt);
                fnd_file.put_line(FND_FILE.LOG, 'Tax rate: '||ln_tax_rate);
                fnd_file.put_line(FND_FILE.LOG, 'Surcharge Amount: '||ln_surcharge_amount);
                fnd_file.put_line(FND_FILE.LOG, 'Surcharge Rate: '||ln_surcharge_rate);
                fnd_file.put_line(FND_FILE.LOG, 'Inv Amount: '||ln_inv_total_amt);
               END IF;

            -- Insert AR record
            INSERT INTO JG_ZZ_VAT_TRX_GT
            ( jg_info_v1
            , jg_info_v20   -- p_tax_year
            , jg_info_v2    -- lc_taxpayer_id
            , jg_info_v3    -- lc_company_name
            , jg_info_v4    -- c_modelo_340.lc_tax_registration_number
            , jg_info_v5    -- c_modelo_340.lc_customer_name
            , jg_info_v6    -- lc_country
            , jg_info_v7    -- c_modelo_340.lc_key_id
            , jg_info_v8    -- c_modelo_340.lc_foreign_taxpayer_id
            , jg_info_v9    -- c_modelo_340.lc_book_type
            , jg_info_v10   -- c_modelo_340.lc_transaction_code
            , jg_info_d1    -- c_modelo_340.ld_invoice_date
            , jg_info_d2    -- c_modelo_340.ld_trx_date
            , jg_info_n1    -- c_modelo_340.ln_tax_rate
            , jg_info_n2    -- c_modelo_340.ln_taxable_amt
            , jg_info_n3    -- c_modelo_340.ln_tax_amt
            , jg_info_n4    -- ln_inv_total_amt
            , jg_info_v11   -- c_modelo_340.lc_trx_num
            , jg_info_v12   -- c_modelo_340.lc_doc_seq
            , jg_info_n8    -- ln_surcharge_rate
            , jg_info_n9    -- ln_surcharge_amount
            , jg_info_v13   -- c_modelo_340.c_intra_type
            , jg_info_v14   -- c_modelo_340.lc_key_declared
            , jg_info_v15   -- lc_country
            , jg_info_v16   -- lc_trx_deadline
            , jg_info_v17   -- c_modelo_340.lc_desc_of_goods
            , jg_info_v21   -- lc_address_detail
            , jg_info_v22   -- lc_city
            , jg_info_v23   -- lc_postal_code
            )
          VALUES
            ( '340'
            , p_tax_year
            , lc_taxpayer_id
            , lc_company_name
            , lc_tax_registration_number
            , lc_customer_name
            , lc_country
            , lc_key_id
            , lc_foreign_taxpayer_id
            , lc_book_type
            , lc_transaction_code
            , ld_invoice_date
            , ld_trx_date
            , ln_tax_rate
            , ln_taxable_amt
            , ln_tax_amt
            , ln_inv_total_amt
            , lc_trx_num
            , lc_doc_seq
            , ln_surcharge_rate
            , ln_surcharge_amount
            , lc_intra_type
            , lc_key_declared
            , lc_country
            , lc_trx_deadline
            , lc_desc_of_goods
            , lc_address_detail
            , lc_city
            , lc_postal_code
            );

        END LOOP;

        G_LINENO := '2.5.6.7';

        IF c_modelo_340%ISOPEN THEN
          CLOSE c_modelo_340;
        END IF;

        IF c_modelo_340_artax%ISOPEN THEN
          CLOSE c_modelo_340_artax;
        END IF;

   -- Calculate overall amounts
   SELECT  sum(jg_info_n2) TAXABLE_AMT,
           sum(jg_info_n3) TAX_AMT,
           sum(jg_info_n4) INV_TOTAL_AMT
   INTO    ln_taxable_amt,
           ln_tax_amt,
           ln_inv_total_amt
   FROM    JG_ZZ_VAT_TRX_GT
   WHERE   nvl(jg_info_v30,'X') <> 'H';

   UPDATE  JG_ZZ_VAT_TRX_GT
   SET     jg_info_n2 = ln_taxable_amt,
           jg_info_n3 = ln_tax_amt,
           jg_info_n4 = ln_inv_total_amt
   WHERE   jg_info_v30 = 'H';

END IF;

    IF P_MODELO = '340' THEN

      SELECT SUM(count_group) INTO P_REC_COUNT FROM (
        SELECT 1 count_group
        FROM   JG_ZZ_VAT_TRX_GT
        WHERE  NVL(jg_info_v30,'X') <> 'H'
        GROUP BY jg_info_v11, jg_info_n1, jg_info_n8);

    ELSE

      SELECT COUNT(*)
      INTO   P_REC_COUNT
      FROM   JG_ZZ_VAT_TRX_GT
      WHERE  NVL(jg_info_v30,'X') <> 'H';

      /* Bug 8485057 apply minimum amounts to the selected transactions */
       IF P_MODELO = '347'
      THEN
        IF G_DEBUG THEN
          fnd_file.put_line(FND_FILE.LOG,'Count of detail records in JG_ZZ_VAT_TRX_GT, before applying minimum amount='||P_REC_COUNT);
        END IF;

        -- Apply minimum amount parameter to the selected transactions
        -- Note: Only transactions tipo 'A' and 'B' are subject to this minimum
        MOD347_MIN_AMOUNT ('A');
        MOD347_MIN_AMOUNT ('B');

        -- Recount the number of transactions after applying the minimum amount
        SELECT COUNT(*)
        INTO   P_REC_COUNT
        FROM   JG_ZZ_VAT_TRX_GT
        WHERE  NVL(jg_info_v30,'X') <> 'H'
        AND    NVL(jg_info_n4,0) <> 1;

        -- Apply minimum cash amount received parameter to the selected transactions
        -- Note: Only transactions in AR are subject to this minimum
        -- Typically tipo B and F, not valid for tipo A and G
        MOD347_MIN_CASH_AMOUNT('B');
        MOD347_MIN_CASH_AMOUNT('F');

      END IF; -- 347
    END IF; -- 340

    UPDATE JG_ZZ_VAT_TRX_GT SET JG_INFO_N30= P_REC_COUNT WHERE jg_info_v30='H';

    G_LINENO := '2.7';
    IF G_DEBUG THEN fnd_file.put_line(FND_FILE.LOG,'Count of detail records in JG_ZZ_VAT_TRX_GT='||P_REC_COUNT); END IF;
    IF P_REPORT_NAME  = 'JEESAMOR' THEN
       G_LINENO := '2.7.1';

       IF P_MODELO = '347' THEN
          G_LINENO := '2.7.1.1';

         UPDATE JG_ZZ_VAT_TRX_GT
         SET    jg_info_n11 =  ( SELECT count(*)
                                 FROM   JG_ZZ_VAT_TRX_GT
                                 WHERE  jg_info_v1  <> '3'
                                 AND    NVL(jg_info_n4,0) <> 1
                                 AND    nvl(jg_info_v30,'X') <> 'H' )  -- CP_TOTAL_DEC_D
              , jg_info_n12 =  ( SELECT count(*)
                                 FROM   JG_ZZ_VAT_TRX_GT
                                 WHERE  jg_info_v1  =  '3'
                                 AND    NVL(jg_info_n4,0) <> 1
                                 AND    nvl(jg_info_v30,'X') <> 'H' )  -- CP_TOTAL_DEC_I
              , jg_info_n13 =   ( SELECT DECODE(G_CURRENCY_CODE,'EUR',
                                         (SUM(nvl(jg_info_n2,jg_info_n1))*100)
                                         ,SUM(nvl(jg_info_n2,jg_info_n1)))
                                 FROM   JG_ZZ_VAT_TRX_GT
                                 WHERE  jg_info_v1 <> '3'
                                 AND    NVL(jg_info_n4,0) <> 1)    -- CP_TOTAL_AMT_DEC_D
              , jg_info_n14 =  ( SELECT SUM(jg_info_n2)
                                 FROM   JG_ZZ_VAT_TRX_GT
                                 WHERE  jg_info_v1  =  '3'
                                 AND    NVL(jg_info_n4,0) <> 1
                                 AND    NVL(jg_info_v30,'X') <> 'H' )  -- CP_TOTAL_DEC_I
              , jg_info_n15 =  ( SELECT count(*)
                                 FROM   JG_ZZ_VAT_TRX_GT
                                 WHERE  nvl(jg_info_v30,'X') <> 'H'
                                 AND    NVL(jg_info_n4,0) <> 1)  -- CP_NO_OF_TYPE2
         WHERE  jg_info_v30 = 'H';
         G_LINENO := '2.7.1.2';

       ELSIF P_MODELO = '415' THEN      /** author:brathod; Modified for condition from P_MODELO='347' */
        G_LINENO := '2.7.1.3';
         UPDATE JG_ZZ_VAT_TRX_GT
         SET  ( jg_info_n11 -- CS_IMP_VENTAS
              , jg_info_n12 -- CS_NUMERO_VENTAS
              , jg_info_n13 -- CS_IMP_MEDIACION
              , jg_info_n14 -- CS_NUMERO_MEDIACION
              , jg_info_n15 -- CS_IMP_COMPRAS
              , jg_info_n16 -- CS_NUMERO_COMPRAS
 -- FH: Added for all transaction codes
              , jg_info_n17 -- CS_IMP_THIRD
              , jg_info_n18 -- CS_NUMERO_THIRD
              , jg_info_n19 -- CS_IMP_BIS
              , jg_info_n20 -- CS_NUMERO_BIS
              , jg_info_n21 -- CS_IMP_PUB
              , jg_info_n22 -- CS_NUMERO_PUB
              , jg_info_n23 -- CS_IMP_TAP
              , jg_info_n24 -- CS_NUMERO_TAP
              , jg_info_n25 -- CS_IMP_TAS
              , jg_info_n26 -- CS_NUMERO_TAS
              ) =
              ( SELECT SUM( DECODE( jg_info_v1
                                    , 'A', NVL(jg_info_n1, jg_info_n2)
                                    , 0 ) ) CP_IMP_VENTAS
                     , SUM( DECODE( jg_info_v1
                                    , 'A', 1
                                    , 0 ) ) CP_NUMERO_VENTAS
                     , SUM( DECODE( jg_info_v1
                                    , 'M', NVL(jg_info_n1, jg_info_n2)
                                    , 0 ) )   CP_IMP_MEDIACION
                     , SUM( DECODE( jg_info_v1
                                    , 'M', 1
                                    , 0 ) )   CP_NUMERO_MEDIACION
                     , SUM( DECODE( jg_info_v1
                                    , 'B', NVL(jg_info_n1, jg_info_n2)
                                    , 0 ) )   CP_IMP_COMPRAS
                     , SUM( DECODE( jg_info_v1
                                    , 'B', 1
                                    , 0 ) )  CF_NUMERO_COMPRAS
 -- FH: Added for all transaction codes
                     , SUM( DECODE( jg_info_v1
                                    , 'C', NVL(jg_info_n1, jg_info_n2)
                                    , 0 ) ) CP_IMP_THIRD
                     , SUM( DECODE( jg_info_v1
                                    , 'C', 1
                                    , 0 ) ) CP_NUMERO_THIRD
                     , SUM( DECODE( jg_info_v1
                                    , 'D', NVL(jg_info_n1, jg_info_n2)
                                    , 0 ) )   CP_IMP_BIS
                     , SUM( DECODE( jg_info_v1
                                    , 'D', 1
                                    , 0 ) )   CP_NUMERO_BIS
                     , SUM( DECODE( jg_info_v1
                                    , 'E', NVL(jg_info_n1, jg_info_n2)
                                    , 0 ) )   CP_IMP_PUB
                     , SUM( DECODE( jg_info_v1
                                    , 'E', 1
                                    , 0 ) )  CF_NUMERO_PUB
                     , SUM( DECODE( jg_info_v1
                                    , 'F', NVL(jg_info_n1, jg_info_n2)
                                    , 0 ) ) CP_IMP_TAS
                     , SUM( DECODE( jg_info_v1
                                    , 'F', 1
                                    , 0 ) ) CP_NUMERO_TAS
                     , SUM( DECODE( jg_info_v1
                                    , 'G', NVL(jg_info_n1, jg_info_n2)
                                    , 0 ) )   CP_IMP_TAP
                     , SUM( DECODE( jg_info_v1
                                    , 'G', 1
                                    , 0 ) )   CP_NUMERO_TAP

                FROM   JG_ZZ_VAT_TRX_GT
                WHERE  NVL(jg_info_v30,'X') <> 'H'
               )
         WHERE  jg_info_v30 = 'H';
          G_LINENO := '2.7.1.4';
       END IF;
       G_LINENO := '2.7.2';
    END IF;
    G_LINENO := '2.8';
    RETURN (TRUE);
  EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(FND_FILE.LOG,'Error while processing Before Report Trigger. Statement No = ' || G_LINENO||' Err:'|| SQLCODE || SUBSTR(SQLERRM,1,200));
    RETURN (FALSE);
  END BEFORE_REPORT;

  FUNCTION after_Report  RETURN BOOLEAN
  IS
  BEGIN
     NULL;
     RETURN (TRUE);
  END after_Report;

END je_es_modelo_ext_pkg;

/
