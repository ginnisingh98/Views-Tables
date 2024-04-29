--------------------------------------------------------
--  DDL for Package IGI_DUNN_POST_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_DUNN_POST_UPG_PKG" AUTHID CURRENT_USER as
  -- $Header: igidunks.pls 120.9 2008/02/19 09:26:50 mbremkum ship $

   CURSOR c_bkts IS
      SELECT distinct adls.dunning_letter_set_id dls_id,
             adls.name
      FROM   ar_dunning_letter_sets      adls,
             igi_dun_letter_sets         idls
      WHERE  idls.dunning_letter_set_id  = adls.dunning_letter_set_id
      AND    idls.use_dunning_flag       = 'Y'
      AND NOT EXISTS (SELECT 'Y'
                      FROM    ar_aging_buckets aab
                      WHERE   aab.description = adls.name);

   CURSOR c_bkts_lines (p_dls_id VARCHAR2) IS
      SELECT adls.dunning_letter_set_id,
             adlsl.dunning_line_num,
             adlsl.range_of_days_from,
             adlsl.range_of_days_to
      FROM   ar_dunning_letter_set_lines        adlsl,
             igi_dun_letter_sets                idls,
             ar_dunning_letter_sets             adls
      WHERE  adls.dunning_letter_set_id = p_dls_id
      AND    adls.dunning_letter_set_id = idls.dunning_letter_set_id
      AND    adlsl.dunning_letter_set_id = adls.dunning_letter_set_id;

   CURSOR c_aging_bkts_site IS
      SELECT distinct adls.dunning_letter_set_id dls_id,
             adls.name,
             idclsl.currency_code ccy_code,
	     idls.charge_per_invoice_flag charge_type
      FROM   igi_dun_cust_letter_set_lines    idclsl,
             ar_dunning_letter_sets      adls,
             igi_dun_letter_sets         idls
      WHERE  decode(idls.charge_per_invoice_flag, 'Y', idclsl.invoice_charge_amount, 'N', idclsl.letter_charge_amount) IS NOT NULL
      AND    idclsl.dunning_letter_set_id = adls.dunning_letter_set_id
      AND    idls.dunning_letter_set_id  = adls.dunning_letter_set_id
      AND    idls.use_dunning_flag       = 'Y'
      AND NOT EXISTS (SELECT 'Y'
                      FROM    ar_charge_schedules acs
                      WHERE   acs.schedule_name = adls.name || '_' || idclsl.currency_code || '_' || idclsl.customer_profile_id);

   CURSOR c_aging_bkts IS
      SELECT distinct adls.dunning_letter_set_id dls_id,
             adls.name,
             idlsl.currency_code ccy_code,
	     idls.charge_per_invoice_flag
      FROM   igi_dun_letter_set_lines    idlsl,
             ar_dunning_letter_sets      adls,
             igi_dun_letter_sets         idls
      WHERE  decode(idls.charge_per_invoice_flag, 'Y', idlsl.invoice_charge_amount, 'N', idlsl.letter_charge_amount) IS NOT NULL
      AND    idlsl.dunning_letter_set_id = adls.dunning_letter_set_id
      AND    idls.dunning_letter_set_id  = adls.dunning_letter_set_id
      AND    idls.use_dunning_flag       = 'Y'
      AND NOT EXISTS (SELECT 'Y'
                      FROM    ar_charge_schedules acs
                      WHERE   acs.schedule_name = adls.name || '_' || idlsl.currency_code);


   CURSOR c_aging_bkt_lines (p_dls_id VARCHAR2, p_ccy_code VARCHAR2) IS
      SELECT adls.dunning_letter_set_id,
             adls.name,
             idlsl.currency_code,
             adlsl.dunning_letter_id,
             adlsl.dunning_line_num,
             adlsl.range_of_days_from,
             adlsl.range_of_days_to,
             idlsl.currency_code ccy_code,
             idlsl.letter_charge_amount,
             idlsl.invoice_charge_amount,
	     (SELECT charge_per_invoice_flag FROM igi_dun_letter_sets WHERE dunning_letter_set_id = p_dls_id) charge_type
      FROM   ar_dunning_letter_set_lines        adlsl,
             igi_dun_letter_set_lines           idlsl,
             ar_dunning_letter_sets             adls
      WHERE  adlsl.dunning_letter_set_id = idlsl.dunning_letter_set_id
      AND    adlsl.dunning_line_num      = idlsl.dunning_line_num
      AND    adlsl.dunning_letter_id     = idlsl.dunning_letter_id
      AND    adlsl.dunning_letter_set_id = adls.dunning_letter_set_id
      AND    (idlsl.letter_charge_amount IS NOT NULL OR
              idlsl.invoice_charge_amount IS NOT NULL)
      AND    adls.dunning_letter_set_id  = p_dls_id
      AND    idlsl.currency_code         = p_ccy_code;

   /*Added for creating Charge Schedules where charge amounts were changed at customer level - mbremkum*/

   CURSOR c_override_dunning_letter (p_dls_id VARCHAR2, p_ccy_code VARCHAR2, p_charge_type VARCHAR2) IS
   SELECT idlsl.dunning_letter_set_id dls_id, idlsl.currency_code ccy_code, idclsl.customer_profile_id
	FROM igi_dun_letter_set_lines idlsl, igi_dun_cust_letter_set_lines idclsl, igi_dun_letter_sets idls
	WHERE decode(p_charge_type, 'N', (nvl(idclsl.letter_charge_amount, -99) - nvl(idlsl.letter_charge_amount,-99)),
	 'Y', (nvl(idclsl.invoice_charge_amount,-99) - nvl(idlsl.invoice_charge_amount,-99))) <> 0
	 AND idls.dunning_letter_set_id = idlsl.dunning_letter_set_id
	 AND idls.use_dunning_flag = 'Y'
	 AND idls.charge_per_invoice_flag = p_charge_type
	 AND idlsl.dunning_letter_set_id = idclsl.dunning_letter_set_id
	 AND idlsl.currency_code = idclsl.currency_code
	 AND idlsl.dunning_letter_set_id = p_dls_id
	 AND idlsl.currency_code = p_ccy_code
	 AND idclsl.dunning_line_num = idlsl.dunning_line_num;

   CURSOR c_override_dunning_letter_uu (p_dls_id VARCHAR2, p_ccy_code VARCHAR2, p_charge_type VARCHAR2) IS
   SELECT idlsl.dunning_letter_set_id dls_id, idlsl.currency_code ccy_code, idclsl.customer_profile_id
	FROM igi_dun_letter_set_lines idlsl, igi_dun_cust_letter_set_lines idclsl, igi_dun_letter_sets idls
	WHERE decode(p_charge_type, 'Y', (nvl(idclsl.letter_charge_amount, -99) - nvl(idlsl.letter_charge_amount,-99)),
	 'N', (nvl(idclsl.invoice_charge_amount,-99) - nvl(idlsl.invoice_charge_amount,-99))) <> 0
	 AND idls.dunning_letter_set_id = idlsl.dunning_letter_set_id
	 AND idlsl.dunning_letter_set_id = idclsl.dunning_letter_set_id
	 AND idlsl.currency_code = idclsl.currency_code
	 AND idls.use_dunning_flag = 'Y'
	 AND idls.charge_per_invoice_flag = p_charge_type
	 AND idlsl.dunning_letter_set_id = p_dls_id
	 AND idlsl.currency_code = p_ccy_code
	 AND idclsl.dunning_line_num = idlsl.dunning_line_num;

   CURSOR c_aging_bkt_lines_site (p_dls_id VARCHAR2, p_ccy_code VARCHAR2, p_customer_profile_id NUMBER) IS
	SELECT adls.dunning_letter_set_id,
	     adls.name,
	     adlsl.dunning_letter_id,
	     adlsl.dunning_line_num,
	     adlsl.range_of_days_from,
	     adlsl.range_of_days_to,
	     idclsl.currency_code ccy_code,
	     idclsl.letter_charge_amount,
	     idclsl.invoice_charge_amount,
	     idclsl.customer_profile_id,
	     idclsl.customer_profile_class_id,
	     idclsl.site_use_id,
	     (SELECT charge_per_invoice_flag FROM igi_dun_letter_sets WHERE dunning_letter_set_id = p_dls_id) charge_type
	FROM   ar_dunning_letter_set_lines        adlsl,
	     igi_dun_cust_letter_set_lines      idclsl,
	     ar_dunning_letter_sets             adls
	WHERE  adlsl.dunning_letter_set_id = adls.dunning_letter_set_id
	AND    adlsl.dunning_letter_set_id = idclsl.dunning_letter_set_id
	AND    adlsl.dunning_line_num      = idclsl.dunning_line_num
	AND    adlsl.dunning_letter_id     = idclsl.dunning_letter_id
	AND    idclsl.currency_code        = p_ccy_code
	AND    adls.dunning_letter_set_id = p_dls_id
	AND    idclsl.customer_profile_id = p_customer_profile_id
	ORDER BY adls.dunning_letter_set_id;

   CURSOR c_aging_bkts_uu IS
        SELECT distinct adls.dunning_letter_set_id dls_id,
             adls.name,
             idlsl.currency_code ccy_code,
             charge_per_invoice_flag charge_type
	FROM igi_dun_letter_set_lines           idlsl,
             ar_dunning_letter_sets             adls,
	     igi_dun_letter_sets		idls
	WHERE decode(charge_per_invoice_flag, 'Y', letter_charge_amount, 'N', invoice_charge_amount) IS NOT NULL
	AND    idlsl.dunning_letter_set_id = adls.dunning_letter_set_id
        AND    idls.dunning_letter_set_id  = adls.dunning_letter_set_id
        AND    idls.use_dunning_flag       = 'Y'
	AND NOT EXISTS (SELECT 'Y'
                      FROM    ar_charge_schedules acs
                      WHERE   acs.schedule_name = adls.name || '_' || idlsl.currency_code || '_' || decode(idls.charge_per_invoice_flag, 'Y', 'PER_LETTER', 'N', 'PER_INVOICE'));


   CURSOR c_aging_bkts_uu_site IS
        SELECT distinct adls.dunning_letter_set_id dls_id,
             adls.name,
             idlsl.currency_code ccy_code,
             charge_per_invoice_flag charge_type
	FROM igi_dun_cust_letter_set_lines           idlsl,
             ar_dunning_letter_sets             adls,
	     igi_dun_letter_sets		idls
	WHERE decode(charge_per_invoice_flag, 'Y', letter_charge_amount, 'N', invoice_charge_amount) IS NOT NULL
	AND    idlsl.dunning_letter_set_id = adls.dunning_letter_set_id
        AND    idls.dunning_letter_set_id  = adls.dunning_letter_set_id
        AND    idls.use_dunning_flag       = 'Y'
	AND NOT EXISTS (SELECT 'Y'
                      FROM    ar_charge_schedules acs
                      WHERE   acs.schedule_name = adls.name || '_' || idlsl.currency_code || '_'|| idlsl.customer_profile_id  || '_' || decode(idls.charge_per_invoice_flag, 'Y', 'PER_LETTER', 'N', 'PER_INVOICE'));


	l_aging_bucket_line_id ar_aging_bucket_lines_b.aging_bucket_line_id%TYPE;
	l_schedule_header_id   ar_charge_schedule_hdrs.schedule_id%TYPE;
	l_aging_bucket_id      ar_aging_buckets.aging_bucket_id%TYPE;
	l_schedule_id          ar_charge_schedules.schedule_id%TYPE;



PROCEDURE DUNNING_UPG(ERRBUF OUT NOCOPY VARCHAR2,
		      RETCODE OUT NOCOPY  VARCHAR2);

  END IGI_DUNN_POST_UPG_PKG;

/
