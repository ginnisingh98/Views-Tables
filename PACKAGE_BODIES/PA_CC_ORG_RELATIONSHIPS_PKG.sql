--------------------------------------------------------
--  DDL for Package Body PA_CC_ORG_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CC_ORG_RELATIONSHIPS_PKG" as
/* $Header: PAXCCOUB.pls 120.2 2005/08/08 12:46:21 sbharath noship $ */


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
        		x_attribute15                IN  Varchar2 )IS

cursor return_rowid is select rowid from pa_cc_org_relationships
                         where prvdr_org_id = x_prvdr_org_id
    			 and	recvr_org_id    =  x_recvr_org_id ;

 BEGIN
  insert into pa_cc_org_relationships (prvdr_org_id,
        recvr_org_id,
	prvdr_allow_cc_flag,
	cross_charge_code,
	prvdr_project_id,
	invoice_grouping_code,
	vendor_site_id,
	ap_inv_exp_type,
	ap_inv_exp_organization_id,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15
)
  values (x_prvdr_org_id,
        x_recvr_org_id                     			,
        x_Prvdr_allow_cc_flag              			,
        x_Cross_charge_code              			,
        x_prvdr_project_id                 			,
        x_invoice_grouping_code         			,
        x_vendor_site_id                   		        ,
        x_ap_inv_exp_type                 			,
        x_ap_inv_exp_organization_id      		        ,
        x_last_update_date                			,
        x_last_updated_by               			,
        x_creation_date                  			,
        x_created_by                     			,
        x_last_update_login         			        ,
        x_attribute_category               		  	,
        x_attribute1                      			,
        x_attribute2                    			,
        x_attribute3                      			,
        x_attribute4                   				,
        x_attribute5                    			,
        x_attribute6                 				,
        x_attribute7                 				,
        x_attribute8                				,
        x_attribute9               				,
        x_attribute10              				,
        x_attribute11              				,
        x_attribute12                    			,
        x_attribute13                  				,
        x_attribute14                  				,
        x_attribute15
);
  open return_rowid;
  fetch return_rowid into x_rowid;
  if (return_rowid%notfound) then
    raise NO_DATA_FOUND;
  end if;
  close return_rowid;

 END insert_row;

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
                        x_attribute15                IN  Varchar2 )IS
BEGIN
update pa_cc_org_relationships
set 	prvdr_org_id 			=	x_prvdr_org_id
        ,recvr_org_id			=	x_recvr_org_id
	,prvdr_allow_cc_flag		=	x_prvdr_allow_cc_flag
	,cross_charge_code		=	x_cross_charge_code
	,prvdr_project_id		=	x_prvdr_project_id
	,invoice_grouping_code		=	x_invoice_grouping_code
	,vendor_site_id			=	x_vendor_site_id
	,ap_inv_exp_type		=	x_ap_inv_exp_type
	,ap_inv_exp_organization_id	=	x_ap_inv_exp_organization_id
	,last_update_date		=	x_last_update_date
	,last_updated_by		=	x_last_updated_by
	,creation_date			=	x_creation_date
	,created_by			=	x_created_by
	,last_update_login		=	x_last_update_login
	,attribute_category		=	x_attribute_category
	,attribute1			=	x_attribute1
	,attribute2			=	x_attribute2
	,attribute3			=	x_attribute3
	,attribute4			=	x_attribute4
	,attribute5			=	x_attribute5
	,attribute6			=	x_attribute6
	,attribute7			=	x_attribute7
	,attribute8			=	x_attribute8
	,attribute9			=	x_attribute9
	,attribute10			=	x_attribute10
	,attribute11			=	x_attribute11
	,attribute12			=	x_attribute12
	,attribute13			=	x_attribute13
	,attribute14			=	x_attribute14
	,attribute15			=	x_attribute15
where rowid = x_rowid ;

END update_row ;

END pa_cc_org_relationships_pkg;

/
