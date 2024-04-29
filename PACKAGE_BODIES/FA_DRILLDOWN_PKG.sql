--------------------------------------------------------
--  DDL for Package Body FA_DRILLDOWN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DRILLDOWN_PKG" as
/* $Header: faddwnb.pls 120.2.12010000.3 2010/03/05 22:56:13 saalampa ship $   */

PROCEDURE DRILLDOWN
   (p_application_id       IN    INTEGER   DEFAULT NULL,
    p_ledger_id            IN    INTEGER   DEFAULT NULL,
    p_legal_entity_id      IN    INTEGER   DEFAULT NULL,
    p_entity_code          IN    VARCHAR2  DEFAULT NULL,
    p_event_class_code     IN    VARCHAR2  DEFAULT NULL,
    p_event_type_code      IN    VARCHAR2  DEFAULT NULL,
    p_source_id_int_1      IN    INTEGER   DEFAULT NULL,
    p_source_id_int_2      IN    INTEGER   DEFAULT NULL,
    p_source_id_int_3      IN    INTEGER   DEFAULT NULL,
    p_source_id_int_4      IN    INTEGER   DEFAULT NULL,
    p_source_id_char_1     IN    VARCHAR2  DEFAULT NULL,
    p_source_id_char_2     IN    VARCHAR2  DEFAULT NULL,
    p_source_id_char_3     IN    VARCHAR2  DEFAULT NULL,
    p_source_id_char_4     IN    VARCHAR2  DEFAULT NULL,
    p_security_id_int_1    IN    INTEGER   DEFAULT NULL,
    p_security_id_int_2    IN    INTEGER   DEFAULT NULL,
    p_security_id_int_3    IN    INTEGER   DEFAULT NULL,
    p_security_id_char_1   IN    VARCHAR2  DEFAULT NULL,
    p_security_id_char_2   IN    VARCHAR2  DEFAULT NULL,
    p_security_id_char_3   IN    VARCHAR2  DEFAULT NULL,
    p_valuation_method     IN    VARCHAR2  DEFAULT NULL,
    p_user_interface_type  OUT   NOCOPY VARCHAR2,
    p_function_name        OUT   NOCOPY VARCHAR2,
    p_parameters           OUT   NOCOPY VARCHAR2) IS

  book_type_code varchar2(15);

BEGIN

  -- type = FORM / HTML
  -- for OA Framwork, params:   '/OA_HTML/OA.jsp?OAFunc=function_name<amp>param1=value1<amp>parma2=value2';

  if (p_application_id = 140) then

    if (p_entity_code = 'TRANSACTIONS') then

        p_user_interface_type := 'FORM';
        p_function_name       := 'XLA_FAXOLTRX';
        p_parameters          := 'FORM_USAGE_MODE="' || 'GL_DRILLDOWN'
        || '"' ||
              ' TRANSACTION_ID="' || to_char(p_source_id_int_1) || '"';

          -- do we need form_usage_mode and parent_form_id here?

    elsif (p_entity_code = 'INTER_ASSET_TRANSACTIONS') then

        p_user_interface_type := 'FORM';
        p_function_name       := 'XLA_FAXOLTRX';
        p_parameters          := 'FORM_USAGE_MODE="' || 'GL_DRILLDOWN'             || '"' ||
                                 ' TRX_REFERENCE_ID="' || to_char(p_source_id_int_1) || '"';

    elsif (p_entity_code = 'DEPRECIATION') then
        book_type_code := replace(p_source_id_char_1,' ','~');
        p_user_interface_type := 'FORM';
        p_function_name       := 'XLA_FAXOLFIN';
        p_parameters          := 'FORM_USAGE_MODE="' || 'GL_DRILLDOWN'             || '"' ||
                                 ' ASSET_ID ="' || (p_source_id_int_1) || '"' ||
                                 ' PERIOD_COUNTER ="' || to_char(p_source_id_int_2) || '"' ||
				 ' DEPRN_RUN_ID ="' || p_source_id_int_3 || '"' ||
				 ' BOOK_TYPE_CODE ="' ||book_type_code ||'"';
    else
        p_user_interface_type := 'NONE';
    end if;

  end if;

END DRILLDOWN;

END FA_DRILLDOWN_PKG;

/
