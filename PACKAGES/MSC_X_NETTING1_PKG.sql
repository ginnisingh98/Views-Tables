--------------------------------------------------------
--  DDL for Package MSC_X_NETTING1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_NETTING1_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCXEX1S.pls 115.4 2003/11/12 01:30:25 yptang ship $ */


PROCEDURE Compute_Late_Order(p_refresh_number IN Number,
   t_company_list       IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   t_company_site_list  IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   t_customer_list   IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   t_customer_site_list    IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   t_supplier_list   IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   t_supplier_site_list    IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   t_item_list       IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   t_group_list      IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   t_type_list       IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   t_trxid1_list     IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   t_trxid2_list     IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   t_date1_list      IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   t_date2_list      IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_company_id            IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_company_name          IN OUT NOCOPY  msc_x_netting_pkg.publisherList,
   a_company_site_id       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_company_site_name     IN OUT NOCOPY  msc_x_netting_pkg.pubsiteList,
   a_item_id               IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_item_name             IN OUT NOCOPY  msc_x_netting_pkg.itemnameList,
   a_item_desc             IN OUT NOCOPY  msc_x_netting_pkg.itemdescList,
   a_exception_type        IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_exception_type_name   IN OUT NOCOPY  msc_x_netting_pkg.exceptypeList,
   a_exception_group       IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_exception_group_name  IN OUT NOCOPY msc_x_netting_pkg.excepgroupList,
   a_trx_id1               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_trx_id2               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_id           IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_name         IN OUT NOCOPY msc_x_netting_pkg.customerList,
   a_customer_site_id      IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_site_name    IN OUT NOCOPY msc_x_netting_pkg.custsiteList,
   a_customer_item_name IN OUT NOCOPY msc_x_netting_pkg.itemnameList,
   a_supplier_id           IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_supplier_name         IN OUT NOCOPY msc_x_netting_pkg.supplierList,
   a_supplier_site_id      IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_supplier_site_name    IN OUT NOCOPY msc_x_netting_pkg.suppsiteList,
   a_supplier_item_name    IN OUT NOCOPY msc_x_netting_pkg.itemnameList,
   a_number1               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_number2               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_number3               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_threshold             IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_lead_time             IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_item_min_qty          IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_item_max_qty          IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_order_number          IN OUT NOCOPY msc_x_netting_pkg.ordernumberList,
   a_release_number        IN OUT NOCOPY msc_x_netting_pkg.releasenumList,
   a_line_number           IN OUT NOCOPY msc_x_netting_pkg.linenumList,
   a_end_order_number      IN OUT NOCOPY msc_x_netting_pkg.ordernumberList,
   a_end_order_rel_number  IN OUT NOCOPY msc_x_netting_pkg.releasenumList,
   a_end_order_line_number IN OUT NOCOPY msc_x_netting_pkg.linenumList,
   a_creation_date         IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_tp_creation_date      IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date1           	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date2        	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date3            	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date4		   IN OUT  NOCOPY msc_x_netting_pkg.date_arr,
   a_date5		   IN OUT  NOCOPY msc_x_netting_pkg.date_arr,
   a_exception_basis	   IN OUT  NOCOPY msc_x_netting_pkg.exceptbasisList);


PROCEDURE Compute_Early_Order(p_refresh_number IN Number,
   t_company_list       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_company_site_list  IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_customer_list   IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_customer_site_list    IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_supplier_list   IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_supplier_site_list    IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_item_list       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_group_list      IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_type_list       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_trxid1_list     IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_trxid2_list     IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_date1_list      IN OUT NOCOPY  msc_x_netting_pkg.date_arr,
   t_date2_list      IN OUT NOCOPY  msc_x_netting_pkg.date_arr,
   a_company_id            IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_company_name          IN OUT NOCOPY  msc_x_netting_pkg.publisherList,
   a_company_site_id       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_company_site_name     IN OUT NOCOPY  msc_x_netting_pkg.pubsiteList,
   a_item_id               IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_item_name             IN OUT NOCOPY  msc_x_netting_pkg.itemnameList,
   a_item_desc             IN OUT NOCOPY  msc_x_netting_pkg.itemdescList,
   a_exception_type        IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_exception_type_name   IN OUT NOCOPY  msc_x_netting_pkg.exceptypeList,
   a_exception_group       IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_exception_group_name  IN OUT NOCOPY msc_x_netting_pkg.excepgroupList,
   a_trx_id1               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_trx_id2               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_id           IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_name         IN OUT NOCOPY msc_x_netting_pkg.customerList,
   a_customer_site_id      IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_site_name    IN OUT NOCOPY msc_x_netting_pkg.custsiteList,
   a_customer_item_name IN OUT NOCOPY msc_x_netting_pkg.itemnameList,
   a_supplier_id           IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_supplier_name         IN OUT NOCOPY msc_x_netting_pkg.supplierList,
   a_supplier_site_id      IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_supplier_site_name    IN OUT NOCOPY msc_x_netting_pkg.suppsiteList,
   a_supplier_item_name    IN OUT NOCOPY msc_x_netting_pkg.itemnameList,
   a_number1               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_number2               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_number3               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_threshold             IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_lead_time             IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_item_min_qty          IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_item_max_qty          IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_order_number          IN OUT NOCOPY msc_x_netting_pkg.ordernumberList,
   a_release_number        IN OUT NOCOPY msc_x_netting_pkg.releasenumList,
   a_line_number           IN OUT NOCOPY msc_x_netting_pkg.linenumList,
   a_end_order_number      IN OUT NOCOPY msc_x_netting_pkg.ordernumberList,
   a_end_order_rel_number  IN OUT NOCOPY msc_x_netting_pkg.releasenumList,
   a_end_order_line_number IN OUT NOCOPY msc_x_netting_pkg.linenumList,
   a_creation_date         IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_tp_creation_date      IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date1           	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date2        	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date3            	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date4		   IN OUT  NOCOPY msc_x_netting_pkg.date_arr,
   a_date5		   IN OUT  NOCOPY msc_x_netting_pkg.date_arr,
   a_exception_basis	   IN OUT  NOCOPY msc_x_netting_pkg.exceptbasisList);

PROCEDURE Compute_Forecast_Mismatch (p_refresh_number In Number,
   t_company_list       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_company_site_list  IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_customer_list   IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_customer_site_list    IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_supplier_list   IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_supplier_site_list    IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_item_list       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_group_list      IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_type_list       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_trxid1_list     IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_trxid2_list     IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_date1_list      IN OUT NOCOPY  msc_x_netting_pkg.date_arr,
   t_date2_list      IN OUT NOCOPY  msc_x_netting_pkg.date_arr,
   a_company_id            IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_company_name          IN OUT NOCOPY  msc_x_netting_pkg.publisherList,
   a_company_site_id       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_company_site_name     IN OUT NOCOPY  msc_x_netting_pkg.pubsiteList,
   a_item_id               IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_item_name             IN OUT NOCOPY  msc_x_netting_pkg.itemnameList,
   a_item_desc             IN OUT NOCOPY  msc_x_netting_pkg.itemdescList,
   a_exception_type        IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_exception_type_name   IN OUT NOCOPY  msc_x_netting_pkg.exceptypeList,
   a_exception_group       IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_exception_group_name  IN OUT NOCOPY msc_x_netting_pkg.excepgroupList,
   a_trx_id1               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_trx_id2               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_id           IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_name         IN OUT NOCOPY msc_x_netting_pkg.customerList,
   a_customer_site_id      IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_site_name    IN OUT NOCOPY msc_x_netting_pkg.custsiteList,
   a_customer_item_name IN OUT NOCOPY msc_x_netting_pkg.itemnameList,
   a_supplier_id           IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_supplier_name         IN OUT NOCOPY msc_x_netting_pkg.supplierList,
   a_supplier_site_id      IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_supplier_site_name    IN OUT NOCOPY msc_x_netting_pkg.suppsiteList,
   a_supplier_item_name    IN OUT NOCOPY msc_x_netting_pkg.itemnameList,
   a_number1               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_number2               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_number3               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_threshold             IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_lead_time             IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_item_min_qty          IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_item_max_qty          IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_order_number          IN OUT NOCOPY msc_x_netting_pkg.ordernumberList,
   a_release_number        IN OUT NOCOPY msc_x_netting_pkg.releasenumList,
   a_line_number           IN OUT NOCOPY msc_x_netting_pkg.linenumList,
   a_end_order_number      IN OUT NOCOPY msc_x_netting_pkg.ordernumberList,
   a_end_order_rel_number  IN OUT NOCOPY msc_x_netting_pkg.releasenumList,
   a_end_order_line_number IN OUT NOCOPY msc_x_netting_pkg.linenumList,
   a_creation_date         IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_tp_creation_date      IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date1           	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date2        	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date3            	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date4		   IN OUT  NOCOPY msc_x_netting_pkg.date_arr,
   a_date5		   IN OUT  NOCOPY msc_x_netting_pkg.date_arr,
   a_exception_basis	   IN OUT  NOCOPY msc_x_netting_pkg.exceptbasisList);




END MSC_X_NETTING1_PKG;


 

/