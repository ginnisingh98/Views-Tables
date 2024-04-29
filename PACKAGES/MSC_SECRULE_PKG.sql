--------------------------------------------------------
--  DDL for Package MSC_SECRULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SECRULE_PKG" AUTHID CURRENT_USER AS
-- $Header: MSCXVSPS.pls 120.1 2005/06/20 04:21:25 appldev ship $

ORDER_TYPE_ZERO     CONSTANT NUMBER := 0;




Procedure      INSERT_SEC_RULE
   ( p_order_type           IN Number,
     p_item_name            IN Varchar2,
     p_customer_name        IN Varchar2,
     p_supplier_name        IN Varchar2,
     p_customer_site_name   IN Varchar2,
     p_supplier_site_name   IN Varchar2,
     p_org_name             IN Varchar2,
     p_grantee_type         IN Varchar2,
     p_grantee_key          IN Varchar2,
     p_start_date           IN date,
     p_end_date             IN date,
     p_privilege            IN Varchar2,
     p_order_number         IN Varchar2,
     p_company_name         IN Varchar2,
     p_return_code          OUT NOCOPY Number,
     p_err_msg              OUT NOCOPY Varchar2);

Procedure      EDIT_SEC_RULE
   ( p_order_type           IN Number,
     p_item_name            IN Varchar2,
     p_customer_name        IN Varchar2,
     p_supplier_name        IN Varchar2,
     p_customer_site_name   IN Varchar2,
     p_supplier_site_name   IN Varchar2,
     p_org_name             IN Varchar2,
     p_grantee_type         IN Varchar2,
     p_grantee_key          IN Varchar2,
     p_start_date           IN date,
     p_end_date             IN date,
     p_privilege            IN Varchar2,
     p_order_number         IN Varchar2,
     p_company_name         IN Varchar2,
     p_rule_id              IN Number,
     p_return_code          OUT NOCOPY Number,
     p_err_msg              OUT NOCOPY Varchar2);


/*Procedure      VALIDATE_ORDER_TYPE
   ( p_order_type           IN Varchar2,
     l_lookup_code	    OUT  Number,
     p_return_code         IN OUT Number,
     p_err_msg             IN OUT Varchar2);
     */

 Procedure      VALIDATE_COMPANY_NAME
   ( p_company_name        IN Varchar2,
     l_company_id	   OUT  NOCOPY Number,
     p_return_code         IN OUT NOCOPY Number,
     p_err_msg             IN OUT NOCOPY Varchar2);

 Procedure      VALIDATE_ITEM_NAME
   ( p_item_name           IN Varchar2,
     p_company_name        IN Varchar2,
     l_item_id		       OUT  NOCOPY Number,
     p_return_code         IN OUT NOCOPY Number,
     p_err_msg             IN OUT NOCOPY Varchar2);

 Procedure      VALIDATE_CUSTOMER_NAME
   ( p_customer_name       IN		Varchar2,
     l_company_id          IN		Number,
     l_customer_id         OUT	NOCOPY	Number,
     l_customer_flag	   IN OUT NOCOPY	boolean,
     p_return_code         IN OUT NOCOPY	Number,
     p_err_msg             IN OUT NOCOPY	Varchar2);

 Procedure      VALIDATE_SUPPLIER_NAME
   ( p_supplier_name       IN		Varchar2,
     l_company_id          IN		Number,
     l_supplier_id         OUT	 NOCOPY	Number,
     l_supplier_flag	   IN OUT NOCOPY	boolean,
     p_return_code         IN OUT NOCOPY Number,
     p_err_msg             IN OUT NOCOPY Varchar2);

  Procedure      VALIDATE_CUSTOMER_SITE_NAME
   ( p_customer_site_name  IN		Varchar2,
     l_company_id          IN		Number,
     l_customer_id	   IN           Number,
     l_customer_site_id    OUT	NOCOPY	Number,
     l_customer_flag	   IN OUT NOCOPY	boolean,
     p_return_code         IN OUT NOCOPY	Number,
     p_err_msg             IN OUT NOCOPY	Varchar2);

 Procedure      VALIDATE_SUPPLIER_SITE_NAME
   ( p_supplier_site_name  IN		Varchar2,
     l_company_id          IN		Number,
     l_supplier_id	       IN       Number,
     l_supplier_site_id    OUT	 NOCOPY	Number,
     l_supplier_flag	   IN OUT NOCOPY	boolean,
     p_return_code         IN OUT NOCOPY	Number,
     p_err_msg             IN OUT NOCOPY	Varchar2);

 Procedure      VALIDATE_ORG_NAME
   ( p_org_name           IN            Varchar2,
     l_company_id         IN		Number,
     l_org_id		  OUT	 NOCOPY	Number,
     p_return_code        IN OUT NOCOPY	Number,
     p_err_msg            IN OUT NOCOPY	Varchar2);

  Procedure      VALIDATE_GRANTEE_KEY
   ( p_grantee_type       IN            Varchar2,
     p_grantee_key        IN		Varchar2,
     l_grantee_key        OUT	 NOCOPY	Number,
     p_return_code        IN OUT NOCOPY	Number,
     p_err_msg            IN OUT NOCOPY	Varchar2);


END MSC_SECRULE_PKG;


 

/
