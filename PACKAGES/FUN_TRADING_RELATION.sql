--------------------------------------------------------
--  DDL for Package FUN_TRADING_RELATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_TRADING_RELATION" AUTHID CURRENT_USER AS
/* $Header: funtraderels.pls 120.7 2006/05/15 13:59:33 ashikuma noship $ */

/*-----------------------------------------------------
 * FUNCTION validate_source
 * ----------------------------------------------------
 * Validates the source input.
 * ---------------------------------------------------*/

FUNCTION validate_source (p_source IN VARCHAR2)
RETURN boolean;


/*-----------------------------------------------------
 * FUNCTION get_customer
 * ----------------------------------------------------
 * Get the customer info.
 * Returns TRUE iff a match is found.
 * ---------------------------------------------------*/

FUNCTION get_customer (
    p_source                             IN VARCHAR2,
    p_trans_le_id                       IN NUMBER ,
    p_tp_le_id                            IN NUMBER ,
    p_trans_org_id                    IN NUMBER := NULL,
    p_tp_org_id                         IN NUMBER := NULL,
    p_trans_organization_id IN NUMBER,
    p_tp_organization_id IN NUMBER,
    x_msg_data	                        OUT NOCOPY VARCHAR2,
    x_cust_acct_id                    OUT NOCOPY NUMBER,
    x_cust_acct_site_id                 OUT NOCOPY NUMBER,
    x_site_use_id                      OUT NOCOPY NUMBER
) RETURN boolean;


/*-----------------------------------------------------
 * FUNCTION get_supplier
 * ----------------------------------------------------
 * Get the supplier info.
 * Returns TRUE iff a match is found.
 * ---------------------------------------------------*/

FUNCTION get_supplier (
    p_source IN VARCHAR2,
    p_trans_le_id IN NUMBER ,
    p_tp_le_id IN NUMBER ,
    p_trans_org_id IN NUMBER := NULL,
    p_tp_org_id IN NUMBER := NULL,
    p_trans_organization_id IN NUMBER,
    p_tp_organization_id IN NUMBER,
    p_trx_date                          IN  DATE,
    x_msg_data	 OUT NOCOPY VARCHAR2,
    x_vendor_id	 OUT NOCOPY NUMBER,
    x_pay_site_id OUT NOCOPY NUMBER
    ) RETURN boolean;

/*-----------------------------------------------------
 * PROCEDUTE get_relation
 * ----------------------------------------------------
 * Get the relation_id
 * ---------------------------------------------------*/
PROCEDURE get_relation (
    p_source IN VARCHAR2,
    p_type IN VARCHAR2,
    p_trans_le_id IN NUMBER ,
    p_tp_le_id IN NUMBER ,
    p_trans_org_id IN NUMBER := NULL,
    p_tp_org_id IN NUMBER := NULL,
    p_trans_organization_id IN NUMBER,
    p_tp_organization_id IN NUMBER,
    x_relation_id OUT NOCOPY	NUMBER,
    x_success OUT NOCOPY VARCHAR2,
    x_msg_data OUT NOCOPY VARCHAR2
    ) ;



END FUN_TRADING_RELATION;


 

/
