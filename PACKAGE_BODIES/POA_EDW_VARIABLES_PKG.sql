--------------------------------------------------------
--  DDL for Package Body POA_EDW_VARIABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_VARIABLES_PKG" AS
/* $Header: poavarb.pls 115.7 2004/01/28 06:35:05 sdiwakar noship $ */

-- We populate some variables in order to avoid checking NULL value

l_dist_id_check_cut	NUMBER := -99977;
l_check_cut_out		DATE;
l_line_loc_goods_rcv	NUMBER := -99977;
l_goods_rcv_out		DATE;
l_dist_id_inv_create	NUMBER := -99977;
l_inv_create_out	DATE;
l_dist_id_inv_rcv	NUMBER := -99977;
l_inv_rcv_out		DATE;
l_req_id_req_app	NUMBER;
l_req_app_out		DATE;
l_dist_id_ipv		NUMBER := -99977;
l_ipv_out		NUMBER;
l_dist_id_supp_app	NUMBER := -99977;
l_supp_app_out		VARCHAR2(240);
l_header_id_app_by	NUMBER := -99977;
l_app_by_out		VARCHAR2(240);
l_doc_id_acc_date	NUMBER;
l_p_type_acc_date	VARCHAR2(15);
l_acc_date_out		DATE;

l_rate_date		DATE := to_date('01/01/0039', 'DD/MM/YYYY');
l_item_id		NUMBER := -99998;
l_rate			NUMBER := -99999;
l_uom_code		VARCHAR2(150) := '**ZZZZZZZ';
l_uom_conv_rate		NUMBER;
l_global_currency_rate	NUMBER;
l_currency_code		VARCHAR2(150) := '**XXXXXXX';
l_rate_type		VARCHAR2(150) := '**YYYYYYY';

-- We populate some variables in order to avoid checking NULL value

PROCEDURE init
IS
BEGIN

l_dist_id_check_cut := -99977;
l_check_cut_out := NULL;
l_line_loc_goods_rcv := -99977;
l_goods_rcv_out := NULL;
l_dist_id_inv_create := -99977;
l_inv_create_out := NULL;
l_dist_id_inv_rcv := -99977;
l_inv_rcv_out := NULL;
l_req_id_req_app := NULL;
l_req_app_out := NULL;
l_dist_id_ipv := -99977;
l_ipv_out := NULL;
l_dist_id_supp_app := -99977;
l_supp_app_out := NULL;
l_header_id_app_by := -99977;
l_app_by_out := NULL;
l_doc_id_acc_date := NULL;
l_p_type_acc_date := NULL;
l_acc_date_out := NULL;

l_rate_date    := to_date('01/01/0039', 'DD/MM/YYYY');
l_item_id      := -99998;
l_rate         := -99999;
l_uom_code     := '**ZZZZZZZ';
l_uom_conv_rate := NULL;
l_global_currency_rate := NULL;
l_currency_code := '**XXXXXXX';
l_rate_type     := '**YYYYYYY';

END init;

FUNCTION get_check_cut_date (p_po_distribution_id IN NUMBER) RETURN DATE
IS
BEGIN

/* --this can be ignored
	if (p_po_distribution_id IS NULL) then
		l_check_cut_out := NULL;
                l_dist_id_check_cut := p_po_distribution_id;
		return l_check_cut_out;
	end if;
*/

	if (p_po_distribution_id <> l_dist_id_check_cut) then
		l_dist_id_check_cut := p_po_distribution_id;
        	l_check_cut_out := POA_EDW_SPEND_PKG.get_check_cut_date(p_po_distribution_id);
	end if;

	return l_check_cut_out;

END GET_CHECK_CUT_DATE;

FUNCTION get_goods_received_date (p_po_line_location_id IN NUMBER) RETURN DATE
IS
BEGIN

/* --this can be ignored
	if (p_po_line_location_id IS NULL) then
		l_goods_rcv_out := NULL;
                l_line_loc_goods_rcv := p_po_line_location_id;
		return l_goods_rcv_out;
	end if;
*/

	if (p_po_line_location_id <> l_line_loc_goods_rcv) then
		l_line_loc_goods_rcv := p_po_line_location_id;
        	l_goods_rcv_out := POA_EDW_SPEND_PKG.get_goods_received_date(p_po_line_location_id);
	end if;
	return l_goods_rcv_out;

END GET_GOODS_RECEIVED_DATE;

FUNCTION get_invoice_creation_date (p_po_distribution_id IN NUMBER) RETURN DATE
IS
BEGIN

/* --this can be ignored
	if (p_po_distribution_id IS NULL) then
		l_inv_create_out := NULL;
                l_dist_id_inv_create := p_po_distribution_id;
		return l_inv_create_out;
	end if;
*/

	if (p_po_distribution_id <> l_dist_id_inv_create) then
		l_dist_id_inv_create := p_po_distribution_id;
        	l_inv_create_out := POA_EDW_SPEND_PKG.get_invoice_creation_date(p_po_distribution_id);
	end if;
	return l_inv_create_out;

END get_invoice_creation_date;

FUNCTION get_invoice_received_date (p_po_distribution_id IN NUMBER) RETURN DATE
IS
BEGIN

/* --this can be ignored
	if (p_po_distribution_id IS NULL) then
		l_inv_rcv_out := NULL;
         	l_dist_id_inv_rcv := p_po_distribution_id;
		return l_inv_rcv_out;
	end if;
*/

	if (p_po_distribution_id <> l_dist_id_inv_rcv) then
		l_dist_id_inv_rcv := p_po_distribution_id;
        	l_inv_rcv_out := POA_EDW_SPEND_PKG.get_invoice_received_date(p_po_distribution_id);
	end if;

	return l_inv_rcv_out;

END get_invoice_received_date;

FUNCTION get_req_approval_date (p_po_req_dist_id IN NUMBER) RETURN DATE
IS
BEGIN

	if (p_po_req_dist_id IS NULL) then
		l_req_app_out := NULL;
                l_req_id_req_app := p_po_req_dist_id;
		return l_req_app_out;
	end if;

	if (p_po_req_dist_id <> l_req_id_req_app OR l_req_id_req_app is NULL) then
		l_req_id_req_app := p_po_req_dist_id;
        	l_req_app_out := POA_EDW_SPEND_PKG.get_req_approval_date(p_po_req_dist_id);
	end if;

	return l_req_app_out;

END get_req_approval_date;


FUNCTION get_ipv (p_po_distribution_id IN NUMBER) RETURN NUMBER
IS
BEGIN

/* --this can be ignored
	if (p_po_distribution_id IS NULL) then
		l_ipv_out := NULL;
                l_dist_id_ipv := p_po_distribution_id;
		return l_ipv_out;
	end if;
*/

	if (p_po_distribution_id <> l_dist_id_ipv) then
		l_dist_id_ipv := p_po_distribution_id;
        	l_ipv_out := POA_EDW_SPEND_PKG.get_ipv(p_po_distribution_id);
	end if;
	return l_ipv_out;

END get_ipv;

FUNCTION get_supplier_approved (p_po_distribution_id IN NUMBER) RETURN VARCHAR2
IS
BEGIN

/* --this can be ignored
	if (p_po_distribution_id IS NULL) then
		l_supp_app_out := NULL;
                l_dist_id_supp_app := p_po_distribution_id;
		return l_supp_app_out;
	end if;
*/

	if (p_po_distribution_id <> l_dist_id_supp_app) then
		l_dist_id_supp_app := p_po_distribution_id;
        	l_supp_app_out := POA_EDW_SPEND_PKG.get_supplier_approved(p_po_distribution_id);
	end if;
	return l_supp_app_out;

END get_supplier_approved;

FUNCTION get_supplier_approved (p_po_distribution_id IN NUMBER,
                                p_vendor_id IN NUMBER,
                                p_vendor_site_id IN NUMBER,
                                p_ship_to_org_id IN NUMBER,
                                p_item_id IN NUMBER,
                                p_category_id IN NUMBER) RETURN VARCHAR2
IS
BEGIN

/* --this can be ignored
        if (p_po_distribution_id IS NULL) then
                l_supp_app_out := NULL;
                l_dist_id_supp_app := p_po_distribution_id;
                return l_supp_app_out;
        end if;
*/

        if (p_po_distribution_id <> l_dist_id_supp_app) then
                l_dist_id_supp_app := p_po_distribution_id;
                l_supp_app_out := POA_EDW_SPEND_PKG.get_supplier_approved(p_po_distribution_id, p_vendor_id, p_vendor_site_id, p_ship_to_org_id, p_item_id, p_category_id);
        end if;
        return l_supp_app_out;

END get_supplier_approved;

FUNCTION approved_by (p_po_header_id IN NUMBER) RETURN NUMBER
IS
BEGIN

/* --this can be ignored
	if (p_po_header_id IS NULL) then
		l_app_by_out := NULL;
                l_header_id_app_by := p_po_header_id;
		return l_app_by_out;
	end if;
*/

	if (p_po_header_id <> l_header_id_app_by) then
		l_header_id_app_by := p_po_header_id;
        	l_app_by_out := POA_EDW_SPEND_PKG.approved_by(p_po_header_id);
	end if;
	return l_app_by_out;

END approved_by;

FUNCTION get_acceptance_date (p_po_doc_id IN NUMBER, p_type IN VARCHAR2) RETURN DATE
IS
BEGIN

	if (p_po_doc_id IS NULL OR p_type IS NULL) then
		l_acc_date_out := NULL;
		l_doc_id_acc_date := p_po_doc_id;
		l_p_type_acc_date := p_type;
		return l_acc_date_out;
	end if;

	if (p_po_doc_id <> l_doc_id_acc_date OR p_type <> l_p_type_acc_date OR
            l_doc_id_acc_date is NULL OR l_p_type_acc_date is NULL) then
		l_doc_id_acc_date := p_po_doc_id;
		l_p_type_acc_date := p_type;
        	l_acc_date_out := POA_EDW_SPEND_PKG.get_acceptance_date(p_po_doc_id, p_type);
	end if;
	return l_acc_date_out;

END get_acceptance_date;

---------------------

 FUNCTION get_global_currency_rate  (p_rate_type      VARCHAR2,
                                     p_currency_code  VARCHAR2,
                                     p_rate_date      DATE,
                                     p_rate           NUMBER)  RETURN NUMBER
 IS
 BEGIN

   if (p_rate_type is NULL) then
      if (p_rate_date <> l_rate_date OR p_currency_code <> l_currency_code
                                     OR l_rate_type is NOT NULL) then
         l_currency_code :=  p_currency_code;
         l_rate_date     :=  p_rate_date;
         l_rate_type     :=  p_rate_type;
         l_global_currency_rate := edw_currency.get_rate (
                    p_currency_code, p_rate_date, NULL);
      end if;
   elsif (p_rate_type = 'User') then
      if (p_rate_date <> l_rate_date OR p_currency_code <> l_currency_code OR
          p_rate_type <> l_rate_type OR l_rate_type is NULL OR
          p_rate <> l_rate) then
         l_currency_code :=  p_currency_code;
         l_rate_date     :=  p_rate_date;
         l_rate_type     :=  p_rate_type;
         l_rate          :=  p_rate;
         l_global_currency_rate := edw_currency.get_rate (
                    p_currency_code, p_rate_date, NULL) * p_rate;
      end if;
   else   /* p_rate_type is NOT NULL and p_rate_type <> 'User' */
      if (p_rate_date <> l_rate_date OR p_currency_code <> l_currency_code OR
          p_rate_type <> l_rate_type OR l_rate_type is NULL) then
         l_rate_type     := p_rate_type;
         l_currency_code := p_currency_code;
         l_rate_date     := p_rate_date;
         l_global_currency_rate := edw_currency.get_rate (
                    p_currency_code, p_rate_date, p_rate_type);
      end if;
   end if;

   return l_global_currency_rate;

 END get_global_currency_rate;


 FUNCTION get_uom_conv_rate (p_uom_code    VARCHAR2,
                             p_item_id     NUMBER)  RETURN NUMBER
 IS
 BEGIN

/* --this can be ignored
   if(p_uom_code is NULL) then
      l_uom_code := p_uom_code;
      l_uom_conv_rate := NULL;
      return l_uom_conv_rate;
   end if;
*/

   if (p_item_id is NULL) then
     if (p_uom_code <> l_uom_code OR l_item_id is NOT NULL) then
        l_uom_code := p_uom_code;
        l_item_id  := p_item_id;
        l_uom_conv_rate := edw_util.get_uom_conv_rate (p_uom_code, p_item_id);
     end if;
   else
     if (p_uom_code <> l_uom_code OR p_item_id <> l_item_id
                                  OR l_item_id is NULL) then
        l_uom_code := p_uom_code;
        l_item_id  := p_item_id;
        l_uom_conv_rate := edw_util.get_uom_conv_rate (p_uom_code, p_item_id);
     end if;
   end if;

   return l_uom_conv_rate;

 END get_uom_conv_rate;


END POA_EDW_VARIABLES_PKG;

/
