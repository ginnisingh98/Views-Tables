--------------------------------------------------------
--  DDL for Package Body ITG_MSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_MSG" AS
/* ARCS: $Header: itgmsgb.pls 120.9 2006/09/15 13:36:01 pvaddana noship $
 * CVS:  itgmsgb.pls,v 1.21 2002/12/27 18:35:04 ecoe Exp
 */

   l_buff VARCHAR2(4000);

  FUNCTION chknul(p_text VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN nvl(p_text,   'NULL');
  END chknul;

  PROCEDURE text(p_text VARCHAR2) IS
  BEGIN
    fnd_message.set_name('FND',   'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE',   chknul(p_text));
  END text;

  PROCEDURE debug(p_pkg_name VARCHAR2,   p_proc_name VARCHAR2,   p_text VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_DEBUG');
    fnd_message.set_token('PKG_NAME',   chknul(p_pkg_name));
    fnd_message.set_token('PROCEDURE_NAME',   chknul(p_proc_name));
    fnd_message.set_token('ERROR_TEXT',   chknul(p_text));
    fnd_msg_pub.ADD;
  END;

  PROCEDURE debug_more(p_text VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_DEBUG_MORE');
    fnd_message.set_token('ERROR_TEXT',   chknul(p_text));
    fnd_msg_pub.ADD;
  END;

  PROCEDURE missing_element_value(p_name VARCHAR2,   p_value VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_MISSING_ELEMENT_VALUE');
    fnd_message.set_token('ELEMENT_NAME',   chknul(p_name));
    fnd_message.set_token('ELEMENT_VALUE',   chknul(p_value));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_MISSING_ELEMENT_VALUE',   p_msg_app => 'ITG',   p_token_vals => 'ELEMENT_NAME::' || chknul(p_name) || '^^ELEMENT_VALUE::' || chknul(p_value),   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE data_value_error(p_value VARCHAR2,   p_min NUMBER,   p_max NUMBER) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_DATA_VALUE_ERROR');
    fnd_message.set_token('DATA_VALUE',   chknul(p_value));
    fnd_message.set_token('MIN_LENGTH',   chknul(to_char(p_min)));
    fnd_message.set_token('MAX_LENGTH',   chknul(to_char(p_max)));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_DATA_VALUE_ERROR',   p_msg_app => 'ITG',   p_token_vals => 'DATA_VALUE::' || chknul(p_value) || '^^MIN_LENGTH::' || chknul(p_min) || '^^MAX_LENGTH::' || chknul(p_max),
    p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE update_failed IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_UPDATE_FAILED');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_UPDATE_FAILED',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE existing_flex_value(p_flex_value VARCHAR2,   p_vset_id NUMBER) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_EXISTING_FLEX_VALUE');
    fnd_message.set_token('FLEX_VALUE',   chknul(p_flex_value));
    fnd_message.set_token('VALUE_SET_ID',   chknul(to_char(p_vset_id)));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_EXISTING_FLEX_VALUE',   p_msg_app => 'ITG',   p_token_vals => 'FLEX_VALUE::' || chknul(p_flex_value) || '^^VALUE_SET_ID::' || chknul(p_vset_id),   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE invalid_account_type(p_acct_type VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_INVALID_ACCOUNT_TYPE');
    fnd_message.set_token('ACCOUNT_TYPE',   chknul(p_acct_type));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_INVALID_ACCOUNT_TYPE',   p_msg_app => 'ITG',   p_token_vals => 'ACCOUNT_TYPE::' || chknul(p_acct_type),   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE flex_insert_fail(p_flex_value VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_FLEX_INSERT_FAIL');
    fnd_message.set_token('FLEX_VALUE',   chknul(p_flex_value));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_FLEX_INSERT_FAIL',   p_msg_app => 'ITG',   p_token_vals => 'FLEX_VALUE::' || chknul(p_flex_value),   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE flex_update_fail_novalue(p_flex_value VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_FLEX_UPDATE_FAIL_NOVALUE');
    fnd_message.set_token('FLEX_VALUE',   chknul(p_flex_value));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_FLEX_UPDATE_FAIL_NOVALUE',   p_msg_app => 'ITG',   p_token_vals => 'FLEX_VALUE::' || chknul(p_flex_value),   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE flex_update_fail_notl(p_flex_value VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_FLEX_UPDATE_FAIL_NOTL');
    fnd_message.set_token('FLEX_VALUE',   chknul(p_flex_value));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_FLEX_UPDATE_FAIL_NOTL',   p_msg_app => 'ITG',   p_token_vals => 'FLEX_VALUE::' || chknul(p_flex_value),   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE invalid_currency_code IS
  BEGIN
    fnd_message.set_name('SQLGL',   'GL INVALID CURRENCY CODE');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'GL INVALID CURRENCY CODE',   p_msg_app => 'SQLGL',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE same_currency_code IS
  BEGIN
    fnd_message.set_name('SQLGL',   'GL_GLXRTDLY_SAMECURR');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'GL_GLXRTDLY_SAMECURR',   p_msg_app => 'SQLGL',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE duplicate_exchange_rate IS
  BEGIN
    fnd_message.set_name('SQLGL',   'GL_DUPLICATE_EXCHANGE_RATE');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'GL_DUPLICATE_EXCHANGE_RATE',   p_msg_app => 'SQLGL',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE no_po_found(p_po_code VARCHAR2,   p_org_id NUMBER) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_PO_FOUND');
    fnd_message.set_token('PO_CODE',   chknul(p_po_code));
    fnd_message.set_token('ORG_ID',   chknul(to_char(p_org_id)));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_PO_FOUND',   p_msg_app => 'ITG',   p_token_vals => 'PO_CODE::' || chknul(p_po_code) || '^^ORG_ID::' || chknul(p_org_id),   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE no_line_locs_found IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_LINE_LOCS_FOUND');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_LINE_LOCS_FOUND',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE allocship_toomany_rtn IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_ALLOCSHIP_TOOMANY_RTN');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_ALLOCSHIP_TOOMANY_RTN',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE allocdist_toomany_rtn IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_ALLOCDIST_TOOMANY_RTN');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_ALLOCDIST_TOOMANY_RTN',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE allocreqn_toomany_rtn IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_ALLOCREQN_TOOMANY_RTN');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_ALLOCREQN_TOOMANY_RTN',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE poline_closed_rcv IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_POLINE_CLOSED_RCV');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_POLINE_CLOSED_RCV',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE poline_zeroqty_rcv IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_POLINE_ZEROQTY_RCV');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_POLINE_ZEROQTY_RCV',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;
  /* Added to fix bug  5438268 to error out the neg qty RECEIPT */
  PROCEDURE poline_negqty_rcv IS
  BEGIN
  fnd_message.set_name('ITG',   'ITG_POLINE_NEGQTY_RCV');
    fnd_msg_pub.ADD;
    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_POLINE_NEGQTY_RCV',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE receipt_tol_exceeded IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_RECEIPT_TOL_EXCEEDED');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_RECEIPT_TOL_EXCEEDED',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE receipt_closepo_fail(p_return_code VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_RECEIPT_CLOSEPO_FAIL');
    fnd_message.set_token('RETURN_CODE',   chknul(p_return_code));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_RECEIPT_CLOSEPO_FAIL',   p_msg_app => 'ITG',   p_token_vals => 'RETURN_CODE::' || chknul(p_return_code),   p_translatable => TRUE,   p_reset => FALSE);

  END;
 /*Added following procedure to fix bug : 5258514*/
  PROCEDURE receipt_closerelease_fail( p_return_code VARCHAR2 ) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_RECEIPT_CLOSERELEASE_FAIL');
    fnd_message.set_token('RETURN_CODE',   chknul(p_return_code));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_RECEIPT_CLOSERELEASE_FAIL',   p_msg_app => 'ITG',   p_token_vals => 'RETURN_CODE::' || chknul(p_return_code),   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE inspect_tol_exceeded IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_INSPECT_TOL_EXCEEDED');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_INSPECT_TOL_EXCEEDED',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE poline_negqty_ins IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_POLINE_NEGQTY_INS');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_POLINE_NEGQTY_INS',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE poline_zeroqty_ins IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_POLINE_ZEROQTY_INS');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_POLINE_ZEROQTY_INS',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE poline_zeroamt_inv IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_POLINE_ZEROAMT_INV');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_POLINE_ZEROAMT_INV',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE poline_badsign_inv IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_POLINE_BADSIGN_INV');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_POLINE_BADSIGN_INV',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE poline_closed_inv IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_POLINE_CLOSED_INV');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_POLINE_CLOSED_INV',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE invoice_tol_exceeded IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_INVOICE_TOL_EXCEEDED');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_INVOICE_TOL_EXCEEDED',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE invoice_closepo_fail(p_return_code VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_INVOICE_CLOSEPO_FAIL');
    fnd_message.set_token('RETURN_CODE',   chknul(p_return_code));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_INVOICE_CLOSEPO_FAIL',   p_msg_app => 'ITG',   p_token_vals => 'RETURN_CODE::' || chknul(p_return_code),   p_translatable => TRUE,   p_reset => FALSE);

  END;
 /*Added following procedure to fix bug : 5258514*/

  PROCEDURE invoice_closerelease_fail(p_return_code VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_INVOICE_CLOSERELEASE_FAIL');
    fnd_message.set_token('RETURN_CODE',   chknul(p_return_code));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_INVOICE_CLOSERELEASE_FAIL',   p_msg_app => 'ITG',   p_token_vals => 'RETURN_CODE::' || chknul(p_return_code),   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE poline_closed_final IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_POLINE_CLOSED_FINAL');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_POLINE_CLOSED_FINAL',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE poline_invalid_doctype IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_POLINE_INVALID_DOCTYPE');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_POLINE_INVALID_DOCTYPE',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE toomany_base_uom_flag IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_TOOMANY_BASE_UOM_FLAG');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_TOOMANY_BASE_UOM_FLAG',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE null_disable_date IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NULL_DISABLE_DATE');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NULL_DISABLE_DATE',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE delete_failed IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_DELETE_FAILED');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_DELETE_FAILED',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE bad_uom_crossval IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_BAD_UOM_CROSSVAL');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_BAD_UOM_CROSSVAL',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE toomany_default_conv_flag IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_TOOMANY_DEFAULT_CONV_FLAG');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_TOOMANY_DEFAULT_CONV_FLAG',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE neg_conv IS
  BEGIN
    fnd_message.set_name('INV',   'INV_NEG_CONV');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'INV_NEG_CONV',   p_msg_app => 'INV',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE conv_not_found(p_uom_code VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_CONV_NOT_FOUND');
    fnd_message.set_token('UOM_CODE',   chknul(p_uom_code));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_CONV_NOT_FOUND',   p_msg_app => 'ITG',   p_token_vals => 'UOM_CODE::' || chknul(p_uom_code),   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE base_uom_not_found(p_uom_code VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_BASE_UOM_NOT_FOUND');
    fnd_message.set_token('UOM_CODE',   chknul(p_uom_code));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_BASE_UOM_NOT_FOUND',   p_msg_app => 'ITG',   p_token_vals => 'UOM_CODE::' || chknul(p_uom_code),   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE uom_not_found(p_uom_code VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_UOM_NOT_FOUND');
    fnd_message.set_token('UOM_CODE',   chknul(p_uom_code));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_UOM_NOT_FOUND',   p_msg_app => 'ITG',   p_token_vals => 'UOM_CODE::' || chknul(p_uom_code),   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE unknown_document_error IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_UNKNOWN_DOCUMENT_ERROR');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_UNKNOWN_DOCUMENT_ERROR',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE document_success IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_DOCUMENT_SUCCESS');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_DOCUMENT_SUCCESS',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE orgeff_check_failed IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_ORGEFF_CHECK_FAILED');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_ORGEFF_CHECK_FAILED',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE invalid_argument(p_name VARCHAR2,   p_value VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_INVALID_ARGUMENT');
    fnd_message.set_token('NAME',   chknul(p_name));
    fnd_message.set_token('VALUE',   chknul(p_value));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_INVALID_ARGUMENT',   p_msg_app => 'ITG',   p_token_vals => 'NAME::' || chknul(p_name) || '^^VALUE::' || chknul(p_value),   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE invalid_doc_direction(p_doc_dir VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_INVALID_DOC_DIRECTION');
    fnd_message.set_token('DIRECTION',   chknul(p_doc_dir));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_INVALID_DOC_DIRECTION',   p_msg_app => 'ITG',   p_token_vals => 'DIRECTION::' || chknul(p_doc_dir),   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE missing_orgind(p_doc_typ VARCHAR2,   p_doc_dir VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_MISSING_ORGIND');
    fnd_message.set_token('DOC_TYPE',   chknul(p_doc_typ));
    fnd_message.set_token('DIRECTION',   chknul(p_doc_dir));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_MISSING_ORGIND',   p_msg_app => 'ITG',   p_token_vals => 'DOC_TYPE::' || chknul(p_doc_typ) || '^^DIRECTION::' || p_doc_dir,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  --- THERE IS NO ADD MESSAGE HERE BY PURPOSE
  PROCEDURE effectivity_update_fail(p_org_id NUMBER,   p_doc_typ VARCHAR2,   p_doc_dir VARCHAR2,   p_eff_id NUMBER) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_EFFECTIVITY_UPDATE_FAIL');
    fnd_message.set_token('ORG_ID',   chknul(to_char(p_org_id)));
    fnd_message.set_token('DOC_TYPE',   chknul(p_doc_typ));
    fnd_message.set_token('DIRECTION',   chknul(p_doc_dir));
    fnd_message.set_token('EFF_ID',   chknul(to_char(p_eff_id)));
  END;

  --- THERE IS NO ADD MESSAGE HERE BY PURPOSE
  PROCEDURE effectivity_insert_fail(p_org_id NUMBER,   p_doc_typ VARCHAR2,   p_doc_dir VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_EFFECTIVITY_INSERT_FAIL');
    fnd_message.set_token('ORG_ID',   chknul(to_char(p_org_id)));
    fnd_message.set_token('DOC_TYPE',   chknul(p_doc_typ));
    fnd_message.set_token('DIRECTION',   chknul(p_doc_dir));
  END;

  PROCEDURE daily_exchange_rate_error(p_currency_from VARCHAR2,   p_currency_to VARCHAR2,   p_error_code VARCHAR2) IS
  BEGIN

    /* p_error_code can be one of:

        DATE_RANGE_TOO_LARGE
        DISABLED_FROM_CURRENCY
        DISABLED_TO_CURRENCY
        EMU_FROM_CURRENCY
        EMU_TO_CURRENCY
        NEGATIVE_CONVERSION_RATE
        NEGATIVE_INVERSE_RATE
        NONEXISTANT_CONVERSION_TYPE
        NONEXISTANT_FROM_CURRENCY
        NONEXISTANT_TO_CURRENCY
        OUT_OF_DATE_FROM_CURRENCY
        OUT_OF_DATE_TO_CURRENCY
        STATISTICAL_FROM_CURRENCY
        STATISTICAL_TO_CURRENCY

        No translated messages for these errors codes seem to be
        available, so I am passing them through as-is.

     */ fnd_message.set_name('ITG',   'ITG_DAILY_EXCHANGE_RATE_ERROR');
    fnd_message.set_token('FROM_CURR',   chknul(p_currency_from));
    fnd_message.set_token('TO_CURR',   chknul(p_currency_to));
    fnd_message.set_token('ERROR_CODE',   chknul(p_error_code));
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_DAILY_EXCHANGE_RATE_ERROR',   p_msg_app => 'ITG',   p_token_vals => 'FROM_CURR::' || p_currency_from || '^^TO_CURR::' || p_currency_to || '^^ERROR_CODE::' || p_error_code,
    p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE checked_error(p_action VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_CHECKED_ERROR');
    fnd_message.set_token('ACTION',   p_action);
    fnd_msg_pub.ADD;
    --ITG_Debug.add_error;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_CHECKED_ERROR',   p_msg_app => 'ITG',   p_token_vals => 'ACTION::' || p_action,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE unexpected_error(p_action VARCHAR2) IS
  BEGIN

    fnd_message.set_name('ITG',   'ITG_UNEXPECTED_ERROR');
    fnd_message.set_token('ACTION',   p_action);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_UNEXPECTED_ERROR',   p_msg_app => 'ITG',   p_token_vals => 'ACTION::' || p_action,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE invalid_org(p_org_id VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_INVALID_ORG');
    fnd_message.set_token('ORG_ID',   p_org_id);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_INVALID_ORG',   p_msg_app => 'ITG',   p_token_vals => 'ORG_ID::' || p_org_id,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE vendor_not_found(p_name VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_VENDOR');
    fnd_message.set_token('NAME',   p_name);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_VENDOR',   p_msg_app => 'ITG',   p_token_vals => 'NAME::' || p_name,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE no_vendor_site(p_site_code VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_VENDORSITE');
    fnd_message.set_token('NAME',   p_site_code);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_VENDORSITE',   p_msg_app => 'ITG',   p_token_vals => 'NAME::' || p_site_code,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE gl_req_fail(p_sob_id VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_GLREQ_FAIL');
    fnd_message.set_token('SOB',   p_sob_id);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_GLREQ_FAIL',   p_msg_app => 'ITG',   p_token_vals => 'SOB::' || p_sob_id,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE no_gl_currency(p_sob_id VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_GLCURR');
    fnd_message.set_token('SOB',   p_sob_id);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_GLCURR',   p_msg_app => 'ITG',   p_token_vals => 'SOB::' || p_sob_id,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE no_set_of_books(p_sob VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_SOB');
    fnd_message.set_token('SOB',   p_sob);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_SOB',   p_msg_app => 'ITG',   p_token_vals => 'SOB::' || p_sob,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE no_gl_period(p_sob VARCHAR2,   p_effective_date VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_GLPERIOD');
    fnd_message.set_token('SOB',   p_sob);
    fnd_message.set_token('DATE',   p_effective_date);
    --ITG_Debug.add_error;
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_GLPERIOD',   p_msg_app => 'ITG',   p_token_vals => 'SOB::' || p_sob || '^^DATE::' || p_effective_date,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE no_uom(p_uom VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_UOM');
    fnd_message.set_token('UOM',   p_uom);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_UOM',   p_msg_app => 'ITG',   p_token_vals => 'UOM::' || p_uom,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE no_uom_class(p_uom_class VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_UOMCLASS');
    fnd_message.set_token('UOMCLASS',   p_uom_class);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_UOMCLASS',   p_msg_app => 'ITG',   p_token_vals => 'UOMCLASS::' || p_uom_class,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE no_uomclass_conv IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_UOMCLASSCONV');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_UOMCLASSCONV',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE dup_uomclass_conv IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_DUP_UOMCLASSCONV');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_DUP_UOMCLASSCONV',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE no_uom_conv IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_UOMCONV');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_UOMCONV',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE no_req_hdr(p_reqid VARCHAR2,   p_org VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_REQHEADER');
    fnd_message.set_token('REQHDR',   p_org || ':' || p_reqid);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_REQHEADER',   p_msg_app => 'ITG',   p_token_vals => 'REQHDR::' || p_org || ':' || p_reqid,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE no_req_line(p_req_id VARCHAR2,   p_req_line VARCHAR2,   p_org VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_REQLINE');
    fnd_message.set_token('REQLINE',   p_org || ':' || p_req_id || ':' || p_req_line);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_REQLINE',   p_msg_app => 'ITG',   p_token_vals => 'REQLINE::' || p_org || ':' || p_req_id || ':' || p_req_line,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE no_po_line(p_org_id VARCHAR2,   p_po_code VARCHAR2,   p_line_num VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_POLINE');
    fnd_message.set_token('POLINE',   p_org_id || ':' || p_po_code || ':' || p_line_num);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_POLINE',   p_msg_app => 'ITG',   p_token_vals => 'POLINE::' || p_org_id || ':' || p_po_code || ':' || p_line_num,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE incorrect_setup IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_INCORRECT_SETUP');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_INCORRRECT_SETUP',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE mici_only_failed IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_MICI_FAILED');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_MICI_FAILED',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE no_hazard_class(p_hazrdmatl VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_HAZMAT');
    fnd_message.set_token('HAZMAT',   p_hazrdmatl);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_HAZMAT',   p_msg_app => 'ITG',   p_token_vals => 'HAZMAT::' || p_hazrdmatl,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE cln_failure(p_clnmsg VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_CLN_FAIL');
    fnd_message.set_token('MSG',   p_clnmsg);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_CLN_FAIL',   p_msg_app => 'ITG',   p_token_vals => 'MSG::' || p_clnmsg,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE no_vset(p_set_id VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_VSET');
    fnd_message.set_token('VSET',   p_set_id);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_VSET',   p_msg_app => 'ITG',   p_token_vals => 'VSET::' || p_set_id,   p_translatable => TRUE,   p_reset => FALSE);

  END;

  PROCEDURE no_currtype_match(p_curr_from VARCHAR2,   p_curr_to VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_CURRTYPE_NOMATCH');
    fnd_message.set_token('FROM',   p_curr_from);
    fnd_message.set_token('TO',   p_curr_to);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_CURRTYPE_NOMATCH',   p_msg_app => 'ITG',   p_token_vals => 'FROM::' || p_curr_from || '^^TO::' || p_curr_to,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE gl_no_currec(p_sob VARCHAR2,   p_currency_to VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_NO_CURR');
    fnd_message.set_token('SOB',   p_sob);
    fnd_message.set_token('CURRTO',   p_currency_to);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_NO_CURR',   p_msg_app => 'ITG',   p_token_vals => 'SOB::' || p_sob || '^^CURRTO::' || p_currency_to,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE ratetype_noupd IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_RATE_NOUPD');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_RATE_NOUPD',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE gl_fromcur_wrong(p_sob VARCHAR2,   p_currency_from VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_FROMCURR_WRONG');
    fnd_message.set_token('SOB',   p_sob);
    fnd_message.set_token('CURRFROM',   p_currency_from);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_FROMCURR_WRONG',   p_msg_app => 'ITG',   p_token_vals => 'SOB::' || p_sob || '^^CURRFROM::' || p_currency_from,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE item_commodity_ign IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_CMMDTY_IGN');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_CMMDTY_IGN',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE item_import_pending(p_ccmid VARCHAR2,   p_status VARCHAR2,   p_phase VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_ITEMIMPORT_PENDING');
    fnd_message.set_token('CCMID',   p_ccmid);
    fnd_message.set_token('STATUS',   p_status);
    fnd_message.set_token('PHASE',   p_phase);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_ITEMIMPORT_PENDING',   p_msg_app => 'ITG',   p_token_vals => 'CCMID::' || p_ccmid || '^^STATUS::' || p_status || '^^PHASE::' || p_phase,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  /* Additional error messages exist, for the effectivities screen.
     These are not wrapped in functions, because they are not called from
     the PL/SQL code:

     ITG_EFF_INVALID_ORG_ID_EX
     ITG_EFF_OBJ_NOT_FOUND_EX: OBJECT_NAME
     ITG_EFF_ORG_EX
     ITG_EFF_ORG_ID_EX
     ITG_EFF_ORG_NAME_EX
     ITG_EFF_SQL_EX
   */

  PROCEDURE itemcat_import_pending(p_ccmid VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_ITEMCATIMPORT_PENDING');
    fnd_message.set_token('CCMID',   p_ccmid);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_ITEMCATIMPORT_PENDING',   p_msg_app => 'ITG',   p_token_vals => 'CCMID::' || p_ccmid,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE inv_cp_fail(p_status VARCHAR2,   p_phase VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_INVCP_FAIL');
    fnd_message.set_token('PHASE',   p_phase);
    fnd_message.set_token('STATUS',   p_status);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_INVCP_FAIL',   p_msg_app => 'ITG',   p_token_vals => 'STATUS::' || p_status || '^^PHASE::' || p_phase,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE item_import_errors IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_ITEMIMPORT_ERRORS');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_ITEMIMPORT_ERRORS',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE dup_vendor IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_DUP_VENDOR');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_DUP_VENDOR',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE vendor_contact_only IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_VENDOR_CONTACT');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_VENDOR_CONTACT',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE vendor_site_only IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_VENDOR_SITE');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_VENDOR_SITE',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE sup_number_exists(p_sup_no VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_DUP_SUPNO');
    fnd_message.set_token('SUPNO',   p_sup_no);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_DUP_SUPNO',   p_msg_app => 'ITG',   p_token_vals => 'SUPNO::' || chknul(p_sup_no),   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE dup_uom(p_uom_code VARCHAR2,   p_unit_of_measure VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_DUP_UOM');
    fnd_message.set_token('UOM_CODE',   p_uom_code);
    fnd_message.set_token('UNIT_OF_MEASURE',   p_unit_of_measure);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_DUP_UOM',   p_msg_app => 'ITG',   p_token_vals => 'UOM_CODE::' || p_uom_code || '^^UNIT_OF_MEASURE::' || p_unit_of_measure,   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE dup_uom_conv(p_item VARCHAR2,   p_uom VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_DUP_UOMCONV');
    fnd_message.set_token('ITEM',   p_item);
    fnd_message.set_token('UOM',   p_uom);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_DUP_UOMCONV',   p_msg_app => 'ITG',   p_token_vals => 'ITEM::' || chknul(p_item) || '^^UOM::' || chknul(p_uom),   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE apicallret(p_api VARCHAR2,   p_retcode VARCHAR2,   p_retmsg VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_APICALL_RET');
    fnd_message.set_token('API',   p_api);
    fnd_message.set_token('RETSTS',   p_retcode);
    fnd_message.set_token('RETMSG',   p_retmsg);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_APICALL_RET',   p_msg_app => 'ITG',   p_token_vals => 'API::' || chknul(p_api) || '^^RETSTS::' || chknul(p_retcode) || '^^RETMSG::' || chknul(p_retmsg),   p_translatable => TRUE,   p_reset => FALSE);
  END;

  PROCEDURE uomconvrate_err IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_UOMCONVRATE_ERR');
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_UOMCONVRATE_ERR',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
  END;

/* Adding following two procs to fix  the  bug 4882347 */
  PROCEDURE inv_qty_larg_than_exp IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_INV_QTY_LARGER_ERR');
    fnd_msg_pub.ADD;
    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_INV_QTY_LARGER_ERR',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
   END;

  PROCEDURE insp_qty_larg_than_exp IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_INSP_QTY_LARGER_ERR');
    fnd_msg_pub.ADD;
    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_INSP_QTY_LARGER_ERR',   p_msg_app => 'ITG',   p_token_vals => NULL,   p_translatable => TRUE,   p_reset => FALSE);
   END;
  /*Added to validate flex_value max size in COA inbound transaction  to fix bug : 5533589 */
  PROCEDURE INVALID_FLEXVAL_LENGTH(p_vset_id  NUMBER,p_flex_value  VARCHAR2) IS
  BEGIN
    fnd_message.set_name('ITG',   'ITG_FLEX_VALUE_MAXSIZE_ERR');
    fnd_message.set_token('VSET',   p_vset_id);
    fnd_message.set_token('FLEXVAL',   p_flex_value);
    fnd_msg_pub.ADD;

    itg_x_utils.addcboddescmsg(p_msg_code => 'ITG_FLEX_VALUE_MAXSIZE_ERR',   p_msg_app => 'ITG',   p_token_vals => 'FLEXVAL::' || chknul(p_flex_value) || '^^VSET::' || chknul(p_vset_id),   p_translatable => TRUE,   p_reset => FALSE);

  END;



  END itg_msg;

/
