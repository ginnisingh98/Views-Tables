--------------------------------------------------------
--  DDL for Package Body IGI_EXP_DOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_DOC_PKG" as
-- $Header: igiexpgb.pls 115.10 2003/08/09 11:38:54 rgopalan ship $
PROCEDURE Insert_Row (x_trx_type_id             NUMBER,
                        x_doc_type_id           NUMBER,
                        x_third_party_id        NUMBER,
                        x_site_id               NUMBER,
                        x_amount                NUMBER,
                        x_trans_unit_id         NUMBER,
                        x_session_id            NUMBER,
                        x_item_per_diag         NUMBER,
                        x_invoice_id            NUMBER,
                        x_type                  VARCHAR2,
                        x_tstatus               VARCHAR2,
                        x_dial_call_num         NUMBER,
			x_currency_code		VARCHAR2)
IS
BEGIN
 NULL;
End Insert_Row;

PROCEDURE Insert_Tran_Unit(     x_trans_unit_id         NUMBER,
                                x_doc_type_id           NUMBER,
                                x_amount                NUMBER,
				x_tran_unit_call_num 	NUMBER)
IS
BEGIN
 NULL;
END Insert_Tran_Unit;

PROCEDURE Delete_from_Temp(x_session NUMBER)
IS
BEGIN
 NULL;
END Delete_from_Temp;

FUNCTION  get_tu_number(p_tuid NUMBER,
                        p_privilage VARCHAR2)
          RETURN VARCHAR2
IS
BEGIN
 NULL;
END get_tu_number;

END IGI_EXP_DOC_PKG;

/
