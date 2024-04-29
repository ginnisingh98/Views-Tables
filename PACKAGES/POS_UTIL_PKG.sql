--------------------------------------------------------
--  DDL for Package POS_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: POSUTILS.pls 120.0.12000000.3 2007/08/22 11:29:29 pkapoor ship $ */

-- global variable for logging
g_log_module_name VARCHAR2(30) := 'POSUTILB';

  FUNCTION bool_to_varchar(b IN BOOLEAN)
    RETURN VARCHAR2;


/** procedure Retrieve_Doc_Security
    --------------------------------
purpose:
--------
the iSP wrapper api to retrieve where clause for Purchasing Document Security
by calling the PO document security api PO_DOCUMENT_CHECKS_GRP. PO_Security_Check

*/

PROCEDURE Retrieve_Doc_Security (p_query_table  IN VARCHAR2,
                                 p_owner_id_column  IN VARCHAR2,
                                 p_employee_id IN VARCHAR2,
                                 p_employee_bind_start  IN NUMBER,
                                 p_org_id  IN NUMBER,
                                 x_return_status OUT  NOCOPY  VARCHAR2,
                                 x_msg_data OUT  NOCOPY  VARCHAR2,
                                 x_where_clause OUT  NOCOPY  VARCHAR2);


PROCEDURE update_revision (p_organizationId in number,
                           p_inventoryItemId in number,
                           p_vendorId in number,
                           p_batchId in number,
                           x_returnCode out NOCOPY varchar,
                           x_err_msg out NOCOPY varchar);

/** function IS_FV_ENABLED
    -----------------------
purpose:
--------
The iSP wrapper api to retrieve the value of Profile Option FV: Federal Enabled
by calling the Federal Financial api fv_install.enabled.

Returns 'T' if the Federal is enabled otherwise 'F'

*/

FUNCTION IS_FV_ENABLED RETURN VARCHAR2;

/** PROCEDURE FV_IS_CCR
    -----------------------
purpose:
--------
The iSP wrapper api to know if record is in CCR,
by calling the Federal Financial api FV_CCR_GRP.FV_IS_CCR

p_object_type, p_object_id:
Here S-> Supplier  --> Pass supplier_id
     B=> Bank branch  --> pass bank brnahc id
     T=> Supplier site -->  Pass Pay site or main address site id
     A-> Bank account Bank account id
*/

PROCEDURE FV_IS_CCR
(       p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2 DEFAULT null,
        p_object_id                     IN      NUMBER,
        p_object_type           IN  VARCHAR2,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count                     OUT     NOCOPY NUMBER,
        x_msg_data                      OUT     NOCOPY VARCHAR2,
        x_ccr_id                        OUT     NOCOPY NUMBER,
        x_out_status            OUT     NOCOPY VARCHAR2,
        x_error_code            OUT NOCOPY NUMBER
);

/** function IS_ADDR_CCR
    -----------------------
purpose:
--------
The iSP wrapper api over FV_IS_CCR to know if there is any CCR Site associated to an address
p_object_id: party_site_id for the address.

Returns 'T' if the Address has atleast one CCR site, otherwise 'F'

*/

FUNCTION IS_ADDR_CCR(
 p_api_version           IN      NUMBER,
 p_init_msg_list         IN      VARCHAR2 ,
 p_object_id             IN      NUMBER
 )RETURN VARCHAR2;


/** function IS_SITE_CCR
    -----------------------
purpose:
--------
The iSP wrapper api over FV_IS_CCR to know if site is a CCR Site
p_object_id: vendor_site_id

Returns 'T' if the site is CCR Site otherwise 'F'

*/
FUNCTION IS_SITE_CCR(
 p_api_version           IN      NUMBER,
 p_init_msg_list         IN      VARCHAR2 ,
 p_object_id             IN      NUMBER
 )RETURN VARCHAR2;


/** function IS_SUPP_CCR
    -----------------------
purpose:
--------
The iSP wrapper api over FV_IS_CCR to know if Supplier is a CCR Supplier.
p_object_id: vendor_id.

Returns 'T' if the supplier is CCR Supplier otherwise 'F'

*/
FUNCTION IS_SUPP_CCR(
 p_api_version           IN      NUMBER,
 p_init_msg_list         IN      VARCHAR2 ,
 p_object_id             IN      NUMBER
 )RETURN VARCHAR2;

/** function IS_CCR_SITE_ACTIVE
    -----------------------
purpose:
--------
The iSP wrapper api over FV_CCR_GRP.FV_CCR_REG_STATUS to know if site is CCR
site and if registration_status is active.
p_object_id: vendor_site_id.

Returns 'A' if the site is CCR Site and registration_status is active otherwise 'F'

*/
FUNCTION IS_CCR_SITE_ACTIVE(
 p_api_version           IN      NUMBER,
 p_init_msg_list         IN      VARCHAR2 ,
 p_object_id             IN      NUMBER
 )RETURN VARCHAR2;


END pos_util_pkg;

 

/
