--------------------------------------------------------
--  DDL for Package AP_SUPPLIER_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_SUPPLIER_INFO_PKG" AUTHID CURRENT_USER AS
/* $Header: apsupinfs.pls 120.1.12010000.3 2008/11/18 10:46:51 anarun noship $ */

-- Type Declarations

TYPE t_contacts_tab IS TABLE OF po_vendor_contacts%ROWTYPE
INDEX BY BINARY_INTEGER;

-- Declare a record for supplier site. Each record will have one
-- site record and a table of contacts associated with that site
TYPE t_site_con_rec IS RECORD ( site_rec    ap_supplier_sites_all%ROWTYPE,
                                contact_tab t_contacts_tab );

-- Declare a table for supplier site with each record being of the
-- type of site record declared above
TYPE t_site_con_tab IS TABLE OF t_site_con_rec
INDEX BY BINARY_INTEGER;

-- Declare a record for supplier information. It will contain a record for
-- supplier and a table of supplier site (containing site rec and contact
-- table) as described above
TYPE t_supplier_info_rec IS RECORD( supp_rec        ap_suppliers%ROWTYPE,
                                    site_con_tab    t_site_con_tab );

-- Declare a table for supplier information with each record being of the
-- type of supplier information record declared above
TYPE t_supplier_info_tab IS TABLE OF t_supplier_info_rec
INDEX BY BINARY_INTEGER;

--  Public Procedure Specifications

------------------------------------------------------------------------------
----------------------------- Supplier_Details -------------------------------
------------------------------------------------------------------------------
/* Fetches the details of Supplier, Site and Contact
 * This is an overloaded procedure
 * Parameters : i_vendor_id          - vendor_id of supplier
 *              i_vendor_site_id     - vendor_site_id of supplier site
 *              i_vendor_contact_id  - vendor_contact_id
 *              o_supplier_info      - Supplier details are populated into
 *                                     this parameter
 *              o_success            - If a valid combination of vendor_id,
 *                                     vendor_site_id and vendor_contact_id
 *                                     was not passed then o_success is set
 *                                     to FALSE
 *
 * Logic :
 * 1) Validation check and query string formulation
 *    First check if the vendor_id exists in ap_suppliers.
 *    If vendor_site_id is available then
 *       a) check if it is valid
 *       b) append it to site query string
 *       c) If vendor_contact_id is available then
 *           i) check if this contact is valid for this combination of
 *              ( vendor_id, vendor_site_id )
 *          ii) append it to contact query string. Here we do not need to
 *              consider it for site query string because while opening
 *              contact cursor, if vendor_site_id is available then we will
 *              use it as a condition
 *        End If
 *    Else
 *       a) If vendor_contact_id is available then
 *            i) check if this contact is valid for this combination of
 *               ( vendor_id, vendor_site_id )
 *           ii) Get the list of vendor_site_id for this contact and add
 *               this list as a IN condition of site query string
 *          End If
 *    End If
 * 2) Populate the suplier details
 * 3) Loop through sites and get site details
 * 4) Loop through contacts for each site to get contact details
 *
*/

PROCEDURE Supplier_Details(
                           i_vendor_id          IN    NUMBER ,
                           i_vendor_site_id     IN    NUMBER   DEFAULT NULL,
                           i_vendor_contact_id  IN    NUMBER   DEFAULT NULL,
                           o_supplier_info      OUT NOCOPY t_supplier_info_rec,
                           o_success            OUT NOCOPY BOOLEAN
                          );

------------------------------------------------------------------------------
----------------------------- Supplier_Details -------------------------------
------------------------------------------------------------------------------
/* Fetches the details of Supplier, Site and Contact for a particular range
 * of vendor_id.
 * This is an overloaded procedure. The parameter o_supplier_info_tab can be
 * used to distinguish between the calls. Here, both i_from_vendor_id and
 * i_to_vendor_id are mandatory parameters.
 * This procedure should be called with a reasonable range of vendor_id based
 * on the resources available at customer's instance to avoid performance
 * issues. If there is some performance issue then the only way to fix it will
 * be to provide a lesser range of vendor_id.
 *
 * Parameters : i_from_vendor_id    - Start range of vendor_id
 *              i_to_vendor_id      - End range of vendor_id
 *              o_supplier_info_tab - Supplier details are populated into
 *                                    this parameter.
 *              o_success           - If no vendor exists in the range of
 *                                    vendor_id for which this procedure is
 *                                    called then o_success is set to FALSE
 *
*/

PROCEDURE Supplier_Details(
                           i_from_vendor_id     IN    NUMBER ,
                           i_to_vendor_id       IN    NUMBER ,
                           o_supplier_info_tab  OUT NOCOPY t_supplier_info_tab,
                           o_success            OUT NOCOPY BOOLEAN
                          );

END AP_SUPPLIER_INFO_PKG;


/
