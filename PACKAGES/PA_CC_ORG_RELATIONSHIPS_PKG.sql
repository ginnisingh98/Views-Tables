--------------------------------------------------------
--  DDL for Package PA_CC_ORG_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CC_ORG_RELATIONSHIPS_PKG" AUTHID CURRENT_USER as
/* $Header: PAXCCOUS.pls 120.2 2005/08/08 12:46:02 sbharath noship $ */

procedure insert_row (  x_rowid               IN OUT NOCOPY Varchar2,
			x_prvdr_org_id        IN Number,
		        x_recvr_org_id        IN Number,
        		x_Prvdr_allow_cc_flag IN Varchar2,
        		x_Cross_charge_code   IN Varchar2,
        		x_prvdr_project_id    IN Number  ,
        		x_invoice_grouping_code IN  Varchar2,
        		x_last_update_date       IN Date,
        		x_last_updated_by        IN Number,
        		x_creation_date          IN Date,
        		x_created_by             IN Number,
        		x_last_update_login      IN Number     ,
        		x_vendor_site_id         IN Number         ,
        		x_ap_inv_exp_type        IN Varchar2   ,
        		x_ap_inv_exp_organization_id IN  Number    ,
        		x_attribute_category         IN  Varchar2  ,
        		x_attribute1                 IN  Varchar2  ,
        		x_attribute2                 IN  Varchar2  ,
        		x_attribute3                 IN  Varchar2  ,
        		x_attribute4                 IN  Varchar2  ,
        		x_attribute5                 IN  Varchar2  ,
        		x_attribute6                 IN  Varchar2  ,
        		x_attribute7                 IN  Varchar2  ,
        		x_attribute8                 IN  Varchar2  ,
        		x_attribute9                 IN  Varchar2  ,
        		x_attribute10                IN  Varchar2  ,
        		x_attribute11                IN  Varchar2  ,
        		x_attribute12                IN  Varchar2  ,
        		x_attribute13                IN  Varchar2  ,
        		x_attribute14                IN  Varchar2  ,
        		x_attribute15                IN  Varchar2 ) ;

procedure update_row (  x_rowid               IN Varchar2,
			x_prvdr_org_id        IN Number,
                        x_recvr_org_id        IN Number,
                        x_Prvdr_allow_cc_flag IN Varchar2,
                        x_Cross_charge_code   IN Varchar2,
                        x_prvdr_project_id    IN Number  ,
                        x_invoice_grouping_code IN  Varchar2,
                        x_last_update_date       IN Date,
                        x_last_updated_by        IN Number,
                        x_creation_date          IN Date,
                        x_created_by             IN Number,
                        x_last_update_login      IN Number     ,
                        x_vendor_site_id         IN Number         ,
                        x_ap_inv_exp_type        IN Varchar2   ,
                        x_ap_inv_exp_organization_id IN  Number    ,
                        x_attribute_category         IN  Varchar2  ,
                        x_attribute1                 IN  Varchar2  ,
                        x_attribute2                 IN  Varchar2  ,
                        x_attribute3                 IN  Varchar2  ,
                        x_attribute4                 IN  Varchar2  ,
                        x_attribute5                 IN  Varchar2  ,
                        x_attribute6                 IN  Varchar2  ,
                        x_attribute7                 IN  Varchar2  ,
                        x_attribute8                 IN  Varchar2  ,
                        x_attribute9                 IN  Varchar2  ,
                        x_attribute10                IN  Varchar2  ,
                        x_attribute11                IN  Varchar2  ,
                        x_attribute12                IN  Varchar2  ,
                        x_attribute13                IN  Varchar2  ,
                        x_attribute14                IN  Varchar2  ,
                        x_attribute15                IN  Varchar2 ) ;
END pa_cc_org_relationships_pkg;

 

/
