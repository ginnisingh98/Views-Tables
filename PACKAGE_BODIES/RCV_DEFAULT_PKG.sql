--------------------------------------------------------
--  DDL for Package Body RCV_DEFAULT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_DEFAULT_PKG" AS
/* $Header: RCVDFLTB.pls 120.38.12010000.27 2014/04/17 23:11:19 vthevark ship $*/
   g_debug_flag       CONSTANT VARCHAR2(1)                           := asn_debug.is_debug_on; -- Bug 9152790
   /* the following marker variables indicate the possibility that the defaulted
      code does not match the ID's derived from the backing docs */
   g_rhi_ou_mkr                BOOLEAN;
   g_rhi_cust_party_name_mkr   BOOLEAN;
   g_rhi_cust_acc_num_mkr      BOOLEAN;
   g_rhi_employee_name_mkr     BOOLEAN;
   g_rhi_vendor_site_code_mkr  BOOLEAN;
   g_rti_ou_mkr                BOOLEAN;
   g_rti_cust_party_name_mkr   BOOLEAN;
   g_rti_cust_acc_num_mkr      BOOLEAN;
   g_rti_cust_item_num_mkr     BOOLEAN;
   g_rti_employee_name_mkr     BOOLEAN;
   g_rti_dlvr_to_prsn_name_mkr BOOLEAN;
   g_rti_vendor_site_code_mkr  BOOLEAN;
   g_rti_locator_mkr           BOOLEAN;
   g_rti_wip_entity_name_mkr   BOOLEAN;
   g_rti_item_description_mkr  BOOLEAN;
   g_rti_item_num_mkr          BOOLEAN;
   g_rti_sub_item_num_mkr      BOOLEAN;
   g_previous_time             NUMBER;
   g_curr_table                po_interface_errors.table_name%TYPE;
   g_curr_group_id             NUMBER;
   g_curr_header_id            NUMBER;
   g_curr_transaction_id       NUMBER;
   g_curr_org_id               NUMBER;
   g_curr_inv_org_id           NUMBER;
   g_subtract_pll_qty_rcv      BOOLEAN;
   g_asn_type                   rcv_shipment_headers.asn_type%type; --Bug: 5598511

/******************************************/
/* SECTION 1: Helper defaulting functions */
/******************************************/
/* WDK - EXPIREMENT TESTING SHOWS THAT CALLING PROCEDURES IN PLSQL IS SLOW  */
/* Therefore, even though using these helper procedures makes the code more */
/* readable, the trade-off is too large for a function that must execute    */
/* quickly */
/*
   PROCEDURE default_and_check(
      p_src_value IN            VARCHAR2, p_dst_value IN OUT NOCOPY VARCHAR2, p_column    IN            VARCHAR2) IS
   BEGIN
      IF (p_dst_value IS NULL) THEN
         p_dst_value  := p_src_value;
      ELSIF(    p_src_value IS NOT NULL
            AND p_dst_value <> p_src_value) THEN
         rcv_error_pkg.set_error_message('RCV_INVALID_ROI_VALUE');
         rcv_error_pkg.set_token('COLUMN', p_column);
         rcv_error_pkg.set_token('ROI_VALUE', p_dst_value);
         rcv_error_pkg.set_token('SYS_VALUE', p_src_value);
         rcv_error_pkg.log_interface_error(p_column);
      END IF;
   END default_and_check;

   PROCEDURE default_and_check(
      p_src_value IN            NUMBER, p_dst_value IN OUT NOCOPY NUMBER, p_column    IN            VARCHAR2) IS
   BEGIN
      IF (p_dst_value IS NULL) THEN
         p_dst_value  := p_src_value;
      ELSIF(    p_src_value IS NOT NULL
            AND p_dst_value <> p_src_value) THEN
         rcv_error_pkg.set_error_message('RCV_INVALID_ROI_VALUE');
         rcv_error_pkg.set_token('COLUMN', p_column);
         rcv_error_pkg.set_token('ROI_VALUE', p_dst_value);
         rcv_error_pkg.set_token('SYS_VALUE', p_src_value);
         rcv_error_pkg.log_interface_error(p_column);
      END IF;
   END default_and_check;

   PROCEDURE default_and_check(
      p_src_value IN            DATE, p_dst_value IN OUT NOCOPY DATE, p_column    IN            VARCHAR2) IS
   BEGIN
      IF (p_dst_value IS NULL) THEN
         p_dst_value  := p_src_value;
      ELSIF(    p_src_value IS NOT NULL
            AND p_dst_value <> p_src_value) THEN
         rcv_error_pkg.set_error_message('RCV_INVALID_ROI_VALUE');
         rcv_error_pkg.set_token('COLUMN', p_column);
         rcv_error_pkg.set_token('ROI_VALUE', p_dst_value);
         rcv_error_pkg.set_token('SYS_VALUE', p_src_value);
         rcv_error_pkg.log_interface_error(p_column);
      END IF;
   END default_and_check;

   PROCEDURE DEFAULT_VALUE(
      p_src IN            VARCHAR2, p_dst IN OUT NOCOPY VARCHAR2) IS
   BEGIN
      IF (p_dst IS NULL) THEN
         p_dst  := p_src;
      END IF;
   END DEFAULT_VALUE;

   PROCEDURE DEFAULT_VALUE(
      p_src IN            NUMBER, p_dst IN OUT NOCOPY NUMBER) IS
   BEGIN
      IF (p_dst IS NULL) THEN
         p_dst  := p_src;
      END IF;
   END DEFAULT_VALUE;

   PROCEDURE DEFAULT_VALUE(
      p_src IN            DATE, p_dst IN OUT NOCOPY DATE) IS
   BEGIN
      IF (p_dst IS NULL) THEN
         p_dst  := p_src;
      END IF;
   END DEFAULT_VALUE;

   PROCEDURE test_is_null(
      p_value  IN VARCHAR2, p_column IN VARCHAR2) IS
   BEGIN
      IF (p_value IS NULL) THEN
         asn_debug.put_line('fail assert test_is_null for column ' || p_column);
         rcv_error_pkg.set_error_message('PO_PDOI_COLUMN_NOT_NULL');
         rcv_error_pkg.set_token('COLUMN', p_column);
         rcv_error_pkg.log_interface_error(p_column);
      END IF;
   END test_is_null;

   PROCEDURE test_is_null(
      p_value  IN NUMBER, p_column IN VARCHAR2) IS
   BEGIN
      IF (p_value IS NULL) THEN
         asn_debug.put_line('fail assert test_is_null for column ' || p_column);
         rcv_error_pkg.set_error_message('PO_PDOI_COLUMN_NOT_NULL');
         rcv_error_pkg.set_token('COLUMN', p_column);
         rcv_error_pkg.log_interface_error(p_column);
      END IF;
   END test_is_null;

   PROCEDURE test_is_null(
      p_value  IN DATE, p_column IN VARCHAR2) IS
   BEGIN
      IF (p_value IS NULL) THEN
         asn_debug.put_line('fail assert test_is_null for column ' || p_column);
         rcv_error_pkg.set_error_message('PO_PDOI_COLUMN_NOT_NULL');
         rcv_error_pkg.set_token('COLUMN', p_column);
         rcv_error_pkg.log_interface_error(p_column);
      END IF;
   END test_is_null;
*/
   PROCEDURE invalid_match_value(
      p_roi_value IN VARCHAR2,
      p_sys_value IN VARCHAR2,
      p_column    IN VARCHAR2
   ) IS
   BEGIN
      rcv_error_pkg.set_error_message('RCV_INVALID_ROI_VALUE');
      rcv_error_pkg.set_token('COLUMN', p_column);
      rcv_error_pkg.set_token('ROI_VALUE', p_roi_value);
      rcv_error_pkg.set_token('SYS_VALUE', p_sys_value);
      rcv_error_pkg.log_interface_error(g_curr_table,
                                        p_column,
                                        g_curr_group_id,
                                        g_curr_header_id,
                                        g_curr_transaction_id
                                       );
   END invalid_match_value;

   PROCEDURE invalid_null_value(
      p_column IN VARCHAR2
   ) IS
   BEGIN
      rcv_error_pkg.set_error_message('PO_PDOI_COLUMN_NOT_NULL');
      rcv_error_pkg.set_token('COLUMN', p_column);
      rcv_error_pkg.log_interface_error(g_curr_table,
                                        p_column,
                                        g_curr_group_id,
                                        g_curr_header_id,
                                        g_curr_transaction_id
                                       );
   END invalid_null_value;

   PROCEDURE invalid_value(
      p_value  IN VARCHAR2,
      p_column IN VARCHAR2
   ) IS
   BEGIN
      rcv_error_pkg.set_error_message('RCV_INVALID_ROI_VALUE_NE');
      rcv_error_pkg.set_token('COLUMN', p_column);
      rcv_error_pkg.set_token('ROI_VALUE', p_value);
      rcv_error_pkg.log_interface_error(g_curr_table,
                                        p_column,
                                        g_curr_group_id,
                                        g_curr_header_id,
                                        g_curr_transaction_id
                                       );
   END invalid_value;

   PROCEDURE invalid_value(
      p_value  IN NUMBER,
      p_column IN VARCHAR2
   ) IS
   BEGIN
      rcv_error_pkg.set_error_message('RCV_INVALID_ROI_VALUE_NE');
      rcv_error_pkg.set_token('COLUMN', p_column);
      rcv_error_pkg.set_token('ROI_VALUE', p_value);
      rcv_error_pkg.log_interface_error(g_curr_table,
                                        p_column,
                                        g_curr_group_id,
                                        g_curr_header_id,
                                        g_curr_transaction_id
                                       );
   END invalid_value;

   PROCEDURE invalid_value(
      p_value  IN DATE,
      p_column IN VARCHAR2
   ) IS
   BEGIN
      rcv_error_pkg.set_error_message('RCV_INVALID_ROI_VALUE_NE');
      rcv_error_pkg.set_token('COLUMN', p_column);
      rcv_error_pkg.set_token('ROI_VALUE', p_value);
      rcv_error_pkg.log_interface_error(g_curr_table,
                                        p_column,
                                        g_curr_group_id,
                                        g_curr_header_id,
                                        g_curr_transaction_id
                                       );
   END invalid_value;

   PROCEDURE elapsed_time(
      p_comment IN VARCHAR2
   ) IS
      x_new_time NUMBER;
   BEGIN
      x_new_time       := DBMS_UTILITY.get_time;

      IF (g_debug_flag = 'Y') THEN
         asn_debug.put_line('Elapsed Time:' || LPAD(x_new_time - NVL(g_previous_time, x_new_time),
                                                    8,
                                                    ' '
                                                   ) || ',Absolute Time:' || LPAD(x_new_time,
                                                                                  14,
                                                                                  ' '
                                                                                 ) || ' - ' || p_comment);
      END IF;

      g_previous_time  := x_new_time;
   END elapsed_time;

/************************************/
/* SECTION 2: Defaulting from codes */
/************************************/
   FUNCTION get_org_id_from_inv_org_id(
      p_organization_id IN mtl_parameters.organization_id%TYPE
   )
      RETURN rcv_headers_interface.org_id%TYPE IS
      x_org_id rcv_headers_interface.org_id%TYPE;
   BEGIN
      IF (p_organization_id IS NULL) THEN
         RETURN NULL;
      END IF;

      IF (p_organization_id = g_curr_inv_org_id) THEN
         RETURN g_curr_org_id;
      END IF;
      --perf fix 5217433
      SELECT DECODE(FPG.MULTI_ORG_FLAG,
                    'Y',
	            DECODE(HOI.ORG_INFORMATION_CONTEXT, 'Accounting Information', TO_NUMBER(HOI.ORG_INFORMATION3), TO_NUMBER(NULL)),
     	            TO_NUMBER(NULL)
                   ) OPERATING_UNIT
      INTO   x_org_id
      FROM   HR_ORGANIZATION_INFORMATION HOI,
             FND_PRODUCT_GROUPS FPG
      WHERE HOI.ORGANIZATION_ID  =  p_organization_id
      AND ( HOI.ORG_INFORMATION_CONTEXT || '') ='Accounting Information';

      g_curr_org_id      := x_org_id;
      g_curr_inv_org_id  := p_organization_id;
      RETURN x_org_id;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END get_org_id_from_inv_org_id;

   FUNCTION get_org_id_from_ou(
      p_ou     IN            rcv_headers_interface.operating_unit%TYPE,
      p_column IN            VARCHAR2,
      p_marker IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.org_id%TYPE IS
      x_org_id rcv_headers_interface.org_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_ou IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT organization_id
      INTO   x_org_id
      FROM   hr_organization_units
      WHERE  NAME = p_ou;

      RETURN x_org_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_ou, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_org_id_from_ou;

   FUNCTION get_ou_from_org_id(
      p_org_id IN            rcv_headers_interface.org_id%TYPE,
      p_column IN            VARCHAR2,
      p_marker IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.operating_unit%TYPE IS
      x_ou rcv_headers_interface.operating_unit%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_org_id IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT NAME
      INTO   x_ou
      FROM   hr_organization_units
      WHERE  organization_id = p_org_id;

      RETURN x_ou;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_org_id, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_ou_from_org_id;

   FUNCTION get_customer_id_from_name_num(
      p_customer_party_name     IN            rcv_headers_interface.customer_party_name%TYPE,
      p_customer_account_number IN            rcv_headers_interface.customer_account_number%TYPE,
      p_column_name             IN            VARCHAR2,
      p_column_num              IN            VARCHAR2,
      p_marker_name             IN OUT NOCOPY BOOLEAN,
      p_marker_num              IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.customer_id%TYPE IS
      x_customer_id rcv_headers_interface.customer_id%TYPE;
   BEGIN
      p_marker_name  := FALSE;
      p_marker_num   := FALSE;

      IF (   p_customer_party_name IS NULL
          OR p_customer_account_number IS NULL) THEN
         IF (p_customer_party_name IS NOT NULL) THEN
            p_marker_name  := TRUE;
         END IF;

         IF (p_customer_account_number IS NOT NULL) THEN
            p_marker_num  := TRUE;
         END IF;

         RETURN NULL;
      END IF;

      SELECT acct.cust_account_id
      INTO   x_customer_id
      FROM   hz_parties party,
             hz_cust_accounts acct
      WHERE  party.party_id = acct.party_id
      AND    party.party_name = p_customer_party_name
      AND    acct.account_number = p_customer_account_number;

      RETURN x_customer_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(' || p_customer_account_number,p_column_name || ', ' || p_column_num, p_customer_party_name || ');
      WHEN TOO_MANY_ROWS THEN
         p_marker_name  := TRUE;
         p_marker_num   := TRUE;
         RETURN NULL;
   END get_customer_id_from_name_num;

   FUNCTION get_customer_name_from_id(
      p_customer_id IN            rcv_headers_interface.customer_id%TYPE,
      p_column      IN            VARCHAR2,
      p_marker      IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.customer_party_name%TYPE IS
      x_customer_party_name rcv_headers_interface.customer_party_name%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_customer_id IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT party.party_name
      INTO   x_customer_party_name
      FROM   hz_parties party,
             hz_cust_accounts acct
      WHERE  party.party_id = acct.party_id
      AND    acct.cust_account_id = p_customer_id;

      RETURN x_customer_party_name;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_customer_id, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_customer_name_from_id;

   FUNCTION get_customer_num_from_id(
      p_customer_id IN            rcv_headers_interface.customer_id%TYPE,
      p_column      IN            VARCHAR2,
      p_marker      IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.customer_account_number%TYPE IS
      x_customer_account_number rcv_headers_interface.customer_account_number%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_customer_id IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT acct.account_number
      INTO   x_customer_account_number
      FROM   hz_cust_accounts acct
      WHERE  acct.cust_account_id = p_customer_id;

      RETURN x_customer_account_number;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_customer_id, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_customer_num_from_id;

   FUNCTION get_employee_id_from_name(
      p_employee_name IN            rcv_headers_interface.employee_name%TYPE,
      p_column        IN            VARCHAR2,
      p_marker        IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.employee_id%TYPE IS
      x_employee_id rcv_headers_interface.employee_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_employee_name IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT employee_id
      INTO   x_employee_id
      FROM   hr_employees
      WHERE  full_name = p_employee_name;

      RETURN x_employee_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_employee_name, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_employee_id_from_name;

   FUNCTION get_employee_name_from_id(
      p_employee_id IN            rcv_headers_interface.employee_id%TYPE,
      p_column      IN            VARCHAR2,
      p_marker      IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.employee_name%TYPE IS
      x_employee_name rcv_headers_interface.employee_name%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_employee_id IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT full_name
      INTO   x_employee_name
      FROM   hr_employees
      WHERE  employee_id = p_employee_id;

      RETURN x_employee_name;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_employee_id, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_employee_name_from_id;

   FUNCTION get_org_id_from_code(
      p_org_code IN            rcv_headers_interface.from_organization_code%TYPE,
      p_column   IN            VARCHAR2,
      p_marker   IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.from_organization_id%TYPE IS
      x_org_id rcv_headers_interface.from_organization_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_org_code IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT organization_id
      INTO   x_org_id
      FROM   mtl_parameters
      WHERE  organization_code = p_org_code;

      RETURN x_org_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_org_code, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_org_id_from_code;

--Bug 7591174 Added a New function to get the to_organization_id from ship_to_location_id
   FUNCTION get_org_id_from_location_id(
      p_location_id   IN            rcv_headers_interface.location_id%TYPE,
      p_column        IN            VARCHAR2,
      p_marker        IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.from_organization_id%TYPE IS
      x_org_id rcv_headers_interface.from_organization_id%TYPE;
   BEGIN
      p_marker    :=FALSE;

      IF(p_location_id IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT org.organization_id
      INTO   x_org_id
      FROM   hr_locations hl,
             mtl_parameters org
      WHERE  hl.location_id = p_location_id
      AND    hl.inventory_organization_id = org.organization_id;

      RETURN x_org_id;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_location_id, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_org_id_from_location_id;

   FUNCTION get_location_id_from_code(
      p_location_code IN            rcv_headers_interface.location_code%TYPE,
      p_column        IN            VARCHAR2,
      p_marker        IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.location_id%TYPE IS
      x_location_id rcv_headers_interface.location_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_location_code IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT location_id
      INTO   x_location_id
      FROM   hr_locations_all
      WHERE  location_code = p_location_code
      AND    (   business_group_id = NVL(hr_general.get_business_group_id, business_group_id)
              OR business_group_id IS NULL);

      RETURN x_location_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
      /* Bug 5056691: No need to error out the transaction, if we are not
                      able to default the location_id. Bypassed the
                      logging of error messages, as it is handled in
                      validation logic. */
         RETURN NULL;
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_location_id_from_code;

   FUNCTION get_payment_terms_id_from_name(
      p_payment_terms_name IN            rcv_headers_interface.payment_terms_name%TYPE,
      p_column             IN            VARCHAR2,
      p_marker             IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.payment_terms_id%TYPE IS
      x_payment_terms_id rcv_headers_interface.payment_terms_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_payment_terms_name IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT term_id
      INTO   x_payment_terms_id
      FROM   ap_terms
      WHERE  NAME = p_payment_terms_name;

      RETURN x_payment_terms_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_payment_terms_name, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_payment_terms_id_from_name;

   FUNCTION get_vendor_id_from_name(
      p_vendor_name IN            rcv_headers_interface.vendor_name%TYPE,
      p_column      IN            VARCHAR2,
      p_marker      IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.vendor_id%TYPE IS
      x_vendor_id rcv_headers_interface.vendor_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_vendor_name IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT vendor_id
      INTO   x_vendor_id
      FROM   po_vendors
      WHERE  vendor_name = p_vendor_name;

      RETURN x_vendor_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_vendor_name, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_vendor_id_from_name;

   FUNCTION get_vendor_id_from_num(
      p_vendor_num IN            rcv_headers_interface.vendor_num%TYPE,
      p_column     IN            VARCHAR2,
      p_marker     IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.vendor_id%TYPE IS
      x_vendor_id rcv_headers_interface.vendor_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_vendor_num IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT vendor_id
      INTO   x_vendor_id
      FROM   po_vendors
      WHERE  segment1 = p_vendor_num;

      RETURN x_vendor_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_vendor_num, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_vendor_id_from_num;

   FUNCTION get_vendor_site_id_from_code(
      p_vendor_site_code IN            rcv_headers_interface.vendor_site_code%TYPE,
      p_vendor_id        IN OUT NOCOPY rcv_headers_interface.vendor_id%TYPE,
      p_org_id           IN            rcv_headers_interface.org_id%TYPE,
      p_column           IN            VARCHAR2,
      p_marker           IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.vendor_site_id%TYPE IS
      x_vendor_site_id rcv_headers_interface.vendor_site_id%TYPE;
      x_vendor_id      rcv_headers_interface.vendor_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_vendor_site_code IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT vendor_site_id,
             vendor_id
      INTO   x_vendor_site_id,
             x_vendor_id
      FROM   po_vendor_sites_all
      WHERE  org_id = NVL(p_org_id, org_id)
      AND    vendor_site_code = p_vendor_site_code
      AND    vendor_id = NVL(p_vendor_id, vendor_id);

      IF (p_vendor_id IS NULL) THEN
         p_vendor_id  := x_vendor_id;
      END IF;

      RETURN x_vendor_site_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_vendor_site_code, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_vendor_site_id_from_code;

   FUNCTION get_vendor_site_code_from_id(
      p_vendor_site_id IN OUT NOCOPY rcv_headers_interface.vendor_site_id%TYPE,
      p_vendor_id      IN OUT NOCOPY rcv_headers_interface.vendor_id%TYPE,
      p_org_id         IN            rcv_headers_interface.org_id%TYPE,
      p_column         IN            VARCHAR2,
      p_marker         IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.vendor_site_code%TYPE IS
      x_vendor_site_code rcv_headers_interface.vendor_site_code%TYPE;
      x_vendor_id        rcv_headers_interface.vendor_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_vendor_site_id IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT vendor_site_code,
             vendor_id
      INTO   x_vendor_site_code,
             x_vendor_id
      FROM   po_vendor_sites
      WHERE  org_id = NVL(p_org_id, org_id)
      AND    vendor_site_id = p_vendor_site_id;

      IF (p_vendor_id IS NULL) THEN
         p_vendor_id  := x_vendor_id;
      END IF;

      RETURN x_vendor_site_code;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_vendor_id, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_vendor_site_code_from_id;

   FUNCTION get_sfloc_id_from_code(
      p_ship_from_location_code IN            rcv_headers_interface.ship_from_location_code%TYPE,
      p_vendor_site_id          IN            rcv_headers_interface.vendor_site_id%TYPE,
      p_column                  IN            VARCHAR2,
      p_marker                  IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_headers_interface.ship_from_location_id%TYPE IS
      x_ship_from_location_id rcv_headers_interface.ship_from_location_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_ship_from_location_code IS NULL) THEN
         RETURN NULL;
      END IF;

      --Bug 5200786. Performace Issue. Added the last where condition
      SELECT max(hps.location_id)
      INTO   x_ship_from_location_id
      FROM   hz_party_sites hps,
             hz_party_site_uses hpsu,
             po_vendor_sites_all pvs
      WHERE  pvs.vendor_site_id = p_vendor_site_id
      AND    hpsu.party_site_id = hps.party_site_id
      AND    hpsu.site_use_type = 'SUPPLIER_SHIP_FROM'
      AND    hps.party_site_number = p_ship_from_location_code||'|'||hps.party_id
      AND    hps.party_site_number like p_ship_from_location_code||'%'; --Bug 5200786.

      IF (x_ship_from_location_id is null) THEN --bug 5263555
        invalid_value(p_vendor_site_id, p_column);
      ELSE
        RETURN x_ship_from_location_id;
      END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	/* Bug 4590642.
	 * Need to use p_vendor_site_id and not p_vendor_id.
	*/
         invalid_value(p_vendor_site_id, p_column);
      WHEN OTHERS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_sfloc_id_from_code;

   FUNCTION get_customer_item_id_from_num(
      p_customer_item_num IN            rcv_transactions_interface.customer_item_num%TYPE,
      p_customer_id       IN            rcv_transactions_interface.customer_id%TYPE,
      p_column            IN            VARCHAR2,
      p_marker            IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_transactions_interface.customer_item_id%TYPE IS
      x_customer_item_id rcv_transactions_interface.customer_item_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (   p_customer_item_num IS NULL
          OR p_customer_id IS NULL) THEN
         IF (p_customer_item_num IS NOT NULL) THEN
            p_marker  := TRUE;
         END IF;

         RETURN NULL;
      END IF;

      SELECT customer_item_id
      INTO   x_customer_item_id
      FROM   mtl_customer_items
      WHERE  customer_item_number = p_customer_item_num
      AND    customer_id = p_customer_id;

      RETURN x_customer_item_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_customer_item_num, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_customer_item_id_from_num;

   FUNCTION get_customer_item_num_from_id(
      p_customer_item_id IN            rcv_transactions_interface.customer_item_id%TYPE,
      p_column           IN            VARCHAR2,
      p_marker           IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_transactions_interface.customer_item_num%TYPE IS
      x_customer_item_num rcv_transactions_interface.customer_item_num%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_customer_item_id IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT customer_item_number
      INTO   x_customer_item_num
      FROM   mtl_customer_items
      WHERE  customer_item_id = p_customer_item_id;

      RETURN x_customer_item_num;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_customer_item_id, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_customer_item_num_from_id;

/*  Bug fix 5383556 : commenting this code as Item ID should not be derived from Item Description, since
     A. It is possible that more than one item have the same description.
     B. An One Time Item's description could match a description of a defined Item.


   FUNCTION get_item_id_from_description(
      p_item_description IN            rcv_transactions_interface.item_description%TYPE,
      p_org_id           IN            rcv_transactions_interface.to_organization_id%TYPE,
      p_column           IN            VARCHAR2,
      p_marker           IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_transactions_interface.item_id%TYPE IS
      x_item_id rcv_transactions_interface.item_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (   p_item_description IS NULL
          OR p_org_id IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT inventory_item_id
      INTO   x_item_id
      FROM   mtl_item_flexfields
      WHERE  organization_id = p_org_id
      AND    description = p_item_description;

      RETURN x_item_id;
   EXCEPTION
      WHEN OTHERS THEN --Note that there is no invalid value here because of one-time-items
         p_marker  := TRUE;
         RETURN NULL;
   END get_item_id_from_description;
*/
   FUNCTION get_item_id_from_num(
      p_item_num IN            rcv_transactions_interface.item_num%TYPE,
      p_org_id   IN            rcv_transactions_interface.to_organization_id%TYPE,
      p_column   IN            VARCHAR2,
      p_marker   IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_transactions_interface.item_id%TYPE IS
      x_item_id rcv_transactions_interface.item_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (   p_item_num IS NULL
          OR p_org_id IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT inventory_item_id
      INTO   x_item_id
      FROM   mtl_item_flexfields
      WHERE  organization_id = p_org_id
      AND    item_number = p_item_num;

      RETURN x_item_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_item_num, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_item_id_from_num;

   FUNCTION get_item_description_from_id(
      p_item_id IN            rcv_transactions_interface.item_id%TYPE,
      p_org_id  IN            rcv_transactions_interface.to_organization_id%TYPE,
      p_column  IN            VARCHAR2,
      p_marker  IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_transactions_interface.item_description%TYPE IS
      x_item_description rcv_transactions_interface.item_description%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (   p_item_id IS NULL
          OR p_org_id IS NULL) THEN
         RETURN NULL;
      END IF;
/** Bug: 5504176
 *    Item description field is MLS(multi lingual support) complaint field.
 *    So, we have to fetch the description from mtl_system_items_vl instead of
 *    mtl_item_flexfields, because mtl_system_items_vl view is based on
 *    mtl_system_items_tl table.
 */
      SELECT description
      INTO   x_item_description
      FROM   mtl_system_items_vl --5504176
      WHERE  organization_id = p_org_id
      AND    inventory_item_id = p_item_id;

      RETURN x_item_description;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_item_id, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_item_description_from_id;

   FUNCTION get_item_num_from_id(
      p_item_id IN            rcv_transactions_interface.item_id%TYPE,
      p_org_id  IN            rcv_transactions_interface.to_organization_id%TYPE,
      p_column  IN            VARCHAR2,
      p_marker  IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_transactions_interface.item_num%TYPE IS
      x_item_num rcv_transactions_interface.item_num%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (   p_item_id IS NULL
          OR p_org_id IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT item_number
      INTO   x_item_num
      FROM   mtl_item_flexfields
      WHERE  organization_id = p_org_id
      AND    inventory_item_id = p_item_id;

      RETURN x_item_num;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_item_id, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_item_num_from_id;

   FUNCTION get_uom_measure_from_code(
      p_uom_code IN            rcv_transactions_interface.uom_code%TYPE,
      p_column   IN            VARCHAR2,
      p_marker   IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_transactions_interface.unit_of_measure%TYPE IS
      x_unit_of_measure rcv_transactions_interface.unit_of_measure%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_uom_code IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT unit_of_measure
      INTO   x_unit_of_measure
      FROM   mtl_units_of_measure
      WHERE  uom_code = p_uom_code;

      RETURN x_unit_of_measure;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_uom_code, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_uom_measure_from_code;

   FUNCTION get_uom_code_from_measure(
      p_unit_of_measure IN            rcv_transactions_interface.unit_of_measure%TYPE,
      p_column          IN            VARCHAR2,
      p_marker          IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_transactions_interface.uom_code%TYPE IS
      x_uom_code rcv_transactions_interface.uom_code%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_unit_of_measure IS NULL) THEN
         RETURN NULL;
      END IF;


      SELECT uom_code
      INTO   x_uom_code
      FROM   mtl_units_of_measure
      WHERE  unit_of_measure = p_unit_of_measure;

      RETURN x_uom_code;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_unit_of_measure, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_uom_code_from_measure;

   FUNCTION get_locator_id_from_locator(
      p_locator      IN            rcv_transactions_interface.LOCATOR%TYPE,
      p_org_id       IN            rcv_transactions_interface.to_organization_id%TYPE,
      p_subinventory IN            rcv_transactions_interface.subinventory%TYPE,
      p_column       IN            VARCHAR2,
      p_marker       IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_transactions_interface.locator_id%TYPE IS
      x_locator_id rcv_transactions_interface.locator_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (   p_locator IS NULL
          OR p_org_id IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT inventory_location_id
      INTO   x_locator_id
      FROM   mtl_item_locations_kfv
      WHERE  organization_id = p_org_id
      AND    concatenated_segments = p_locator
      AND    (   subinventory_code = NVL(p_subinventory, subinventory_code)
              OR subinventory_code IS NULL)
      AND    (   disable_date > SYSDATE
              OR disable_date IS NULL);

      RETURN x_locator_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_locator, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_locator_id_from_locator;

   FUNCTION get_locator_from_locator_id(
      p_locator_id   IN            rcv_transactions_interface.locator_id%TYPE,
      p_org_id       IN            rcv_transactions_interface.to_organization_id%TYPE,
      p_subinventory IN            rcv_transactions_interface.subinventory%TYPE,
      p_column       IN            VARCHAR2,
      p_marker       IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_transactions_interface.LOCATOR%TYPE IS
      x_locator rcv_transactions_interface.LOCATOR%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (   p_locator_id IS NULL
          OR p_org_id IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT concatenated_segments
      INTO   x_locator
      FROM   mtl_item_locations_kfv
      WHERE  organization_id = p_org_id
      AND    inventory_location_id = p_locator_id
      AND    (   subinventory_code = NVL(p_subinventory, subinventory_code)
              OR subinventory_code IS NULL)
      AND    (   disable_date > SYSDATE
              OR disable_date IS NULL);

      RETURN x_locator;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_locator_id, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_locator_from_locator_id;

   FUNCTION get_rtng_header_id_from_code(
      p_routing_code IN            rcv_transactions_interface.routing_code%TYPE,
      p_column       IN            VARCHAR2,
      p_marker       IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_transactions_interface.routing_header_id%TYPE IS
      x_routing_header_id rcv_transactions_interface.routing_header_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_routing_code IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT routing_header_id
      INTO   x_routing_header_id
      FROM   rcv_routing_headers
      WHERE  routing_name = p_routing_code;

      RETURN x_routing_header_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_routing_code, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_rtng_header_id_from_code;

   FUNCTION get_rtng_step_id_from_code(
      p_routing_step IN            rcv_transactions_interface.routing_step%TYPE,
      p_column       IN            VARCHAR2,
      p_marker       IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_transactions_interface.routing_step_id%TYPE IS
      x_routing_step_id rcv_transactions_interface.routing_step_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (p_routing_step IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT routing_step_id
      INTO   x_routing_step_id
      FROM   rcv_routing_steps
      WHERE  step_name = p_routing_step;

      RETURN x_routing_step_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_routing_step, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_rtng_step_id_from_code;

   FUNCTION get_wip_entity_id_from_name(
      p_wip_entity_name IN            rcv_transactions_interface.wip_entity_name%TYPE,
      p_org_id          IN            rcv_transactions_interface.to_organization_id%TYPE,
      p_column          IN            VARCHAR2,
      p_marker          IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_transactions_interface.wip_entity_id%TYPE IS
      x_wip_entity_id rcv_transactions_interface.wip_entity_id%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (   p_wip_entity_name IS NULL
          OR p_org_id IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT wip_entity_id
      INTO   x_wip_entity_id
      FROM   wip_entities
      WHERE  organization_id = p_org_id
      AND    wip_entity_name = p_wip_entity_name;

      RETURN x_wip_entity_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_wip_entity_name, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_wip_entity_id_from_name;

   FUNCTION get_wip_entity_name_from_id(
      p_wip_entity_id IN            rcv_transactions_interface.wip_entity_id%TYPE,
      p_org_id        IN            rcv_transactions_interface.to_organization_id%TYPE,
      p_column        IN            VARCHAR2,
      p_marker        IN OUT NOCOPY BOOLEAN
   )
      RETURN rcv_transactions_interface.wip_entity_name%TYPE IS
      x_wip_entity_name rcv_transactions_interface.wip_entity_name%TYPE;
   BEGIN
      p_marker  := FALSE;

      IF (   p_wip_entity_id IS NULL
          OR p_org_id IS NULL) THEN
         RETURN NULL;
      END IF;

      SELECT wip_entity_name
      INTO   x_wip_entity_name
      FROM   wip_entities
      WHERE  organization_id = p_org_id
      AND    wip_entity_id = p_wip_entity_id;

      RETURN x_wip_entity_name;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         invalid_value(p_wip_entity_id, p_column);
      WHEN TOO_MANY_ROWS THEN
         p_marker  := TRUE;
         RETURN NULL;
   END get_wip_entity_name_from_id;

/*******************************************************/
/* SECTION 3: Framework for calling default from codes */
/*******************************************************/
   PROCEDURE default_rhi_from_code(
      rhi IN OUT NOCOPY rcv_headers_interface%ROWTYPE
   ) IS
      x_dummy_mkr BOOLEAN;
   BEGIN
      IF (rhi.customer_id IS NULL) THEN
         rhi.customer_id  := get_customer_id_from_name_num(rhi.customer_party_name,
                                                           rhi.customer_account_number,
                                                           'CUSTOMER_PARTY_NAME',
                                                           'CUSTOMER_ACCOUNT_NUMBER',
                                                           g_rhi_cust_party_name_mkr,
                                                           g_rhi_cust_acc_num_mkr
                                                          );
      ELSIF(rhi.customer_id <> get_customer_id_from_name_num(rhi.customer_party_name,
                                                             rhi.customer_account_number,
                                                             'CUSTOMER_PARTY_NAME',
                                                             'CUSTOMER_ACCOUNT_NUMBER',
                                                             g_rhi_cust_party_name_mkr,
                                                             g_rhi_cust_acc_num_mkr
                                                            )) THEN
         invalid_match_value(rhi.customer_id,
                             get_customer_id_from_name_num(rhi.customer_party_name,
                                                           rhi.customer_account_number,
                                                           'CUSTOMER_PARTY_NAME',
                                                           'CUSTOMER_ACCOUNT_NUMBER',
                                                           g_rhi_cust_party_name_mkr,
                                                           g_rhi_cust_acc_num_mkr
                                                          ),
                             'CUSTOMER_ID'
                            );
      END IF;

      IF (rhi.employee_id IS NULL) THEN
         rhi.employee_id  := get_employee_id_from_name(rhi.employee_name,
                                                       'EMPLOYEE_NAME',
                                                       g_rhi_employee_name_mkr
                                                      );
      ELSIF(rhi.employee_id <> get_employee_id_from_name(rhi.employee_name,
                                                         'EMPLOYEE_NAME',
                                                         g_rhi_employee_name_mkr
                                                        )) THEN
         invalid_match_value(rhi.employee_id,
                             get_employee_id_from_name(rhi.employee_name,
                                                       'EMPLOYEE_NAME',
                                                       g_rhi_employee_name_mkr
                                                      ),
                             'EMPLOYEE_ID'
                            );
      END IF;

      IF (rhi.from_organization_id IS NULL) THEN
         rhi.from_organization_id  := get_org_id_from_code(rhi.from_organization_code,
                                                           'ORGANIZATION_CODE',
                                                           x_dummy_mkr
                                                          );
      ELSIF(rhi.from_organization_id <> get_org_id_from_code(rhi.from_organization_code,
                                                             'ORGANIZATION_CODE',
                                                             x_dummy_mkr
                                                            )) THEN
         invalid_match_value(rhi.from_organization_id,
                             get_org_id_from_code(rhi.from_organization_code,
                                                  'ORGANIZATION_CODE',
                                                  x_dummy_mkr
                                                 ),
                             'FROM_ORGANIZATION_ID'
                            );
      END IF;

      IF (rhi.org_id IS NULL) THEN
         rhi.org_id  := get_org_id_from_ou(rhi.operating_unit,
                                           'OPERATING_UNIT',
                                           g_rhi_ou_mkr
                                          );
      ELSIF(rhi.org_id <> get_org_id_from_ou(rhi.operating_unit,
                                             'OPERATING_UNIT',
                                             g_rhi_ou_mkr
                                            )) THEN
         invalid_match_value(rhi.org_id,
                             get_org_id_from_ou(rhi.operating_unit,
                                                'OPERATING_UNIT',
                                                g_rhi_ou_mkr
                                               ),
                             'ORG_ID'
                            );
      END IF;

      IF (rhi.ship_to_organization_id IS NULL) THEN
         rhi.ship_to_organization_id  := get_org_id_from_code(rhi.ship_to_organization_code,
                                                              'SHIP_TO_ORGANIZATION_CODE',
                                                              x_dummy_mkr
                                                             );
      ELSIF(rhi.ship_to_organization_id <> get_org_id_from_code(rhi.ship_to_organization_code,
                                                                'SHIP_TO_ORGANIZATION_CODE',
                                                                x_dummy_mkr
                                                               )) THEN
         invalid_match_value(rhi.ship_to_organization_id,
                             get_org_id_from_code(rhi.ship_to_organization_code,
                                                  'SHIP_TO_ORGANIZATION_CODE',
                                                  x_dummy_mkr
                                                 ),
                             'SHIP_TO_ORGANIZATION_ID'
                            );
      END IF;

      /*
      ** Bug#4615534 - Org_id defaulting from inventory organization
      ** needs to be done only for In-transit shipments
      */
      IF(rhi.receipt_source_code IN ('INVENTORY','INTERNAL ORDER')) THEN -- Bug 9706173
      /* With the SHIP_TO_ORGANIZATION_ID we need to derive the org_id */
          IF (rhi.org_id IS NULL) THEN
             rhi.org_id  := get_org_id_from_inv_org_id(rhi.ship_to_organization_id);
          END IF;
      END IF;

      IF (rhi.location_id IS NULL) THEN
         rhi.location_id  := get_location_id_from_code(rhi.location_code,
                                                       'LOCATION_CODE',
                                                       x_dummy_mkr
                                                      );
      ELSIF(rhi.location_id <> get_location_id_from_code(rhi.location_code,
                                                         'LOCATION_CODE',
                                                         x_dummy_mkr
                                                        )) THEN
         invalid_match_value(rhi.location_id,
                             get_location_id_from_code(rhi.location_code,
                                                       'LOCATION_CODE',
                                                       x_dummy_mkr
                                                      ),
                             'LOCATION_ID'
                            );
      END IF;

      IF (rhi.payment_terms_id IS NULL) THEN
         rhi.payment_terms_id  := get_payment_terms_id_from_name(rhi.payment_terms_name,
                                                                 'PAYMENT_TERMS_NAME',
                                                                 x_dummy_mkr
                                                                );
      ELSIF(rhi.payment_terms_id <> get_payment_terms_id_from_name(rhi.payment_terms_name,
                                                                   'PAYMENT_TERMS_NAME',
                                                                   x_dummy_mkr
                                                                  )) THEN
         invalid_match_value(rhi.payment_terms_id,
                             get_payment_terms_id_from_name(rhi.payment_terms_name,
                                                            'PAYMENT_TERMS_NAME',
                                                            x_dummy_mkr
                                                           ),
                             'PAYMENT_TERMS_ID'
                            );
      END IF;
      -- Bug 6434823, Bug 6603681, Bug 7651399
      asn_debug.put_line('checking for rhi vendor fields');
      If (rhi.receipt_source_code = 'VENDOR' and rhi.vendor_id IS NULL AND rhi.vendor_name IS NULL AND rhi.vendor_num IS NULL) Then
          rcv_error_pkg.set_error_message('RCV_VENDOR_ALL_NULL');
          rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE',
                                            'VENDOR_ID',
                                            g_curr_group_id,
                                            g_curr_header_id,
                                            g_curr_transaction_id);

      Else
          IF (rhi.vendor_id IS NULL) THEN
             rhi.vendor_id  := get_vendor_id_from_name(rhi.vendor_name,
                                                       'VENDOR_NAME',
                                                       x_dummy_mkr
                                                      );
          ELSIF(rhi.vendor_id <> get_vendor_id_from_name(rhi.vendor_name,
                                                         'VENDOR_NAME',
                                                         x_dummy_mkr
                                                        )) THEN
             invalid_match_value(rhi.vendor_id,
                                 get_vendor_id_from_name(rhi.vendor_name,
                                                         'VENDOR_NAME',
                                                         x_dummy_mkr
                                                        ),
                                 'VENDOR_ID'
                                );
          END IF;

          IF (rhi.vendor_id IS NULL) THEN
             rhi.vendor_id  := get_vendor_id_from_num(rhi.vendor_num,
                                                      'VENDOR_NUM',
                                                      x_dummy_mkr
                                                     );
          ELSIF(rhi.vendor_id <> get_vendor_id_from_num(rhi.vendor_num,
                                                        'VENDOR_NUM',
                                                        x_dummy_mkr
                                                       )) THEN
             invalid_match_value(rhi.vendor_id,
                                 get_vendor_id_from_num(rhi.vendor_num,
                                                        'VENDOR_NUM',
                                                        x_dummy_mkr
                                                       ),
                                 'VENDOR_ID'
                                );
          END IF;
      END IF;

      IF (rhi.vendor_site_id IS NULL) THEN
         rhi.vendor_site_id  := get_vendor_site_id_from_code(rhi.vendor_site_code,
                                                             rhi.vendor_id,
                                                             rhi.org_id,
                                                             'VENDOR_SITE_CODE',
                                                             g_rhi_vendor_site_code_mkr
                                                            );
      ELSIF(rhi.vendor_site_id <> get_vendor_site_id_from_code(rhi.vendor_site_code,
                                                               rhi.vendor_id,
                                                               rhi.org_id,
                                                               'VENDOR_SITE_CODE',
                                                               g_rhi_vendor_site_code_mkr
                                                              )) THEN
         invalid_match_value(rhi.vendor_site_id,
                             get_vendor_site_id_from_code(rhi.vendor_site_code,
                                                          rhi.vendor_id,
                                                          rhi.org_id,
                                                          'VENDOR_SITE_CODE',
                                                          g_rhi_vendor_site_code_mkr
                                                         ),
                             'VENDOR_SITE_ID'
                            );
      END IF;

      IF (rhi.ship_from_location_id IS NULL) THEN
         rhi.ship_from_location_id  := get_sfloc_id_from_code(rhi.ship_from_location_code,
                                                              rhi.vendor_site_id,
                                                              'SHIP_FROM_LOCATION_CODE',
                                                              x_dummy_mkr
                                                             );
	/* Bug 4590642.
	 * Use rhi.vendor_site_id instead of rhi.vendor_id.
	*/
      ELSIF(rhi.ship_from_location_id <> get_sfloc_id_from_code(rhi.ship_from_location_code,
                                                                rhi.vendor_site_id,
                                                                'SHIP_FROM_LOCATION_CODE',
                                                                x_dummy_mkr
                                                               )) THEN
         invalid_match_value(rhi.ship_from_location_id,
				/* Bug 4590642.
				 * we should not call with rhi.org_id.
				 * Also use rhi.vendor_site_id instead
				 * of rhi.venor_id.
				*/
                             get_sfloc_id_from_code(rhi.ship_from_location_code,
                                                    rhi.vendor_site_id,
                                                   -- rhi.org_id,
                                                    'SHIP_FROM_LOCATION_CODE',
                                                    x_dummy_mkr
                                                   ),
                             'SHIP_FROM_LOCATION_ID'
                            );
      END IF;
   END default_rhi_from_code;

   PROCEDURE check_rhi_consistency(
      rhi IN OUT NOCOPY rcv_headers_interface%ROWTYPE
   ) IS
      x_dummy_mkr BOOLEAN;
   BEGIN
      IF (g_rhi_ou_mkr = TRUE) THEN
         IF (rhi.operating_unit IS NULL) THEN
            rhi.operating_unit  := get_ou_from_org_id(rhi.org_id,
                                                      'ORG_ID',
                                                      x_dummy_mkr
                                                     );
         ELSIF(rhi.operating_unit <> get_ou_from_org_id(rhi.org_id,
                                                        'ORG_ID',
                                                        x_dummy_mkr
                                                       )) THEN
            invalid_match_value(rhi.operating_unit,
                                get_ou_from_org_id(rhi.org_id,
                                                   'ORG_ID',
                                                   x_dummy_mkr
                                                  ),
                                'OPERATING_UNIT'
                               );
         END IF;
      END IF;

      IF (g_rhi_cust_party_name_mkr = TRUE) THEN
         IF (rhi.customer_party_name IS NULL) THEN
            rhi.customer_party_name  := get_customer_name_from_id(rhi.customer_id,
                                                                  'CUSTOMER_ID',
                                                                  x_dummy_mkr
                                                                 );
         ELSIF(rhi.customer_party_name <> get_customer_name_from_id(rhi.customer_id,
                                                                    'CUSTOMER_ID',
                                                                    x_dummy_mkr
                                                                   )) THEN
            invalid_match_value(rhi.customer_party_name,
                                get_customer_name_from_id(rhi.customer_id,
                                                          'CUSTOMER_ID',
                                                          x_dummy_mkr
                                                         ),
                                'CUSTOMER_PARTY_NAME'
                               );
         END IF;
      END IF;

      IF (g_rhi_cust_acc_num_mkr = TRUE) THEN
         IF (rhi.customer_account_number IS NULL) THEN
            rhi.customer_account_number  := get_customer_num_from_id(rhi.customer_id,
                                                                     'CUSTOMER_ID',
                                                                     x_dummy_mkr
                                                                    );
         ELSIF(rhi.customer_account_number <> get_customer_num_from_id(rhi.customer_id,
                                                                       'CUSTOMER_ID',
                                                                       x_dummy_mkr
                                                                      )) THEN
            invalid_match_value(rhi.customer_account_number,
                                get_customer_num_from_id(rhi.customer_id,
                                                         'CUSTOMER_ID',
                                                         x_dummy_mkr
                                                        ),
                                'CUSTOMER_ACCOUNT_NUMBER'
                               );
         END IF;
      END IF;

      IF (g_rhi_employee_name_mkr = TRUE) THEN
         IF (rhi.employee_name IS NULL) THEN
            rhi.employee_name  := get_employee_name_from_id(rhi.employee_id,
                                                            'EMPLOYEE_ID',
                                                            x_dummy_mkr
                                                           );
         ELSIF(rhi.employee_name <> get_employee_name_from_id(rhi.employee_id,
                                                              'EMPLOYEE_ID',
                                                              x_dummy_mkr
                                                             )) THEN
            invalid_match_value(rhi.employee_name,
                                get_employee_name_from_id(rhi.employee_id,
                                                          'EMPLOYEE_ID',
                                                          x_dummy_mkr
                                                         ),
                                'EMPLOYEE_NAME'
                               );
         END IF;
      END IF;

      IF (g_rhi_vendor_site_code_mkr = TRUE) THEN
         IF (rhi.vendor_site_code IS NULL) THEN
            rhi.vendor_site_code  := get_vendor_site_code_from_id(rhi.vendor_site_id,
                                                                  rhi.vendor_id,
                                                                  rhi.org_id,
                                                                  'VENDOR_SITE_ID',
                                                                  x_dummy_mkr
                                                                 );
         ELSIF(rhi.vendor_site_code <> get_vendor_site_code_from_id(rhi.vendor_site_id,
                                                                    rhi.vendor_id,
                                                                    rhi.org_id,
                                                                    'VENDOR_SITE_ID',
                                                                    x_dummy_mkr
                                                                   )) THEN
            invalid_match_value(rhi.vendor_site_code,
                                get_vendor_site_code_from_id(rhi.vendor_site_id,
                                                             rhi.vendor_id,
                                                             rhi.org_id,
                                                             'VENDOR_SITE_ID',
                                                             x_dummy_mkr
                                                            ),
                                'VENDOR_SITE_CODE'
                               );
         END IF;
      END IF;
   END check_rhi_consistency;

   PROCEDURE default_rti_from_code(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      x_dummy_mkr BOOLEAN;
   BEGIN
      IF (rti.customer_id IS NULL) THEN
         rti.customer_id  := get_customer_id_from_name_num(rti.customer_party_name,
                                                           rti.customer_account_number,
                                                           'CUSTOMER_PARTY_NAME',
                                                           'CUSTOMER_ACCOUNT_NUMBER',
                                                           g_rti_cust_party_name_mkr,
                                                           g_rti_cust_acc_num_mkr
                                                          );
      ELSIF(rti.customer_id <> get_customer_id_from_name_num(rti.customer_party_name,
                                                             rti.customer_account_number,
                                                             'CUSTOMER_PARTY_NAME',
                                                             'CUSTOMER_ACCOUNT_NUMBER',
                                                             g_rti_cust_party_name_mkr,
                                                             g_rti_cust_acc_num_mkr
                                                            )) THEN
         invalid_match_value(rti.customer_id,
                             get_customer_id_from_name_num(rti.customer_party_name,
                                                           rti.customer_account_number,
                                                           'CUSTOMER_PARTY_NAME',
                                                           'CUSTOMER_ACCOUNT_NUMBER',
                                                           g_rti_cust_party_name_mkr,
                                                           g_rti_cust_acc_num_mkr
                                                          ),
                             'CUSTOMER_ID'
                            );
      END IF;

      IF (rti.customer_item_id IS NULL) THEN
         rti.customer_item_id  := get_customer_item_id_from_num(rti.customer_item_num,
                                                                rti.customer_id,
                                                                'CUSTOMER_ITEM_NUM',
                                                                g_rti_cust_item_num_mkr
                                                               );
      ELSIF(rti.customer_item_id <> get_customer_item_id_from_num(rti.customer_item_num,
                                                                  rti.customer_id,
                                                                  'CUSTOMER_ITEM_NUM',
                                                                  g_rti_cust_item_num_mkr
                                                                 )) THEN
         invalid_match_value(rti.customer_item_id,
                             get_customer_item_id_from_num(rti.customer_item_num,
                                                           rti.customer_id,
                                                           'CUSTOMER_ITEM_NUM',
                                                           g_rti_cust_item_num_mkr
                                                          ),
                             'CUSTOMER_ITEM_ID'
                            );
      END IF;

      IF (rti.deliver_to_location_id IS NULL) THEN
         rti.deliver_to_location_id  := get_location_id_from_code(rti.deliver_to_location_code,
                                                                  'DELIVER_TO_LOCATION_CODE',
                                                                  x_dummy_mkr
                                                                 );
      ELSIF(rti.deliver_to_location_id <> get_location_id_from_code(rti.deliver_to_location_code,
                                                                    'DELIVER_TO_LOCATION_CODE',
                                                                    x_dummy_mkr
                                                                   )) THEN
         invalid_match_value(rti.deliver_to_location_id,
                             get_location_id_from_code(rti.deliver_to_location_code,
                                                       'DELIVER_TO_LOCATION_CODE',
                                                       x_dummy_mkr
                                                      ),
                             'DELIVER_TO_LOCATION_ID'
                            );
      END IF;

      IF (rti.location_id IS NULL) THEN
         rti.location_id  := get_location_id_from_code(rti.location_code,
                                                       'LOCATION_CODE',
                                                       x_dummy_mkr
                                                      );
      ELSIF(rti.location_id <> get_location_id_from_code(rti.location_code,
                                                         'LOCATION_CODE',
                                                         x_dummy_mkr
                                                        )) THEN
         invalid_match_value(rti.location_id,
                             get_location_id_from_code(rti.location_code,
                                                       'LOCATION_CODE',
                                                       x_dummy_mkr
                                                      ),
                             'LOCATION_ID'
                            );
      END IF;

      IF (rti.ship_to_location_id IS NULL) THEN
         rti.ship_to_location_id  := get_location_id_from_code(rti.ship_to_location_code,
                                                               'SHIP_TO_LOCATION_CODE',
                                                               x_dummy_mkr
                                                              );
      ELSIF(rti.ship_to_location_id <> get_location_id_from_code(rti.ship_to_location_code,
                                                                 'SHIP_TO_LOCATION_CODE',
                                                                 x_dummy_mkr
                                                                )) THEN
         invalid_match_value(rti.ship_to_location_id,
                             get_location_id_from_code(rti.ship_to_location_code,
                                                       'SHIP_TO_LOCATION_CODE',
                                                       x_dummy_mkr
                                                      ),
                             'SHIP_TO_LOCATION_ID'
                            );
      END IF;

      IF (rti.deliver_to_person_id IS NULL) THEN
         rti.deliver_to_person_id  := get_employee_id_from_name(rti.deliver_to_person_name,
                                                                'DELIVER_TO_PERSON_NAME',
                                                                g_rti_dlvr_to_prsn_name_mkr
                                                               );
      ELSIF(rti.deliver_to_person_id <> get_employee_id_from_name(rti.deliver_to_person_name,
                                                                  'DELIVER_TO_PERSON_NAME',
                                                                  g_rti_dlvr_to_prsn_name_mkr
                                                                 )) THEN
         invalid_match_value(rti.deliver_to_person_id,
                             get_employee_id_from_name(rti.deliver_to_person_name,
                                                       'DELIVER_TO_PERSON_NAME',
                                                       g_rti_dlvr_to_prsn_name_mkr
                                                      ),
                             'DELIVER_TO_PERSON_ID'
                            );
      END IF;

      IF (rti.from_organization_id IS NULL) THEN
         rti.from_organization_id  := get_org_id_from_code(rti.from_organization_code,
                                                           'FROM_ORGANIZATION_CODE',
                                                           x_dummy_mkr
                                                          );
      ELSIF(rti.from_organization_id <> get_org_id_from_code(rti.from_organization_code,
                                                             'FROM_ORGANIZATION_CODE',
                                                             x_dummy_mkr
                                                            )) THEN
         invalid_match_value(rti.from_organization_id,
                             get_org_id_from_code(rti.from_organization_code,
                                                  'FROM_ORGANIZATION_CODE',
                                                  x_dummy_mkr
                                                 ),
                             'FROM_ORGANIZATION_ID'
                            );
      END IF;

      IF (rti.intransit_owning_org_id IS NULL) THEN
         rti.intransit_owning_org_id  := get_org_id_from_code(rti.intransit_owning_org_code,
                                                              'INTRANSIT_OWNING_ORG_CODE',
                                                              x_dummy_mkr
                                                             );
      ELSIF(rti.intransit_owning_org_id <> get_org_id_from_code(rti.intransit_owning_org_code,
                                                                'INTRANSIT_OWNING_ORG_CODE',
                                                                x_dummy_mkr
                                                               )) THEN
         invalid_match_value(rti.intransit_owning_org_id,
                             get_org_id_from_code(rti.intransit_owning_org_code,
                                                  'INTRANSIT_OWNING_ORG_CODE',
                                                  x_dummy_mkr
                                                 ),
                             'INTRANSIT_OWNING_ORG_ID'
                            );
      END IF;

      IF (rti.org_id IS NULL) THEN
         rti.org_id  := get_org_id_from_ou(rti.operating_unit,
                                           'OPERATING_UNIT',
                                           g_rti_ou_mkr
                                          );
      ELSIF(rti.org_id <> get_org_id_from_ou(rti.operating_unit,
                                             'OPERATING_UNIT',
                                             g_rti_ou_mkr
                                            )) THEN
         invalid_match_value(rti.org_id,
                             get_org_id_from_ou(rti.operating_unit,
                                                'OPERATING_UNIT',
                                                g_rti_ou_mkr
                                               ),
                             'ORG_ID'
                            );
      END IF;

      IF (rti.to_organization_id IS NULL) THEN
         rti.to_organization_id  := get_org_id_from_code(rti.to_organization_code,
                                                         'TO_ORGANIZATION_CODE',
                                                         x_dummy_mkr
                                                        );
      ELSIF(rti.to_organization_id <> get_org_id_from_code(rti.to_organization_code,
                                                           'TO_ORGANIZATION_CODE',
                                                           x_dummy_mkr
                                                          )) THEN
         invalid_match_value(rti.to_organization_id,
                             get_org_id_from_code(rti.to_organization_code,
                                                  'TO_ORGANIZATION_CODE',
                                                  x_dummy_mkr
                                                 ),
                             'TO_ORGANIZATION_ID'
                            );
      END IF;

      --Bug 7591174 Added a call to get the organization_id from ship_to_location_id
      IF (rti.to_organization_id IS NULL) THEN
         rti.to_organization_id  := get_org_id_from_location_id(rti.ship_to_location_id,
                                                         'SHIP_TO_LOCATION_ID',
                                                         x_dummy_mkr
                                                        );
      END IF;
      /*
      ** Bug#4615534 - Org_id defaulting from inventory organization
      ** needs to be done only for In-transit shipments
      */
      IF(rti.receipt_source_code IN ('INVENTORY','INTERNAL ORDER')) THEN -- Bug 9706173
      /* With the TO_ORGANIZATION_ID we need to derive the org_id */
          IF (rti.org_id IS NULL) THEN
             rti.org_id  := get_org_id_from_inv_org_id(rti.to_organization_id);
          END IF;
      END IF;

      IF (rti.vendor_id IS NULL) THEN
         rti.vendor_id  := get_vendor_id_from_name(rti.vendor_name,
                                                   'VENDOR_NAME',
                                                   x_dummy_mkr
                                                  );
      ELSIF(rti.vendor_id <> get_vendor_id_from_name(rti.vendor_name,
                                                     'VENDOR_NAME',
                                                     x_dummy_mkr
                                                    )) THEN
         invalid_match_value(rti.vendor_id,
                             get_vendor_id_from_name(rti.vendor_name,
                                                     'VENDOR_NAME',
                                                     x_dummy_mkr
                                                    ),
                             'VENDOR_ID'
                            );
      END IF;

      IF (rti.vendor_id IS NULL) THEN
         rti.vendor_id  := get_vendor_id_from_num(rti.vendor_num,
                                                  'VENDOR_NUM',
                                                  x_dummy_mkr
                                                 );
      ELSIF(rti.vendor_id <> get_vendor_id_from_num(rti.vendor_num,
                                                    'VENDOR_NUM',
                                                    x_dummy_mkr
                                                   )) THEN
         invalid_match_value(rti.vendor_id,
                             get_vendor_id_from_num(rti.vendor_num,
                                                    'VENDOR_NUM',
                                                    x_dummy_mkr
                                                   ),
                             'VENDOR_ID'
                            );
      END IF;

      IF (rti.vendor_site_id IS NULL) THEN
         rti.vendor_site_id  := get_vendor_site_id_from_code(rti.vendor_site_code,
                                                             rti.vendor_id,
                                                             rti.org_id,
                                                             'VENDOR_SITE_CODE',
                                                             g_rti_vendor_site_code_mkr
                                                            );
      ELSIF(rti.vendor_site_id <> get_vendor_site_id_from_code(rti.vendor_site_code,
                                                               rti.vendor_id,
                                                               rti.org_id,
                                                               'VENDOR_SITE_CODE',
                                                               g_rti_vendor_site_code_mkr
                                                              )) THEN
         invalid_match_value(rti.vendor_site_id,
                             get_vendor_site_id_from_code(rti.vendor_site_code,
                                                          rti.vendor_id,
                                                          rti.org_id,
                                                          'VENDOR_SITE_CODE',
                                                          g_rti_vendor_site_code_mkr
                                                         ),
                             'VENDOR_SITE_ID'
                            );
      END IF;

      IF (rti.uom_code IS NULL) THEN
         rti.uom_code  := get_uom_code_from_measure(rti.unit_of_measure,
                                                    'UNIT_OF_MEASURE',
                                                    x_dummy_mkr
                                                   );
      ELSIF(rti.uom_code <> get_uom_code_from_measure(rti.unit_of_measure,
                                                      'UNIT_OF_MEASURE',
                                                      x_dummy_mkr
                                                     )) THEN
         invalid_match_value(rti.uom_code,
                             get_uom_code_from_measure(rti.unit_of_measure,
                                                       'UNIT_OF_MEASURE',
                                                       x_dummy_mkr
                                                      ),
                             'UOM_CODE'
                            );
      END IF;

      IF (rti.unit_of_measure IS NULL) THEN
         rti.unit_of_measure  := get_uom_measure_from_code(rti.uom_code,
                                                           'UOM_CODE',
                                                           x_dummy_mkr
                                                          );
      ELSIF(rti.unit_of_measure <> get_uom_measure_from_code(rti.uom_code,
                                                             'UOM_CODE',
                                                             x_dummy_mkr
                                                            )) THEN
         invalid_match_value(rti.unit_of_measure,
                             get_uom_measure_from_code(rti.uom_code,
                                                       'UOM_CODE',
                                                       x_dummy_mkr
                                                      ),
                             'UNIT_OF_MEASURE'
                            );
      END IF;

      IF (rti.secondary_uom_code IS NULL) THEN
         rti.secondary_uom_code  := get_uom_code_from_measure(rti.secondary_unit_of_measure,
                                                              'SECONDARY_UNIT_OF_MEASURE',
                                                              x_dummy_mkr
                                                             );
      ELSIF(rti.secondary_uom_code <> get_uom_code_from_measure(rti.secondary_unit_of_measure,
                                                                'SECONDARY_UNIT_OF_MEASURE',
                                                                x_dummy_mkr
                                                               )) THEN
         invalid_match_value(rti.secondary_uom_code,
                             get_uom_code_from_measure(rti.secondary_unit_of_measure,
                                                       'SECONDARY_UNIT_OF_MEASURE',
                                                       x_dummy_mkr
                                                      ),
                             'SECONDARY_UOM_CODE'
                            );
      END IF;

      IF (rti.secondary_unit_of_measure IS NULL) THEN
         rti.secondary_unit_of_measure  := get_uom_measure_from_code(rti.secondary_uom_code,
                                                                     'SECONDARY_UOM_CODE',
                                                                     x_dummy_mkr
                                                                    );
      ELSIF(rti.secondary_unit_of_measure <> get_uom_measure_from_code(rti.secondary_uom_code,
                                                                       'SECONDARY_UOM_CODE',
                                                                       x_dummy_mkr
                                                                      )) THEN
         invalid_match_value(rti.secondary_unit_of_measure,
                             get_uom_measure_from_code(rti.secondary_uom_code,
                                                       'SECONDARY_UOM_CODE',
                                                       x_dummy_mkr
                                                      ),
                             'SECONDARY_UNIT_OF_MEASURE'
                            );
      END IF;

      IF (rti.locator_id IS NULL) THEN
         rti.locator_id  := get_locator_id_from_locator(rti.LOCATOR,
                                                        rti.to_organization_id,
                                                        rti.subinventory,
                                                        'LOCATOR',
                                                        g_rti_locator_mkr
                                                       );
      ELSIF(rti.locator_id <> get_locator_id_from_locator(rti.LOCATOR,
                                                          rti.to_organization_id,
                                                          rti.subinventory,
                                                          'LOCATOR',
                                                          g_rti_locator_mkr
                                                         )) THEN
         invalid_match_value(rti.locator_id,
                             get_locator_id_from_locator(rti.LOCATOR,
                                                         rti.to_organization_id,
                                                         rti.subinventory,
                                                         'LOCATOR',
                                                         g_rti_locator_mkr
                                                        ),
                             'LOCATOR_ID'
                            );
      END IF;

      IF (rti.routing_header_id IS NULL) THEN
         rti.routing_header_id  := get_rtng_header_id_from_code(rti.routing_code,
                                                                'ROUTING_CODE',
                                                                x_dummy_mkr
                                                               );
      ELSIF(rti.routing_header_id <> get_rtng_header_id_from_code(rti.routing_code,
                                                                  'ROUTING_CODE',
                                                                  x_dummy_mkr
                                                                 )) THEN
         invalid_match_value(rti.routing_header_id,
                             get_rtng_header_id_from_code(rti.routing_code,
                                                          'ROUTING_CODE',
                                                          x_dummy_mkr
                                                         ),
                             'ROUTING_HEADER_ID'
                            );
      END IF;

      IF (rti.routing_step_id IS NULL) THEN
         rti.routing_step_id  := get_rtng_step_id_from_code(rti.routing_step,
                                                            'ROUTING_STEP',
                                                            x_dummy_mkr
                                                           );
      ELSIF(rti.routing_step_id <> get_rtng_step_id_from_code(rti.routing_step,
                                                              'ROUTING_STEP',
                                                              x_dummy_mkr
                                                             )) THEN
         invalid_match_value(rti.routing_step_id,
                             get_rtng_step_id_from_code(rti.routing_step,
                                                        'ROUTING_STEP',
                                                        x_dummy_mkr
                                                       ),
                             'ROUTING_STEP_ID'
                            );
      END IF;

      IF (rti.wip_entity_id IS NULL) THEN
         rti.wip_entity_id  := get_wip_entity_id_from_name(rti.wip_entity_name,
                                                           rti.to_organization_id,
                                                           'WIP_ENTITY_NAME',
                                                           g_rti_wip_entity_name_mkr
                                                          );
      ELSIF(rti.wip_entity_id <> get_wip_entity_id_from_name(rti.wip_entity_name,
                                                             rti.to_organization_id,
                                                             'WIP_ENTITY_NAME',
                                                             g_rti_wip_entity_name_mkr
                                                            )) THEN
         invalid_match_value(rti.wip_entity_id,
                             get_wip_entity_id_from_name(rti.wip_entity_name,
                                                         rti.to_organization_id,
                                                         'WIP_ENTITY_NAME',
                                                         g_rti_wip_entity_name_mkr
                                                        ),
                             'WIP_ENTITY_ID'
                            );
      END IF;

/*  Bug fix 5383556 : commenting this code as Item ID should not be derived from Item Description, since
     A. It is possible that more than one item have the same description.
     B. An One Time Item's description could match a description of a defined Item.

      IF (rti.item_id IS NULL) THEN
         rti.item_id  := get_item_id_from_description(rti.item_description,
                                                      rti.to_organization_id,
                                                      'ITEM_DESCRIPTION',
                                                      g_rti_item_description_mkr
                                                     );
      ELSIF(rti.item_id <> get_item_id_from_description(rti.item_description,
                                                        rti.to_organization_id,
                                                        'ITEM_DESCRIPTION',
                                                        g_rti_item_description_mkr
                                                       )) THEN
         invalid_match_value(rti.item_id,
                             get_item_id_from_description(rti.item_description,
                                                          rti.to_organization_id,
                                                          'ITEM_DESCRIPTION',
                                                          g_rti_item_description_mkr
                                                         ),
                             'ITEM_ID'
                            );
      END IF;
*/
      IF (rti.item_id IS NULL) THEN
         rti.item_id  := get_item_id_from_num(rti.item_num,
                                              rti.to_organization_id,
                                              'ITEM_NUM',
                                              g_rti_item_num_mkr
                                             );
      ELSIF(rti.item_id <> get_item_id_from_num(rti.item_num,
                                                rti.to_organization_id,
                                                'ITEM_NUM',
                                                g_rti_item_num_mkr
                                               )) THEN
         invalid_match_value(rti.item_id,
                             get_item_id_from_num(rti.item_num,
                                                  rti.to_organization_id,
                                                  'ITEM_NUM',
                                                  g_rti_item_num_mkr
                                                 ),
                             'ITEM_ID'
                            );
      END IF;
      /**  Bug 5516651: Bypassed the item description validation.
       *   Reason:
       *     When creating PO we can change the item description and while
       *     receiving RTI record is populated with the item description
       *     mentioned in the PO.
       *     if we validate the RTI.item description with the item description got
       *     from master item table, validation will fail.
       *     So, bypassing the item description validation
       */
      IF (rti.item_description IS NULL) THEN
         rti.item_description  := get_item_description_from_id(rti.item_id,
                                                               rti.to_organization_id,
                                                               'ITEM_ID',
                                                               x_dummy_mkr
                                                              );
/*      ELSIF(rti.item_description <> get_item_description_from_id(rti.item_id,
                                                                 rti.to_organization_id,
                                                                 'ITEM_ID',
                                                                 x_dummy_mkr
                                                                )) THEN
         invalid_match_value(rti.item_description,
                             get_item_description_from_id(rti.item_id,
                                                          rti.to_organization_id,
                                                          'ITEM_ID',
                                                          x_dummy_mkr
                                                         ),
                             'ITEM_DESCRIPTION'
                            );*/ --Bug 5516651
      END IF;

      IF (rti.item_num IS NULL) THEN
         rti.item_num  := get_item_num_from_id(rti.item_id,
                                               rti.to_organization_id,
                                               'ITEM_ID',
                                               x_dummy_mkr
                                              );
      ELSIF(rti.item_num <> get_item_num_from_id(rti.item_id,
                                                 rti.to_organization_id,
                                                 'ITEM_ID',
                                                 x_dummy_mkr
                                                )) THEN
         invalid_match_value(rti.item_num,
                             get_item_num_from_id(rti.item_id,
                                                  rti.to_organization_id,
                                                  'ITEM_ID',
                                                  x_dummy_mkr
                                                 ),
                             'ITEM_NUM'
                            );
      END IF;

      IF (rti.substitute_item_id IS NULL) THEN
         rti.substitute_item_id  := get_item_id_from_num(rti.substitute_item_num,
                                                         rti.to_organization_id,
                                                         'SUBSTITUTE_ITEM_NUM',
                                                         g_rti_sub_item_num_mkr
                                                        );
      ELSIF(rti.substitute_item_id <> get_item_id_from_num(rti.substitute_item_num,
                                                           rti.to_organization_id,
                                                           'SUBSTITUTE_ITEM_NUM',
                                                           g_rti_sub_item_num_mkr
                                                          )) THEN
         invalid_match_value(rti.substitute_item_id,
                             get_item_id_from_num(rti.substitute_item_num,
                                                  rti.to_organization_id,
                                                  'SUBSTITUTE_ITEM_NUM',
                                                  g_rti_sub_item_num_mkr
                                                 ),
                             'SUBSTITUTE_ITEM_ID'
                            );
      END IF;

      IF (rti.substitute_item_num IS NULL) THEN
         rti.substitute_item_num  := get_item_num_from_id(rti.substitute_item_id,
                                                          rti.to_organization_id,
                                                          'SUBSTITUTE_ITEM_ID',
                                                          x_dummy_mkr
                                                         );
      ELSIF(rti.substitute_item_num <> get_item_num_from_id(rti.substitute_item_id,
                                                            rti.to_organization_id,
                                                            'SUBSTITUTE_ITEM_ID',
                                                            x_dummy_mkr
                                                           )) THEN
         invalid_match_value(rti.substitute_item_num,
                             get_item_num_from_id(rti.substitute_item_id,
                                                  rti.to_organization_id,
                                                  'SUBSTITUTE_ITEM_ID',
                                                  x_dummy_mkr
                                                 ),
                             'SUBSTITUTE_ITEM_NUM'
                            );
      END IF;
   /* Not processing TRANSFER_LICENSE_PLATE_NUMBER or WIP_LINE_CODE*/
   END default_rti_from_code;

   PROCEDURE check_rti_consistency(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      x_dummy_mkr BOOLEAN;
   BEGIN
      IF (g_rti_ou_mkr = TRUE) THEN
         IF (rti.operating_unit IS NULL) THEN
            rti.operating_unit  := get_ou_from_org_id(rti.org_id,
                                                      'ORG_ID',
                                                      x_dummy_mkr
                                                     );
         ELSIF(rti.operating_unit <> get_ou_from_org_id(rti.org_id,
                                                        'ORG_ID',
                                                        x_dummy_mkr
                                                       )) THEN
            invalid_match_value(rti.operating_unit,
                                get_ou_from_org_id(rti.org_id,
                                                   'ORG_ID',
                                                   x_dummy_mkr
                                                  ),
                                'OPERATING_UNIT'
                               );
         END IF;
      END IF;

      IF (g_rti_cust_party_name_mkr = TRUE) THEN
         IF (rti.customer_party_name IS NULL) THEN
            rti.customer_party_name  := get_customer_name_from_id(rti.customer_id,
                                                                  'CUSTOMER_ID',
                                                                  x_dummy_mkr
                                                                 );
         ELSIF(rti.customer_party_name <> get_customer_name_from_id(rti.customer_id,
                                                                    'CUSTOMER_ID',
                                                                    x_dummy_mkr
                                                                   )) THEN
            invalid_match_value(rti.customer_party_name,
                                get_customer_name_from_id(rti.customer_id,
                                                          'CUSTOMER_ID',
                                                          x_dummy_mkr
                                                         ),
                                'CUSTOMER_PARTY_NAME'
                               );
         END IF;
      END IF;

      IF (g_rti_cust_acc_num_mkr = TRUE) THEN
         IF (rti.customer_account_number IS NULL) THEN
            rti.customer_account_number  := get_customer_num_from_id(rti.customer_id,
                                                                     'CUSTOMER_ID',
                                                                     x_dummy_mkr
                                                                    );
         ELSIF(rti.customer_account_number <> get_customer_num_from_id(rti.customer_id,
                                                                       'CUSTOMER_ID',
                                                                       x_dummy_mkr
                                                                      )) THEN
            invalid_match_value(rti.customer_account_number,
                                get_customer_num_from_id(rti.customer_id,
                                                         'CUSTOMER_ID',
                                                         x_dummy_mkr
                                                        ),
                                'CUSTOMER_ACCOUNT_NUMBER'
                               );
         END IF;
      END IF;

      IF (g_rti_cust_item_num_mkr = TRUE) THEN
         IF (rti.customer_item_num IS NULL) THEN
            rti.customer_item_num  := get_customer_item_num_from_id(rti.customer_item_id,
                                                                    'CUSTOMER_ITEM_ID',
                                                                    x_dummy_mkr
                                                                   );
         ELSIF(rti.customer_item_num <> get_customer_item_num_from_id(rti.customer_item_id,
                                                                      'CUSTOMER_ITEM_ID',
                                                                      x_dummy_mkr
                                                                     )) THEN
            invalid_match_value(rti.customer_item_num,
                                get_customer_item_num_from_id(rti.customer_item_id,
                                                              'CUSTOMER_ITEM_ID',
                                                              x_dummy_mkr
                                                             ),
                                'CUSTOMER_ITEM_NUM'
                               );
         END IF;
      END IF;

      IF (g_rti_employee_name_mkr = TRUE) THEN
         IF (rti.deliver_to_person_name IS NULL) THEN
            rti.deliver_to_person_name  := get_employee_name_from_id(rti.deliver_to_person_id,
                                                                     'DELIVER_TO_PERSON_ID',
                                                                     x_dummy_mkr
                                                                    );
         ELSIF(rti.deliver_to_person_name <> get_employee_name_from_id(rti.deliver_to_person_id,
                                                                       'DELIVER_TO_PERSON_ID',
                                                                       x_dummy_mkr
                                                                      )) THEN
            invalid_match_value(rti.deliver_to_person_name,
                                get_employee_name_from_id(rti.deliver_to_person_id,
                                                          'DELIVER_TO_PERSON_ID',
                                                          x_dummy_mkr
                                                         ),
                                'DELIVER_TO_PERSON_NAME'
                               );
         END IF;
      END IF;

      IF (g_rti_dlvr_to_prsn_name_mkr = TRUE) THEN
         IF (rti.vendor_site_code IS NULL) THEN
            rti.vendor_site_code  := get_vendor_site_code_from_id(rti.vendor_site_id,
                                                                  rti.vendor_id,
                                                                  rti.org_id,
                                                                  'VENDOR_SITE_ID',
                                                                  x_dummy_mkr
                                                                 );
         ELSIF(rti.vendor_site_code <> get_vendor_site_code_from_id(rti.vendor_site_id,
                                                                    rti.vendor_id,
                                                                    rti.org_id,
                                                                    'VENDOR_SITE_ID',
                                                                    x_dummy_mkr
                                                                   )) THEN
            invalid_match_value(rti.vendor_site_code,
                                get_vendor_site_code_from_id(rti.vendor_site_id,
                                                             rti.vendor_id,
                                                             rti.org_id,
                                                             'VENDOR_SITE_ID',
                                                             x_dummy_mkr
                                                            ),
                                'VENDOR_SITE_CODE'
                               );
         END IF;
      END IF;

      IF (g_rti_vendor_site_code_mkr = TRUE) THEN
         IF (rti.vendor_site_code IS NULL) THEN
            rti.vendor_site_code  := get_vendor_site_code_from_id(rti.vendor_site_id,
                                                                  rti.vendor_id,
                                                                  rti.org_id,
                                                                  'VENDOR_SITE_ID',
                                                                  x_dummy_mkr
                                                                 );
         ELSIF(rti.vendor_site_code <> get_vendor_site_code_from_id(rti.vendor_site_id,
                                                                    rti.vendor_id,
                                                                    rti.org_id,
                                                                    'VENDOR_SITE_ID',
                                                                    x_dummy_mkr
                                                                   )) THEN
            invalid_match_value(rti.vendor_site_code,
                                get_vendor_site_code_from_id(rti.vendor_site_id,
                                                             rti.vendor_id,
                                                             rti.org_id,
                                                             'VENDOR_SITE_ID',
                                                             x_dummy_mkr
                                                            ),
                                'VENDOR_SITE_CODE'
                               );
         END IF;
      END IF;

      IF (g_rti_locator_mkr = TRUE) THEN
         IF (rti.LOCATOR IS NULL) THEN
            rti.LOCATOR  := get_locator_from_locator_id(rti.locator_id,
                                                        rti.to_organization_id,
                                                        rti.subinventory,
                                                        'LOCATOR_ID',
                                                        x_dummy_mkr
                                                       );
         ELSIF(rti.LOCATOR <> get_locator_from_locator_id(rti.locator_id,
                                                          rti.to_organization_id,
                                                          rti.subinventory,
                                                          'LOCATOR_ID',
                                                          x_dummy_mkr
                                                         )) THEN
            invalid_match_value(rti.LOCATOR,
                                get_locator_from_locator_id(rti.locator_id,
                                                            rti.to_organization_id,
                                                            rti.subinventory,
                                                            'LOCATOR_ID',
                                                            x_dummy_mkr
                                                           ),
                                'LOCATOR'
                               );
         END IF;
      END IF;

      IF (g_rti_wip_entity_name_mkr = TRUE) THEN
         IF (rti.wip_entity_name IS NULL) THEN
            rti.wip_entity_name  := get_wip_entity_name_from_id(rti.wip_entity_id,
                                                                rti.to_organization_id,
                                                                'WIP_ENTITY_ID',
                                                                x_dummy_mkr
                                                               );
         ELSIF(rti.wip_entity_name <> get_wip_entity_name_from_id(rti.wip_entity_id,
                                                                  rti.to_organization_id,
                                                                  'WIP_ENTITY_ID',
                                                                  x_dummy_mkr
                                                                 )) THEN
            invalid_match_value(rti.wip_entity_name,
                                get_wip_entity_name_from_id(rti.wip_entity_id,
                                                            rti.to_organization_id,
                                                            'WIP_ENTITY_ID',
                                                            x_dummy_mkr
                                                           ),
                                'WIP_ENTITY_NAME'
                               );
         END IF;
      END IF;

      IF (g_rti_item_description_mkr = TRUE) THEN
         IF (rti.item_description IS NULL) THEN
            rti.item_description  := get_item_description_from_id(rti.item_id,
                                                                  rti.to_organization_id,
                                                                  'ITEM_ID',
                                                                  x_dummy_mkr
                                                                 );
/*         ELSIF(rti.item_description <> get_item_description_from_id(rti.item_id,
                                                                    rti.to_organization_id,
                                                                    'ITEM_ID',
                                                                    x_dummy_mkr
                                                                   )) THEN
            invalid_match_value(rti.item_description,
                                get_item_description_from_id(rti.item_id,
                                                             rti.to_organization_id,
                                                             'ITEM_ID',
                                                             x_dummy_mkr
                                                            ),
                                'ITEM_DESCRIPTION'
                               );*/ --Bug 5516651
         END IF;
      END IF;

      IF (g_rti_item_num_mkr = TRUE) THEN
         IF (rti.item_num IS NULL) THEN
            rti.item_num  := get_item_num_from_id(rti.item_id,
                                                  rti.to_organization_id,
                                                  'ITEM_ID',
                                                  x_dummy_mkr
                                                 );
         ELSIF(rti.item_num <> get_item_num_from_id(rti.item_id,
                                                    rti.to_organization_id,
                                                    'ITEM_ID',
                                                    x_dummy_mkr
                                                   )) THEN
            invalid_match_value(rti.item_num,
                                get_item_num_from_id(rti.item_id,
                                                     rti.to_organization_id,
                                                     'ITEM_ID',
                                                     x_dummy_mkr
                                                    ),
                                'ITEM_NUM'
                               );
         END IF;
      END IF;

      IF (g_rti_sub_item_num_mkr = TRUE) THEN
         IF (rti.substitute_item_num IS NULL) THEN
            rti.substitute_item_num  := get_item_num_from_id(rti.substitute_item_id,
                                                             rti.to_organization_id,
                                                             'SUBSTITUTE_ITEM_ID',
                                                             x_dummy_mkr
                                                            );
         ELSIF(rti.substitute_item_num <> get_item_num_from_id(rti.substitute_item_id,
                                                               rti.to_organization_id,
                                                               'SUBSTITUTE_ITEM_ID',
                                                               x_dummy_mkr
                                                              )) THEN
            invalid_match_value(rti.substitute_item_num,
                                get_item_num_from_id(rti.substitute_item_id,
                                                     rti.to_organization_id,
                                                     'SUBSTITUTE_ITEM_ID',
                                                     x_dummy_mkr
                                                    ),
                                'SUBSTITUTE_ITEM_NUM'
                               );
         END IF;
      END IF;
   END check_rti_consistency;

/****************************************/
/* SECTION 4: default from backing docs */
/****************************************/
   PROCEDURE default_rhi_from_rsh(
      rhi IN OUT NOCOPY rcv_headers_interface%ROWTYPE
   ) IS
      rsh rcv_shipment_headers%ROWTYPE;
   BEGIN
      IF (rhi.receipt_header_id IS NOT NULL) THEN
         rsh  := rcv_table_functions.get_rsh_row_from_id(rhi.receipt_header_id);
      ELSIF(rhi.shipment_num IS NOT NULL) THEN
         --Bug 9005670 Added receipt_source_code in the below procedre call.
         rsh  := rcv_table_functions.get_rsh_row_from_num(rhi.shipment_num,
                                                          rhi.vendor_id,
                                                          rhi.vendor_site_id,
                                                          rhi.ship_to_organization_id,
                                                          rhi.shipped_date,
                                                          rhi.receipt_source_code,
                                                          no_data_found_is_error    => FALSE
                                                         );
      --Add to receipt 17962808 begin
      ELSIF (rhi.transaction_type = 'ADD' AND rhi.receipt_num IS NOT NULL) THEN
        elapsed_time('get_rsh_row_from_receipt_num: ' || rhi.receipt_num);
        rsh := rcv_table_functions.get_rsh_row_from_receipt_num(rhi.receipt_num,
                                                                rhi.ship_to_organization_id,
                                                                no_data_found_is_error => FALSE
                                                                );
      --Add to receipt 17962808 end
      END IF;

      IF (rsh.shipment_header_id IS NULL) THEN
         RETURN;
      END IF;

      IF (rhi.from_organization_id IS NULL) THEN
         rhi.from_organization_id  := rsh.organization_id;
      ELSIF(rhi.from_organization_id <> rsh.organization_id) THEN
         invalid_match_value(rhi.from_organization_id,
                             rsh.organization_id,
                             'FROM_ORGANIZATION_ID'
                            );
      END IF;

      IF (rhi.receipt_header_id IS NULL) THEN
         rhi.receipt_header_id  := rsh.shipment_header_id;
      ELSIF(rhi.receipt_header_id <> rsh.shipment_header_id) THEN
         invalid_match_value(rhi.receipt_header_id,
                             rsh.shipment_header_id,
                             'RECEIPT_HEADER_ID'
                            );
      END IF;

      IF (rhi.receipt_num IS NULL) THEN
         rhi.receipt_num  := rsh.receipt_num;
      ELSIF(rhi.receipt_num <> rsh.receipt_num) THEN
         invalid_match_value(rhi.receipt_num,
                             rsh.receipt_num,
                             'RECEIPT_NUM'
                            );
      END IF;

      IF (rhi.ship_to_organization_id IS NULL) THEN
         rhi.ship_to_organization_id  := rsh.ship_to_org_id;
      ELSIF(rhi.ship_to_organization_id <> rsh.ship_to_org_id) THEN
         invalid_match_value(rhi.ship_to_organization_id,
                             rsh.ship_to_org_id,
                             'SHIP_TO_ORGANIZATION_ID'
                            );
      END IF;

      /*
      ** Bug#4615534 - Org_id defaulting from inventory organization
      ** needs to be done only for In-transit shipments
      */
      IF(rhi.receipt_source_code IN ('INVENTORY','INTERNAL ORDER')) THEN -- Bug 9706173
          IF (rhi.org_id IS NULL) THEN
             rhi.org_id  := get_org_id_from_inv_org_id(rsh.ship_to_org_id);
          END IF;
      END IF;

      IF (rhi.ship_from_location_id IS NULL) THEN
         rhi.ship_from_location_id  := rsh.ship_from_location_id;
      ELSIF(rhi.ship_from_location_id <> rsh.ship_from_location_id) THEN
         invalid_match_value(rhi.ship_from_location_id,
                             rsh.ship_from_location_id,
                             'SHIP_FROM_LOCATION_ID'
                            );
      END IF;

      IF (rhi.attribute1 IS NULL) THEN
         rhi.attribute1  := rsh.attribute1;
      END IF;

      IF (rhi.attribute10 IS NULL) THEN
         rhi.attribute10  := rsh.attribute10;
      END IF;

      IF (rhi.attribute11 IS NULL) THEN
         rhi.attribute11  := rsh.attribute11;
      END IF;

      IF (rhi.attribute12 IS NULL) THEN
         rhi.attribute12  := rsh.attribute12;
      END IF;

      IF (rhi.attribute13 IS NULL) THEN
         rhi.attribute13  := rsh.attribute13;
      END IF;

      IF (rhi.attribute14 IS NULL) THEN
         rhi.attribute14  := rsh.attribute14;
      END IF;

      IF (rhi.attribute15 IS NULL) THEN
         rhi.attribute15  := rsh.attribute15;
      END IF;

      IF (rhi.attribute2 IS NULL) THEN
         rhi.attribute2  := rsh.attribute2;
      END IF;

      IF (rhi.attribute3 IS NULL) THEN
         rhi.attribute3  := rsh.attribute3;
      END IF;

      IF (rhi.attribute4 IS NULL) THEN
         rhi.attribute4  := rsh.attribute4;
      END IF;

      IF (rhi.attribute5 IS NULL) THEN
         rhi.attribute5  := rsh.attribute5;
      END IF;

      IF (rhi.attribute6 IS NULL) THEN
         rhi.attribute6  := rsh.attribute6;
      END IF;

      IF (rhi.attribute7 IS NULL) THEN
         rhi.attribute7  := rsh.attribute7;
      END IF;

      IF (rhi.attribute8 IS NULL) THEN
         rhi.attribute8  := rsh.attribute8;
      END IF;

      IF (rhi.attribute9 IS NULL) THEN
         rhi.attribute9  := rsh.attribute9;
      END IF;

      IF (rhi.attribute_category IS NULL) THEN
         rhi.attribute_category  := rsh.attribute_category;
      END IF;

      IF (rhi.bill_of_lading IS NULL) THEN
         rhi.bill_of_lading  := rsh.bill_of_lading;
      END IF;

      IF (rhi.carrier_equipment IS NULL) THEN
         rhi.carrier_equipment  := rsh.carrier_equipment;
      END IF;

      IF (rhi.carrier_method IS NULL) THEN
         rhi.carrier_method  := rsh.carrier_method;
      END IF;

      IF (rhi.comments IS NULL) THEN
         rhi.comments  := rsh.comments;
      END IF;

      IF (rhi.conversion_rate IS NULL) THEN
         rhi.conversion_rate  := TO_NUMBER(rsh.conversion_rate);
      END IF;

      IF (rhi.conversion_rate_date IS NULL) THEN
         rhi.conversion_rate_date  := rsh.conversion_date;
      END IF;

      IF (rhi.conversion_rate_type IS NULL) THEN
         rhi.conversion_rate_type  := rsh.conversion_rate_type;
      END IF;

      IF (rhi.currency_code IS NULL) THEN
         rhi.currency_code  := rsh.currency_code;
      END IF;

      IF (rhi.customer_id IS NULL) THEN
         rhi.customer_id  := rsh.customer_id;
      --Add to receipt 17962808 begin;
      ELSIF(rhi.customer_id <> rsh.customer_id) THEN
         invalid_match_value(rhi.customer_id,
                          rsh.customer_id,
                          'customer_id');
      --Add to receipt 17962808 end;
      END IF;

      IF (rhi.customer_site_id IS NULL) THEN
         rhi.customer_site_id  := rsh.customer_site_id;
      END IF;

      IF (rhi.edi_control_num IS NULL) THEN
         rhi.edi_control_num  := rsh.edi_control_num;
      END IF;

      IF (rhi.employee_id IS NULL) THEN
         rhi.employee_id  := rsh.employee_id;
      END IF;

      IF (rhi.expected_receipt_date IS NULL) THEN
         rhi.expected_receipt_date  := rsh.expected_receipt_date;
      END IF;

      IF (rhi.freight_amount IS NULL) THEN
         rhi.freight_amount  := rsh.freight_amount;
      END IF;

      IF (rhi.freight_bill_number IS NULL) THEN
         rhi.freight_bill_number  := rsh.freight_bill_number;
      END IF;

      IF (rhi.freight_carrier_code IS NULL) THEN
         rhi.freight_carrier_code  := rsh.freight_carrier_code;
      END IF;

      IF (rhi.freight_terms IS NULL) THEN
         rhi.freight_terms  := rsh.freight_terms;
      END IF;

      IF (rhi.gross_weight IS NULL) THEN
         rhi.gross_weight  := rsh.gross_weight;
      END IF;

      IF (rhi.gross_weight_uom_code IS NULL) THEN
         rhi.gross_weight_uom_code  := rsh.gross_weight_uom_code;
      END IF;

      IF (rhi.hazard_class IS NULL) THEN
         rhi.hazard_class  := rsh.hazard_class;
      END IF;

      IF (rhi.hazard_code IS NULL) THEN
         rhi.hazard_code  := rsh.hazard_code;
      END IF;

      IF (rhi.hazard_description IS NULL) THEN
         rhi.hazard_description  := rsh.hazard_description;
      END IF;

      IF (rhi.invoice_date IS NULL) THEN
         rhi.invoice_date  := rsh.invoice_date;
      END IF;

      IF (rhi.invoice_num IS NULL) THEN
         rhi.invoice_num  := rsh.invoice_num;
      END IF;

      IF (rhi.invoice_status_code IS NULL) THEN
         rhi.invoice_status_code  := rsh.invoice_status_code;
      END IF;

      IF (rhi.location_id IS NULL) THEN
         rhi.location_id  := rsh.ship_to_location_id;
      END IF;

      IF (rhi.net_weight IS NULL) THEN
         rhi.net_weight  := rsh.net_weight;
      END IF;

      IF (rhi.net_weight_uom_code IS NULL) THEN
         rhi.net_weight_uom_code  := rsh.net_weight_uom_code;
      END IF;

      IF (rhi.notice_creation_date IS NULL) THEN
         rhi.notice_creation_date  := rsh.notice_creation_date;
      END IF;

      IF (rhi.num_of_containers IS NULL) THEN
         rhi.num_of_containers  := rsh.num_of_containers;
      END IF;

      IF (rhi.packaging_code IS NULL) THEN
         rhi.packaging_code  := rsh.packaging_code;
      END IF;

      IF (rhi.packing_slip IS NULL) THEN
         rhi.packing_slip  := rsh.packing_slip;
      END IF;

      IF (rhi.payment_terms_id IS NULL) THEN
         rhi.payment_terms_id  := rsh.payment_terms_id;
      END IF;

      IF (rhi.receipt_source_code IS NULL) THEN
         rhi.receipt_source_code  := rsh.receipt_source_code;
      END IF;

      IF (rhi.remit_to_site_id IS NULL) THEN
         rhi.remit_to_site_id  := rsh.remit_to_site_id;
      END IF;

      IF (rhi.shipment_num IS NULL) THEN
         rhi.shipment_num  := rsh.shipment_num;
      END IF;

      --18326341, exclude Add to ASN feature via ROI begin
      IF ( rhi.transaction_type = 'ADD' AND rhi.shipment_num IS NOT NULL
           AND rsh.ASN_TYPE IN ('ASN', 'ASBN', 'LCM', 'WC') ) THEN
         invalid_match_value(rhi.shipment_num,
                             NULL,
                             'shipment_num');
      END IF;
      --18326341, exclude Add to ASN feature via ROI end

      IF (rhi.shipped_date IS NULL) THEN
         rhi.shipped_date  := rsh.shipped_date;
      END IF;

      IF (rhi.special_handling_code IS NULL) THEN
         rhi.special_handling_code  := rsh.special_handling_code;
      END IF;

      IF (rhi.tar_weight IS NULL) THEN
         rhi.tar_weight  := rsh.tar_weight;
      END IF;

      IF (rhi.tar_weight_uom_code IS NULL) THEN
         rhi.tar_weight_uom_code  := rsh.tar_weight_uom_code;
      END IF;

      IF (rhi.tax_amount IS NULL) THEN
         rhi.tax_amount  := rsh.tax_amount;
      END IF;

      IF (rhi.tax_name IS NULL) THEN
         rhi.tax_name  := rsh.tax_name;
      END IF;

      IF (rhi.usggl_transaction_code IS NULL) THEN
         rhi.usggl_transaction_code  := rsh.ussgl_transaction_code;
      END IF;

      IF (rhi.vendor_id IS NULL) THEN
         rhi.vendor_id  := rsh.vendor_id;
      --Add to receipt 17962808 begin;
      ELSIF(rhi.vendor_id <> rsh.vendor_id) THEN
         invalid_match_value(rhi.vendor_id,
                             rsh.vendor_id,
                             'vendor_id');
      END IF;

      IF (rhi.receipt_source_code <> rsh.receipt_source_code) THEN
        invalid_match_value(rhi.receipt_source_code,
                            rsh.receipt_source_code,
                            'receipt_source_code');
      END IF;
      --Add to receipt 17962808 end;

      IF (rhi.vendor_site_id IS NULL) THEN
         rhi.vendor_site_id  := rsh.vendor_site_id;
      END IF;

      IF (rhi.waybill_airbill_num IS NULL) THEN
         rhi.waybill_airbill_num  := rsh.waybill_airbill_num;
      END IF;
   END default_rhi_from_rsh;

   PROCEDURE default_rti_from_rhi(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      rhi rcv_headers_interface%ROWTYPE;
   BEGIN
      /* If this row does not have a header_interface_id it is possible that the
         parent_interface_txn does.  This extra query is free because of caching */
      IF (    rti.header_interface_id IS NULL
          AND rti.parent_interface_txn_id IS NOT NULL) THEN
         rti.header_interface_id  := rcv_table_functions.get_rti_row_from_id(rti.parent_interface_txn_id).header_interface_id;
      END IF;

      IF (rti.header_interface_id IS NOT NULL) THEN
         rhi  := rcv_table_functions.get_rhi_row_from_id(rti.header_interface_id);
      END IF;

      IF (rhi.header_interface_id IS NULL) THEN
         RETURN;
      END IF;

      /* it is ok if a header has previously been processed. */
      IF (rhi.processing_status_code = 'ERROR') THEN
         rcv_error_pkg.set_error_message('RCV_HEADER_IS_ERROR');
         rcv_error_pkg.set_token('HEADER_INTERFACE_ID', rhi.header_interface_id);
         rcv_error_pkg.log_interface_error('HEADER_INTERFACE_ID');
      END IF;

      IF (    rhi.GROUP_ID IS NULL
          AND rti.GROUP_ID IS NOT NULL) THEN
         rhi.GROUP_ID  := rti.GROUP_ID;
         rcv_table_functions.update_rhi_row(rhi);
      END IF;

      IF (rti.GROUP_ID IS NULL) THEN
         rti.GROUP_ID  := rhi.GROUP_ID;
      ELSIF(rti.GROUP_ID <> rhi.GROUP_ID) THEN
         invalid_match_value(rti.GROUP_ID,
                             rhi.GROUP_ID,
                             'GROUP_ID'
                            );
      END IF;

      IF (rti.header_interface_id IS NULL) THEN
         rti.header_interface_id  := rhi.header_interface_id;
      ELSIF(rti.header_interface_id <> rhi.header_interface_id) THEN
         invalid_match_value(rti.header_interface_id,
                             rhi.header_interface_id,
                             'HEADER_INTERFACE_ID'
                            );
      END IF;

      IF (rti.receipt_source_code IS NULL) THEN
         rti.receipt_source_code  := rhi.receipt_source_code;
      ELSIF(rti.receipt_source_code <> rhi.receipt_source_code) THEN
         invalid_match_value(rti.receipt_source_code,
                             rhi.receipt_source_code,
                             'RECEIPT_SOURCE_CODE'
                            );
      END IF;

      IF (rti.shipment_header_id IS NULL) THEN
         rti.shipment_header_id  := rhi.receipt_header_id;
      ELSIF(rti.shipment_header_id <> rhi.receipt_header_id) THEN
         invalid_match_value(rti.shipment_header_id,
                             rhi.receipt_header_id,
                             'SHIPMENT_HEADER_ID'
                            );
      END IF;

      IF (rti.shipment_num IS NULL) THEN
         rti.shipment_num  := rhi.shipment_num;
      ELSIF(rti.shipment_num <> rhi.shipment_num) THEN
         invalid_match_value(rti.shipment_num,
                             rhi.shipment_num,
                             'SHIPMENT_NUM'
                            );
      END IF;

      /** WDK: Still not sure on what is or isn't allowed with
      *** multiple orgs in under the same header. In the meantime
      *** I am relaxing this requirement
      **/
      /*
      IF (rti.from_organization_code IS NULL) THEN
         rti.from_organization_code  := rhi.from_organization_code;
      ELSIF(rti.from_organization_code <> rhi.from_organization_code) THEN
         invalid_match_value(rti.from_organization_code,
                             rhi.from_organization_code,
                             'FROM_ORGANIZATION_CODE'
                            );
      END IF;

      IF (rti.from_organization_id IS NULL) THEN
         rti.from_organization_id  := rhi.from_organization_id;
      ELSIF(rti.from_organization_id <> rhi.from_organization_id) THEN
         invalid_match_value(rti.from_organization_id,
                             rhi.from_organization_id,
                             'FROM_ORGANIZATION_ID'
                            );
      END IF;

      IF (rti.to_organization_code IS NULL) THEN
         rti.to_organization_code  := rhi.ship_to_organization_code;
      ELSIF(rti.to_organization_code <> rhi.ship_to_organization_code) THEN
         invalid_match_value(rti.to_organization_code,
                             rhi.ship_to_organization_code,
                             'TO_ORGANIZATION_CODE'
                            );
      END IF;

      IF (rti.to_organization_id IS NULL) THEN
         rti.to_organization_id  := rhi.ship_to_organization_id;
      ELSIF(rti.to_organization_id <> rhi.ship_to_organization_id) THEN
         invalid_match_value(rti.to_organization_id,
                             rhi.ship_to_organization_id,
                             'TO_ORGANIZATION_ID'
                            );
      END IF;
      */
      IF (rti.org_id IS NULL) THEN
         rti.org_id  := rhi.org_id;
      ELSIF(rti.org_id <> rhi.org_id) THEN
         invalid_match_value(rti.org_id,
                             rhi.org_id,
                             'ORG_ID'
                            );
      END IF;

      IF (rti.operating_unit IS NULL) THEN
         rti.operating_unit  := rhi.operating_unit;
      ELSIF(rti.operating_unit <> rhi.operating_unit) THEN
         invalid_match_value(rti.operating_unit,
                             rhi.operating_unit,
                             'OPERATING_UNIT'
                            );
      END IF;

      IF (rti.from_organization_code IS NULL) THEN
         rti.from_organization_code  := rhi.from_organization_code;
      END IF;

      IF (rti.from_organization_id IS NULL) THEN
         rti.from_organization_id  := rhi.from_organization_id;
      END IF;

      IF (rti.to_organization_code IS NULL) THEN
         rti.to_organization_code  := rhi.ship_to_organization_code;
      END IF;

      IF (rti.to_organization_id IS NULL) THEN
         rti.to_organization_id  := rhi.ship_to_organization_id;
      END IF;

      IF (rti.operating_unit IS NULL) THEN
         rti.operating_unit  := rhi.operating_unit;
      END IF;

      IF (rti.org_id IS NULL) THEN
         rti.org_id  := rhi.org_id;
      END IF;

      -- bug 9274603
      /*
      IF (rti.attribute1 IS NULL) THEN
         rti.attribute1  := rhi.attribute1;
      END IF;

      IF (rti.attribute10 IS NULL) THEN
         rti.attribute10  := rhi.attribute10;
      END IF;

      IF (rti.attribute11 IS NULL) THEN
         rti.attribute11  := rhi.attribute11;
      END IF;

      IF (rti.attribute12 IS NULL) THEN
         rti.attribute12  := rhi.attribute12;
      END IF;

      IF (rti.attribute13 IS NULL) THEN
         rti.attribute13  := rhi.attribute13;
      END IF;

      IF (rti.attribute14 IS NULL) THEN
         rti.attribute14  := rhi.attribute14;
      END IF;

      IF (rti.attribute15 IS NULL) THEN
         rti.attribute15  := rhi.attribute15;
      END IF;

      IF (rti.attribute2 IS NULL) THEN
         rti.attribute2  := rhi.attribute2;
      END IF;

      IF (rti.attribute3 IS NULL) THEN
         rti.attribute3  := rhi.attribute3;
      END IF;

      IF (rti.attribute4 IS NULL) THEN
         rti.attribute4  := rhi.attribute4;
      END IF;

      IF (rti.attribute5 IS NULL) THEN
         rti.attribute5  := rhi.attribute5;
      END IF;

      IF (rti.attribute6 IS NULL) THEN
         rti.attribute6  := rhi.attribute6;
      END IF;

      IF (rti.attribute7 IS NULL) THEN
         rti.attribute7  := rhi.attribute7;
      END IF;

      IF (rti.attribute8 IS NULL) THEN
         rti.attribute8  := rhi.attribute8;
      END IF;

      IF (rti.attribute9 IS NULL) THEN
         rti.attribute9  := rhi.attribute9;
      END IF;

      IF (rti.attribute_category IS NULL) THEN
         rti.attribute_category  := rhi.attribute_category;
      END IF;
      */

      IF (rti.auto_transact_code IS NULL) THEN
         rti.auto_transact_code  := rhi.auto_transact_code;
      END IF;

      IF (rti.bill_of_lading IS NULL) THEN
         rti.bill_of_lading  := rhi.bill_of_lading;
      END IF;

      IF (rti.currency_code IS NULL) THEN
         rti.currency_code  := rhi.currency_code;
      END IF;

      IF (rti.currency_conversion_rate IS NULL) THEN
         rti.currency_conversion_rate  := rhi.conversion_rate;
      END IF;

      IF (rti.currency_conversion_date IS NULL) THEN
         rti.currency_conversion_date  := rhi.conversion_rate_date;
      END IF;

      IF (rti.currency_conversion_type IS NULL) THEN
         rti.currency_conversion_type  := rhi.conversion_rate_type;
      END IF;

      IF (rti.customer_account_number IS NULL) THEN
         rti.customer_account_number  := rhi.customer_account_number;
      END IF;

      IF (rti.customer_id IS NULL) THEN
         rti.customer_id  := rhi.customer_id;
      END IF;

      IF (rti.customer_party_name IS NULL) THEN
         rti.customer_party_name  := rhi.customer_party_name;
      END IF;

      IF (rti.customer_site_id IS NULL) THEN
         rti.customer_site_id  := rhi.customer_site_id;
      END IF;

      IF (rti.employee_id IS NULL) THEN
         rti.employee_id  := rhi.employee_id;
      END IF;

      IF (rti.expected_receipt_date IS NULL) THEN
         rti.expected_receipt_date  := rhi.expected_receipt_date;
      END IF;

      IF (rti.freight_carrier_code IS NULL) THEN
         rti.freight_carrier_code  := rhi.freight_carrier_code;
      END IF;

      IF (rti.GROUP_ID IS NULL) THEN
         rti.GROUP_ID  := rhi.GROUP_ID;
      END IF;

      IF (rti.location_code IS NULL) THEN
         rti.location_code  := rhi.location_code;
      END IF;

      IF (rti.location_id IS NULL) THEN
         rti.location_id  := rhi.location_id;
      END IF;

      IF (rti.num_of_containers IS NULL) THEN
         rti.num_of_containers  := rhi.num_of_containers;
      END IF;

      IF (rti.packing_slip IS NULL) THEN
         rti.packing_slip  := rhi.packing_slip;
      END IF;

      IF (rti.processing_status_code IS NULL) THEN
         rti.processing_status_code  := rhi.processing_status_code;
      END IF;

      IF (rti.shipped_date IS NULL) THEN
         rti.shipped_date  := rhi.shipped_date;
      END IF;

      IF (rti.tax_amount IS NULL) THEN
         rti.tax_amount  := rhi.tax_amount;
      END IF;

      IF (rti.tax_name IS NULL) THEN
         rti.tax_name  := rhi.tax_name;
      END IF;

      IF (rti.transaction_type IS NULL) THEN
         rti.transaction_type  := rhi.transaction_type;
      END IF;

      IF (rti.ussgl_transaction_code IS NULL) THEN
         rti.ussgl_transaction_code  := rhi.usggl_transaction_code;
      END IF;

      IF (rti.validation_flag IS NULL) THEN
         rti.validation_flag  := rhi.validation_flag;
      END IF;

      IF (rti.vendor_id IS NULL) THEN
         rti.vendor_id  := rhi.vendor_id;
      END IF;

      IF (rti.vendor_name IS NULL) THEN
         rti.vendor_name  := rhi.vendor_name;
      END IF;

      IF (rti.vendor_num IS NULL) THEN
         rti.vendor_num  := rhi.vendor_num;
      END IF;

      /* Bug 10306164 comment the code related to Vendor site, as RTIs
         with same RHI may have differnt vendor site id */

      /* IF (rti.vendor_site_code IS NULL) THEN
         rti.vendor_site_code  := rhi.vendor_site_code;
      END IF;

      IF (rti.vendor_site_id IS NULL) THEN
         rti.vendor_site_id  := rhi.vendor_site_id;
      END IF;*/

      IF (rti.waybill_airbill_num IS NULL) THEN
         rti.waybill_airbill_num  := rhi.waybill_airbill_num;
      END IF;
   END default_rti_from_rhi;

   PROCEDURE default_rti_from_rti(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      prti rcv_transactions_interface%ROWTYPE;
   BEGIN
      IF (rti.parent_interface_txn_id IS NOT NULL) THEN
         prti  := rcv_table_functions.get_rti_row_from_id(rti.parent_interface_txn_id);
      END IF;

      IF (prti.interface_transaction_id IS NULL) THEN
         RETURN;
      END IF;

      /* PENDING is the only status that's going to get processed, therefore
         everything else is an error */
      IF (prti.processing_status_code <> 'PENDING') THEN
         rcv_error_pkg.set_error_message('RCV_INTERFACE_PARENT_NOT_PENDING');
         rcv_error_pkg.set_token('PARENT_INTERFACE_TXN_ID', prti.parent_interface_txn_id);
         rcv_error_pkg.log_interface_error('PARENT_INTERFACE_TXN_ID');
      END IF;

      IF (rti.document_distribution_num IS NULL) THEN
         rti.document_distribution_num  := prti.document_distribution_num;
      ELSIF(rti.document_distribution_num <> prti.document_distribution_num) THEN
         invalid_match_value(rti.document_distribution_num,
                             prti.document_distribution_num,
                             'DOCUMENT_DISTRIBUTION_NUM'
                            );
      END IF;

      IF (rti.document_line_num IS NULL) THEN
         rti.document_line_num  := prti.document_line_num;
      ELSIF(rti.document_line_num <> prti.document_line_num) THEN
         invalid_match_value(rti.document_line_num,
                             prti.document_line_num,
                             'DOCUMENT_LINE_NUM'
                            );
      END IF;

      IF (rti.document_num IS NULL) THEN
         rti.document_num  := prti.document_num;
      ELSIF(rti.document_num <> prti.document_num) THEN
         invalid_match_value(rti.document_num,
                             prti.document_num,
                             'DOCUMENT_NUM'
                            );
      END IF;

      IF (rti.document_shipment_line_num IS NULL) THEN
         rti.document_shipment_line_num  := prti.document_shipment_line_num;
      ELSIF(rti.document_shipment_line_num <> prti.document_shipment_line_num) THEN
         invalid_match_value(rti.document_shipment_line_num,
                             prti.document_shipment_line_num,
                             'DOCUMENT_SHIPMENT_LINE_NUM'
                            );
      END IF;

      IF (rti.from_organization_code IS NULL) THEN
         rti.from_organization_code  := prti.from_organization_code;
      ELSIF(rti.from_organization_code <> prti.from_organization_code) THEN
         invalid_match_value(rti.from_organization_code,
                             prti.from_organization_code,
                             'FROM_ORGANIZATION_CODE'
                            );
      END IF;

      IF (rti.from_organization_id IS NULL) THEN
         rti.from_organization_id  := prti.from_organization_id;
      ELSIF(rti.from_organization_id <> prti.from_organization_id) THEN
         invalid_match_value(rti.from_organization_id,
                             prti.from_organization_id,
                             'FROM_ORGANIZATION_ID'
                            );
      END IF;

      IF (rti.header_interface_id IS NULL) THEN
         rti.header_interface_id  := prti.header_interface_id;
      ELSIF(rti.header_interface_id <> prti.header_interface_id) THEN
         invalid_match_value(rti.header_interface_id,
                             prti.header_interface_id,
                             'HEADER_INTERFACE_ID'
                            );
      END IF;

      IF (rti.item_category IS NULL) THEN
         rti.item_category  := prti.item_category;
      ELSIF(rti.item_category <> prti.item_category) THEN
         invalid_match_value(rti.item_category,
                             prti.item_category,
                             'ITEM_CATEGORY'
                            );
      END IF;

      /*As part of bug 7012051 removed the validation of item_description
        and make it defaulted from parent interface transaction*/
      rti.item_description  := prti.item_description;

     /* IF (rti.item_description IS NULL) THEN
         rti.item_description  := prti.item_description;
      ELSIF(rti.item_description <> prti.item_description) THEN
         invalid_match_value(rti.item_description,
                             prti.item_description,
                             'ITEM_DESCRIPTION'
                            );
      END IF;*/

      IF (rti.item_id IS NULL) THEN
         rti.item_id  := prti.item_id;
      ELSIF(rti.item_id <> prti.item_id) THEN
         invalid_match_value(rti.item_id,
                             prti.item_id,
                             'ITEM_ID'
                            );
      END IF;

      IF (rti.item_num IS NULL) THEN
         rti.item_num  := prti.item_num;
      ELSIF(rti.item_num <> prti.item_num) THEN
         invalid_match_value(rti.item_num,
                             prti.item_num,
                             'ITEM_NUM'
                            );
      END IF;

      IF (rti.item_revision IS NULL) THEN
         rti.item_revision  := prti.item_revision;
      /*
      Bug 5975270: We can't compare the two revisions right now
      as we are not sure if item is revision controlled or not.
      ELSIF(rti.item_revision <> prti.item_revision) THEN
         invalid_match_value(rti.item_revision,
                             prti.item_revision,
                             'ITEM_REVISION'
                            );
      */
      END IF;

      IF (rti.job_id IS NULL) THEN
         rti.job_id  := prti.job_id;
      ELSIF(rti.job_id <> prti.job_id) THEN
         invalid_match_value(rti.job_id,
                             prti.job_id,
                             'JOB_ID'
                            );
      END IF;

      IF (rti.oe_order_header_id IS NULL) THEN
         rti.oe_order_header_id  := prti.oe_order_header_id;
      ELSIF(rti.oe_order_header_id <> prti.oe_order_header_id) THEN
         invalid_match_value(rti.oe_order_header_id,
                             prti.oe_order_header_id,
                             'OE_ORDER_HEADER_ID'
                            );
      END IF;

      IF (rti.oe_order_line_id IS NULL) THEN
         rti.oe_order_line_id  := prti.oe_order_line_id;
      ELSIF(rti.oe_order_line_id <> prti.oe_order_line_id) THEN
         invalid_match_value(rti.oe_order_line_id,
                             prti.oe_order_line_id,
                             'OE_ORDER_LINE_ID'
                            );
      END IF;

      IF (rti.oe_order_num IS NULL) THEN
         rti.oe_order_num  := prti.oe_order_num;
      ELSIF(rti.oe_order_num <> prti.oe_order_num) THEN
         invalid_match_value(rti.oe_order_num,
                             prti.oe_order_num,
                             'OE_ORDER_NUM'
                            );
      END IF;

      IF (rti.oe_order_line_num IS NULL) THEN
         rti.oe_order_line_num  := prti.oe_order_line_num;
      ELSIF(rti.oe_order_line_num <> prti.oe_order_line_num) THEN
         invalid_match_value(rti.oe_order_line_num,
                             prti.oe_order_line_num,
                             'OE_ORDER_LINE_NUM'
                            );
      END IF;

      IF (rti.org_id IS NULL) THEN
         rti.org_id  := prti.org_id;
      ELSIF(rti.org_id <> prti.org_id) THEN
         invalid_match_value(rti.org_id,
                             prti.org_id,
                             'ORG_ID'
                            );
      END IF;

      IF (rti.parent_interface_txn_id IS NULL) THEN
         rti.parent_interface_txn_id  := prti.interface_transaction_id;
      ELSIF(rti.parent_interface_txn_id <> prti.interface_transaction_id) THEN
         invalid_match_value(rti.parent_interface_txn_id,
                             prti.interface_transaction_id,
                             'PARENT_INTERFACE_TXN_ID'
                            );
      END IF;

      -- Bug 7494637:
      -- Removing the code that defaults rti.parent_source_transaction_num from prti.source_transaction_num


      IF (rti.po_distribution_id IS NULL) THEN
         rti.po_distribution_id  := prti.po_distribution_id;
      ELSIF(rti.po_distribution_id <> prti.po_distribution_id) THEN
         invalid_match_value(rti.po_distribution_id,
                             prti.po_distribution_id,
                             'PO_DISTRIBUTION_ID'
                            );
      END IF;

      IF (rti.po_header_id IS NULL) THEN
         rti.po_header_id  := prti.po_header_id;
      ELSIF(rti.po_header_id <> prti.po_header_id) THEN
         invalid_match_value(rti.po_header_id,
                             prti.po_header_id,
                             'PO_HEADER_ID'
                            );
      END IF;

      IF (rti.po_line_id IS NULL) THEN
         rti.po_line_id  := prti.po_line_id;
      ELSIF(rti.po_line_id <> prti.po_line_id) THEN
         invalid_match_value(rti.po_line_id,
                             prti.po_line_id,
                             'PO_LINE_ID'
                            );
      END IF;

      IF (rti.po_line_location_id IS NULL) THEN
         rti.po_line_location_id  := prti.po_line_location_id;
      ELSIF(rti.po_line_location_id <> prti.po_line_location_id) THEN
         invalid_match_value(rti.po_line_location_id,
                             prti.po_line_location_id,
                             'PO_LINE_LOCATION_ID'
                            );
      END IF;

      IF (rti.po_release_id IS NULL) THEN
         rti.po_release_id  := prti.po_release_id;
      ELSIF(rti.po_release_id <> prti.po_release_id) THEN
         invalid_match_value(rti.po_release_id,
                             prti.po_release_id,
                             'PO_RELEASE_ID'
                            );
      END IF;

      IF (rti.po_revision_num IS NULL) THEN
         rti.po_revision_num  := prti.po_revision_num;
      ELSIF(rti.po_revision_num <> prti.po_revision_num) THEN
         invalid_match_value(rti.po_revision_num,
                             prti.po_revision_num,
                             'PO_REVISION_NUM'
                            );
      END IF;

      IF (rti.primary_unit_of_measure IS NULL) THEN
         rti.primary_unit_of_measure  := prti.primary_unit_of_measure;
      ELSIF(rti.primary_unit_of_measure <> prti.primary_unit_of_measure) THEN
         invalid_match_value(rti.primary_unit_of_measure,
                             prti.primary_unit_of_measure,
                             'PRIMARY_UNIT_OF_MEASURE'
                            );
      END IF;

      IF (rti.project_id IS NULL) THEN
         rti.project_id  := prti.project_id;
      ELSIF(rti.project_id <> prti.project_id) THEN
         invalid_match_value(rti.project_id,
                             prti.project_id,
                             'PROJECT_ID'
                            );
      END IF;

      IF (rti.release_num IS NULL) THEN
         rti.release_num  := prti.release_num;
      ELSIF(rti.release_num <> prti.release_num) THEN
         invalid_match_value(rti.release_num,
                             prti.release_num,
                             'RELEASE_NUM'
                            );
      END IF;

      IF (rti.requisition_line_id IS NULL) THEN
         rti.requisition_line_id  := prti.requisition_line_id;
      ELSIF(rti.requisition_line_id <> prti.requisition_line_id) THEN
         invalid_match_value(rti.requisition_line_id,
                             prti.requisition_line_id,
                             'REQUISITION_LINE_ID'
                            );
      END IF;

      IF (rti.req_distribution_id IS NULL) THEN
         rti.req_distribution_id  := prti.req_distribution_id;
      ELSIF(rti.req_distribution_id <> prti.req_distribution_id) THEN
         invalid_match_value(rti.req_distribution_id,
                             prti.req_distribution_id,
                             'REQ_DISTRIBUTION_ID'
                            );
      END IF;

      IF (rti.req_distribution_num IS NULL) THEN
         rti.req_distribution_num  := prti.req_distribution_num;
      ELSIF(rti.req_distribution_num <> prti.req_distribution_num) THEN
         invalid_match_value(rti.req_distribution_num,
                             prti.req_distribution_num,
                             'REQ_DISTRIBUTION_NUM'
                            );
      END IF;

      IF (rti.req_line_num IS NULL) THEN
         rti.req_line_num  := prti.req_line_num;
      ELSIF(rti.req_line_num <> prti.req_line_num) THEN
         invalid_match_value(rti.req_line_num,
                             prti.req_line_num,
                             'REQ_LINE_NUM'
                            );
      END IF;

      IF (rti.req_num IS NULL) THEN
         rti.req_num  := prti.req_num;
      ELSIF(rti.req_num <> prti.req_num) THEN
         invalid_match_value(rti.req_num,
                             prti.req_num,
                             'REQ_NUM'
                            );
      END IF;

      IF (rti.shipment_header_id IS NULL) THEN
         rti.shipment_header_id  := prti.shipment_header_id;
      ELSIF(rti.shipment_header_id <> prti.shipment_header_id) THEN
         invalid_match_value(rti.shipment_header_id,
                             prti.shipment_header_id,
                             'SHIPMENT_HEADER_ID'
                            );
      END IF;

      IF (rti.shipment_line_id IS NULL) THEN
         rti.shipment_line_id  := prti.shipment_line_id;
      ELSIF(rti.shipment_line_id <> prti.shipment_line_id) THEN
         invalid_match_value(rti.shipment_line_id,
                             prti.shipment_line_id,
                             'SHIPMENT_LINE_ID'
                            );
      END IF;

      IF (rti.shipment_num IS NULL) THEN
         rti.shipment_num  := prti.shipment_num;
      ELSIF(rti.shipment_num <> prti.shipment_num) THEN
         invalid_match_value(rti.shipment_num,
                             prti.shipment_num,
                             'SHIPMENT_NUM'
                            );
      END IF;

      IF (rti.source_document_code IS NULL) THEN
         rti.source_document_code  := prti.source_document_code;
      ELSIF(rti.source_document_code <> prti.source_document_code) THEN
         invalid_match_value(rti.source_document_code,
                             prti.source_document_code,
                             'SOURCE_DOCUMENT_CODE'
                            );
      END IF;

      IF (rti.to_organization_code IS NULL) THEN
         rti.to_organization_code  := prti.to_organization_code;
      ELSIF(rti.to_organization_code <> prti.to_organization_code) THEN
         invalid_match_value(rti.to_organization_code,
                             prti.to_organization_code,
                             'TO_ORGANIZATION_CODE'
                            );
      END IF;

      IF (rti.to_organization_id IS NULL) THEN
         rti.to_organization_id  := prti.to_organization_id;
      ELSIF(rti.to_organization_id <> prti.to_organization_id) THEN
         invalid_match_value(rti.to_organization_id,
                             prti.to_organization_id,
                             'TO_ORGANIZATION_ID'
                            );
      END IF;

      IF (rti.wip_entity_id IS NULL) THEN
         rti.wip_entity_id  := prti.wip_entity_id;
      ELSIF(rti.wip_entity_id <> prti.wip_entity_id) THEN
         invalid_match_value(rti.wip_entity_id,
                             prti.wip_entity_id,
                             'WIP_ENTITY_ID'
                            );
      END IF;

      IF (rti.wip_entity_name IS NULL) THEN
         rti.wip_entity_name  := prti.wip_entity_name;
      ELSIF(rti.wip_entity_name <> prti.wip_entity_name) THEN
         invalid_match_value(rti.wip_entity_name,
                             prti.wip_entity_name,
                             'WIP_ENTITY_NAME'
                            );
      END IF;

      IF (rti.wip_line_code IS NULL) THEN
         rti.wip_line_code  := prti.wip_line_code;
      ELSIF(rti.wip_line_code <> prti.wip_line_code) THEN
         invalid_match_value(rti.wip_line_code,
                             prti.wip_line_code,
                             'WIP_LINE_CODE'
                            );
      END IF;

      IF (rti.wip_line_id IS NULL) THEN
         rti.wip_line_id  := prti.wip_line_id;
      ELSIF(rti.wip_line_id <> prti.wip_line_id) THEN
         invalid_match_value(rti.wip_line_id,
                             prti.wip_line_id,
                             'WIP_LINE_ID'
                            );
      END IF;

      IF (rti.wip_operation_seq_num IS NULL) THEN
         rti.wip_operation_seq_num  := prti.wip_operation_seq_num;
      ELSIF(rti.wip_operation_seq_num <> prti.wip_operation_seq_num) THEN
         invalid_match_value(rti.wip_operation_seq_num,
                             prti.wip_operation_seq_num,
                             'WIP_OPERATION_SEQ_NUM'
                            );
      END IF;

      IF (rti.wip_repetitive_schedule_id IS NULL) THEN
         rti.wip_repetitive_schedule_id  := prti.wip_repetitive_schedule_id;
      ELSIF(rti.wip_repetitive_schedule_id <> prti.wip_repetitive_schedule_id) THEN
         invalid_match_value(rti.wip_repetitive_schedule_id,
                             prti.wip_repetitive_schedule_id,
                             'WIP_REPETITIVE_SCHEDULE_ID'
                            );
      END IF;

      IF (rti.wip_resource_seq_num IS NULL) THEN
         rti.wip_resource_seq_num  := prti.wip_resource_seq_num;
      ELSIF(rti.wip_resource_seq_num <> prti.wip_resource_seq_num) THEN
         invalid_match_value(rti.wip_resource_seq_num,
                             prti.wip_resource_seq_num,
                             'WIP_RESOURCE_SEQ_NUM'
                            );
      END IF;

      IF (rti.accrual_status_code IS NULL) THEN
         rti.accrual_status_code  := prti.accrual_status_code;
      END IF;

      IF (rti.actual_cost IS NULL) THEN
         rti.actual_cost  := prti.actual_cost;
      END IF;

	/* Bug 5299177
	 * We expect customers to give the amount. We do not default but error out
	 * if it is not given. Commenting out the foll code.
      IF (rti.amount IS NULL) THEN
         rti.amount  := prti.amount;

      END IF;
	* 5299177 */

      IF (rti.asn_attach_id IS NULL) THEN
         rti.asn_attach_id  := prti.asn_attach_id;
      END IF;

      IF (rti.attribute1 IS NULL) THEN
         rti.attribute1  := prti.attribute1;
      END IF;

      IF (rti.attribute10 IS NULL) THEN
         rti.attribute10  := prti.attribute10;
      END IF;

      IF (rti.attribute11 IS NULL) THEN
         rti.attribute11  := prti.attribute11;
      END IF;

      IF (rti.attribute12 IS NULL) THEN
         rti.attribute12  := prti.attribute12;
      END IF;

      IF (rti.attribute13 IS NULL) THEN
         rti.attribute13  := prti.attribute13;
      END IF;

      IF (rti.attribute14 IS NULL) THEN
         rti.attribute14  := prti.attribute14;
      END IF;

      IF (rti.attribute15 IS NULL) THEN
         rti.attribute15  := prti.attribute15;
      END IF;

      IF (rti.attribute2 IS NULL) THEN
         rti.attribute2  := prti.attribute2;
      END IF;

      IF (rti.attribute3 IS NULL) THEN
         rti.attribute3  := prti.attribute3;
      END IF;

      IF (rti.attribute4 IS NULL) THEN
         rti.attribute4  := prti.attribute4;
      END IF;

      IF (rti.attribute5 IS NULL) THEN
         rti.attribute5  := prti.attribute5;
      END IF;

      IF (rti.attribute6 IS NULL) THEN
         rti.attribute6  := prti.attribute6;
      END IF;

      IF (rti.attribute7 IS NULL) THEN
         rti.attribute7  := prti.attribute7;
      END IF;

      IF (rti.attribute8 IS NULL) THEN
         rti.attribute8  := prti.attribute8;
      END IF;

      IF (rti.attribute9 IS NULL) THEN
         rti.attribute9  := prti.attribute9;
      END IF;

      IF (rti.attribute_category IS NULL) THEN
         rti.attribute_category  := prti.attribute_category;
      END IF;

      IF (rti.auto_transact_code IS NULL) THEN
         rti.auto_transact_code  := prti.auto_transact_code;
      END IF;

      IF (rti.barcode_label IS NULL) THEN
         rti.barcode_label  := prti.barcode_label;
      END IF;

      IF (rti.bill_of_lading IS NULL) THEN
         rti.bill_of_lading  := prti.bill_of_lading;
      END IF;

      IF (rti.bom_resource_id IS NULL) THEN
         rti.bom_resource_id  := prti.bom_resource_id;
      END IF;

      IF (rti.category_id IS NULL) THEN
         rti.category_id  := prti.category_id;
      END IF;

      IF (rti.charge_account_id IS NULL) THEN
         rti.charge_account_id  := prti.charge_account_id;
      END IF;

      IF (rti.container_num IS NULL) THEN
         rti.container_num  := prti.container_num;
      END IF;

      IF (rti.cost_group_id IS NULL) THEN
         rti.cost_group_id  := prti.cost_group_id;
      END IF;

      IF (rti.country_of_origin_code IS NULL) THEN
         rti.country_of_origin_code  := prti.country_of_origin_code;
      END IF;

      IF (rti.create_debit_memo_flag IS NULL) THEN
         rti.create_debit_memo_flag  := prti.create_debit_memo_flag;
      END IF;

      IF (rti.currency_code IS NULL) THEN
         rti.currency_code  := prti.currency_code;
      END IF;

      IF (rti.currency_conversion_date IS NULL) THEN
         rti.currency_conversion_date  := prti.currency_conversion_date;
      END IF;

      IF (rti.currency_conversion_rate IS NULL) THEN
         rti.currency_conversion_rate  := prti.currency_conversion_rate;
      END IF;

      IF (rti.currency_conversion_type IS NULL) THEN
         rti.currency_conversion_type  := prti.currency_conversion_type;
      END IF;

      IF (rti.customer_account_number IS NULL) THEN
         rti.customer_account_number  := prti.customer_account_number;
      END IF;

      IF (rti.customer_id IS NULL) THEN
         rti.customer_id  := prti.customer_id;
      END IF;

      IF (rti.customer_item_id IS NULL) THEN
         rti.customer_item_id  := prti.customer_item_id;
      END IF;

      IF (rti.customer_item_num IS NULL) THEN
         rti.customer_item_num  := prti.customer_item_num;
      END IF;

      IF (rti.customer_party_name IS NULL) THEN
         rti.customer_party_name  := prti.customer_party_name;
      END IF;

      IF (rti.customer_site_id IS NULL) THEN
         rti.customer_site_id  := prti.customer_site_id;
      END IF;

      IF (rti.deliver_to_location_code IS NULL) THEN
         rti.deliver_to_location_code  := prti.deliver_to_location_code;
      END IF;

      IF (rti.deliver_to_location_id IS NULL) THEN
         rti.deliver_to_location_id  := prti.deliver_to_location_id;
      END IF;

      IF (rti.deliver_to_person_id IS NULL) THEN
         rti.deliver_to_person_id  := prti.deliver_to_person_id;
      END IF;

      IF (rti.deliver_to_person_name IS NULL) THEN
         rti.deliver_to_person_name  := prti.deliver_to_person_name;
      END IF;

      IF (rti.department_code IS NULL) THEN
         rti.department_code  := prti.department_code;
      END IF;

      IF (rti.destination_context IS NULL) THEN
         rti.destination_context  := prti.destination_context;
      END IF;

      IF (rti.destination_type_code IS NULL) THEN
         rti.destination_type_code  := prti.destination_type_code;
      END IF;

      IF (rti.employee_id IS NULL) THEN
         rti.employee_id  := prti.employee_id;
      END IF;

      IF (rti.erecord_id IS NULL) THEN
         rti.erecord_id  := prti.erecord_id;
      END IF;

      IF (rti.expected_receipt_date IS NULL) THEN
         rti.expected_receipt_date  := prti.expected_receipt_date;
      END IF;

      IF (rti.freight_carrier_code IS NULL) THEN
         rti.freight_carrier_code  := prti.freight_carrier_code;
      END IF;

      IF (rti.from_locator IS NULL) THEN
         rti.from_locator  := prti.from_locator;
      END IF;

      IF (rti.from_locator_id IS NULL) THEN
         rti.from_locator_id  := prti.from_locator_id;
      END IF;

	/* Bug 5584736.
	 * We have a detailed defaulting routine for defaulting
	 * subinventory and locator later. Commenting out this code
	 * here since this is creating problems later.
      IF (rti.from_subinventory IS NULL) THEN
         rti.from_subinventory  := prti.from_subinventory;
      END IF;
	*/

      IF (rti.government_context IS NULL) THEN
         rti.government_context  := prti.government_context;
      END IF;

      IF (rti.GROUP_ID IS NULL) THEN
         rti.GROUP_ID  := prti.GROUP_ID;
      END IF;

      IF (rti.inspection_quality_code IS NULL) THEN
         rti.inspection_quality_code  := prti.inspection_quality_code;
      END IF;

      IF (rti.inspection_status_code IS NULL) THEN
         rti.inspection_status_code  := prti.inspection_status_code;
      END IF;

      IF (rti.interface_available_amt IS NULL) THEN
         rti.interface_available_amt  := prti.interface_available_amt;
      END IF;

      IF (rti.interface_available_qty IS NULL) THEN
         rti.interface_available_qty  := prti.interface_available_qty;
      END IF;

      IF (rti.interface_source_code IS NULL) THEN
         rti.interface_source_code  := prti.interface_source_code;
      END IF;

      IF (rti.interface_source_line_id IS NULL) THEN
         rti.interface_source_line_id  := prti.interface_source_line_id;
      END IF;

      IF (rti.interface_transaction_amt IS NULL) THEN
         rti.interface_transaction_amt  := prti.interface_transaction_amt;
      END IF;

      IF (rti.interface_transaction_id IS NULL) THEN
         rti.interface_transaction_id  := prti.interface_transaction_id;
      END IF;

      IF (rti.interface_transaction_qty IS NULL) THEN
         rti.interface_transaction_qty  := prti.interface_transaction_qty;
      END IF;

      IF (rti.intransit_owning_org_code IS NULL) THEN
         rti.intransit_owning_org_code  := prti.intransit_owning_org_code;
      END IF;

      IF (rti.intransit_owning_org_id IS NULL) THEN
         rti.intransit_owning_org_id  := prti.intransit_owning_org_id;
      END IF;

      IF (rti.inv_transaction_id IS NULL) THEN
         rti.inv_transaction_id  := prti.inv_transaction_id;
      END IF;

      /*
      IF (rti.license_plate_number IS NULL) THEN
         rti.license_plate_number  := prti.license_plate_number;
      END IF;
      */
      IF (rti.location_code IS NULL) THEN
         rti.location_code  := prti.location_code;
      END IF;

      IF (rti.location_id IS NULL) THEN
         rti.location_id  := prti.location_id;
      END IF;

      IF (rti.LOCATOR IS NULL) THEN
         rti.LOCATOR  := prti.LOCATOR;
      END IF;

      IF (rti.locator_id IS NULL) THEN
         rti.locator_id  := prti.locator_id;
      END IF;

      /*
      IF (rti.lpn_group_id IS NULL) THEN
         rti.lpn_group_id  := prti.lpn_group_id;
      END IF;

      IF (rti.lpn_id IS NULL) THEN
         rti.lpn_id  := prti.lpn_id;
      END IF;
      */
      IF (rti.mmtt_temp_id IS NULL) THEN
         rti.mmtt_temp_id  := prti.mmtt_temp_id;
      END IF;

      IF (rti.mobile_txn IS NULL) THEN
         rti.mobile_txn  := prti.mobile_txn;
      END IF;

      IF (rti.movement_id IS NULL) THEN
         rti.movement_id  := prti.movement_id;
      END IF;

      IF (rti.notice_unit_price IS NULL) THEN
         rti.notice_unit_price  := prti.notice_unit_price;
      END IF;

      IF (rti.num_of_containers IS NULL) THEN
         rti.num_of_containers  := prti.num_of_containers;
      END IF;

      IF (rti.packing_slip IS NULL) THEN
         rti.packing_slip  := prti.packing_slip;
      END IF;

      IF (rti.po_unit_price IS NULL) THEN
         rti.po_unit_price  := prti.po_unit_price;
      END IF;

      IF (rti.processing_mode_code IS NULL) THEN
         rti.processing_mode_code  := prti.processing_mode_code;
      END IF;

      IF (rti.processing_status_code IS NULL) THEN
         rti.processing_status_code  := prti.processing_status_code;
      END IF;

      IF (rti.program_application_id IS NULL) THEN
         rti.program_application_id  := prti.program_application_id;
      END IF;

      IF (rti.program_id IS NULL) THEN
         rti.program_id  := prti.program_id;
      END IF;

      IF (rti.program_update_date IS NULL) THEN
         rti.program_update_date  := prti.program_update_date;
      END IF;

      IF (rti.put_away_rule_id IS NULL) THEN
         rti.put_away_rule_id  := prti.put_away_rule_id;
      END IF;

      IF (rti.put_away_strategy_id IS NULL) THEN
         rti.put_away_strategy_id  := prti.put_away_strategy_id;
      END IF;

      IF (rti.qa_collection_id IS NULL) THEN
         rti.qa_collection_id  := prti.qa_collection_id;
      END IF;

      IF (rti.qc_grade IS NULL) THEN
         rti.qc_grade  := prti.qc_grade;
      END IF;

      IF (rti.reason_id IS NULL) THEN
         rti.reason_id  := prti.reason_id;
      END IF;

      IF (rti.reason_name IS NULL) THEN
         rti.reason_name  := prti.reason_name;
      END IF;

      IF (rti.receipt_exception_flag IS NULL) THEN
         rti.receipt_exception_flag  := prti.receipt_exception_flag;
      END IF;

      IF (rti.receipt_source_code IS NULL) THEN
         rti.receipt_source_code  := prti.receipt_source_code;
      END IF;

      IF (rti.request_id IS NULL) THEN
         rti.request_id  := prti.request_id;
      END IF;

      IF (rti.resource_code IS NULL) THEN
         rti.resource_code  := prti.resource_code;
      END IF;

      IF (rti.rma_reference IS NULL) THEN
         rti.rma_reference  := prti.rma_reference;
      END IF;

      IF (rti.routing_code IS NULL) THEN
         rti.routing_code  := prti.routing_code;
      END IF;

      IF (rti.routing_header_id IS NULL) THEN
         rti.routing_header_id  := prti.routing_header_id;
      END IF;

      IF (rti.routing_step IS NULL) THEN
         rti.routing_step  := prti.routing_step;
      END IF;

      IF (rti.routing_step_id IS NULL) THEN
         rti.routing_step_id  := prti.routing_step_id;
      END IF;

      IF (rti.secondary_unit_of_measure IS NULL) THEN
         rti.secondary_unit_of_measure  := prti.secondary_unit_of_measure;
      END IF;

      IF (rti.secondary_uom_code IS NULL) THEN
         rti.secondary_uom_code  := prti.secondary_uom_code;
      END IF;

      IF (rti.shipment_line_status_code IS NULL) THEN
         rti.shipment_line_status_code  := prti.shipment_line_status_code;
      END IF;

      IF (rti.shipped_date IS NULL) THEN
         rti.shipped_date  := prti.shipped_date;
      END IF;

      IF (rti.ship_head_attribute1 IS NULL) THEN
         rti.ship_head_attribute1  := prti.ship_head_attribute1;
      END IF;

      IF (rti.ship_head_attribute10 IS NULL) THEN
         rti.ship_head_attribute10  := prti.ship_head_attribute10;
      END IF;

      IF (rti.ship_head_attribute11 IS NULL) THEN
         rti.ship_head_attribute11  := prti.ship_head_attribute11;
      END IF;

      IF (rti.ship_head_attribute12 IS NULL) THEN
         rti.ship_head_attribute12  := prti.ship_head_attribute12;
      END IF;

      IF (rti.ship_head_attribute13 IS NULL) THEN
         rti.ship_head_attribute13  := prti.ship_head_attribute13;
      END IF;

      IF (rti.ship_head_attribute14 IS NULL) THEN
         rti.ship_head_attribute14  := prti.ship_head_attribute14;
      END IF;

      IF (rti.ship_head_attribute15 IS NULL) THEN
         rti.ship_head_attribute15  := prti.ship_head_attribute15;
      END IF;

      IF (rti.ship_head_attribute2 IS NULL) THEN
         rti.ship_head_attribute2  := prti.ship_head_attribute2;
      END IF;

      IF (rti.ship_head_attribute3 IS NULL) THEN
         rti.ship_head_attribute3  := prti.ship_head_attribute3;
      END IF;

      IF (rti.ship_head_attribute4 IS NULL) THEN
         rti.ship_head_attribute4  := prti.ship_head_attribute4;
      END IF;

      IF (rti.ship_head_attribute5 IS NULL) THEN
         rti.ship_head_attribute5  := prti.ship_head_attribute5;
      END IF;

      IF (rti.ship_head_attribute6 IS NULL) THEN
         rti.ship_head_attribute6  := prti.ship_head_attribute6;
      END IF;

      IF (rti.ship_head_attribute7 IS NULL) THEN
         rti.ship_head_attribute7  := prti.ship_head_attribute7;
      END IF;

      IF (rti.ship_head_attribute8 IS NULL) THEN
         rti.ship_head_attribute8  := prti.ship_head_attribute8;
      END IF;

      IF (rti.ship_head_attribute9 IS NULL) THEN
         rti.ship_head_attribute9  := prti.ship_head_attribute9;
      END IF;

      IF (rti.ship_head_attribute_category IS NULL) THEN
         rti.ship_head_attribute_category  := prti.ship_head_attribute_category;
      END IF;

      IF (rti.ship_line_attribute1 IS NULL) THEN
         rti.ship_line_attribute1  := prti.ship_line_attribute1;
      END IF;

      IF (rti.ship_line_attribute10 IS NULL) THEN
         rti.ship_line_attribute10  := prti.ship_line_attribute10;
      END IF;

      IF (rti.ship_line_attribute11 IS NULL) THEN
         rti.ship_line_attribute11  := prti.ship_line_attribute11;
      END IF;

      IF (rti.ship_line_attribute12 IS NULL) THEN
         rti.ship_line_attribute12  := prti.ship_line_attribute12;
      END IF;

      IF (rti.ship_line_attribute13 IS NULL) THEN
         rti.ship_line_attribute13  := prti.ship_line_attribute13;
      END IF;

      IF (rti.ship_line_attribute14 IS NULL) THEN
         rti.ship_line_attribute14  := prti.ship_line_attribute14;
      END IF;

      IF (rti.ship_line_attribute15 IS NULL) THEN
         rti.ship_line_attribute15  := prti.ship_line_attribute15;
      END IF;

      IF (rti.ship_line_attribute2 IS NULL) THEN
         rti.ship_line_attribute2  := prti.ship_line_attribute2;
      END IF;

      IF (rti.ship_line_attribute3 IS NULL) THEN
         rti.ship_line_attribute3  := prti.ship_line_attribute3;
      END IF;

      IF (rti.ship_line_attribute4 IS NULL) THEN
         rti.ship_line_attribute4  := prti.ship_line_attribute4;
      END IF;

      IF (rti.ship_line_attribute5 IS NULL) THEN
         rti.ship_line_attribute5  := prti.ship_line_attribute5;
      END IF;

      IF (rti.ship_line_attribute6 IS NULL) THEN
         rti.ship_line_attribute6  := prti.ship_line_attribute6;
      END IF;

      IF (rti.ship_line_attribute7 IS NULL) THEN
         rti.ship_line_attribute7  := prti.ship_line_attribute7;
      END IF;

      IF (rti.ship_line_attribute8 IS NULL) THEN
         rti.ship_line_attribute8  := prti.ship_line_attribute8;
      END IF;

      IF (rti.ship_line_attribute9 IS NULL) THEN
         rti.ship_line_attribute9  := prti.ship_line_attribute9;
      END IF;

      IF (rti.ship_line_attribute_category IS NULL) THEN
         rti.ship_line_attribute_category  := prti.ship_line_attribute_category;
      END IF;

      IF (rti.ship_to_location_code IS NULL) THEN
         rti.ship_to_location_code  := prti.ship_to_location_code;
      END IF;

      IF (rti.ship_to_location_id IS NULL) THEN
         rti.ship_to_location_id  := prti.ship_to_location_id;
      END IF;

      IF (rti.source_doc_unit_of_measure IS NULL) THEN
         rti.source_doc_unit_of_measure  := prti.source_doc_unit_of_measure;
      END IF;

      -- Bug 18362332:
      -- Removing the code that defaults rti.source_transaction_num from prti.source_transaction_num

	/* Bug 5584736.
	 * We have a detailed defaulting routine for defaulting
	 * subinventory and locator later. Commenting out this code
	 * here since this is creating problems later.
      IF (rti.subinventory IS NULL) THEN
         rti.subinventory  := prti.subinventory;
      END IF;
	*/

      IF (rti.substitute_item_id IS NULL) THEN
         rti.substitute_item_id  := prti.substitute_item_id;
      END IF;

      IF (rti.substitute_item_num IS NULL) THEN
         rti.substitute_item_num  := prti.substitute_item_num;
      END IF;

      IF (rti.substitute_unordered_code IS NULL) THEN
         rti.substitute_unordered_code  := prti.substitute_unordered_code;
      END IF;

      IF (rti.task_id IS NULL) THEN
         rti.task_id  := prti.task_id;
      END IF;

      IF (rti.tax_amount IS NULL) THEN
         rti.tax_amount  := prti.tax_amount;
      END IF;

      IF (rti.tax_name IS NULL) THEN
         rti.tax_name  := prti.tax_name;
      END IF;

      IF (rti.timecard_id IS NULL) THEN
         rti.timecard_id  := prti.timecard_id;
      END IF;

      IF (rti.timecard_ovn IS NULL) THEN
         rti.timecard_ovn  := prti.timecard_ovn;
      END IF;

      IF (rti.transaction_date IS NULL) THEN
         rti.transaction_date  := prti.transaction_date;
      END IF;

      IF (rti.transaction_status_code IS NULL) THEN
         rti.transaction_status_code  := prti.transaction_status_code;
      END IF;

      IF (rti.transaction_type IS NULL) THEN
         rti.transaction_type  := prti.transaction_type;
      END IF;

      IF (rti.transfer_cost IS NULL) THEN
         rti.transfer_cost  := prti.transfer_cost;
      END IF;

      IF (rti.transfer_cost_group_id IS NULL) THEN
         rti.transfer_cost_group_id  := prti.transfer_cost_group_id;
      END IF;

      /*
      IF (rti.transfer_license_plate_number IS NULL) THEN
         rti.transfer_license_plate_number  := prti.transfer_license_plate_number;
      END IF;

      IF (rti.transfer_lpn_id IS NULL) THEN
         rti.transfer_lpn_id  := prti.transfer_lpn_id;
      END IF;
      */
      IF (rti.transfer_percentage IS NULL) THEN
         rti.transfer_percentage  := prti.transfer_percentage;
      END IF;

      IF (rti.transportation_account_id IS NULL) THEN
         rti.transportation_account_id  := prti.transportation_account_id;
      END IF;

      IF (rti.transportation_cost IS NULL) THEN
         rti.transportation_cost  := prti.transportation_cost;
      END IF;

      IF (rti.truck_num IS NULL) THEN
         rti.truck_num  := prti.truck_num;
      END IF;

      IF (rti.unit_of_measure IS NULL) THEN
         rti.unit_of_measure  := prti.unit_of_measure;
      END IF;

      IF (rti.uom_code IS NULL) THEN
         rti.uom_code  := prti.uom_code;
      END IF;

      IF (rti.use_mtl_lot IS NULL) THEN
         rti.use_mtl_lot  := prti.use_mtl_lot;
      END IF;

      IF (rti.use_mtl_serial IS NULL) THEN
         rti.use_mtl_serial  := prti.use_mtl_serial;
      END IF;

      IF (rti.ussgl_transaction_code IS NULL) THEN
         rti.ussgl_transaction_code  := prti.ussgl_transaction_code;
      END IF;

      IF (rti.validation_flag IS NULL) THEN
         rti.validation_flag  := prti.validation_flag;
      END IF;

      IF (rti.vendor_cum_shipped_qty IS NULL) THEN
         rti.vendor_cum_shipped_qty  := prti.vendor_cum_shipped_qty;
      END IF;

      IF (rti.vendor_id IS NULL) THEN
         rti.vendor_id  := prti.vendor_id;
      END IF;

      IF (rti.vendor_item_num IS NULL) THEN
         rti.vendor_item_num  := prti.vendor_item_num;
      END IF;

      IF (rti.vendor_lot_num IS NULL) THEN
         rti.vendor_lot_num  := prti.vendor_lot_num;
      END IF;

      IF (rti.vendor_name IS NULL) THEN
         rti.vendor_name  := prti.vendor_name;
      END IF;

      IF (rti.vendor_num IS NULL) THEN
         rti.vendor_num  := prti.vendor_num;
      END IF;

      IF (rti.vendor_site_code IS NULL) THEN
         rti.vendor_site_code  := prti.vendor_site_code;
      END IF;

      IF (rti.vendor_site_id IS NULL) THEN
         rti.vendor_site_id  := prti.vendor_site_id;
      END IF;

      IF (rti.waybill_airbill_num IS NULL) THEN
         rti.waybill_airbill_num  := prti.waybill_airbill_num;
      END IF;

      --Quantity code
	/* Bug 5299177
	 * We expect customers to give the quantity. We do not default but error out
	 * if it is not given. Commenting out the foll code.
      IF (rti.quantity IS NULL) THEN
         rti.quantity  := prti.quantity;

         IF (rti.primary_quantity IS NULL) THEN
            rti.primary_quantity  := prti.primary_quantity;
         END IF;

         IF (rti.secondary_quantity IS NULL) THEN
            rti.secondary_quantity  := prti.secondary_quantity;
         END IF;

         IF (rti.source_doc_quantity IS NULL) THEN
            rti.source_doc_quantity  := prti.source_doc_quantity;
         END IF;
      END IF;

      IF (rti.quantity_invoiced IS NULL) THEN
         rti.quantity_invoiced  := prti.quantity_invoiced;
      END IF;

      IF (rti.quantity_shipped IS NULL) THEN
         rti.quantity_shipped  := prti.quantity_shipped;
      END IF;
	* 5299177 */
   END default_rti_from_rti;

   PROCEDURE default_rti_from_rt(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      rt rcv_transactions%ROWTYPE;
   BEGIN
      IF (rti.parent_transaction_id IS NOT NULL) THEN
         rt  := rcv_table_functions.get_rt_row_from_id(rti.parent_transaction_id);
      END IF;

      IF (rt.transaction_id IS NULL) THEN
         RETURN;
      END IF;

      IF (rti.job_id IS NULL) THEN
         rti.job_id  := rt.job_id;
      ELSIF(rti.job_id <> rt.job_id) THEN
         invalid_match_value(rti.job_id,
                             rt.job_id,
                             'JOB_ID'
                            );
      END IF;

      IF (rti.oe_order_header_id IS NULL) THEN
         rti.oe_order_header_id  := rt.oe_order_header_id;
      ELSIF(rti.oe_order_header_id <> rt.oe_order_header_id) THEN
         invalid_match_value(rti.oe_order_header_id,
                             rt.oe_order_header_id,
                             'OE_ORDER_HEADER_ID'
                            );
      END IF;

      IF (rti.oe_order_line_id IS NULL) THEN
         rti.oe_order_line_id  := rt.oe_order_line_id;
      ELSIF(rti.oe_order_line_id <> rt.oe_order_line_id) THEN
         invalid_match_value(rti.oe_order_line_id,
                             rt.oe_order_line_id,
                             'OE_ORDER_LINE_ID'
                            );
      END IF;

      /*
      ** Bug#4615534 - Org_id defaulting from inventory organization
      ** needs to be done only for In-transit shipments
      */
      IF(rti.receipt_source_code IN ('INVENTORY','INTERNAL ORDER')) THEN -- Bug 9706173
          IF (rti.org_id IS NULL) THEN
             rti.org_id  := get_org_id_from_inv_org_id(rt.organization_id);
          END IF;
      END IF;

      IF (rti.parent_transaction_id IS NULL) THEN
         rti.parent_transaction_id  := rt.transaction_id;
      ELSIF(rti.parent_transaction_id <> rt.transaction_id) THEN
         invalid_match_value(rti.parent_transaction_id,
                             rt.transaction_id,
                             'PARENT_TRANSACTION_ID'
                            );
      END IF;

      IF (rti.po_distribution_id IS NULL) THEN
         rti.po_distribution_id  := rt.po_distribution_id;
      ELSIF(rti.po_distribution_id <> rt.po_distribution_id) THEN
         invalid_match_value(rti.po_distribution_id,
                             rt.po_distribution_id,
                             'PO_DISTRIBUTION_ID'
                            );
      END IF;

      IF (rti.po_header_id IS NULL) THEN
         rti.po_header_id  := rt.po_header_id;
      ELSIF(rti.po_header_id <> rt.po_header_id) THEN
         invalid_match_value(rti.po_header_id,
                             rt.po_header_id,
                             'PO_HEADER_ID'
                            );
      END IF;

      IF (rti.po_line_id IS NULL) THEN
         rti.po_line_id  := rt.po_line_id;
      ELSIF(rti.po_line_id <> rt.po_line_id) THEN
         invalid_match_value(rti.po_line_id,
                             rt.po_line_id,
                             'PO_LINE_ID'
                            );
      END IF;

      IF (rti.po_line_location_id IS NULL) THEN
         rti.po_line_location_id  := rt.po_line_location_id;
      ELSIF(rti.po_line_location_id <> rt.po_line_location_id) THEN
         invalid_match_value(rti.po_line_location_id,
                             rt.po_line_location_id,
                             'PO_LINE_LOCATION_ID'
                            );
      END IF;

      IF (rti.po_release_id IS NULL) THEN
         rti.po_release_id  := rt.po_release_id;
      ELSIF(rti.po_release_id <> rt.po_release_id) THEN
         invalid_match_value(rti.po_release_id,
                             rt.po_release_id,
                             'PO_RELEASE_ID'
                            );
      END IF;

      IF (rti.po_revision_num IS NULL) THEN
         rti.po_revision_num  := rt.po_revision_num;
      ELSIF(rti.po_revision_num <> rt.po_revision_num) THEN
         invalid_match_value(rti.po_revision_num,
                             rt.po_revision_num,
                             'PO_REVISION_NUM'
                            );
      END IF;

      IF (rti.primary_unit_of_measure IS NULL) THEN
         rti.primary_unit_of_measure  := rt.primary_unit_of_measure;
      ELSIF(rti.primary_unit_of_measure <> rt.primary_unit_of_measure) THEN
         invalid_match_value(rti.primary_unit_of_measure,
                             rt.primary_unit_of_measure,
                             'PRIMARY_UNIT_OF_MEASURE'
                            );
      END IF;

      IF (rti.project_id IS NULL) THEN
         rti.project_id  := rt.project_id;
      ELSIF(rti.project_id <> rt.project_id) THEN
         invalid_match_value(rti.project_id,
                             rt.project_id,
                             'PROJECT_ID'
                            );
      END IF;

      IF (rti.requisition_line_id IS NULL) THEN
         rti.requisition_line_id  := rt.requisition_line_id;
      ELSIF(rti.requisition_line_id <> rt.requisition_line_id) THEN
         invalid_match_value(rti.requisition_line_id,
                             rt.requisition_line_id,
                             'REQUISITION_LINE_ID'
                            );
      END IF;

      IF (rti.req_distribution_id IS NULL) THEN
         rti.req_distribution_id  := rt.req_distribution_id;
      ELSIF(rti.req_distribution_id <> rt.req_distribution_id) THEN
         invalid_match_value(rti.req_distribution_id,
                             rt.req_distribution_id,
                             'REQ_DISTRIBUTION_ID'
                            );
      END IF;

      IF (rti.shipment_header_id IS NULL) THEN
         rti.shipment_header_id  := rt.shipment_header_id;
      ELSIF(rti.shipment_header_id <> rt.shipment_header_id) THEN
         invalid_match_value(rti.shipment_header_id,
                             rt.shipment_header_id,
                             'SHIPMENT_HEADER_ID'
                            );
      END IF;

      IF (rti.shipment_line_id IS NULL) THEN
         rti.shipment_line_id  := rt.shipment_line_id;
      ELSIF(rti.shipment_line_id <> rt.shipment_line_id) THEN
         invalid_match_value(rti.shipment_line_id,
                             rt.shipment_line_id,
                             'SHIPMENT_LINE_ID'
                            );
      END IF;

      IF (rti.source_document_code IS NULL) THEN
         rti.source_document_code  := rt.source_document_code;
      ELSIF(rti.source_document_code <> rt.source_document_code) THEN
         invalid_match_value(rti.source_document_code,
                             rt.source_document_code,
                             'SOURCE_DOCUMENT_CODE'
                            );
      END IF;

      IF (rti.to_organization_id IS NULL) THEN
         rti.to_organization_id  := rt.organization_id;
      ELSIF(rti.to_organization_id <> rt.organization_id) THEN
         invalid_match_value(rti.to_organization_id,
                             rt.organization_id,
                             'TO_ORGANIZATION_ID'
                            );
      END IF;

      IF (rti.wip_entity_id IS NULL) THEN
         rti.wip_entity_id  := rt.wip_entity_id;
      ELSIF(rti.wip_entity_id <> rt.wip_entity_id) THEN
         invalid_match_value(rti.wip_entity_id,
                             rt.wip_entity_id,
                             'WIP_ENTITY_ID'
                            );
      END IF;

      IF (rti.wip_line_id IS NULL) THEN
         rti.wip_line_id  := rt.wip_line_id;
      ELSIF(rti.wip_line_id <> rt.wip_line_id) THEN
         invalid_match_value(rti.wip_line_id,
                             rt.wip_line_id,
                             'WIP_LINE_ID'
                            );
      END IF;

      IF (rti.wip_operation_seq_num IS NULL) THEN
         rti.wip_operation_seq_num  := rt.wip_operation_seq_num;
      ELSIF(rti.wip_operation_seq_num <> rt.wip_operation_seq_num) THEN
         invalid_match_value(rti.wip_operation_seq_num,
                             rt.wip_operation_seq_num,
                             'WIP_OPERATION_SEQ_NUM'
                            );
      END IF;

      IF (rti.wip_repetitive_schedule_id IS NULL) THEN
         rti.wip_repetitive_schedule_id  := rt.wip_repetitive_schedule_id;
      ELSIF(rti.wip_repetitive_schedule_id <> rt.wip_repetitive_schedule_id) THEN
         invalid_match_value(rti.wip_repetitive_schedule_id,
                             rt.wip_repetitive_schedule_id,
                             'WIP_REPETITIVE_SCHEDULE_ID'
                            );
      END IF;

      IF (rti.wip_resource_seq_num IS NULL) THEN
         rti.wip_resource_seq_num  := rt.wip_resource_seq_num;
      ELSIF(rti.wip_resource_seq_num <> rt.wip_resource_seq_num) THEN
         invalid_match_value(rti.wip_resource_seq_num,
                             rt.wip_resource_seq_num,
                             'WIP_RESOURCE_SEQ_NUM'
                            );
      END IF;

      --Bug 13725088 lcm_shipment_line_id and unit_landed_cost should be defaulted from RT for all the
      --subsequent transactions after receipt if it is not populated.

      IF(rcv_table_functions.is_lcm_shipment (rti.po_line_location_id)='Y') THEN
         IF (rti.transaction_type not in ('SHIP','RECEIVE')) THEN
            IF(rti.lcm_shipment_line_id IS NULL) THEN
               rti.lcm_shipment_line_id:=rt.lcm_shipment_line_id;
            END IF;

            IF(rti.unit_landed_cost IS NULL) THEN
               rti.unit_landed_cost:=rt.unit_landed_cost;
            END IF;
         END IF;
      END IF;


      IF (rti.accrual_status_code IS NULL) THEN
         rti.accrual_status_code  := rt.accrual_status_code;
      END IF;

	/* Bug 5299177
	 * We expect customers to give the amount. We do not default but error out
	 * if it is not given. Commenting out the foll code.
      IF (rti.amount IS NULL) THEN
         rti.amount  := rt.amount;
      END IF;
	* 5299177 */

      IF (rti.attribute1 IS NULL) THEN
         rti.attribute1  := rt.attribute1;
      END IF;

      IF (rti.attribute10 IS NULL) THEN
         rti.attribute10  := rt.attribute10;
      END IF;

      IF (rti.attribute11 IS NULL) THEN
         rti.attribute11  := rt.attribute11;
      END IF;

      IF (rti.attribute12 IS NULL) THEN
         rti.attribute12  := rt.attribute12;
      END IF;

      IF (rti.attribute13 IS NULL) THEN
         rti.attribute13  := rt.attribute13;
      END IF;

      IF (rti.attribute14 IS NULL) THEN
         rti.attribute14  := rt.attribute14;
      END IF;

      IF (rti.attribute15 IS NULL) THEN
         rti.attribute15  := rt.attribute15;
      END IF;

      IF (rti.attribute2 IS NULL) THEN
         rti.attribute2  := rt.attribute2;
      END IF;

      IF (rti.attribute3 IS NULL) THEN
         rti.attribute3  := rt.attribute3;
      END IF;

      IF (rti.attribute4 IS NULL) THEN
         rti.attribute4  := rt.attribute4;
      END IF;

      IF (rti.attribute5 IS NULL) THEN
         rti.attribute5  := rt.attribute5;
      END IF;

      IF (rti.attribute6 IS NULL) THEN
         rti.attribute6  := rt.attribute6;
      END IF;

      IF (rti.attribute7 IS NULL) THEN
         rti.attribute7  := rt.attribute7;
      END IF;

      IF (rti.attribute8 IS NULL) THEN
         rti.attribute8  := rt.attribute8;
      END IF;

      IF (rti.attribute9 IS NULL) THEN
         rti.attribute9  := rt.attribute9;
      END IF;

      IF (rti.attribute_category IS NULL) THEN
         rti.attribute_category  := rt.attribute_category;
      END IF;

      IF (rti.bom_resource_id IS NULL) THEN
         rti.bom_resource_id  := rt.bom_resource_id;
      END IF;

      IF (rti.country_of_origin_code IS NULL) THEN
         rti.country_of_origin_code  := rt.country_of_origin_code;
      END IF;

      IF (rti.currency_code IS NULL) THEN
         rti.currency_code  := rt.currency_code;
      END IF;

      IF (rti.currency_conversion_date IS NULL) THEN
         rti.currency_conversion_date  := rt.currency_conversion_date;
      END IF;

      IF (rti.currency_conversion_rate IS NULL) THEN
         rti.currency_conversion_rate  := rt.currency_conversion_rate;
      END IF;

      IF (rti.currency_conversion_type IS NULL) THEN
         rti.currency_conversion_type  := rt.currency_conversion_type;
      END IF;

      IF (rti.customer_id IS NULL) THEN
         rti.customer_id  := rt.customer_id;
      END IF;

      IF (rti.customer_site_id IS NULL) THEN
         rti.customer_site_id  := rt.customer_site_id;
      END IF;

      IF (rti.deliver_to_location_id IS NULL) THEN
         rti.deliver_to_location_id  := rt.deliver_to_location_id;
      END IF;

      IF (rti.deliver_to_person_id IS NULL) THEN
         rti.deliver_to_person_id  := rt.deliver_to_person_id;
      END IF;

      IF (rti.department_code IS NULL) THEN
         rti.department_code  := rt.department_code;
      END IF;

      IF (rti.destination_context IS NULL) THEN
         rti.destination_context  := rt.destination_context;
      END IF;

      IF (rti.destination_type_code IS NULL) THEN
         rti.destination_type_code  := rt.destination_type_code;
      END IF;

      IF (rti.employee_id IS NULL) THEN
         rti.employee_id  := rt.employee_id;
      END IF;

      IF (rti.from_locator_id IS NULL) THEN
         rti.from_locator_id  := rt.from_locator_id;
      END IF;

	/* Bug 5584736.
	 * We have a detailed defaulting routine for defaulting
	 * subinventory and locator later. Commenting out this code
	 * here since this is creating problems later.
      IF (rti.from_subinventory IS NULL) THEN
         rti.from_subinventory  := rt.from_subinventory;
      END IF;
	*/

      IF (rti.inspection_quality_code IS NULL) THEN
         rti.inspection_quality_code  := rt.inspection_quality_code;
      END IF;

      IF (rti.inspection_status_code IS NULL) THEN
         rti.inspection_status_code  := rt.inspection_status_code;
      END IF;

      IF (rti.interface_source_code IS NULL) THEN
         rti.interface_source_code  := rt.interface_source_code;
      END IF;

      IF (rti.interface_source_line_id IS NULL) THEN
         rti.interface_source_line_id  := rt.interface_source_line_id;
      END IF;

      IF (rti.interface_transaction_id IS NULL) THEN
         rti.interface_transaction_id  := rt.interface_transaction_id;
      END IF;

      IF (rti.inv_transaction_id IS NULL) THEN
         rti.inv_transaction_id  := rt.inv_transaction_id;
      END IF;

      IF (rti.location_id IS NULL) THEN
         rti.location_id  := rt.location_id;
      END IF;

      IF (rti.locator_id IS NULL) THEN
          IF (rti.subinventory IS NOT NULL AND
              rt.subinventory IS NOT NULL  AND
              rti.subinventory = rt.subinventory ) THEN   --Bug 13445044
                  rti.locator_id  := rt.locator_id;
          END IF;
      END IF;

      /*
      IF (rti.lpn_group_id IS NULL) THEN
         rti.lpn_group_id  := rt.lpn_group_id;
      END IF;

      IF (rti.lpn_id IS NULL) THEN
         rti.lpn_id  := rt.lpn_id;
      END IF;
      */
      IF (rti.mobile_txn IS NULL) THEN
         rti.mobile_txn  := rt.mobile_txn;
      END IF;

      IF (rti.movement_id IS NULL) THEN
         rti.movement_id  := rt.movement_id;
      END IF;

      IF (rti.po_unit_price IS NULL) THEN
         rti.po_unit_price  := rt.po_unit_price;
      END IF;

      IF (rti.qa_collection_id IS NULL) THEN
         rti.qa_collection_id  := rt.qa_collection_id;
      END IF;

      IF (rti.qc_grade IS NULL) THEN
         rti.qc_grade  := rt.qc_grade;
      END IF;

      IF (rti.reason_id IS NULL) THEN
         rti.reason_id  := rt.reason_id;
      END IF;

      IF (rti.receipt_exception_flag IS NULL) THEN
         rti.receipt_exception_flag  := rt.receipt_exception_flag;
      END IF;

      IF (rti.request_id IS NULL) THEN
         rti.request_id  := rt.request_id;
      END IF;

      IF (rti.rma_reference IS NULL) THEN
         rti.rma_reference  := rt.rma_reference;
      END IF;

      IF (rti.routing_header_id IS NULL) THEN
         rti.routing_header_id  := rt.routing_header_id;
      END IF;

      IF (rti.routing_step_id IS NULL) THEN
         rti.routing_step_id  := rt.routing_step_id;
      END IF;

      IF (rti.secondary_unit_of_measure IS NULL) THEN
         rti.secondary_unit_of_measure  := rt.secondary_unit_of_measure;
      END IF;

      IF (rti.secondary_uom_code IS NULL) THEN
         rti.secondary_uom_code  := rt.secondary_uom_code;
      END IF;

      IF (rti.source_doc_unit_of_measure IS NULL) THEN
         rti.source_doc_unit_of_measure  := rt.source_doc_unit_of_measure;
      END IF;

      -- Bug 18362332:
      -- Removing the code that defaults rti.source_transaction_num from rt.source_transaction_num

	/* Bug 5584736.
	 * We have a detailed defaulting routine for defaulting
	 * subinventory and locator later. Commenting out this code
	 * here since this is creating problems later.
      IF (rti.subinventory IS NULL) THEN
         rti.subinventory  := rt.subinventory;
      END IF;
	*/

      IF (rti.substitute_unordered_code IS NULL) THEN
         rti.substitute_unordered_code  := rt.substitute_unordered_code;
      END IF;

      IF (rti.task_id IS NULL) THEN
         rti.task_id  := rt.task_id;
      END IF;

      IF (rti.timecard_id IS NULL) THEN
         rti.timecard_id  := rt.timecard_id;
      END IF;

      IF (rti.timecard_ovn IS NULL) THEN
         rti.timecard_ovn  := rt.timecard_ovn;
      END IF;

      IF (rti.transaction_date IS NULL) THEN
         rti.transaction_date  := rt.transaction_date;
      END IF;

      IF (rti.transaction_type IS NULL) THEN
         rti.transaction_type  := rt.transaction_type;
      END IF;

      /*
      IF (rti.transfer_lpn_id IS NULL) THEN
         rti.transfer_lpn_id  := rt.transfer_lpn_id;
      END IF;
      */
      IF (rti.unit_of_measure IS NULL) THEN
         rti.unit_of_measure  := rt.unit_of_measure;
      END IF;

      IF (rti.uom_code IS NULL) THEN
         rti.uom_code  := rt.uom_code;
      END IF;

      IF (rti.vendor_id IS NULL) THEN
         rti.vendor_id  := rt.vendor_id;
      END IF;

      IF (rti.vendor_lot_num IS NULL) THEN
         rti.vendor_lot_num  := rt.vendor_lot_num;
      END IF;

      IF (rti.vendor_site_id IS NULL) THEN
         rti.vendor_site_id  := rt.vendor_site_id;
      END IF;

      --Quantity
	/* Bug 5299177
	 * We expect customers to give the quantity. We do not default but error out
	 * if it is not given. Commenting out the foll code.
      IF (rti.quantity IS NULL) THEN
         rti.quantity  := rt.quantity;

         IF (rti.primary_quantity IS NULL) THEN
            rti.primary_quantity  := rt.primary_quantity;
         END IF;

         IF (rti.secondary_quantity IS NULL) THEN
            rti.secondary_quantity  := rt.secondary_quantity;
         END IF;

         IF (rti.source_doc_quantity IS NULL) THEN
            rti.source_doc_quantity  := rt.source_doc_quantity;
         END IF;
      END IF;
	* 5299177 */
   END default_rti_from_rt;

   PROCEDURE default_rti_from_rsl(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      rsl rcv_shipment_lines%ROWTYPE;
/** Bug: 5502427
  * For Internal Orders, oe_order_line_id is getting stamped in RTI
  * by the cursor get_oe_order_line_id_from_mmt. If oe_order_line_id is
  * stamped, defaulting will be done based on the Sales Order for Internal orders.
  * But, we should not defalut based on SO for the Internal Orders.
  * So, commenting the logic of defaulting oe_order_line_id using the
  * cursor get_oe_order_line_id_from_mmt
  */
/*      CURSOR get_oe_order_line_id_from_mmt(
         p_mmt_transaction_id IN rcv_shipment_lines.mmt_transaction_id%TYPE
      ) IS
         SELECT source_line_id
         FROM   mtl_material_transactions
         WHERE  source_code = 'ORDER ENTRY'
         AND    transaction_id = p_mmt_transaction_id;*/
   BEGIN
      IF (rti.shipment_line_id IS NOT NULL) THEN
         rsl  := rcv_table_functions.get_rsl_row_from_id(rti.shipment_line_id);
      END IF;

      IF (rsl.shipment_line_id IS NULL) THEN
         RETURN;
      END IF;

      /* This one is problematic
      IF (rti.document_line_num IS NULL) THEN
         rti.document_line_num  := rsl.line_num;
      ELSIF(rti.document_line_num <> rsl.line_num) THEN
         invalid_match_value(rti.document_line_num,
                             rsl.line_num,
                             'DOCUMENT_LINE_NUM'
                            );
      END IF;
      */
      IF (rti.from_organization_id IS NULL) THEN
         rti.from_organization_id  := rsl.from_organization_id;
      ELSIF(rti.from_organization_id <> rsl.from_organization_id) THEN
         invalid_match_value(rti.from_organization_id,
                             rsl.from_organization_id,
                             'FROM_ORGANIZATION_ID'
                            );
      END IF;

      IF (rti.job_id IS NULL) THEN
         rti.job_id  := rsl.job_id;
      ELSIF(rti.job_id <> rsl.job_id) THEN
         invalid_match_value(rti.job_id,
                             rsl.job_id,
                             'JOB_ID'
                            );
      END IF;

      IF (rti.oe_order_header_id IS NULL) THEN
         rti.oe_order_header_id  := rsl.oe_order_header_id;
      ELSIF(rti.oe_order_header_id <> rsl.oe_order_header_id) THEN
         invalid_match_value(rti.oe_order_header_id,
                             rsl.oe_order_header_id,
                             'OE_ORDER_HEADER_ID'
                            );
      END IF;

      IF (rti.oe_order_line_id IS NULL) THEN
         rti.oe_order_line_id  := rsl.oe_order_line_id;
      ELSIF(rti.oe_order_line_id <> rsl.oe_order_line_id) THEN
         invalid_match_value(rti.oe_order_line_id,
                             rsl.oe_order_line_id,
                             'OE_ORDER_LINE_ID'
                            );
      END IF;

      /*
      ** Bug#4615534 - Org_id defaulting from inventory organization
      ** needs to be done only for In-transit shipments
      */
      IF(rti.receipt_source_code IN ('INVENTORY','INTERNAL ORDER')) THEN -- Bug 9706173
          IF (rti.org_id IS NULL) THEN
             rti.org_id  := get_org_id_from_inv_org_id(rsl.to_organization_id);
          END IF;
      END IF;

      IF (rti.po_distribution_id IS NULL) THEN
         rti.po_distribution_id  := rsl.po_distribution_id;
      ELSIF(rti.po_distribution_id <> rsl.po_distribution_id) THEN
         invalid_match_value(rti.po_distribution_id,
                             rsl.po_distribution_id,
                             'PO_DISTRIBUTION_ID'
                            );
      END IF;

      IF (rti.po_header_id IS NULL) THEN
         rti.po_header_id  := rsl.po_header_id;
      ELSIF(rti.po_header_id <> rsl.po_header_id) THEN
         invalid_match_value(rti.po_header_id,
                             rsl.po_header_id,
                             'PO_HEADER_ID'
                            );
      END IF;

      IF (rti.po_line_id IS NULL) THEN
         rti.po_line_id  := rsl.po_line_id;
      ELSIF(rti.po_line_id <> rsl.po_line_id) THEN
         invalid_match_value(rti.po_line_id,
                             rsl.po_line_id,
                             'PO_LINE_ID'
                            );
      END IF;

      IF (rti.po_line_location_id IS NULL) THEN
         rti.po_line_location_id  := rsl.po_line_location_id;
      ELSIF(rti.po_line_location_id <> rsl.po_line_location_id) THEN
         invalid_match_value(rti.po_line_location_id,
                             rsl.po_line_location_id,
                             'PO_LINE_LOCATION_ID'
                            );
      END IF;

      IF (rti.po_release_id IS NULL) THEN
         rti.po_release_id  := rsl.po_release_id;
      ELSIF(rti.po_release_id <> rsl.po_release_id) THEN
         invalid_match_value(rti.po_release_id,
                             rsl.po_release_id,
                             'PO_RELEASE_ID'
                            );
      END IF;

      IF (rti.requisition_line_id IS NULL) THEN
         rti.requisition_line_id  := rsl.requisition_line_id;
      ELSIF(rti.requisition_line_id <> rsl.requisition_line_id) THEN
         invalid_match_value(rti.requisition_line_id,
                             rsl.requisition_line_id,
                             'REQUISITION_LINE_ID'
                            );
      END IF;

      IF (rti.req_distribution_id IS NULL) THEN
         rti.req_distribution_id  := rsl.req_distribution_id;
      ELSIF(rti.req_distribution_id <> rsl.req_distribution_id) THEN
         invalid_match_value(rti.req_distribution_id,
                             rsl.req_distribution_id,
                             'REQ_DISTRIBUTION_ID'
                            );
      END IF;

      IF (rti.shipment_header_id IS NULL) THEN
         rti.shipment_header_id  := rsl.shipment_header_id;
      ELSIF(rti.shipment_header_id <> rsl.shipment_header_id) THEN
         invalid_match_value(rti.shipment_header_id,
                             rsl.shipment_header_id,
                             'SHIPMENT_HEADER_ID'
                            );
      END IF;

      IF (rti.shipment_line_id IS NULL) THEN
         rti.shipment_line_id  := rsl.shipment_line_id;
      ELSIF(rti.shipment_line_id <> rsl.shipment_line_id) THEN
         invalid_match_value(rti.shipment_line_id,
                             rsl.shipment_line_id,
                             'SHIPMENT_LINE_ID'
                            );
      END IF;

      IF (rti.source_document_code IS NULL) THEN
         rti.source_document_code  := rsl.source_document_code;
      ELSIF(rti.source_document_code <> rsl.source_document_code) THEN
         invalid_match_value(rti.source_document_code,
                             rsl.source_document_code,
                             'SOURCE_DOCUMENT_CODE'
                            );
      END IF;

      IF (rti.to_organization_id IS NULL) THEN
         rti.to_organization_id  := rsl.to_organization_id;
      ELSIF(rti.to_organization_id <> rsl.to_organization_id) THEN
         invalid_match_value(rti.to_organization_id,
                             rsl.to_organization_id,
                             'TO_ORGANIZATION_ID'
                            );
      END IF;

	/* Bug 5299177
	 * We expect customers to give the amount. We do not default but error out
	 * if it is not given. Commenting out the foll code.
      IF (rti.amount IS NULL) THEN
         rti.amount  := rsl.amount;
      END IF;
	* 5299177 */

      IF (rti.barcode_label IS NULL) THEN
         rti.barcode_label  := rsl.bar_code_label;
      END IF;

      IF (rti.category_id IS NULL) THEN
         rti.category_id  := rsl.category_id;
      END IF;

      IF (rti.charge_account_id IS NULL) THEN
         rti.charge_account_id  := rsl.charge_account_id;
      END IF;

      IF (rti.container_num IS NULL) THEN
         rti.container_num  := rsl.container_num;
      END IF;

/*    Bug 5999801. We should not default cost_group_id from RSL
 *    as it will be appropriately derived by the cost group engine
      IF (rti.cost_group_id IS NULL) THEN
         rti.cost_group_id  := rsl.cost_group_id;
      END IF;
*/
      IF (rti.country_of_origin_code IS NULL) THEN
         rti.country_of_origin_code  := rsl.country_of_origin_code;
      END IF;

      IF (rti.customer_item_num IS NULL) THEN
         rti.customer_item_num  := rsl.customer_item_num;
      END IF;

      IF (rti.deliver_to_location_id IS NULL) THEN
         rti.deliver_to_location_id  := rsl.deliver_to_location_id;
      END IF;

      IF (rti.deliver_to_person_id IS NULL) THEN
         rti.deliver_to_person_id  := rsl.deliver_to_person_id;
      END IF;

      IF (rti.destination_context IS NULL) THEN
         rti.destination_context  := rsl.destination_context;
      END IF;

      IF (rti.destination_type_code IS NULL) THEN
         rti.destination_type_code  := rsl.destination_type_code;
      END IF;

      IF (rti.employee_id IS NULL) THEN
         rti.employee_id  := rsl.employee_id;
      END IF;

      IF (rti.government_context IS NULL) THEN
         rti.government_context  := rsl.government_context;
      END IF;

      IF (rti.item_description IS NULL) THEN
         rti.item_description  := rsl.item_description;
      END IF;

      IF (rti.item_id IS NULL) THEN
         rti.item_id  := rsl.item_id;
      END IF;

      IF (rti.item_revision IS NULL) THEN
         rti.item_revision  := rsl.item_revision;
      END IF;

      IF (rti.locator_id IS NULL) THEN
         rti.locator_id  := rsl.locator_id;
      END IF;

      IF (rti.notice_unit_price IS NULL) THEN
         rti.notice_unit_price  := rsl.notice_unit_price;
      END IF;

      IF (rti.packing_slip IS NULL) THEN
         rti.packing_slip  := rsl.packing_slip;
      END IF;

      IF (rti.primary_unit_of_measure IS NULL) THEN
         rti.primary_unit_of_measure  := rsl.primary_unit_of_measure;
      END IF;

      IF (rti.qc_grade IS NULL) THEN
         rti.qc_grade  := rsl.qc_grade;
      END IF;

      IF (rti.reason_id IS NULL) THEN
         rti.reason_id  := rsl.reason_id;
      END IF;

      IF (rti.request_id IS NULL) THEN
         rti.request_id  := rsl.request_id;
      END IF;

      IF (rti.routing_header_id IS NULL) THEN
         rti.routing_header_id  := rsl.routing_header_id;
      END IF;

      IF (rti.secondary_unit_of_measure IS NULL) THEN
         rti.secondary_unit_of_measure  := rsl.secondary_unit_of_measure;
      END IF;

      IF (rti.shipment_line_status_code IS NULL) THEN
         rti.shipment_line_status_code  := rsl.shipment_line_status_code;
      END IF;

      IF (rti.ship_line_attribute1 IS NULL) THEN
         rti.ship_line_attribute1  := rsl.attribute1;
      END IF;

      IF (rti.ship_line_attribute10 IS NULL) THEN
         rti.ship_line_attribute10  := rsl.attribute10;
      END IF;

      IF (rti.ship_line_attribute11 IS NULL) THEN
         rti.ship_line_attribute11  := rsl.attribute11;
      END IF;

      IF (rti.ship_line_attribute12 IS NULL) THEN
         rti.ship_line_attribute12  := rsl.attribute12;
      END IF;

      IF (rti.ship_line_attribute13 IS NULL) THEN
         rti.ship_line_attribute13  := rsl.attribute13;
      END IF;

      IF (rti.ship_line_attribute14 IS NULL) THEN
         rti.ship_line_attribute14  := rsl.attribute14;
      END IF;

      IF (rti.ship_line_attribute15 IS NULL) THEN
         rti.ship_line_attribute15  := rsl.attribute15;
      END IF;

      IF (rti.ship_line_attribute2 IS NULL) THEN
         rti.ship_line_attribute2  := rsl.attribute2;
      END IF;

      IF (rti.ship_line_attribute3 IS NULL) THEN
         rti.ship_line_attribute3  := rsl.attribute3;
      END IF;

      IF (rti.ship_line_attribute4 IS NULL) THEN
         rti.ship_line_attribute4  := rsl.attribute4;
      END IF;

      IF (rti.ship_line_attribute5 IS NULL) THEN
         rti.ship_line_attribute5  := rsl.attribute5;
      END IF;

      IF (rti.ship_line_attribute6 IS NULL) THEN
         rti.ship_line_attribute6  := rsl.attribute6;
      END IF;

      IF (rti.ship_line_attribute7 IS NULL) THEN
         rti.ship_line_attribute7  := rsl.attribute7;
      END IF;

      IF (rti.ship_line_attribute8 IS NULL) THEN
         rti.ship_line_attribute8  := rsl.attribute8;
      END IF;

      IF (rti.ship_line_attribute9 IS NULL) THEN
         rti.ship_line_attribute9  := rsl.attribute9;
      END IF;

      IF (rti.ship_line_attribute_category IS NULL) THEN
         rti.ship_line_attribute_category  := rsl.attribute_category;
      END IF;

      IF (rti.ship_to_location_id IS NULL) THEN
         rti.ship_to_location_id  := rsl.ship_to_location_id;
      END IF;

	/* Bug 5584736.
	 * We have a detailed defaulting routine for defaulting
	 * subinventory and locator later. Commenting out this code
	 * here since this is creating problems later.
      IF (rti.subinventory IS NULL) THEN
         rti.subinventory  := rsl.to_subinventory;
      END IF;
	*/

      IF (rti.tax_amount IS NULL) THEN
         rti.tax_amount  := rsl.tax_amount;
      END IF;

      IF (rti.tax_name IS NULL) THEN
         rti.tax_name  := rsl.tax_name;
      END IF;

      IF (rti.timecard_id IS NULL) THEN
         rti.timecard_id  := rsl.timecard_id;
      END IF;

      IF (rti.timecard_ovn IS NULL) THEN
         rti.timecard_ovn  := rsl.timecard_ovn;
      END IF;

      IF (rti.transfer_cost IS NULL) THEN
         rti.transfer_cost  := rsl.transfer_cost;
      END IF;

      IF (rti.transfer_percentage IS NULL) THEN
         rti.transfer_percentage  := rsl.transfer_percentage;
      END IF;

      IF (rti.transportation_account_id IS NULL) THEN
         rti.transportation_account_id  := rsl.transportation_account_id;
      END IF;

      IF (rti.transportation_cost IS NULL) THEN
         rti.transportation_cost  := rsl.transportation_cost;
      END IF;

      IF (rti.truck_num IS NULL) THEN
         rti.truck_num  := rsl.truck_num;
      END IF;

      IF (rti.unit_of_measure IS NULL) THEN
         rti.unit_of_measure  := rsl.unit_of_measure;
      END IF;

      IF (rti.ussgl_transaction_code IS NULL) THEN
         rti.ussgl_transaction_code  := rsl.ussgl_transaction_code;
      END IF;

      IF (rti.vendor_cum_shipped_qty IS NULL) THEN
         rti.vendor_cum_shipped_qty  := rsl.vendor_cum_shipped_quantity;
      END IF;

      IF (rti.vendor_item_num IS NULL) THEN
         rti.vendor_item_num  := rsl.vendor_item_num;
      END IF;

      IF (rti.vendor_lot_num IS NULL) THEN
         rti.vendor_lot_num  := rsl.vendor_lot_num;
      END IF;

      --Quantity
	/* Bug 5299177
	 * We expect customers to give the quantity. We do not default but error out
	 * if it is not given. Commenting out the foll code.
      IF (rti.quantity_shipped IS NULL) THEN
         rti.quantity_shipped  := rsl.quantity_shipped;
      END IF;
	* 5299177 */

      --Necessary for internal orders
/* Bug:5502427 */
/*      IF (rsl.mmt_transaction_id IS NOT NULL) THEN
         OPEN get_oe_order_line_id_from_mmt(rsl.mmt_transaction_id);
         FETCH get_oe_order_line_id_from_mmt INTO rti.oe_order_line_id;
         CLOSE get_oe_order_line_id_from_mmt;
      END IF;*/
   END default_rti_from_rsl;

   PROCEDURE default_rti_from_rsh(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      rsh rcv_shipment_headers%ROWTYPE;
   BEGIN
      IF (rti.shipment_header_id IS NOT NULL) THEN
         rsh  := rcv_table_functions.get_rsh_row_from_id(rti.shipment_header_id);
      END IF;

      IF (rsh.shipment_header_id IS NULL) THEN
         RETURN;
      END IF;

      IF (rti.from_organization_id IS NULL) THEN
         rti.from_organization_id  := rsh.organization_id;
      ELSIF(rti.from_organization_id <> rsh.organization_id) THEN
         invalid_match_value(rti.from_organization_id,
                             rsh.organization_id,
                             'FROM_ORGANIZATION_ID'
                            );
      END IF;

      /*
      ** Bug#4615534 - Org_id defaulting from inventory organization
      ** needs to be done only for In-transit shipments
      */
      IF(rti.receipt_source_code IN ('INVENTORY','INTERNAL ORDER')) THEN -- Bug 9706173
          IF (rti.org_id IS NULL) THEN
             rti.org_id  := get_org_id_from_inv_org_id(rsh.ship_to_org_id);
          END IF;
      END IF;

      IF (rti.shipment_header_id IS NULL) THEN
         rti.shipment_header_id  := rsh.shipment_header_id;
      ELSIF(rti.shipment_header_id <> rsh.shipment_header_id) THEN
         invalid_match_value(rti.shipment_header_id,
                             rsh.shipment_header_id,
                             'SHIPMENT_HEADER_ID'
                            );
      END IF;

      IF (rti.shipment_num IS NULL) THEN
         rti.shipment_num  := rsh.shipment_num;
      ELSIF(rti.shipment_num <> rsh.shipment_num) THEN
         invalid_match_value(rti.shipment_num,
                             rsh.shipment_num,
                             'SHIPMENT_NUM'
                            );
      END IF;

      IF (rti.to_organization_id IS NULL) THEN
         rti.to_organization_id  := rsh.ship_to_org_id;
      ELSIF(rti.to_organization_id <> rsh.ship_to_org_id) THEN
         invalid_match_value(rti.to_organization_id,
                             rsh.ship_to_org_id,
                             'TO_ORGANIZATION_ID'
                            );
      END IF;

      IF (rti.bill_of_lading IS NULL) THEN
         rti.bill_of_lading  := rsh.bill_of_lading;
      END IF;

      IF (rti.currency_code IS NULL) THEN
         rti.currency_code  := rsh.currency_code;
      END IF;

      IF (rti.currency_conversion_date IS NULL) THEN
         rti.currency_conversion_date  := rsh.conversion_date;
      END IF;

      IF (rti.currency_conversion_rate IS NULL) THEN
         rti.currency_conversion_rate  := TO_NUMBER(rsh.conversion_rate);
      END IF;

      IF (rti.currency_conversion_type IS NULL) THEN
         rti.currency_conversion_type  := rsh.conversion_rate_type;
      END IF;

      IF (rti.customer_id IS NULL) THEN
         rti.customer_id  := rsh.customer_id;
      END IF;

      IF (rti.customer_site_id IS NULL) THEN
         rti.customer_site_id  := rsh.customer_site_id;
      END IF;

      IF (rti.employee_id IS NULL) THEN
         rti.employee_id  := rsh.employee_id;
      END IF;

      IF (rti.expected_receipt_date IS NULL) THEN
         rti.expected_receipt_date  := rsh.expected_receipt_date;
      END IF;

      IF (rti.freight_carrier_code IS NULL) THEN
         rti.freight_carrier_code  := rsh.freight_carrier_code;
      END IF;

      IF (rti.government_context IS NULL) THEN
         rti.government_context  := rsh.government_context;
      END IF;

      IF (rti.num_of_containers IS NULL) THEN
         rti.num_of_containers  := rsh.num_of_containers;
      END IF;

      IF (rti.packing_slip IS NULL) THEN
         rti.packing_slip  := rsh.packing_slip;
      END IF;

      IF (rti.receipt_source_code IS NULL) THEN
         rti.receipt_source_code  := rsh.receipt_source_code;
      END IF;

      IF (rti.request_id IS NULL) THEN
         rti.request_id  := rsh.request_id;
      END IF;

      IF (rti.shipped_date IS NULL) THEN
         rti.shipped_date  := rsh.shipped_date;
      END IF;

      IF (rti.ship_line_attribute1 IS NULL) THEN
         rti.ship_line_attribute1  := rsh.attribute1;
      END IF;

      IF (rti.ship_line_attribute10 IS NULL) THEN
         rti.ship_line_attribute10  := rsh.attribute10;
      END IF;

      IF (rti.ship_line_attribute11 IS NULL) THEN
         rti.ship_line_attribute11  := rsh.attribute11;
      END IF;

      IF (rti.ship_line_attribute12 IS NULL) THEN
         rti.ship_line_attribute12  := rsh.attribute12;
      END IF;

      IF (rti.ship_line_attribute13 IS NULL) THEN
         rti.ship_line_attribute13  := rsh.attribute13;
      END IF;

      IF (rti.ship_line_attribute14 IS NULL) THEN
         rti.ship_line_attribute14  := rsh.attribute14;
      END IF;

      IF (rti.ship_line_attribute15 IS NULL) THEN
         rti.ship_line_attribute15  := rsh.attribute15;
      END IF;

      IF (rti.ship_line_attribute2 IS NULL) THEN
         rti.ship_line_attribute2  := rsh.attribute2;
      END IF;

      IF (rti.ship_line_attribute3 IS NULL) THEN
         rti.ship_line_attribute3  := rsh.attribute3;
      END IF;

      IF (rti.ship_line_attribute4 IS NULL) THEN
         rti.ship_line_attribute4  := rsh.attribute4;
      END IF;

      IF (rti.ship_line_attribute5 IS NULL) THEN
         rti.ship_line_attribute5  := rsh.attribute5;
      END IF;

      IF (rti.ship_line_attribute6 IS NULL) THEN
         rti.ship_line_attribute6  := rsh.attribute6;
      END IF;

      IF (rti.ship_line_attribute7 IS NULL) THEN
         rti.ship_line_attribute7  := rsh.attribute7;
      END IF;

      IF (rti.ship_line_attribute8 IS NULL) THEN
         rti.ship_line_attribute8  := rsh.attribute8;
      END IF;

      IF (rti.ship_line_attribute9 IS NULL) THEN
         rti.ship_line_attribute9  := rsh.attribute9;
      END IF;

      IF (rti.ship_line_attribute_category IS NULL) THEN
         rti.ship_line_attribute_category  := rsh.attribute_category;
      END IF;

      IF (rti.ship_to_location_id IS NULL) THEN
         rti.ship_to_location_id  := rsh.ship_to_location_id;
      END IF;

      IF (rti.tax_amount IS NULL) THEN
         rti.tax_amount  := rsh.tax_amount;
      END IF;

      IF (rti.tax_name IS NULL) THEN
         rti.tax_name  := rsh.tax_name;
      END IF;

      IF (rti.ussgl_transaction_code IS NULL) THEN
         rti.ussgl_transaction_code  := rsh.ussgl_transaction_code;
      END IF;

      IF (rti.vendor_id IS NULL) THEN
         rti.vendor_id  := rsh.vendor_id;
      END IF;

      /* Bug 10306164 comment the code related to Vendor site , as RTIs
         with same RSH may have differnt vendor site id */

      /* IF (rti.vendor_site_id IS NULL) THEN
         rti.vendor_site_id  := rsh.vendor_site_id;
      END IF;*/

      IF (rti.waybill_airbill_num IS NULL) THEN
         rti.waybill_airbill_num  := rsh.waybill_airbill_num;
      END IF;
   END default_rti_from_rsh;

   PROCEDURE default_rti_from_pod(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      pod        po_distributions_all%ROWTYPE;
      x_quantity NUMBER;
   BEGIN
      IF (rti.po_distribution_id IS NOT NULL) THEN
         pod  := rcv_table_functions.get_pod_row_from_id(rti.po_distribution_id);
      END IF;

      IF (pod.po_distribution_id IS NULL) THEN
         RETURN;
      END IF;

      IF (rti.document_distribution_num IS NULL) THEN
         rti.document_distribution_num  := pod.distribution_num;
      ELSIF(rti.document_distribution_num <> pod.distribution_num) THEN
         invalid_match_value(rti.document_distribution_num,
                             pod.distribution_num,
                             'DOCUMENT_DISTRIBUTION_NUM'
                            );
      END IF;

      IF (rti.org_id IS NULL) THEN
         rti.org_id  := pod.org_id;
      ELSIF(rti.org_id <> pod.org_id) THEN
         invalid_match_value(rti.org_id,
                             pod.org_id,
                             'ORG_ID'
                            );
      END IF;

      IF (rti.po_distribution_id IS NULL) THEN
         rti.po_distribution_id  := pod.po_distribution_id;
      ELSIF(rti.po_distribution_id <> pod.po_distribution_id) THEN
         invalid_match_value(rti.po_distribution_id,
                             pod.po_distribution_id,
                             'PO_DISTRIBUTION_ID'
                            );
      END IF;

      IF (rti.po_header_id IS NULL) THEN
         rti.po_header_id  := pod.po_header_id;
      ELSIF(rti.po_header_id <> pod.po_header_id) THEN
         invalid_match_value(rti.po_header_id,
                             pod.po_header_id,
                             'PO_HEADER_ID'
                            );
      END IF;

      IF (rti.po_line_id IS NULL) THEN
         rti.po_line_id  := pod.po_line_id;
      ELSIF(rti.po_line_id <> pod.po_line_id) THEN
         invalid_match_value(rti.po_line_id,
                             pod.po_line_id,
                             'PO_LINE_ID'
                            );
      END IF;

      IF (rti.po_line_location_id IS NULL) THEN
         rti.po_line_location_id  := pod.line_location_id;
      ELSIF(rti.po_line_location_id <> pod.line_location_id) THEN
         invalid_match_value(rti.po_line_location_id,
                             pod.line_location_id,
                             'PO_LINE_LOCATION_ID'
                            );
      END IF;

      IF (rti.po_release_id IS NULL) THEN
         rti.po_release_id  := pod.po_release_id;
      ELSIF(rti.po_release_id <> pod.po_release_id) THEN
         invalid_match_value(rti.po_release_id,
                             pod.po_release_id,
                             'PO_RELEASE_ID'
                            );
      END IF;

      IF (rti.req_distribution_id IS NULL) THEN
         rti.req_distribution_id  := pod.req_distribution_id;
      ELSIF(rti.req_distribution_id <> pod.req_distribution_id) THEN
         invalid_match_value(rti.req_distribution_id,
                             pod.req_distribution_id,
                             'REQ_DISTRIBUTION_ID'
                            );
      END IF;

      IF (rti.to_organization_id IS NULL) THEN
         rti.to_organization_id  := pod.destination_organization_id;
      ELSIF(rti.to_organization_id <> pod.destination_organization_id) THEN
         invalid_match_value(rti.to_organization_id,
                             pod.destination_organization_id,
                             'TO_ORGANIZATION_ID'
                            );
      END IF;

      IF (rti.wip_entity_id IS NULL) THEN
         rti.wip_entity_id  := pod.wip_entity_id;
      ELSIF(rti.wip_entity_id <> pod.wip_entity_id) THEN
         invalid_match_value(rti.wip_entity_id,
                             pod.wip_entity_id,
                             'WIP_ENTITY_ID'
                            );
      END IF;

      IF (rti.wip_line_id IS NULL) THEN
         rti.wip_line_id  := pod.wip_line_id;
      ELSIF(rti.wip_line_id <> pod.wip_line_id) THEN
         invalid_match_value(rti.wip_line_id,
                             pod.wip_line_id,
                             'WIP_LINE_ID'
                            );
      END IF;

      IF (rti.wip_operation_seq_num IS NULL) THEN
         rti.wip_operation_seq_num  := pod.wip_operation_seq_num;
      ELSIF(rti.wip_operation_seq_num <> pod.wip_operation_seq_num) THEN
         invalid_match_value(rti.wip_operation_seq_num,
                             pod.wip_operation_seq_num,
                             'WIP_OPERATION_SEQ_NUM'
                            );
      END IF;

      IF (rti.wip_repetitive_schedule_id IS NULL) THEN
         rti.wip_repetitive_schedule_id  := pod.wip_repetitive_schedule_id;
      ELSIF(rti.wip_repetitive_schedule_id <> pod.wip_repetitive_schedule_id) THEN
         invalid_match_value(rti.wip_repetitive_schedule_id,
                             pod.wip_repetitive_schedule_id,
                             'WIP_REPETITIVE_SCHEDULE_ID'
                            );
      END IF;

      IF (rti.wip_resource_seq_num IS NULL) THEN
         rti.wip_resource_seq_num  := pod.wip_resource_seq_num;
      ELSIF(rti.wip_resource_seq_num <> pod.wip_resource_seq_num) THEN
         invalid_match_value(rti.wip_resource_seq_num,
                             pod.wip_resource_seq_num,
                             'WIP_RESOURCE_SEQ_NUM'
                            );
      END IF;

      IF (rti.actual_cost IS NULL) THEN
         rti.actual_cost  := pod.amount_billed;
      END IF;

	/* Bug 5299177
	 * We expect customers to give the amount. We do not default but error out
	 * if it is not given. Commenting out the foll code.
      IF (rti.amount IS NULL) THEN
         rti.amount  := pod.amount_ordered - pod.amount_cancelled;
      END IF;
	* 5299177 */
      /* Start of Bug 6487455 */

      /* IF (rti.attribute1 IS NULL) THEN
         rti.attribute1  := pod.attribute1;
      END IF;

      IF (rti.attribute10 IS NULL) THEN
         rti.attribute10  := pod.attribute10;
      END IF;

      IF (rti.attribute11 IS NULL) THEN
         rti.attribute11  := pod.attribute11;
      END IF;

      IF (rti.attribute12 IS NULL) THEN
         rti.attribute12  := pod.attribute12;
      END IF;

      IF (rti.attribute13 IS NULL) THEN
         rti.attribute13  := pod.attribute13;
      END IF;

      IF (rti.attribute14 IS NULL) THEN
         rti.attribute14  := pod.attribute14;
      END IF;

      IF (rti.attribute15 IS NULL) THEN
         rti.attribute15  := pod.attribute15;
      END IF;

      IF (rti.attribute2 IS NULL) THEN
         rti.attribute2  := pod.attribute2;
      END IF;

      IF (rti.attribute3 IS NULL) THEN
         rti.attribute3  := pod.attribute3;
      END IF;

      IF (rti.attribute4 IS NULL) THEN
         rti.attribute4  := pod.attribute4;
      END IF;

      IF (rti.attribute5 IS NULL) THEN
         rti.attribute5  := pod.attribute5;
      END IF;

      IF (rti.attribute6 IS NULL) THEN
         rti.attribute6  := pod.attribute6;
      END IF;

      IF (rti.attribute7 IS NULL) THEN
         rti.attribute7  := pod.attribute7;
      END IF;

      IF (rti.attribute8 IS NULL) THEN
         rti.attribute8  := pod.attribute8;
      END IF;

      IF (rti.attribute9 IS NULL) THEN
         rti.attribute9  := pod.attribute9;
      END IF;

      IF (rti.attribute_category IS NULL) THEN
         rti.attribute_category  := pod.attribute_category;
      END IF; */

      /* End Bug 6487455 */

      IF (rti.bom_resource_id IS NULL) THEN
         rti.bom_resource_id  := pod.bom_resource_id;
      END IF;

      IF (rti.charge_account_id IS NULL) THEN
         rti.charge_account_id  := NVL(pod.dest_charge_account_id, pod.code_combination_id);
      END IF;

      /* Begin Bug 13013727, if match option is receipt, we should default this
         from transaction date*/
      /* IF (rti.currency_conversion_date IS NULL) THEN
         rti.currency_conversion_date  := pod.rate_date;
      END IF;

      IF (rti.currency_conversion_rate IS NULL) THEN
         rti.currency_conversion_rate  := pod.rate;
      END IF; */
      /* End Bug 13013727 */

      IF (rti.deliver_to_location_id IS NULL) THEN
         rti.deliver_to_location_id  := pod.deliver_to_location_id;
      END IF;

      IF (rti.deliver_to_person_id IS NULL) THEN
         rti.deliver_to_person_id  := pod.deliver_to_person_id;
      END IF;

      IF (rti.destination_context IS NULL) THEN
         rti.destination_context  := pod.destination_context;
      END IF;

      IF (rti.destination_type_code IS NULL) THEN
         rti.destination_type_code  := pod.destination_type_code;
      END IF;

      IF (rti.government_context IS NULL) THEN
         rti.government_context  := pod.government_context;
      END IF;

      IF (rti.project_id IS NULL) THEN
         rti.project_id  := pod.project_id;
      END IF;

	/* Bug 5584736.
	 * We have a detailed defaulting routine for defaulting
	 * subinventory and locator later. Commenting out this code
	 * here since this is creating problems later.
      IF (rti.subinventory IS NULL) THEN
         rti.subinventory  := pod.destination_subinventory;
      END IF;
	*/

      IF (rti.task_id IS NULL) THEN
         rti.task_id  := pod.task_id;
      END IF;

      IF (rti.ussgl_transaction_code IS NULL) THEN
         rti.ussgl_transaction_code  := pod.ussgl_transaction_code;
      END IF;

      --Quantity
	/* Bug 5299177
	 * We expect customers to give the quantity. We do not default but error out
	 * if it is not given. Commenting out the foll code.
      IF (rti.quantity IS NULL) THEN
         x_quantity              := pod.quantity_billed;

         IF (   x_quantity = 0
             OR x_quantity IS NULL) THEN
            x_quantity  := pod.quantity_ordered - NVL(pod.quantity_cancelled, 0);
         END IF;

         rti.quantity            := x_quantity;
         g_subtract_pll_qty_rcv  := TRUE;
      END IF;
	* 5299177 */
   END default_rti_from_pod;

   PROCEDURE default_rti_from_pll(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      pll        po_line_locations_all%ROWTYPE;
      x_quantity NUMBER;
   BEGIN
      IF (rti.po_line_location_id IS NOT NULL) THEN
         pll  := rcv_table_functions.get_pll_row_from_id(rti.po_line_location_id);
      END IF;

      IF (pll.line_location_id IS NULL) THEN
         RETURN;
      END IF;

      IF (rti.document_shipment_line_num IS NULL) THEN
         rti.document_shipment_line_num  := pll.shipment_num;
      ELSIF(rti.document_shipment_line_num <> pll.shipment_num) THEN
         invalid_match_value(rti.document_shipment_line_num,
                             pll.shipment_num,
                             'DOCUMENT_SHIPMENT_LINE_NUM'
                            );
      END IF;

      IF (rti.org_id IS NULL) THEN
         rti.org_id  := pll.org_id;
      ELSIF(rti.org_id <> pll.org_id) THEN
         invalid_match_value(rti.org_id,
                             pll.org_id,
                             'ORG_ID'
                            );
      END IF;

      IF (rti.po_header_id IS NULL) THEN
         rti.po_header_id  := pll.po_header_id;
      ELSIF(rti.po_header_id <> pll.po_header_id) THEN
         invalid_match_value(rti.po_header_id,
                             pll.po_header_id,
                             'PO_HEADER_ID'
                            );
      END IF;
      /* Complex work.
       * Get nvl(pll.price_override,pl.unit_price.
      */

      select nvl(poll.price_override,pol.unit_price)
      into pll.price_override
      from po_line_locations_all poll,
           po_lines_all pol
      where poll.line_location_id = pll.line_location_id
      and pol.po_line_id = poll.po_line_id;

      IF (rti.po_unit_price IS NULL) THEN
            rti.po_unit_price  := pll.price_override;
      end if;

      IF (rti.po_line_id IS NULL) THEN
         rti.po_line_id  := pll.po_line_id;
      ELSIF(rti.po_line_id <> pll.po_line_id) THEN
         invalid_match_value(rti.po_line_id,
                             pll.po_line_id,
                             'PO_LINE_ID'
                            );
      END IF;

      IF (rti.po_line_location_id IS NULL) THEN
         rti.po_line_location_id  := pll.line_location_id;
      ELSIF(rti.po_line_location_id <> pll.line_location_id) THEN
         invalid_match_value(rti.po_line_location_id,
                             pll.line_location_id,
                             'PO_LINE_LOCATION_ID'
                            );
      END IF;

      IF (rti.po_release_id IS NULL) THEN
         rti.po_release_id  := pll.po_release_id;
      ELSIF(rti.po_release_id <> pll.po_release_id) THEN
         invalid_match_value(rti.po_release_id,
                             pll.po_release_id,
                             'PO_RELEASE_ID'
                            );
      END IF;

      IF (rti.to_organization_id IS NULL) THEN
         rti.to_organization_id  := pll.ship_to_organization_id;
      ELSIF(rti.to_organization_id <> pll.ship_to_organization_id) THEN
         invalid_match_value(rti.to_organization_id,
                             pll.ship_to_organization_id,
                             'TO_ORGANIZATION_ID'
                            );
      END IF;

     /* Complex Work.
      * Item_description is at the shipment level for
      * complex work POs and at the line level
      * for non-complex work POs.
      */
      select nvl(poll.description,pol.item_description)
      into pll.description
      from po_line_locations_all poll,
           po_lines_all pol
      where poll.line_location_id = pll.line_location_id
      and pol.po_line_id = poll.po_line_id;


         IF (rti.item_description IS NULL) THEN

           /* Bug 4753230 : Item description should not be defaulted for rti rows
           **               populated for OTL retrieval
           */
           IF ( rti.timecard_id IS NULL ) THEN
             rti.item_description  := pll.description;
           END IF;

         ELSIF(rti.item_description <> pll.description) THEN
         /** Bug: 5598511
          * For ASN created with substitution item, item description and item id of rti
          * won't match with the item description and item id of pol or poll.
          * So, bypassing the item description and item id validation for ASN.
          */
          /* IF g_asn_type NOT IN ('ASN','ASBN') THEN --Bug: 5598511
            invalid_match_value(rti.item_description,
                                pll.description,
                                'ITEM_DESCRIPTION'
                               );
            END IF;*/
	    rti.item_description  := pll.description;
	    /* Bug 7012051: Made the item_description to be defaulted  from
	       Pll.description so that transaction should not fail when invalid
	       item description is entered*/
         END IF;


      IF (rti.substitute_unordered_code IS NULL) THEN
         IF (rti.item_description IS NULL) THEN

           /* Bug 4753230 : Item description should not be defaulted for rti rows
           **               populated for OTL retrieval
           */
           IF ( rti.timecard_id IS NULL ) THEN
             rti.item_description  := pll.description;
           END IF;

         ELSIF(rti.item_description <> pll.description) THEN
          /* IF g_asn_type NOT IN ('ASN','ASBN') THEN --Bug: 5598511
            invalid_match_value(rti.item_description,
                                pll.description,
                                'ITEM_DESCRIPTION'
                               );
           END IF;*/
	   rti.item_description  := pll.description;
	    /* Bug 7012051: Made the item_description to be defaulted  from
	       Pll.description so that transaction should not fail when invalid
	       item description is entered*/
         END IF;
      END IF;

      /* Complex Work. We should not default amount since it should
       * be done by the user.
      IF (rti.amount IS NULL) THEN
         rti.amount  := pll.amount;
      END IF;
      */

      IF (rti.attribute1 IS NULL) THEN
         rti.attribute1  := pll.attribute1;
      END IF;

      IF (rti.attribute10 IS NULL) THEN
         rti.attribute10  := pll.attribute10;
      END IF;

      IF (rti.attribute11 IS NULL) THEN
         rti.attribute11  := pll.attribute11;
      END IF;

      IF (rti.attribute12 IS NULL) THEN
         rti.attribute12  := pll.attribute12;
      END IF;

      IF (rti.attribute13 IS NULL) THEN
         rti.attribute13  := pll.attribute13;
      END IF;

      IF (rti.attribute14 IS NULL) THEN
         rti.attribute14  := pll.attribute14;
      END IF;

      IF (rti.attribute15 IS NULL) THEN
         rti.attribute15  := pll.attribute15;
      END IF;

      IF (rti.attribute2 IS NULL) THEN
         rti.attribute2  := pll.attribute2;
      END IF;

      IF (rti.attribute3 IS NULL) THEN
         rti.attribute3  := pll.attribute3;
      END IF;

      IF (rti.attribute4 IS NULL) THEN
         rti.attribute4  := pll.attribute4;
      END IF;

      IF (rti.attribute5 IS NULL) THEN
         rti.attribute5  := pll.attribute5;
      END IF;

      IF (rti.attribute6 IS NULL) THEN
         rti.attribute6  := pll.attribute6;
      END IF;

      IF (rti.attribute7 IS NULL) THEN
         rti.attribute7  := pll.attribute7;
      END IF;

      IF (rti.attribute8 IS NULL) THEN
         rti.attribute8  := pll.attribute8;
      END IF;

      IF (rti.attribute9 IS NULL) THEN
         rti.attribute9  := pll.attribute9;
      END IF;

      IF (rti.attribute_category IS NULL) THEN
         rti.attribute_category  := pll.attribute_category;
      END IF;

      IF (rti.country_of_origin_code IS NULL) THEN
         rti.country_of_origin_code  := pll.country_of_origin_code;
      END IF;

      IF (rti.government_context IS NULL) THEN
         rti.government_context  := pll.government_context;
      END IF;

      IF (rti.routing_header_id IS NULL) THEN
         rti.routing_header_id  := pll.receiving_routing_id;
      END IF;

      IF (rti.secondary_unit_of_measure IS NULL) THEN
         rti.secondary_unit_of_measure  := pll.secondary_unit_of_measure;
      END IF;

      IF (rti.ship_to_location_id IS NULL) THEN
         rti.ship_to_location_id  := pll.ship_to_location_id;
      END IF;

      IF (rti.source_doc_unit_of_measure IS NULL) THEN
         rti.source_doc_unit_of_measure  := pll.unit_meas_lookup_code;
      END IF;

      IF (rti.tax_name IS NULL) THEN
         rti.tax_name  := pll.tax_name;
      END IF;

      IF (rti.unit_of_measure IS NULL) THEN
         rti.unit_of_measure  := pll.unit_meas_lookup_code;
      END IF;

      IF (rti.ussgl_transaction_code IS NULL) THEN
         rti.ussgl_transaction_code  := pll.ussgl_transaction_code;
      END IF;

      /* Complex work. */

      IF (rti.po_unit_price IS NULL) THEN
            rti.po_unit_price  := pll.price_override;
      END IF;
      --Quantity
      /* Complex Work. We should not default quantity since it should
       * be done by the user.
      IF (rti.quantity IS NULL) THEN
         x_quantity    := pll.quantity_billed;

         IF (   x_quantity = 0
             OR x_quantity IS NULL) THEN
            x_quantity  := pll.quantity - NVL(pll.quantity_cancelled, 0);
         END IF;

         rti.quantity  := x_quantity - NVL(pll.quantity_received, 0);

         IF (    rti.secondary_quantity IS NULL
             AND rti.quantity = pll.quantity) THEN
            rti.secondary_quantity  := pll.secondary_quantity;
         END IF;
      ELSIF(g_subtract_pll_qty_rcv = TRUE) THEN
         rti.quantity  := rti.quantity - NVL(pll.quantity_received, 0);
      END IF;
      */
   END default_rti_from_pll;

   PROCEDURE default_rti_from_pol(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      pol po_lines_all%ROWTYPE;
   BEGIN
      asn_debug.put_line('Enter default_rti_from_pol');
      IF (rti.po_line_id IS NOT NULL) THEN
         pol  := rcv_table_functions.get_pol_row_from_id(rti.po_line_id);
      END IF;
      asn_debug.put_line('Afte  get_pol_row_from_id');

      IF (pol.po_line_id IS NULL) THEN
         asn_debug.put_line('pol.po_line_id  is: '||pol.po_line_id);
         RETURN;
      END IF;

      IF (rti.document_line_num IS NULL) THEN
         rti.document_line_num  := pol.line_num;
      ELSIF(rti.document_line_num <> pol.line_num) THEN
         invalid_match_value(rti.document_line_num,
                             pol.line_num,
                             'DOCUMENT_LINE_NUM'
                            );
      END IF;

      IF (rti.substitute_unordered_code IS NULL) THEN
     /* Complex Work.
      * Item_description is at the shipment level for
      * Complex work. For non complex work POs it is at
      * the line level. So the check for item_description
      * is done at the shipment_level itself. Commented
      * out the code here.

         IF (rti.item_description IS NULL) THEN
            rti.item_description  := pol.item_description;
         ELSIF(rti.item_description <> pol.item_description) THEN
            invalid_match_value(rti.item_description,
                                pol.item_description,
                                'ITEM_DESCRIPTION'
                               );
         END IF;

       */
         IF (rti.item_id IS NULL) THEN
            rti.item_id  := pol.item_id;
         ELSIF(rti.item_id <> pol.item_id) THEN
           IF g_asn_type NOT IN ('ASN','ASBN') THEN --Bug: 5598511
             invalid_match_value(rti.item_id,
                                pol.item_id,
                                'ITEM_ID'
                               );
           END IF;
         END IF;

         IF (rti.item_revision IS NULL) THEN
            rti.item_revision  := pol.item_revision;
         /*
         Bug 5975270: We can't compare the two revisions right now
         as we are not sure if item is revision controlled or not.
         ELSIF(rti.item_revision <> pol.item_revision) THEN
           IF g_asn_type NOT IN ('ASN','ASBN') THEN --Bug: 5598511
             invalid_match_value(rti.item_revision,
                                pol.item_revision,
                                'ITEM_REVISION'
                               );
             END IF;
            */
         END IF;
      END IF;

      IF (rti.job_id IS NULL) THEN
         rti.job_id  := pol.job_id;
      ELSIF(rti.job_id <> pol.job_id) THEN
         invalid_match_value(rti.job_id,
                             pol.job_id,
                             'JOB_ID'
                            );
      END IF;

      IF (rti.org_id IS NULL) THEN
         rti.org_id  := pol.org_id;
      ELSIF(rti.org_id <> pol.org_id) THEN
         invalid_match_value(rti.org_id,
                             pol.org_id,
                             'ORG_ID'
                            );
      END IF;

      IF (rti.po_header_id IS NULL) THEN
         rti.po_header_id  := pol.po_header_id;
      ELSIF(rti.po_header_id <> pol.po_header_id) THEN
         invalid_match_value(rti.po_header_id,
                             pol.po_header_id,
                             'PO_HEADER_ID'
                            );
      END IF;

      asn_debug.put_line('Before  po_line_id');
      IF (rti.po_line_id IS NULL) THEN
         rti.po_line_id  := pol.po_line_id;
      ELSIF(rti.po_line_id <> pol.po_line_id) THEN
         invalid_match_value(rti.po_line_id,
                             pol.po_line_id,
                             'PO_LINE_ID'
                            );
      END IF;

      IF (rti.project_id IS NULL) THEN
         rti.project_id  := pol.project_id;
      ELSIF(rti.project_id <> pol.project_id) THEN
         invalid_match_value(rti.project_id,
                             pol.project_id,
                             'PROJECT_ID'
                            );
      END IF;

      IF (rti.task_id IS NULL) THEN
         rti.task_id  := pol.task_id;
      ELSIF(rti.task_id <> pol.task_id) THEN
         invalid_match_value(rti.task_id,
                             pol.task_id,
                             'TASK_ID'
                            );
      END IF;

      /* Complex Work.
       * We should not pick up amount from po_lines.
       * It should be populated by the user.

      IF (rti.amount IS NULL) THEN
         rti.amount  := pol.amount;
      END IF;
     */

     /* Start of Bug 6487455 */

      /* IF (rti.attribute1 IS NULL) THEN
         rti.attribute1  := pol.attribute1;
      END IF;

      IF (rti.attribute10 IS NULL) THEN
         rti.attribute10  := pol.attribute10;
      END IF;

      IF (rti.attribute11 IS NULL) THEN
         rti.attribute11  := pol.attribute11;
      END IF;

      IF (rti.attribute12 IS NULL) THEN
         rti.attribute12  := pol.attribute12;
      END IF;

      IF (rti.attribute13 IS NULL) THEN
         rti.attribute13  := pol.attribute13;
      END IF;

      IF (rti.attribute14 IS NULL) THEN
         rti.attribute14  := pol.attribute14;
      END IF;

      IF (rti.attribute15 IS NULL) THEN
         rti.attribute15  := pol.attribute15;
      END IF;

      IF (rti.attribute2 IS NULL) THEN
         rti.attribute2  := pol.attribute2;
      END IF;

      IF (rti.attribute3 IS NULL) THEN
         rti.attribute3  := pol.attribute3;
      END IF;

      IF (rti.attribute4 IS NULL) THEN
         rti.attribute4  := pol.attribute4;
      END IF;

      IF (rti.attribute5 IS NULL) THEN
         rti.attribute5  := pol.attribute5;
      END IF;

      IF (rti.attribute6 IS NULL) THEN
         rti.attribute6  := pol.attribute6;
      END IF;

      IF (rti.attribute7 IS NULL) THEN
         rti.attribute7  := pol.attribute7;
      END IF;

      IF (rti.attribute8 IS NULL) THEN
         rti.attribute8  := pol.attribute8;
      END IF;

      IF (rti.attribute9 IS NULL) THEN
         rti.attribute9  := pol.attribute9;
      END IF;

      IF (rti.attribute_category IS NULL) THEN
         rti.attribute_category  := pol.attribute_category;
      END IF; */

      /* End Bug 6487455 */

      IF (rti.category_id IS NULL) THEN
         rti.category_id  := pol.category_id;
      END IF;

      IF (rti.government_context IS NULL) THEN
         rti.government_context  := pol.government_context;
      END IF;

      /* Complex Work. */
      IF (rti.po_unit_price IS NULL) THEN
         rti.po_unit_price  := pol.unit_price;
      END IF;

      IF (rti.qc_grade IS NULL) THEN
         rti.qc_grade  := pol.qc_grade;
      END IF;

      IF (rti.secondary_unit_of_measure IS NULL) THEN
         rti.secondary_unit_of_measure  := pol.secondary_unit_of_measure;
      END IF;

      IF (rti.source_doc_unit_of_measure IS NULL) THEN
         rti.source_doc_unit_of_measure  := pol.unit_meas_lookup_code;
      END IF;

      IF (rti.tax_name IS NULL) THEN
         rti.tax_name  := pol.tax_name;
      END IF;

      IF (rti.unit_of_measure IS NULL) THEN
         rti.unit_of_measure  := pol.unit_meas_lookup_code;
      END IF;

      IF (rti.ussgl_transaction_code IS NULL) THEN
         rti.ussgl_transaction_code  := pol.ussgl_transaction_code;
      END IF;

      --Quantity
      /* Complex Work.
       * User should enter quantity. Should not be defaulted.

      IF (rti.quantity IS NULL) THEN
         rti.quantity  := pol.quantity;

         IF (rti.secondary_quantity IS NULL) THEN
            rti.secondary_quantity  := pol.secondary_quantity;
         END IF;
      END IF;
      */
      asn_debug.put_line('Leave default_rti_from_pol');
   END default_rti_from_pol;

   PROCEDURE default_rti_from_poh(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      poh po_headers_all%ROWTYPE;
   BEGIN
      IF (rti.po_header_id IS NOT NULL) THEN
         poh  := rcv_table_functions.get_poh_row_from_id(rti.po_header_id);
      END IF;

      IF (poh.po_header_id IS NULL) THEN
         RETURN;
      END IF;

      IF (rti.document_num IS NULL) THEN
         rti.document_num  := poh.segment1;
      ELSIF(rti.document_num <> poh.segment1) THEN
         invalid_match_value(rti.document_num,
                             poh.segment1,
                             'DOCUMENT_NUM'
                            );
      END IF;

      IF (rti.org_id IS NULL) THEN
         rti.org_id  := poh.org_id;
      ELSIF(rti.org_id <> poh.org_id) THEN
         invalid_match_value(rti.org_id,
                             poh.org_id,
                             'ORG_ID'
                            );
      END IF;

      IF (rti.po_header_id IS NULL) THEN
         rti.po_header_id  := poh.po_header_id;
      ELSIF(rti.po_header_id <> poh.po_header_id) THEN
         invalid_match_value(rti.po_header_id,
                             poh.po_header_id,
                             'PO_HEADER_ID'
                            );
      END IF;

      /* Start of Bug 6487455 */

      /* IF (rti.attribute1 IS NULL) THEN
         rti.attribute1  := poh.attribute1;
      END IF;

      IF (rti.attribute10 IS NULL) THEN
         rti.attribute10  := poh.attribute10;
      END IF;

      IF (rti.attribute11 IS NULL) THEN
         rti.attribute11  := poh.attribute11;
      END IF;

      IF (rti.attribute12 IS NULL) THEN
         rti.attribute12  := poh.attribute12;
      END IF;

      IF (rti.attribute13 IS NULL) THEN
         rti.attribute13  := poh.attribute13;
      END IF;

      IF (rti.attribute14 IS NULL) THEN
         rti.attribute14  := poh.attribute14;
      END IF;

      IF (rti.attribute15 IS NULL) THEN
         rti.attribute15  := poh.attribute15;
      END IF;

      IF (rti.attribute2 IS NULL) THEN
         rti.attribute2  := poh.attribute2;
      END IF;

      IF (rti.attribute3 IS NULL) THEN
         rti.attribute3  := poh.attribute3;
      END IF;

      IF (rti.attribute4 IS NULL) THEN
         rti.attribute4  := poh.attribute4;
      END IF;

      IF (rti.attribute5 IS NULL) THEN
         rti.attribute5  := poh.attribute5;
      END IF;

      IF (rti.attribute6 IS NULL) THEN
         rti.attribute6  := poh.attribute6;
      END IF;

      IF (rti.attribute7 IS NULL) THEN
         rti.attribute7  := poh.attribute7;
      END IF;

      IF (rti.attribute8 IS NULL) THEN
         rti.attribute8  := poh.attribute8;
      END IF;

      IF (rti.attribute9 IS NULL) THEN
         rti.attribute9  := poh.attribute9;
      END IF;

      IF (rti.attribute_category IS NULL) THEN
         rti.attribute_category  := poh.attribute_category;
      END IF; */

      /* End Bug 6487455 */

      IF (rti.currency_code IS NULL) THEN
         rti.currency_code  := poh.currency_code;
      END IF;

      /* Begin Bug 13013727, if match option is receipt,
         we should default this from transaction date*/
      /* IF (rti.currency_conversion_date IS NULL) THEN
         rti.currency_conversion_date  := poh.rate_date;
      END IF;

      IF (rti.currency_conversion_rate IS NULL) THEN
         rti.currency_conversion_rate  := poh.rate;
      END IF; */
      /* End Bug 13013727. */

      IF (rti.currency_conversion_type IS NULL) THEN
         rti.currency_conversion_type  := poh.rate_type;
      END IF;

      IF (rti.employee_id IS NULL) THEN
         rti.employee_id  := poh.agent_id;
      END IF;

      IF (rti.government_context IS NULL) THEN
         rti.government_context  := poh.government_context;
      END IF;

      IF (rti.interface_source_code IS NULL) THEN
         rti.interface_source_code  := poh.interface_source_code;
      END IF;

      IF (rti.ship_to_location_id IS NULL) THEN
         rti.ship_to_location_id  := poh.ship_to_location_id;
      END IF;

      IF (rti.ussgl_transaction_code IS NULL) THEN
         rti.ussgl_transaction_code  := poh.ussgl_transaction_code;
      END IF;

      IF (rti.vendor_id IS NULL) THEN
         rti.vendor_id  := poh.vendor_id;
      END IF;
      -- Bug 6520985
      -- Bug 10306164 revert commented code in bug 6520985
      IF (rti.vendor_site_id IS NULL) THEN
         rti.vendor_site_id  := poh.vendor_site_id;
      END IF;
   END default_rti_from_poh;

   PROCEDURE default_rti_from_oel(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      oel oe_order_lines_all%ROWTYPE;
   BEGIN
      IF (rti.oe_order_line_id IS NOT NULL) THEN
         oel  := rcv_table_functions.get_oel_row_from_id(rti.oe_order_line_id);
      END IF;

      IF (oel.line_id IS NULL) THEN
         RETURN;
      END IF;
/** Bug:5502427
  *  default_rti_from_oel() procedure will get invoked only for RMAs
  *  as per the fix done through this bug. So no need to handle
  *  the Internal Order case in this procedure
  */
--      IF (rti.source_document_code = 'RMA') THEN
         IF (rti.to_organization_id IS NULL) THEN
            rti.to_organization_id  := oel.ship_from_org_id;
         ELSIF(rti.to_organization_id <> oel.ship_from_org_id) THEN
            invalid_match_value(rti.to_organization_id,
                                oel.ship_from_org_id,
                                'TO_ORGANIZATION_ID'
                               );
         END IF;
      /* WDK - This appears to cause a problem
      IF (rti.from_organization_id IS NULL) THEN
         rti.from_organization_id  := oel.ship_to_org_id;
      END IF;
      */
/*      ELSE --RTI.SOURCE_CODE_CODE = 'REQ'
         IF (rti.from_organization_id IS NULL) THEN
            rti.from_organization_id  := oel.ship_from_org_id;
         ELSIF(rti.from_organization_id <> oel.ship_from_org_id) THEN
            invalid_match_value(rti.from_organization_id,
                                oel.ship_from_org_id,
                                'FROM_ORGANIZATION_ID'
                               );
         END IF;

         IF (rti.to_organization_id IS NULL) THEN
            rti.to_organization_id  := oel.ship_to_org_id;
         END IF;
      END IF;*/

      IF (rti.substitute_unordered_code IS NULL) THEN
         IF (rti.item_id IS NULL) THEN
            rti.item_id  := oel.inventory_item_id;
         ELSIF(rti.item_id <> oel.inventory_item_id) THEN
            invalid_match_value(rti.item_id,
                                oel.inventory_item_id,
                                'ITEM_ID'
                               );
         END IF;
      END IF;

      IF (rti.oe_order_header_id IS NULL) THEN
         rti.oe_order_header_id  := oel.header_id;
      ELSIF(rti.oe_order_header_id <> oel.header_id) THEN
         invalid_match_value(rti.oe_order_header_id,
                             oel.header_id,
                             'OE_ORDER_HEADER_ID'
                            );
      END IF;

      IF (rti.oe_order_line_id IS NULL) THEN
         rti.oe_order_line_id  := oel.line_id;
      ELSIF(rti.oe_order_line_id <> oel.line_id) THEN
         invalid_match_value(rti.oe_order_line_id,
                             oel.line_id,
                             'OE_ORDER_LINE_ID'
                            );
      END IF;

      IF (rti.oe_order_line_num IS NULL) THEN
         rti.oe_order_line_num  := oel.line_number;
      ELSIF(rti.oe_order_line_num <> oel.line_number) THEN
         invalid_match_value(rti.oe_order_line_num,
                             oel.line_number,
                             'OE_ORDER_LINE_NUM'
                            );
      END IF;

      IF (rti.document_line_num IS NULL) THEN
         rti.document_line_num  := oel.line_number;
      ELSIF(rti.document_line_num <> oel.line_number) THEN
         invalid_match_value(rti.document_line_num,
                             oel.line_number,
                             'DOCUMENT_LINE_NUM'
                            );
      END IF;

      IF (rti.org_id IS NULL) THEN
         rti.org_id  := oel.org_id;
      ELSIF(rti.org_id <> oel.org_id) THEN
         invalid_match_value(rti.org_id,
                             oel.org_id,
                             'ORG_ID'
                            );
      END IF;

      IF (rti.project_id IS NULL) THEN
         rti.project_id  := oel.project_id;
      ELSIF(rti.project_id <> oel.project_id) THEN
         invalid_match_value(rti.project_id,
                             oel.project_id,
                             'PROJECT_ID'
                            );
      END IF;

      IF (rti.task_id IS NULL) THEN
         rti.task_id  := oel.task_id;
      ELSIF(rti.task_id <> oel.task_id) THEN
         invalid_match_value(rti.task_id,
                             oel.task_id,
                             'TASK_ID'
                            );
      END IF;

      IF (rti.attribute1 IS NULL) THEN
         rti.attribute1  := oel.return_attribute1;
      END IF;

      IF (rti.attribute10 IS NULL) THEN
         rti.attribute10  := oel.return_attribute10;
      END IF;

      IF (rti.attribute11 IS NULL) THEN
         rti.attribute11  := oel.return_attribute11;
      END IF;

      IF (rti.attribute12 IS NULL) THEN
         rti.attribute12  := oel.return_attribute12;
      END IF;

      IF (rti.attribute13 IS NULL) THEN
         rti.attribute13  := oel.return_attribute13;
      END IF;

      IF (rti.attribute14 IS NULL) THEN
         rti.attribute14  := oel.return_attribute14;
      END IF;

      IF (rti.attribute15 IS NULL) THEN
         rti.attribute15  := oel.return_attribute15;
      END IF;

      IF (rti.attribute2 IS NULL) THEN
         rti.attribute2  := oel.return_attribute2;
      END IF;

      IF (rti.attribute3 IS NULL) THEN
         rti.attribute3  := oel.return_attribute3;
      END IF;

      IF (rti.attribute4 IS NULL) THEN
         rti.attribute4  := oel.return_attribute4;
      END IF;

      IF (rti.attribute5 IS NULL) THEN
         rti.attribute5  := oel.return_attribute5;
      END IF;

      IF (rti.attribute6 IS NULL) THEN
         rti.attribute6  := oel.return_attribute6;
      END IF;

      IF (rti.attribute7 IS NULL) THEN
         rti.attribute7  := oel.return_attribute7;
      END IF;

      IF (rti.attribute8 IS NULL) THEN
         rti.attribute8  := oel.return_attribute8;
      END IF;

      IF (rti.attribute9 IS NULL) THEN
         rti.attribute9  := oel.return_attribute9;
      END IF;

      IF (rti.attribute_category IS NULL) THEN
         rti.attribute_category  := oel.return_context;
      END IF;

      IF (rti.customer_id IS NULL) THEN
         rti.customer_id  := oel.end_customer_id;
      END IF;

      IF (rti.customer_item_num IS NULL) THEN
         rti.customer_item_num  := oel.end_item_unit_number;
      END IF;

      IF (rti.customer_site_id IS NULL) THEN
         rti.customer_site_id  := oel.end_customer_site_use_id;
      END IF;

      IF (rti.freight_carrier_code IS NULL) THEN
         rti.freight_carrier_code  := oel.freight_carrier_code;
      END IF;

      IF (rti.item_num IS NULL) THEN
         rti.item_num  := oel.ordered_item;
      END IF;

      IF (rti.item_revision IS NULL) THEN
         rti.item_revision  := oel.item_revision;
      END IF;

      IF (rti.po_unit_price IS NULL) THEN
         rti.po_unit_price  := oel.unit_selling_price;
      END IF;

      IF (rti.secondary_uom_code IS NULL) THEN
         rti.secondary_uom_code  := NVL(oel.shipping_quantity_uom2, oel.ordered_quantity_uom2);
      END IF;

	/* Bug 5584736.
	 * We have a detailed defaulting routine for defaulting
	 * subinventory and locator later. Commenting out this code
	 * here since this is creating problems later.
      IF (rti.subinventory IS NULL) THEN
         rti.subinventory  := oel.subinventory;
      END IF;
	*/

      IF (rti.tax_amount IS NULL) THEN
         rti.tax_amount  := oel.tax_value;
      END IF;

      IF (rti.tax_name IS NULL) THEN
         rti.tax_name  := oel.tax_code;
      END IF;

      IF (rti.uom_code IS NULL) THEN
         rti.uom_code  := NVL(oel.shipping_quantity_uom, oel.order_quantity_uom);
      END IF;

    /* Bug 7196654
    * Made the item_description to be defaulted  from
    * oel.user_item_description so that transaction should not fail
    * when invalid item description is entered*/

      rti.item_description := oel.user_item_description;

    /* end Bug 7196654 */

      --Quantity
	/* Bug 5299177
	 * We expect customers to give the quantity. We do not default but error out
	 * if it is not given. Commenting out the foll code.
      IF (rti.quantity IS NULL) THEN
         rti.quantity  := NVL(oel.shipped_quantity, oel.ordered_quantity);

         IF (rti.secondary_quantity IS NULL) THEN
            rti.secondary_quantity  := NVL(oel.shipped_quantity2, oel.ordered_quantity2);
         END IF;
      END IF;
	* 5299177 */
   END default_rti_from_oel;

   PROCEDURE default_rti_from_oeh(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      oeh oe_order_headers_all%ROWTYPE;
   BEGIN
      IF (rti.oe_order_header_id IS NOT NULL) THEN
         oeh  := rcv_table_functions.get_oeh_row_from_id(rti.oe_order_header_id);
      END IF;

      IF (oeh.header_id IS NULL) THEN
         RETURN;
      END IF;

      IF (rti.oe_order_num IS NULL) THEN
         rti.oe_order_num  := oeh.order_number;
      ELSIF(rti.oe_order_num <> oeh.order_number) THEN
         invalid_match_value(rti.oe_order_num,
                             oeh.order_number,
                             'OE_ORDER_NUM'
                            );
      END IF;

      IF (rti.document_num IS NULL) THEN
         rti.document_num  := oeh.order_number;
      ELSIF(rti.document_num <> oeh.order_number) THEN
         invalid_match_value(rti.document_num,
                             oeh.order_number,
                             'DOCUMENT_NUM'
                            );
      END IF;

      IF (rti.org_id IS NULL) THEN
         rti.org_id  := oeh.org_id;
      ELSIF(rti.org_id <> oeh.org_id) THEN
         invalid_match_value(rti.org_id,
                             oeh.org_id,
                             'ORG_ID'
                            );
      END IF;
/** Bug:5502427
  *  default_rti_from_oeh() procedure will get invoked only for RMAs
  *  as per the fix done through this bug. So no need to handle
  *  the Internal Order case in this procedure
  */
--      IF (rti.source_document_code = 'RMA') THEN
         IF (rti.to_organization_id IS NULL) THEN
            rti.to_organization_id  := oeh.ship_from_org_id;
         END IF;
      /* WDK - This appears to cause a problem
      IF (rti.from_organization_id IS NULL) THEN
         rti.from_organization_id  := oeh.ship_to_org_id;
      END IF;
      */
/*      ELSE --RTI.SOURCE_CODE_CODE = 'REQ'
         IF (rti.from_organization_id IS NULL) THEN
            rti.from_organization_id  := oeh.ship_from_org_id;
         END IF;

         IF (rti.to_organization_id IS NULL) THEN
            rti.to_organization_id  := oeh.ship_to_org_id;
         END IF;
      END IF;*/

      IF (rti.currency_conversion_date IS NULL) THEN
         rti.currency_conversion_date  := oeh.conversion_rate_date;
      END IF;

      IF (rti.currency_conversion_rate IS NULL) THEN
         rti.currency_conversion_rate  := oeh.conversion_rate;
      END IF;

      IF (rti.currency_conversion_type IS NULL) THEN
         rti.currency_conversion_type  := oeh.conversion_type_code;
      END IF;

      IF (rti.customer_id IS NULL) THEN
         rti.customer_id  := oeh.end_customer_id;
      END IF;

      IF (rti.customer_site_id IS NULL) THEN
         rti.customer_site_id  := oeh.end_customer_site_use_id;
      END IF;

      IF (rti.freight_carrier_code IS NULL) THEN
         rti.freight_carrier_code  := oeh.freight_carrier_code;
      END IF;

      IF (rti.oe_order_header_id IS NULL) THEN
         rti.oe_order_header_id  := oeh.header_id;
      END IF;

      IF (rti.oe_order_num IS NULL) THEN
         rti.oe_order_num  := oeh.order_number;
      END IF;
   END default_rti_from_oeh;

/************************************/
/* SECTION 5: default row framework */
/************************************/
   PROCEDURE create_rhi_from_rti(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      x_receipt_num rcv_headers_interface.receipt_num%TYPE;
   BEGIN
      IF (rti.header_interface_id IS NOT NULL) THEN
         RETURN;
      END IF;

      SELECT rcv_headers_interface_s.NEXTVAL
      INTO   rti.header_interface_id
      FROM   DUAL;

      IF (rti.expected_receipt_date IS NULL) THEN
         rti.expected_receipt_date  := SYSDATE;
      END IF;

      x_receipt_num  := rcv_table_functions.get_rsh_row_from_id(rti.shipment_header_id).receipt_num;

      INSERT INTO rcv_headers_interface
                  (created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   attribute_category,
                   attribute1,
                   attribute10,
                   attribute11,
                   attribute12,
                   attribute13,
                   attribute14,
                   attribute15,
                   attribute2,
                   attribute3,
                   attribute4,
                   attribute5,
                   attribute6,
                   attribute7,
                   attribute8,
                   attribute9,
                   auto_transact_code,
                   bill_of_lading,
                   comments,
                   currency_code,
                   conversion_rate_date,
                   conversion_rate,
                   conversion_rate_type,
                   customer_account_number,
                   customer_id,
                   customer_party_name,
                   customer_site_id,
                   employee_id,
                   expected_receipt_date,
                   freight_carrier_code,
                   from_organization_code,
                   from_organization_id,
                   GROUP_ID,
                   header_interface_id,
                   location_code,
                   location_id,
                   num_of_containers,
                   packing_slip,
                   processing_request_id,
                   processing_status_code,
                   receipt_source_code,
                   receipt_header_id,
                   receipt_num,
                   shipment_num,
                   shipped_date,
                   tax_amount,
                   tax_name,
                   ship_to_organization_code,
                   ship_to_organization_id,
                   org_id,
                   operating_unit,
                   transaction_type,
                   test_flag,
                   usggl_transaction_code,
                   validation_flag,
                   vendor_id,
                   vendor_name,
                   vendor_num,
                   vendor_site_code,
                   vendor_site_id,
                   waybill_airbill_num
                  )
           VALUES (rti.created_by,
                   rti.creation_date,
                   rti.last_updated_by,
                   rti.last_update_date,
                   rti.last_update_login,
                   rti.attribute_category,
                   rti.attribute1,
                   rti.attribute10,
                   rti.attribute11,
                   rti.attribute12,
                   rti.attribute13,
                   rti.attribute14,
                   rti.attribute15,
                   rti.attribute2,
                   rti.attribute3,
                   rti.attribute4,
                   rti.attribute5,
                   rti.attribute6,
                   rti.attribute7,
                   rti.attribute8,
                   rti.attribute9,
                   rti.auto_transact_code,
                   rti.bill_of_lading,
                   rti.comments,
                   rti.currency_code,
                   rti.currency_conversion_date,
                   rti.currency_conversion_rate,
                   rti.currency_conversion_type,
                   rti.customer_account_number,
                   rti.customer_id,
                   rti.customer_party_name,
                   rti.customer_site_id,
                   rti.employee_id,
                   rti.expected_receipt_date,
                   rti.freight_carrier_code,
                   rti.from_organization_code,
                   rti.from_organization_id,
                   rti.GROUP_ID,
                   rti.header_interface_id,
                   rti.location_code,
                   rti.location_id,
                   rti.num_of_containers,
                   rti.packing_slip,
                   rti.processing_request_id,
                   rti.processing_status_code,
                   rti.receipt_source_code,
                   rti.shipment_header_id,
                   x_receipt_num,
                   rti.shipment_num,
                   rti.shipped_date,
                   rti.tax_amount,
                   rti.tax_name,
                   rti.to_organization_code,
                   rti.to_organization_id,
                   rti.org_id,
                   rti.operating_unit,
                   'NEW',
                   'Y',
                   rti.ussgl_transaction_code,
                   rti.validation_flag,
                   rti.vendor_id,
                   rti.vendor_name,
                   rti.vendor_num,
                   rti.vendor_site_code,
                   rti.vendor_site_id,
                   rti.waybill_airbill_num
                  );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END create_rhi_from_rti;

   /*Bug: 4735484
	Defaulting the use_mtl_lot and use_mtl_serial column using
	lot control code and serial control code of the item in the
	given inventory org.
   */
   PROCEDURE default_lot_serial_control(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   )IS
   BEGIN
   /*
    NOTE: For one time item the item_id would be null and hence there is
    no need to populate the lot and serial control code. This case is
    taken care by the help of follwoing if condition.
   */
   IF (rti.item_id IS NOT NULL) THEN
           asn_debug.put_line ('Defaulting use_mtl_lot and use_mtl_serial');
           SELECT   lot_control_code,
                    serial_number_control_code
            INTO   rti.use_mtl_lot,
                   rti.use_mtl_serial
            FROM   mtl_system_items
            WHERE  mtl_system_items.inventory_item_id = rti.item_id
            AND    mtl_system_items.organization_id = rti.to_organization_id;
   END IF;
   EXCEPTION
   WHEN OTHERS THEN
      asn_debug.put_line ('Unable to default use_mtl_lot and use_mtl_serial');
      NULL;
   END default_lot_serial_control;

   PROCEDURE default_header(
      rhi IN OUT NOCOPY rcv_headers_interface%ROWTYPE
   ) IS
   BEGIN
      g_curr_table                := 'RCV_HEADERS_INTERFACE';
      g_curr_group_id             := rhi.GROUP_ID;
      g_curr_header_id            := rhi.header_interface_id;
      g_curr_transaction_id       := rhi.header_interface_id;
      rhi.processing_status_code  := 'PENDING';
      rhi.validation_flag         := 'Y';
      default_rhi_from_code(rhi);
      default_rhi_from_rsh(rhi);
      check_rhi_consistency(rhi);

      IF (rhi.transaction_type IS NULL) THEN
         rhi.transaction_type  := 'NEW';
      END IF;

      IF (rhi.expected_receipt_date IS NULL) THEN
         rhi.expected_receipt_date  := SYSDATE;
      END IF;
   EXCEPTION
      WHEN rcv_table_functions.e_fatal_error THEN
         rcv_error_pkg.log_interface_error(g_curr_table,
                                           rcv_table_functions.g_error_column,
                                           g_curr_group_id,
                                           g_curr_header_id,
                                           g_curr_transaction_id
                                          );
      WHEN rcv_error_pkg.e_fatal_error THEN
         RAISE rcv_error_pkg.e_fatal_error;
      WHEN OTHERS THEN
         rcv_error_pkg.set_sql_error_message('default_header', '000');
         rcv_error_pkg.log_interface_error('INTERFACE_TRANSACTION_ID');
   END default_header;

   PROCEDURE default_transaction(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
      x_dummy_mkr          BOOLEAN;
      x_temp_subinv        rcv_transactions_interface.subinventory%TYPE;
      x_temp_primary_uom   rcv_transactions_interface.primary_unit_of_measure%TYPE;
      x_subinv_starts_null BOOLEAN;
   BEGIN
      elapsed_time('BEGIN default_transaction');
      asn_debug.put_line('rti.interface_transaction_id = ' || rti.interface_transaction_id);
      g_curr_table                 := 'RCV_HEADERS_INTERFACE';
      g_curr_group_id              := rti.GROUP_ID;
      g_curr_header_id             := rti.header_interface_id;
      g_curr_transaction_id        := rti.interface_transaction_id;
      g_subtract_pll_qty_rcv       := FALSE;
      x_subinv_starts_null         := FALSE;
	/* Bug 5584736.
	 * We have a detailed defaulting routine for defaulting
	 * subinventory and locator later. Commenting out this code
	 * here since this is creating problems later.

      IF (    rti.subinventory IS NULL
          AND rti.LOCATOR IS NULL
          AND rti.locator_id IS NULL) THEN
         x_subinv_starts_null  := TRUE;
      END IF;

      IF (SUBSTR(rti.transaction_type,
                 1,
                 6
                ) = 'RETURN') THEN
         --The following code reverses the roles of the subinventories for
         --RETURNs because it was easier to keep a consistent model this way
         --The matching reversal is found at the end and in the error section
         x_temp_subinv          := rti.subinventory;
         rti.subinventory       := rti.from_subinventory;
         rti.from_subinventory  := x_temp_subinv;
      END IF;
	*/

      default_rti_from_code(rti);
      elapsed_time('default_rti_from_code');
      default_rti_from_rhi(rti);
      elapsed_time('default_rti_from_rhi');

      IF (    rti.parent_interface_txn_id IS NOT NULL
          AND rti.parent_transaction_id IS NOT NULL) THEN
         rcv_error_pkg.set_error_message('RCV_CANNOT_HAVE_2_PARENT');
         rcv_error_pkg.log_interface_error('PARENT_TRANSACTION_ID');
      END IF;

      default_rti_from_rti(rti);
      elapsed_time('default_rti_from_rti');
      default_rti_from_rt(rti);
      elapsed_time('default_rti_from_rt');
      rti.processing_status_code   := 'PENDING';
      rti.transaction_status_code  := 'PENDING';
      rti.validation_flag          := 'Y';
      rti.order_transaction_id     := rti.interface_transaction_id;

      IF (rti.transaction_type IS NULL) THEN
         rti.transaction_type  := 'RECEIVE';
      END IF;

      IF (rti.transaction_date IS NULL) THEN
         rti.transaction_date  := SYSDATE;
      END IF;

      IF (rti.interface_source_code IS NULL) THEN
         rti.interface_source_code  := 'RCV';
      END IF;

      IF (    rti.receipt_source_code IS NULL
          AND rti.source_document_code IS NULL) THEN
         rti.receipt_source_code   := 'VENDOR';
         rti.source_document_code  := 'PO';
      END IF;

      IF (rti.receipt_source_code = 'VENDOR') THEN
         IF (rti.source_document_code IS NULL) THEN
            rti.source_document_code  := 'PO';
         ELSIF(rti.source_document_code <> 'PO') THEN
            invalid_match_value(rti.source_document_code,
                                'PO',
                                'SOURCE_DOCUMENT_CODE'
                               );
         END IF;
      ELSIF(rti.receipt_source_code = 'INVENTORY') THEN
         IF (rti.source_document_code IS NULL) THEN
            rti.source_document_code  := 'INVENTORY';
         ELSIF(rti.source_document_code <> 'INVENTORY') THEN
            invalid_match_value(rti.source_document_code,
                                'INVENTORY',
                                'SOURCE_DOCUMENT_CODE'
                               );
         END IF;
      ELSIF(rti.receipt_source_code = 'INTERNAL ORDER') THEN
         IF (rti.source_document_code IS NULL) THEN
            rti.source_document_code  := 'REQ';
         ELSIF(rti.source_document_code <> 'REQ') THEN
            invalid_match_value(rti.source_document_code,
                                'REQ',
                                'SOURCE_DOCUMENT_CODE'
                               );
         END IF;
      ELSIF(rti.receipt_source_code = 'CUSTOMER') THEN
         IF (rti.source_document_code IS NULL) THEN
            rti.source_document_code  := 'RMA';
         ELSIF(rti.source_document_code <> 'RMA') THEN
            invalid_match_value(rti.source_document_code,
                                'RMA',
                                'SOURCE_DOCUMENT_CODE'
                               );
         END IF;
      ELSIF(rti.receipt_source_code IS NOT NULL) THEN
         invalid_value(rti.receipt_source_code, 'RECEIPT_SOURCE_CODE');
      END IF;

      IF (rti.source_document_code = 'PO') THEN
         IF (rti.receipt_source_code IS NULL) THEN
            rti.receipt_source_code  := 'VENDOR';
         ELSIF(rti.receipt_source_code <> 'VENDOR') THEN
            invalid_match_value(rti.receipt_source_code,
                                'VENDOR',
                                'RECEIPT_SOURCE_CODE '
                               );
         END IF;
      ELSIF(rti.source_document_code = 'INVENTORY') THEN
         IF (rti.receipt_source_code IS NULL) THEN
            rti.receipt_source_code  := 'INVENTORY';
         ELSIF(rti.receipt_source_code <> 'INVENTORY') THEN
            invalid_match_value(rti.receipt_source_code,
                                'INVENTORY',
                                'RECEIPT_SOURCE_CODE '
                               );
         END IF;
      ELSIF(rti.source_document_code = 'REQ') THEN
         IF (rti.receipt_source_code IS NULL) THEN
            rti.receipt_source_code  := 'INTERNAL ORDER';
         ELSIF(rti.receipt_source_code <> 'INTERNAL ORDER') THEN
            invalid_match_value(rti.receipt_source_code,
                                'INTERNAL ORDER',
                                'RECEIPT_SOURCE_CODE '
                               );
         END IF;
      ELSIF(rti.source_document_code = 'RMA') THEN
         IF (rti.receipt_source_code IS NULL) THEN
            rti.receipt_source_code  := 'CUSTOMER';
         ELSIF(rti.receipt_source_code <> 'CUSTOMER') THEN
            invalid_match_value(rti.receipt_source_code,
                                'CUSTOMER',
                                'RECEIPT_SOURCE_CODE '
                               );
         END IF;
      ELSIF(rti.source_document_code IS NOT NULL) THEN
         invalid_value(rti.source_document_code, 'SOURCE_DOCUMENT_CODE');
      END IF;

      IF (rti.receipt_source_code IS NULL) THEN
         invalid_null_value('RECEIPT_SOURCE_CODE');
      END IF;

      IF (rti.source_document_code IS NULL) THEN
         invalid_null_value('SOURCE_DOCUMENT_CODE');
      END IF;

      IF (rti.source_document_code = 'INVENTORY') THEN
         IF (rti.document_num IS NULL) THEN
            rti.document_num  := rti.shipment_num;
         ELSIF(rti.document_num <> rti.shipment_num) THEN
            invalid_match_value(rti.document_num,
                                rti.shipment_num,
                                'DOCUMENT_NUM'
                               );
         END IF;

         IF (rti.shipment_num IS NULL) THEN
            rti.shipment_num  := rti.document_num;
         ELSIF(rti.shipment_num <> rti.document_num) THEN
            invalid_match_value(rti.shipment_num,
                                rti.document_num,
                                'SHIPMENT_NUM'
                               );
         END IF;
      END IF;

      elapsed_time('general defaulting');

      IF (    rti.shipment_header_id IS NULL
          AND rti.shipment_num IS NOT NULL) THEN
          --Bug 9005670 Added receipt_source_code in the below procedre call.
         rti.shipment_header_id  := rcv_table_functions.get_rsh_row_from_num(rti.shipment_num,
                                                                             rti.vendor_id,
                                                                             rti.vendor_site_id,
                                                                             rti.to_organization_id,
                                                                             rti.shipped_date,
                                                                             rti.receipt_source_code,
                                                                             no_data_found_is_error    => FALSE
                                                                            ).shipment_header_id;
         elapsed_time('get_rsh_row_from_num');
      END IF;

      IF (    rti.shipment_line_id IS NULL
          AND rti.shipment_header_id IS NOT NULL
          AND rti.document_shipment_line_num IS NOT NULL
          AND rcv_table_functions.get_rhi_row_from_id(rti.header_interface_id).transaction_type<>'ADD') THEN --Add to receipt 17962808
         rti.shipment_line_id  := rcv_table_functions.get_rsl_row_from_num(rti.document_shipment_line_num, rti.shipment_header_id).shipment_line_id; --Bug 8514736
         elapsed_time('get_rsl_row_from_num');
      END IF;

      IF (    rti.shipment_header_id IS NULL
          AND rti.shipment_line_id IS NOT NULL) THEN
         rti.shipment_header_id  := rcv_table_functions.get_rsl_row_from_id(rti.shipment_line_id).shipment_header_id;
      END IF;

      IF (rti.source_document_code in ('INVENTORY','REQ')) THEN -- BUG 8514736 add 'REQ'(Interal Order) to verify
         IF (rti.shipment_header_id IS NULL) THEN
            invalid_null_value('SHIPMENT_HEADER_ID');
         END IF;

         IF (rti.shipment_line_id IS NULL) THEN
            invalid_null_value('SHIPMENT_LINE_ID');
         END IF;
      END IF;

      default_rti_from_rsl(rti);
      elapsed_time('default_rti_from_rsl');
      default_rti_from_rsh(rti);
      elapsed_time('default_rti_from_rsh');

      --The following defaults up the chain if a lower level id is provided
      IF (    rti.po_line_location_id IS NULL
          AND rti.po_distribution_id IS NOT NULL) THEN
         rti.po_line_location_id  := rcv_table_functions.get_pod_row_from_id(rti.po_distribution_id).line_location_id;
      END IF;

      IF (    rti.po_line_id IS NULL
          AND rti.po_line_location_id IS NOT NULL) THEN
         rti.po_line_id  := rcv_table_functions.get_pll_row_from_id(rti.po_line_location_id).po_line_id;
      END IF;

	/* Bug 5299177
	 * We were populating the value of po_header_id to rti.po_line_location_id instead
	 * of rti.po_header_id. Changed it.
	*/
      IF (    rti.po_header_id IS NULL
          AND rti.po_line_id IS NOT NULL) THEN
         rti.po_header_id  := rcv_table_functions.get_pol_row_from_id(rti.po_line_id).po_header_id;
      END IF;

      IF (    rti.oe_order_header_id IS NULL
          AND rti.oe_order_line_id IS NOT NULL) THEN
         rti.oe_order_header_id  := rcv_table_functions.get_oel_row_from_id(rti.oe_order_line_id).header_id;
      END IF;

      IF (rti.transaction_type IN('UNORDERED', 'MATCH')) THEN
         rti.validation_flag  := 'N';
         RETURN; --End of the line. No backing docs to worry about
      END IF;

      IF (rti.source_document_code = 'PO') THEN
         IF (    rti.po_header_id IS NULL
             AND rti.document_num IS NOT NULL) THEN
            rti.po_header_id  := rcv_table_functions.get_poh_row_from_num(rti.document_num, rti.org_id).po_header_id;
         END IF;

         IF (rti.po_header_id IS NULL) THEN
            invalid_null_value('PO_HEADER_ID');
         END IF;

         IF (rti.po_line_id IS NULL) THEN
            rti.po_line_id  := rcv_table_functions.get_pol_row_from_num(rti.document_line_num,
                                                                        rti.po_header_id,
                                                                        rti.item_description,
                                                                        rti.vendor_item_num,
                                                                        rti.item_id
                                                                       ).po_line_id;
        --Bug 7591174 Added item_id in the above call to get the po line num.
         END IF;

         IF (rti.po_line_id IS NULL) THEN
            invalid_null_value('PO_LINE_ID');
         END IF;

        /*Bug 12618848 Do not error out the RTI if it fetches more than one PO line.
          In preprocessor, it will be decided*/
         IF rti.po_line_id = -99 THEN
            rti.po_line_id := NULL;
         END IF;
        /*End of Bug 12618848 */

         IF (rti.po_line_location_id IS NULL) THEN
            rti.po_line_location_id  := rcv_table_functions.get_pll_row_from_num(rti.document_shipment_line_num, rti.po_line_id).line_location_id;
         END IF;

         /* It is OK not to have a shipment yet, this will get decided in the preprocessor
         IF (rti.po_line_location_id IS NULL) THEN
            invalid_null_value('PO_LINE_LOCATION_ID');
         END IF;
         */

         IF (rti.po_distribution_id IS NULL) THEN
            rti.po_distribution_id  := rcv_table_functions.get_pod_row_from_num(rti.document_distribution_num, rti.po_line_location_id).po_distribution_id;
         END IF;

         /* It is OK not to have a distribution yet, this will get decided in the preprocessor
         IF (rti.po_distribution_id IS NULL) THEN
            invalid_null_value('PO_DISTRIBUTION_ID');
         END IF;
         */

         elapsed_time('po source doc defaulting');
/** Bug:5502427
  * For Internal Order case, Sales Order contains the information pertaining
  * to the Source organisation. Receiving is done in the destination org.
  * So, we shouldn't default based on SO for the Internal Orders.
  * For Iternal Orders defaulting is handled in default_rti_from_rsh() and
  * default_rti_from_rsl() procedures.
  */
      ELSIF(rti.source_document_code = 'RMA') THEN
         IF (rti.document_num IS NULL) THEN
            rti.document_num  := rti.oe_order_num;
         ELSIF(rti.document_num <> rti.oe_order_num) THEN
            invalid_match_value(rti.document_num,
                                rti.oe_order_num,
                                'DOCUMENT_NUM'
                               );
         END IF;

         IF (rti.document_line_num IS NULL) THEN
            rti.document_line_num  := rti.oe_order_line_num;
         ELSIF(rti.document_line_num <> rti.oe_order_line_num) THEN
            invalid_match_value(rti.document_line_num,
                                rti.oe_order_line_num,
                                'DOCUMENT_LINE_NUM'
                               );
         END IF;

         IF (    rti.oe_order_header_id IS NULL
             AND rti.document_num IS NOT NULL) THEN
            /* WDK: NOTICE THE REVISION HACK FOR OE IS OVERLOADING PO_REVISION_NUM COLUMN */
            rti.oe_order_header_id  := rcv_table_functions.get_oeh_row_from_num(rti.document_num,
                                                                                NULL, --WDK, not sure what should be here
                                                                                rti.po_revision_num,
                                                                                rti.org_id
                                                                               ).header_id;
         END IF;

         IF (rti.oe_order_header_id IS NULL) THEN
            invalid_null_value('OE_ORDER_HEADER_ID');
         END IF;

         IF (rti.oe_order_line_id IS NULL) THEN
            rti.oe_order_line_id  := rcv_table_functions.get_oel_row_from_num(rti.document_line_num, rti.oe_order_header_id).line_id;
         END IF;

	/* Bug 5158457. It is ok not to have line number. It will be
         * decided in the preprocessor code.
         IF (rti.oe_order_line_id IS NULL) THEN
            invalid_null_value('OE_ORDER_LINE_ID');
         END IF;
	*/

         elapsed_time('rma/req source doc defaulting');
      END IF;

      g_asn_type := nvl(rcv_table_functions.get_rsh_row_from_id(rti.shipment_header_id).asn_type,'@@@'); --Bug: 5598511

      default_rti_from_pod(rti);
      elapsed_time('default_rti_from_pod');
      default_rti_from_pll(rti);
      elapsed_time('default_rti_from_pll');
      default_rti_from_pol(rti);
      elapsed_time('default_rti_from_pol');
      default_rti_from_poh(rti);
      elapsed_time('default_rti_from_poh');

      IF (rti.uom_code IS NULL) THEN
         rti.uom_code  := get_uom_code_from_measure(rti.unit_of_measure,
                                                    'UNIT_OF_MEASURE',
                                                    x_dummy_mkr
                                                   );
      ELSIF(rti.uom_code <> get_uom_code_from_measure(rti.unit_of_measure,
                                                      'UNIT_OF_MEASURE',
                                                      x_dummy_mkr
                                                     )) THEN
         invalid_match_value(rti.uom_code,
                             get_uom_code_from_measure(rti.unit_of_measure,
                                                       'UNIT_OF_MEASURE',
                                                       x_dummy_mkr
                                                      ),
                             'UOM_CODE'
                            );
      END IF;

      IF (rti.secondary_uom_code IS NULL) THEN
         rti.secondary_uom_code  := get_uom_code_from_measure(rti.secondary_unit_of_measure,
                                                              'SECONDARY_UNIT_OF_MEASURE',
                                                              x_dummy_mkr
                                                             );
      ELSIF(rti.secondary_uom_code <> get_uom_code_from_measure(rti.secondary_unit_of_measure,
                                                                'SECONDARY_UNIT_OF_MEASURE',
                                                                x_dummy_mkr
                                                               )) THEN
         invalid_match_value(rti.secondary_uom_code,
                             get_uom_code_from_measure(rti.secondary_unit_of_measure,
                                                       'SECONDARY_UNIT_OF_MEASURE',
                                                       x_dummy_mkr
                                                      ),
                             'SECONDARY_UOM_CODE'
                            );
      END IF;
      /*Bug 5592084: Incase the PRIMARY_UNIT_OF_MEASURE has invalid value
      we error out the record.
      */
      x_temp_primary_uom := get_uom_code_from_measure(rti.primary_unit_of_measure,
                                                     'PRIMARY_UNIT_OF_MEASURE',
                                                      x_dummy_mkr
                                                     );
      default_rti_from_oel(rti);
      elapsed_time('default_rti_from_oel');
      default_rti_from_oeh(rti);
      elapsed_time('default_rti_from_oeh');

      IF (rti.unit_of_measure IS NULL) THEN
         rti.unit_of_measure  := get_uom_measure_from_code(rti.uom_code,
                                                           'UOM_CODE',
                                                           x_dummy_mkr
                                                          );
      ELSIF(rti.unit_of_measure <> get_uom_measure_from_code(rti.uom_code,
                                                             'UOM_CODE',
                                                             x_dummy_mkr
                                                            )) THEN
         invalid_match_value(rti.unit_of_measure,
                             get_uom_measure_from_code(rti.uom_code,
                                                       'UOM_CODE',
                                                       x_dummy_mkr
                                                      ),
                             'UNIT_OF_MEASURE'
                            );
      END IF;

      IF (rti.secondary_unit_of_measure IS NULL) THEN
         rti.secondary_unit_of_measure  := get_uom_measure_from_code(rti.secondary_uom_code,
                                                                     'SECONDARY_UOM_CODE',
                                                                     x_dummy_mkr
                                                                    );
      ELSIF(rti.secondary_unit_of_measure <> get_uom_measure_from_code(rti.secondary_uom_code,
                                                                       'SECONDARY_UOM_CODE',
                                                                       x_dummy_mkr
                                                                      )) THEN
         invalid_match_value(rti.secondary_unit_of_measure,
                             get_uom_measure_from_code(rti.secondary_uom_code,
                                                       'SECONDARY_UOM_CODE',
                                                       x_dummy_mkr
                                                      ),
                             'SECONDARY_UNIT_OF_MEASURE'
                            );
      END IF;

      check_rti_consistency(rti);
      elapsed_time('check_rti_consistency');

      IF (rti.destination_type_code IS NULL) THEN
         IF (rti.transaction_type = 'DELIVER') THEN
            rti.destination_type_code  := 'INVENTORY';
         ELSE
            rti.destination_type_code  := 'RECEIVING';
         END IF;
      END IF;

      IF (rti.auto_transact_code IS NULL) THEN
         IF (rti.routing_header_id = 3) THEN
            rti.auto_transact_code  := 'DELIVER';
         ELSE
            rti.auto_transact_code  := 'RECEIVE';
         END IF;
      END IF;

      IF (rti.transaction_type IN('RECEIVE', 'SHIP')) THEN
         create_rhi_from_rti(rti);
         elapsed_time('create_rhi_from_rti');
      END IF;

	/* Bug 5584736.
	 * We have a detailed defaulting routine for defaulting
	 * subinventory and locator later. Commenting out this code
	 * here since this is creating problems later.
      IF (SUBSTR(rti.transaction_type,
                 1,
                 6
                ) = 'RETURN') THEN
         x_temp_subinv          := rti.subinventory;
         rti.subinventory       := rti.from_subinventory;
         rti.from_subinventory  := x_temp_subinv;
      END IF;

      IF (    rti.transaction_type = 'RECEIVE'
          AND rti.auto_transact_code <> 'DELIVER'
          AND x_subinv_starts_null = TRUE) THEN
         rti.subinventory  := NULL;
         rti.LOCATOR       := NULL;
         rti.locator_id    := NULL;
      END IF;
	*/

      /*Bug: 4735484
	Defaulting the use_mtl_lot and use_mtl_serial column using
	lot control code and serial control code of the item in the
	given inventory org.
      */
      default_lot_serial_control(rti);

      asn_debug.put_line('org_id = ' || rti.org_id);
      elapsed_time('END default_transaction');
   EXCEPTION
      WHEN rcv_table_functions.e_fatal_error THEN
	/* Bug 5584736.
	 * We have a detailed defaulting routine for defaulting
	 * subinventory and locator later. Commenting out this code
	 * here since this is creating problems later.
         IF (SUBSTR(rti.transaction_type,
                    1,
                    6
                   ) = 'RETURN') THEN
            x_temp_subinv          := rti.subinventory;
            rti.subinventory       := rti.from_subinventory;
            rti.from_subinventory  := x_temp_subinv;
         END IF;
	*/

         rcv_error_pkg.log_interface_error(g_curr_table,
                                           rcv_table_functions.g_error_column,
                                           g_curr_group_id,
                                           g_curr_header_id,
                                           g_curr_transaction_id
                                          );
      WHEN rcv_error_pkg.e_fatal_error THEN
	/* Bug 5584736.
	 * We have a detailed defaulting routine for defaulting
	 * subinventory and locator later. Commenting out this code
	 * here since this is creating problems later.
         IF (SUBSTR(rti.transaction_type,
                    1,
                    6
                   ) = 'RETURN') THEN
            x_temp_subinv          := rti.subinventory;
            rti.subinventory       := rti.from_subinventory;
            rti.from_subinventory  := x_temp_subinv;
         END IF;
	*/

         RAISE rcv_error_pkg.e_fatal_error;
      WHEN OTHERS THEN
	/* Bug 5584736.
	 * We have a detailed defaulting routine for defaulting
	 * subinventory and locator later. Commenting out this code
	 * here since this is creating problems later.
         IF (SUBSTR(rti.transaction_type,
                    1,
                    6
                   ) = 'RETURN') THEN
            x_temp_subinv          := rti.subinventory;
            rti.subinventory       := rti.from_subinventory;
            rti.from_subinventory  := x_temp_subinv;
         END IF;
	*/

         rcv_error_pkg.set_sql_error_message('deafault_transaction', '000');
         rcv_error_pkg.log_interface_error('INTERFACE_TRANSACTION_ID');
   END default_transaction;

   PROCEDURE default_from_parent(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   ) IS
   BEGIN
      default_rti_from_rti(rti);
   END default_from_parent;
END rcv_default_pkg;

/
