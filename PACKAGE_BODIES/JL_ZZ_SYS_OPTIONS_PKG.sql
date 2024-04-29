--------------------------------------------------------
--  DDL for Package Body JL_ZZ_SYS_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_SYS_OPTIONS_PKG" AS
/* $Header: jlzzsopb.pls 120.11 2006/12/21 19:22:57 appradha ship $ */


/* ==========================================================*
 | Fetches the value of Bank Transfer Currency               |
 * ==========================================================*/

        FUNCTION get_bank_transfer_currency
        (
	p_org_id IN NUMBER DEFAULT NULL
	) RETURN    VARCHAR2 IS

        x_btf_currency   varchar2(3);

        BEGIN

          x_btf_currency := 'BRL';

          return(x_btf_currency);

        END get_bank_transfer_currency;

/* ==============================================================*
 | Fetches the value of Copy Taxpayer ID Flag                    |
 * ==============================================================*/

        FUNCTION get_copy_cus_sup_name
        (
	p_org_id IN NUMBER DEFAULT NULL
	) RETURN    VARCHAR2 IS

        x_copy_taxpayer_id_flag   varchar2(30);

        BEGIN

          x_copy_taxpayer_id_flag := FND_PROFILE.VALUE('JLZZ_COPY_CUS_SUP_NUM');

          return(x_copy_taxpayer_id_flag);

         END get_copy_cus_sup_name;

/* ==========================================================*
 | Fetches the value of Payment Action                       |
 * ==========================================================*/

        FUNCTION get_payment_action
        (
	p_org_id IN NUMBER
	) RETURN    VARCHAR2 IS

        x_payment_action   ap_system_parameters_all.global_attribute6%type;

        BEGIN

          BEGIN

            /* 1-Anticipate; 2-Postpone; 3-Change Manually (previously Keep) */
            Select global_attribute6
              Into   x_payment_action
              From   ap_system_parameters_all
              Where  nvl(org_id,-99) = nvl(p_org_id,-99);
          Exception
            when others THEN
              x_payment_action := NULL;

          END;

          return(x_payment_action);

        END get_payment_action;

/* ==========================================================*
 | Fetches the value of Payment Action for AR                |
 * ==========================================================*/

        FUNCTION get_payment_action_AR
        (
	p_org_id IN NUMBER
	) RETURN    VARCHAR2 IS

        x_payment_action   ar_system_parameters_all.global_attribute20%type;

        BEGIN

          BEGIN

            /* 1-Anticipate; 2-Postpone; 3-Change Manually (previously Keep) */
            Select global_attribute3
              Into   x_payment_action
              From   ar_system_parameters_all
              Where  nvl(org_id,-99) = nvl(p_org_id,-99);
          Exception
            when others THEN
              x_payment_action := NULL;

          END;

          return(x_payment_action);

        END get_payment_action_AR;

/* ==========================================================*
 | Fetches the value of Payment Location                     |
 * ==========================================================*/

        FUNCTION get_payment_location
        (
	p_org_id IN NUMBER
	) RETURN    VARCHAR2 IS

        x_payment_location   ap_system_parameters_all.global_attribute7%type;

        BEGIN

          BEGIN

            /* 1-Company; 2-Supplier; 3-Customer */
            Select global_attribute7
              Into   x_payment_location
              From   ap_system_parameters_all
              Where  nvl(org_id,-99) = nvl(p_org_id,-99);
          Exception
            when others THEN
              x_payment_location := NULL;

          END;

          return(x_payment_location);

         END get_payment_location;

/* ===============================================================*
 | Fetches the value of Taxpayer ID Error Flag                    |
 * ===============================================================*/

        FUNCTION get_taxid_raise_error
        (
	p_org_id IN NUMBER DEFAULT NULL
	) RETURN    VARCHAR2 IS

        x_require_taxpayer_id_flag   varchar2(30);

        BEGIN

          x_require_taxpayer_id_flag := FND_PROFILE.VALUE('JLZZ_TAXID_RAISE_ERROR');

          return(x_require_taxpayer_id_flag);

        END get_taxid_raise_error;

/* =======================================================================*
 | Fetches value of 'Use Related Transactions for Threshold Checking' flag|
 * =======================================================================*/

        FUNCTION get_ar_tx_use_whole_operation
        (
	p_org_id IN NUMBER
	) RETURN    VARCHAR2 IS

        x_tx_use_wh_oper ar_system_parameters_all.global_attribute19%type;

        BEGIN

          BEGIN

              Select global_attribute19
              Into   x_tx_use_wh_oper
              From   ar_system_parameters_all
              Where  nvl(org_id,-99) = nvl(p_org_id,-99);
          Exception
            when others THEN
              x_tx_use_wh_oper := NULL;
          END;

          return(x_tx_use_wh_oper);

        END get_ar_tx_use_whole_operation;


/* ==========================================================*
 | Fetches the value of Change Date Automatically            |
 * ==========================================================*/

        FUNCTION get_change_date_automatically
        (
	p_org_id IN NUMBER
	) RETURN    VARCHAR2 IS

        x_change_date_automatically   ap_system_parameters_all.global_attribute8%type;

        BEGIN

          BEGIN

            /* Y-Yes; N-No */
            Select global_attribute8
              Into   x_change_date_automatically
              From   ap_system_parameters_all
              Where  nvl(org_id,-99) = nvl(p_org_id,-99);
          Exception
            when others THEN
              x_change_date_automatically := NULL;

          END;

          return(x_change_date_automatically);

         END get_change_date_automatically;

/* ==============================================================*
 | Fetches the value of Calendar                                 |
 * ==============================================================*/

        FUNCTION get_calendar
        (
	p_org_id IN NUMBER DEFAULT NULL
	) RETURN    VARCHAR2 IS

        x_calendar   varchar2(30);

        BEGIN

          x_calendar := FND_PROFILE.VALUE('JLBR_CALENDAR');

          return(x_calendar);

         END get_calendar;

END JL_ZZ_SYS_OPTIONS_PKG;

/
