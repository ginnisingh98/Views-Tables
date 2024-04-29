--------------------------------------------------------
--  DDL for Package MSC_X_NETTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_NETTING_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCXNETS.pls 120.1 2008/01/07 09:28:28 dejoshi ship $ */

--===========================================================
-- Constants
--===========================================================
G_PLAN_ID      		Number := -1;
G_SR_INSTANCE_ID  	Number := -1;
SALES_FORECAST    	Number := 1;
ORDER_FORECAST    	Number := 2;
SUPPLY_COMMIT     	Number := 3;
HISTORICAL_SALES  	Number := 4;
ALLOCATED_ONHAND  	Number := 9;
UNALLOCATED_ONHAND   	Number := 10;
PURCHASE_ORDER    	Number := 13;
SALES_ORDER    		Number := 14;
ASN         		Number := 15;
SHIPMENT_RECEIPT  	Number := 16;
ASCP_SALES_ORDER_MDS	Number := 6;
ASCP_SALES_ORDER	Number := 30;
ASCP_PURCHASE_ORDER	Number := 1;

G_ZERO			Number := 0;

G_MAGIC_NUMBER    	Number := -99;

SUPPLY_PLANNING      	CONSTANT INTEGER := 1;
DEMAND_PLANNING      	CONSTANT INTEGER := 2;
VMI         		CONSTANT INTEGER := 3;
EXECUTION_ORDER      	CONSTANT INTEGER := 4;

BUYER       		CONSTANT INTEGER := 1;
SELLER         		CONSTANT INTEGER := 2;

G_PROCESSING_TIME	Number := 9999;
G_REPLENISH_TIME_FENCE  Number := 100;
G_AUTO_RELEASE_FLAG  	Varchar2(3) := 'No';

-----------------------------------------------------------------
--  the srs exception group constants
-----------------------------------------------------------------
G_GROUP1    CONSTANT Number := -1001;		-- late order
G_GROUP2    CONSTANT Number := -1002;		-- material shortage
G_GROUP3    CONSTANT Number := -1003;		-- response required
G_GROUP4    CONSTANT Number := -1004;		-- potential late order
G_GROUP5    CONSTANT Number := -1005;		-- forecast mismatch
G_GROUP6    CONSTANT Number := -1006;		-- early order
G_GROUP7    CONSTANT Number := -1007;		-- material excess
G_GROUP8    CONSTANT Number := -1008;		-- changed order
G_GROUP9    CONSTANT Number := -1009;		-- forecast accuracy
G_GROUP10      CONSTANT Number := -1010;	-- performance

-----------------------------------------------------------------
-- exception group constants
-----------------------------------------------------------------
G_LATE_ORDER      	CONSTANT Number := 1;
G_MATERIAL_SHORTAGE  	CONSTANT Number := 2;
G_RESPONSE_REQUIRED  	CONSTANT Number   := 3;
G_POTENTIAL_LATE_ORDER  CONSTANT Number   := 4;
G_FORECAST_MISMATCH  	CONSTANT Number   := 5;
G_EARLY_ORDER     	CONSTANT Number   := 6;
G_MATERIAL_EXCESS 	CONSTANT Number   := 7;
G_CHANGED_ORDER      	CONSTANT Number   := 8;
G_FORECAST_ACCURACY  	CONSTANT Number   := 9;
G_PERFORMANCE     	CONSTANT Number   := 10;
------------------------------------------------------------------
-- exception type constants
-----------------------------------------------------------------
G_EXCEP1    Number := 1;
G_EXCEP2    Number := 2;
G_EXCEP3    Number := 3;
G_EXCEP4    Number := 4;
G_EXCEP5    Number := 5;
G_EXCEP6    Number := 6;
G_EXCEP7    Number := 7;
G_EXCEP8    Number := 8;
G_EXCEP9    Number := 9;
G_EXCEP10      Number := 10;
G_EXCEP11      Number := 11;
G_EXCEP12      Number := 12;
G_EXCEP13      Number := 13;
G_EXCEP14      Number := 14;
G_EXCEP15      Number := 15;
G_EXCEP16      Number := 16;
G_EXCEP17      Number := 17;
G_EXCEP18      Number := 18;
G_EXCEP19      Number := 19;
G_EXCEP20      Number := 20;
G_EXCEP21      Number := 21;
G_EXCEP22      Number := 22;
G_EXCEP23      Number := 23;
G_EXCEP24      Number := 24;
G_EXCEP25      Number := 25;
G_EXCEP26      Number := 26;
G_EXCEP27      Number := 27;
G_EXCEP28      Number := 28;
G_EXCEP29      Number := 29;
G_EXCEP30      Number := 30;
G_EXCEP31      Number := 31;
G_EXCEP32      Number := 32;
G_EXCEP33      Number := 33;
G_EXCEP34      Number := 34;
G_EXCEP35      Number := 35;
G_EXCEP36      Number := 36;
G_EXCEP37      Number := 37;
G_EXCEP38      Number := 38;
G_EXCEP39      Number := 39;
G_EXCEP40      Number := 40;
G_EXCEP41      Number := 41;
G_EXCEP42      Number := 42;
G_EXCEP43      Number := 43;
G_EXCEP44      Number := 44;
G_EXCEP45      Number := 45;
G_EXCEP46      Number := 46;
G_EXCEP47      Number := 47;
G_EXCEP48      Number := 48;
G_EXCEP49	Number := 49;  --bug# 2761469
G_EXCEP50	Number := 50;
G_EXCEP51	Number := 51;

---------------------------------------------------------------
--   PL/SQL table types
---------------------------------------------------------------
TYPE number_arr   	IS TABLE of NUMBER;
TYPE date_arr     	IS TABLE of DATE;

TYPE publisherList      IS TABLE OF    	msc_companies.company_name%TYPE;
TYPE pubsiteList        IS TABLE OF    	msc_company_sites.company_site_name%TYPE;
TYPE customerList       IS TABLE OF    	msc_companies.company_name%TYPE;
TYPE custsiteList       IS TABLE OF    	msc_company_sites.company_site_name%TYPE;
TYPE supplierList       IS TABLE OF    	msc_companies.company_name%TYPE;
TYPE suppsiteList       IS TABLE OF    	msc_company_sites.company_site_name%TYPE;
TYPE exceptypeList   	IS TABLE OF 	msc_x_exception_details.exception_type_name%TYPE;
TYPE excepgroupList  	IS TABLE OF 	msc_x_exception_details.exception_group_name%TYPE;
TYPE itemnameList 	IS TABLE OF 	msc_x_exception_details.item_name%TYPE;
TYPE itemdescList 	IS TABLE OF 	msc_x_exception_details.item_description%TYPE;
TYPE ordernumberList 	IS TABLE OF 	msc_x_exception_details.order_number%TYPE;
TYPE releasenumList  	IS TABLE OF 	msc_x_exception_details.release_number%TYPE;
TYPE linenumList  	IS TABLE OF    	msc_x_exception_details.line_number%TYPE;
TYPE tpitemnameList  	IS TABLE OF    	msc_x_exception_details.trading_partner_item_name%TYPE;
TYPE exceptbasisList	IS TABLE OF	msc_x_exception_details.exception_basis%TYPE;

--===========================================================


PROCEDURE Launch_Engine(p_errbuf OUT NOCOPY VARCHAR2,
         p_retcode OUT NOCOPY VARCHAR2,
         p_early_order IN VARCHAR2,
         p_changed_order IN VARCHAR2,
         p_forecast_accuracy IN VARCHAR2,
         p_forecast_mismatch IN VARCHAR2,
         p_late_order IN VARCHAR2,
         p_material_excess IN VARCHAR2,
         p_material_shortage IN VARCHAR2,
         p_performance IN VARCHAR2,
         p_potential_late_order IN VARCHAR2,
         p_response_required IN VARCHAR2,
         p_custom_exception IN VARCHAR2);

PROCEDURE Start_Netting (p_early_order IN VARCHAR2,
         p_changed_order IN VARCHAR2,
         p_forecast_accuracy IN VARCHAR2,
         p_forecast_mismatch IN VARCHAR2,
         p_late_order IN VARCHAR2,
         p_material_excess IN VARCHAR2,
         p_material_shortage IN VARCHAR2,
         p_performance IN VARCHAR2,
         p_potential_late_order IN VARCHAR2,
         p_response_required IN VARCHAR2,
         p_custom_exception IN VARCHAR2);


PROCEDURE POTENTIAL_LO_NETTING (p_max_refresh_number in Number,
            p_potential_late_order in VARCHAR2);


FUNCTION DOES_EXCEPTION_ORG_EXIST (p_org_id IN Number) RETURN Number;

PROCEDURE POPULATE_EXCEPTION_ORG;


FUNCTION GENERATE_COMPLEMENT_EXCEPTION(p_company_id IN Number,
                                        p_company_site_id In Number,
                                        p_item_id IN Number,
                                        p_refresh_number IN Number,
                                        p_type IN Number,
                                        p_role IN NUMBER default null)
RETURN Boolean;

PROCEDURE Delete_Item(l_type in varchar2,
            l_key in varchar2);


PROCEDURE DELETE_WF_NOTIFICATION(p_type in varchar2,
            p_key in varchar2);

FUNCTION GET_MESSAGE_TYPE(p_exception_code in Number) RETURN Varchar2;

FUNCTION GET_MESSAGE_GROUP(p_exception_group in Number) RETURN Varchar2;

PROCEDURE UPDATE_EXCEPTIONS_SUMMARY(p_company_id IN Number,
                p_company_site_id IN Number,
                p_item_id IN Number,
                p_exception_type IN Number,
                p_exception_group IN Number);


PROCEDURE ADD_EXCEPTION_DETAILS (p_company_id IN Number,
            p_company_name IN Varchar2,
                                p_company_site_id IN Number,
                                p_company_site_name In Varchar2,
                                p_item_id In Number,
                                p_item_name In Varchar2,
                                p_item_description In Varchar2,
                                p_exception_type IN Number,
                                p_exception_type_name In Varchar2,
                                p_exception_group In Number,
                                p_exception_group_name IN Varchar2,
                                p_trx_id1 IN Number,
                                p_trx_id2 IN Number,
                                p_customer_id IN Number,
                                p_customer_name IN Varchar2,
                                p_customer_site_id IN Number,
                                p_customer_site_name in varchar2,
                                p_customer_item_name In Varchar2,
                                p_supplier_id IN Number,
                                p_supplier_name In Varchar2,
                                p_supplier_site_id IN Number ,
                                p_supplier_site_name In Varchar2,
                                p_supplier_item_name In Varchar2,
                                p_quantity3 IN Number ,
                                p_quantity1 In Number,
                                p_quantity2 In Number,
                                p_threshold In Number,
                                p_lead_time In Number,
                                p_item_min_qty In Number,
                                p_item_max_qty In Number,
                                p_order_number IN Varchar2 ,
                                p_release_number IN Varchar2,
                                p_line_number IN Varchar2,
                                p_end_order_number IN Varchar2 default null,
                                p_end_order_rel_number In Varchar2 default null,
                                p_end_order_line_number IN Varchar2 default null,
                                p_actual_date IN Date default null,
                                p_tp_actual_date IN Date default null,
                                p_creation_date IN Date default null,
                                p_tp_creation_date IN Date default null,
                                p_other_date IN Date default null
                              , p_replenishment_method IN NUMBER default null
                              );

PROCEDURE UPDATE_ITEM_EXCEPTION( p_company_id IN Number,
            p_company_site_id IN Number,
                                p_item_id IN Number,
                                p_exception_type IN Number,
            p_exception_group IN Number);

PROCEDURE ADD_ITEM_EXCEPTION( p_company_id IN Number,
            p_company_site_id In Number,
                                p_item_id IN Number,
                                p_exception_type IN Number,
                                p_exception_group IN Number);

FUNCTION DOES_EXCEPTION_EXIST(p_company_id IN Number,
            p_company_site_id IN Number,
                                p_item_id IN Number,
                                p_exception_type IN Number,
                                p_exception_group In Number) RETURN Number;


FUNCTION Get_Total_Qty( p_order_number IN VARCHAR2,
                        p_release_number IN VARCHAR2,
                        p_line_number IN VARCHAR2,
         p_company_id IN Number,
                        p_company_site_id IN NUMBER,
         p_tp_id IN Number,
                        p_tp_site_id IN NUMBER,
         p_item_id IN NUMBER) RETURN Number;

FUNCTION Does_So_Exist( p_order_number IN VARCHAR2,
                        p_release_number IN VARCHAR2,
                        p_line_number IN VARCHAR2,
         p_company_id IN Number,
         p_company_site_id IN Number,
                        p_tp_id IN NUMBER,
                        p_tp_site_id IN NUMBER,
                        p_item_id IN NUMBER) RETURN Number;

FUNCTION Does_Po_Exist( p_end_order_number IN VARCHAR2,
                        p_end_order_rel_number IN VARCHAR2,
                        p_end_order_line_number IN VARCHAR2,
         p_company_id IN NUMBER,
         p_company_site_id IN NUMBER,
                        p_tp_id IN NUMBER,
                        p_tp_site_id IN NUMBER,
                        p_item_id IN NUMBER) RETURN NUMBER;

FUNCTION Does_ShipRcpt_Exist( p_order_number IN VARCHAR2,
                        p_release_number IN VARCHAR2,
                        p_line_number IN VARCHAR2,
         p_company_id IN NUMBER,
         p_company_site_id IN NUMBER,
                        p_tp_id IN NUMBER,
                        p_tp_site_id IN NUMBER,
                        p_item_id IN NUMBER) RETURN NUMBER;

FUNCTION Does_Detail_Excep_Exist(p_company_id IN Number,
                                p_company_site_id IN Number,
            p_item_id IN Number,
                                p_exception_type IN Number,
            p_trx_id1 IN Number,
                                p_trx_id2 IN Number default null) RETURN NUMBER;

FUNCTION DOES_LO_EXIST  (p_company_id IN Number,
                        p_company_site_id IN Number,
                        p_item_id In Number,
                        p_exception_type In number,
                        p_trx_id In number) RETURN NUMBER ;

PROCEDURE DELETE_EXEC_ORDER_DEPENDENCY(p_refresh_number IN Number);

PROCEDURE PURGE_ZQTY_EXEC_ORDER (p_refresh_number IN Number);


PROCEDURE DELETE_OBSOLETE_EXCEPTIONS( p_company_id IN Number,
            p_company_site_id    in Number,
            p_customer_id   in Number,
            p_customer_site_id In Number,
            p_supplier_id In Number,
            p_supplier_site_id IN Number,
            p_exception_group IN Number,
            p_curr_exc_type  in Number,
            p_obs_exc_type  in Number,
            p_item_id   in Number,
            p_bkt_start_date  in Date,
            p_bkt_end_date    in Date,
            p_type in Number default null,
            p_transaction_id1 In Number default null,
            p_transaction_id2 IN Number default null
            );

PROCEDURE CLEAN_UP_PROCESS;


PROCEDURE ADD_TO_DELETE_TBL (p_company_id in number,
            p_company_site_id in number,
            p_customer_id in number,
            p_customer_site_id in number,
            p_supplier_id in number,
            p_supplier_site_id in number,
            p_item_id   in number,
            p_group in number,
            p_type in number,
            p_trxid1 in number,
            p_trxid2 in number,
            p_date1 in date,
            p_date2 in date,
            t_company_list IN OUT NOCOPY number_arr,
            t_company_site_list IN OUT NOCOPY number_arr,
            t_customer_list IN OUT NOCOPY number_arr,
            t_customer_site_list IN OUT NOCOPY number_arr,
            t_supplier_list IN OUT NOCOPY number_arr,
            t_supplier_site_list IN OUT NOCOPY number_arr,
            t_item_list IN OUT NOCOPY number_arr,
            t_group_list IN OUT NOCOPY number_arr,
            t_type_list IN OUT NOCOPY number_arr,
            t_trxid1_list IN OUT NOCOPY number_arr,
            t_trxid2_list IN OUT NOCOPY number_arr,
            t_date1_list IN OUT NOCOPY date_arr,
            t_date2_list IN OUT NOCOPY date_arr) ;

PROCEDURE archive_exception (t_company_list In number_arr,
         t_company_site_list in number_arr,
         t_customer_list in number_arr,
         t_customer_site_list in number_arr,
         t_supplier_list in number_arr,
         t_supplier_site_list in number_arr,
         t_item_list In number_arr,
         t_group_list in number_arr,
         t_type_list in number_arr,
         t_trxid1_list in number_arr,
         t_trxid2_list in number_arr,
         t_date1_list in date_arr,
         t_date2_list in date_arr);



--================================================================
-- with bulk insert
--================================================================
PROCEDURE ADD_TO_EXCEPTION_TBL (
   p_company_id IN Number,
   p_company_name       IN Varchar2,
         p_company_site_id    IN Number,
         p_company_site_name  IN Varchar2,
         p_item_id      IN Number,
        p_item_name     IN Varchar2,
        p_item_description    IN Varchar2,
        p_exception_type   IN Number,
        p_exception_type_name    IN Varchar2,
        p_exception_group  IN Number,
        p_exception_group_name   IN Varchar2,
        p_trx_id1       IN Number,
        p_trx_id2       IN Number,
        p_customer_id      IN Number,
        p_customer_name    IN Varchar2,
        p_customer_site_id    IN Number,
        p_customer_site_name  IN varchar2,
        p_customer_item_name  IN Varchar2,
        p_supplier_id      IN Number,
         p_supplier_name   IN Varchar2,
        p_supplier_site_id    IN Number,
        p_supplier_site_name  IN Varchar2,
        p_supplier_item_name  IN Varchar2,
        p_number1       IN Number,
        p_number2       IN Number,
        p_number3       IN Number,
        p_threshold     IN Number,
        p_lead_time     IN Number,
        p_item_min_qty     IN Number,
        p_item_max_qty     IN Number,
        p_order_number     IN Varchar2 ,
        p_release_number   IN Varchar2,
        p_line_number      IN Varchar2,
        p_end_order_number    IN Varchar2,
        p_end_order_rel_number  IN Varchar2,
        p_end_order_line_number IN Varchar2,
        p_creation_date    	IN Date,
        p_tp_creation_date    	IN Date,
        p_date1      		IN Date,
        p_date2   		IN Date,
        p_date3       		IN Date,
        p_date4			IN Date,
        p_date5			IN Date,
        p_exception_basis	IN Varchar2,
   a_company_id            IN OUT  NOCOPY number_arr,
   a_company_name          IN OUT  NOCOPY publisherList,
   a_company_site_id       IN OUT  NOCOPY number_arr,
   a_company_site_name     IN OUT  NOCOPY pubsiteList,
   a_item_id               IN OUT  NOCOPY number_arr,
   a_item_name             IN OUT  NOCOPY itemnameList,
   a_item_desc             IN OUT  NOCOPY itemdescList,
   a_exception_type        IN OUT  NOCOPY number_arr,
   a_exception_type_name   IN OUT  NOCOPY exceptypeList,
   a_exception_group       IN OUT  NOCOPY number_arr,
   a_exception_group_name  IN OUT  NOCOPY excepgroupList,
   a_trx_id1               IN OUT  NOCOPY number_arr,
   a_trx_id2               IN OUT  NOCOPY number_arr,
   a_customer_id           IN OUT  NOCOPY number_arr,
   a_customer_name         IN OUT  NOCOPY customerList,
   a_customer_site_id      IN OUT  NOCOPY number_arr,
   a_customer_site_name    IN OUT  NOCOPY custsiteList,
   a_customer_item_name IN OUT  NOCOPY itemnameList,
   a_supplier_id           IN OUT  NOCOPY number_arr,
   a_supplier_name         IN OUT  NOCOPY supplierList,
   a_supplier_site_id      IN OUT  NOCOPY number_arr,
   a_supplier_site_name    IN OUT  NOCOPY suppsiteList,
   a_supplier_item_name    IN OUT  NOCOPY itemnameList,
   a_number1               IN OUT  NOCOPY number_arr,
   a_number2               IN OUT  NOCOPY number_arr,
   a_number3               IN OUT  NOCOPY number_arr,
   a_threshold             IN OUT  NOCOPY number_arr,
   a_lead_time             IN OUT  NOCOPY number_arr,
   a_item_min_qty          IN OUT  NOCOPY number_arr,
   a_item_max_qty          IN OUT  NOCOPY number_arr,
   a_order_number          IN OUT  NOCOPY ordernumberList,
   a_release_number        IN OUT  NOCOPY releasenumList,
   a_line_number           IN OUT  NOCOPY linenumList,
   a_end_order_number      IN OUT  NOCOPY ordernumberList,
   a_end_order_rel_number  IN OUT  NOCOPY releasenumList,
   a_end_order_line_number IN OUT  NOCOPY linenumList,
   a_creation_date         IN OUT  NOCOPY date_arr,
   a_tp_creation_date      IN OUT  NOCOPY date_arr,
   a_date1           	   IN OUT  NOCOPY date_arr,
   a_date2        	   IN OUT  NOCOPY date_arr,
   a_date3                 IN OUT  NOCOPY date_arr,
   a_date4		   IN OUT  NOCOPY date_arr,
   a_date5		   IN OUT  NOCOPY date_arr,
   a_exception_basis	   IN OUT  NOCOPY exceptbasisList);

--===================================================================
-- PROCEDURE POPUATE_EXCEPTION_DATA
--===================================================================
PROCEDURE POPULATE_EXCEPTION_DATA(
   a_company_id            IN  number_arr,
   a_company_name          IN  publisherList,
   a_company_site_id       IN  number_arr,
   a_company_site_name     IN  pubsiteList,
   a_item_id               IN  number_arr,
   a_item_name             IN  itemnameList,
   a_item_desc             IN  itemdescList,
   a_exception_type        IN  number_arr,
   a_exception_type_name   IN  exceptypeList,
   a_exception_group       IN  number_arr,
   a_exception_group_name  IN  excepgroupList,
   a_trx_id1               IN  number_arr,
   a_trx_id2               IN  number_arr,
   a_customer_id           IN  number_arr,
   a_customer_name         IN  customerList,
   a_customer_site_id      IN  number_arr,
   a_customer_site_name    IN  custsiteList,
   a_customer_item_name IN  itemnameList,
   a_supplier_id           IN  number_arr,
   a_supplier_name         IN  supplierList,
   a_supplier_site_id      IN  number_arr,
   a_supplier_site_name    IN  suppsiteList,
   a_supplier_item_name    IN  itemnameList,
   a_number1               IN  number_arr,
   a_number2               IN  number_arr,
   a_number3               IN  number_arr,
   a_threshold             IN  number_arr,
   a_lead_time             IN  number_arr,
   a_item_min_qty          IN  number_arr,
   a_item_max_qty          IN  number_arr,
   a_order_number          IN  ordernumberList,
   a_release_number        IN  releasenumList,
   a_line_number           IN  linenumList,
   a_end_order_number      IN  ordernumberList,
   a_end_order_rel_number  IN  releasenumList,
   a_end_order_line_number IN  linenumList,
   a_creation_date         IN  date_arr,
   a_tp_creation_date      IN  date_arr,
   a_date1           	   IN  date_arr,
   a_date2        	   IN  date_arr,
   a_date3            	   IN  date_arr,
   a_date4		   IN  date_arr,
   a_date5		   IN  date_arr,
   a_exception_basis	   IN  exceptbasisList);

PROCEDURE update_item (p_refresh_number in Number);

PROCEDURE  DELETE_EXCEP; --added for bug#6729356

END MSC_X_NETTING_PKG;


/
