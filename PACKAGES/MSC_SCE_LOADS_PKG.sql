--------------------------------------------------------
--  DDL for Package MSC_SCE_LOADS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SCE_LOADS_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCXLDS.pls 120.3 2007/07/04 10:33:27 vsiyer noship $ */

  /*Constants*/
  G_NULL_STRING          CONSTANT VARCHAR2(10) := '-234567';
  G_PLAN_ID              CONSTANT NUMBER       := -1;
  G_SR_INSTANCE_ID       CONSTANT NUMBER       := -1;
  G_OPERATOR             CONSTANT NUMBER       := 1;
  G_BATCH_SIZE           CONSTANT NUMBER       := 500;
  G_UOM                  CONSTANT VARCHAR2(3)  := 'Ea';

  /* Order types */
  G_SALES_FORECAST       CONSTANT NUMBER       := 1;
  G_SUPPLY_SCHEDULE      CONSTANT NUMBER       := 2;
  G_ORDER_FORECAST       CONSTANT NUMBER       := 2;
  G_SUPPLY_COMMIT        CONSTANT NUMBER       := 3;
  G_ALLOCATED_SUPPLY     CONSTANT NUMBER       := 3;
  G_HIST_SALES           CONSTANT NUMBER       := 4;
  G_SELL_THRO_FCST       CONSTANT NUMBER       := 5;
  G_SUPPLIER_CAP         CONSTANT NUMBER       := 6;
  G_SAFETY_STOCK         CONSTANT NUMBER       := 7;
  G_PROJ_SS              CONSTANT NUMBER       := 8;
  G_ALLOC_ONHAND         CONSTANT NUMBER       := 9;
  G_UNALLOCATED_ONHAND   CONSTANT NUMBER       := 10;
  G_PROJ_UNALLOC_AVAIL   CONSTANT NUMBER       := 11;
  G_PROJ_ALLOC_AVAIL     CONSTANT NUMBER       := 12;
  G_PURCHASE_ORDER       CONSTANT NUMBER       := 13;
  G_SALES_ORDER          CONSTANT NUMBER       := 14;
  G_ASN                  CONSTANT NUMBER       := 15;
  G_SHIP_RECEIPT         CONSTANT NUMBER       := 16;
  G_INTRANSIT            CONSTANT NUMBER       := 17;
  G_WORK_ORDER           CONSTANT NUMBER       := 45;
  G_REPLENISHMENT        CONSTANT NUMBER       := 19;
  G_REQUISITION          CONSTANT NUMBER       := 20;
  G_POA                  CONSTANT NUMBER       := 21;
  g_proj_avai_bal        CONSTANT NUMBER       := 27;
  G_CONS_ADVICE		 CONSTANT NUMBER       := 28;

  G_PO_ACKNOWLEDGEMENT CONSTANT NUMBER       := 21;
  G_NEGOTIATED_CAPACITY CONSTANT NUMBER       := 6;

  /* Bucket type */
  G_DAY                  CONSTANT NUMBER       := 1;
  G_WEEK                 CONSTANT NUMBER       := 2;
  G_MONTH                CONSTANT NUMBER       := 3;

  /* Row statuses */
  G_HEADER_FAILURE       CONSTANT NUMBER       := 1;
  G_PROCESS              CONSTANT NUMBER       := 2;
  G_SUCCESS              CONSTANT NUMBER       := 3;
  G_FAILURE              CONSTANT NUMBER       := 4;
  G_DELETED              CONSTANT NUMBER       := -99;

  /* Serial_Number_Control_code */
  G_SERIAL_ITEM          CONSTANT NUMBER       := 1;

  /* PL/SQL table types */
  TYPE headeridList     IS TABLE OF    msc_supdem_lines_interface.parent_header_id%TYPE;
  TYPE lineidList       IS TABLE OF    msc_supdem_lines_interface.line_id%TYPE;
  TYPE publisherList    IS TABLE OF    msc_companies.company_name%TYPE;
  TYPE publishidList    IS TABLE OF    msc_companies.company_id%TYPE;
  TYPE pubsiteList      IS TABLE OF    msc_company_sites.company_site_name%TYPE;
  TYPE pubsiteidList    IS TABLE OF    msc_company_sites.company_site_id%TYPE;
  TYPE pubaddrList      IS TABLE OF    msc_sup_dem_entries.publisher_address%TYPE;
  TYPE customerList     IS TABLE OF    msc_companies.company_name%TYPE;
  TYPE custidList       IS TABLE OF    msc_companies.company_id%TYPE;
  TYPE custsiteList     IS TABLE OF    msc_company_sites.company_site_name%TYPE;
  TYPE custsiteidList   IS TABLE OF    msc_company_sites.company_site_id%TYPE;
  TYPE custaddrList     IS TABLE OF    msc_sup_dem_entries.customer_address%TYPE;
  TYPE supplierList     IS TABLE OF    msc_companies.company_name%TYPE;
  TYPE suppidList       IS TABLE OF    msc_companies.company_id%TYPE;
  TYPE suppsiteList     IS TABLE OF    msc_company_sites.company_site_name%TYPE;
  TYPE suppsiteidList   IS TABLE OF    msc_company_sites.company_site_id%TYPE;
  TYPE suppaddrList     IS TABLE OF    msc_sup_dem_entries.supplier_address%TYPE;
  TYPE shipfromList     IS TABLE OF    msc_companies.company_name%TYPE;
  TYPE shipfromidList   IS TABLE OF    msc_companies.company_id%TYPE;
  TYPE shipfromsiteList IS TABLE OF    msc_company_sites.company_site_name%TYPE;
  TYPE shipfromsidList  IS TABLE OF    msc_company_sites.company_site_id%TYPE;
  TYPE shipfromaddrList IS TABLE OF    msc_sup_dem_entries.ship_from_address%TYPE;
  TYPE shiptoList       IS TABLE OF    msc_companies.company_name%TYPE;
  TYPE shiptoidList     IS TABLE OF    msc_companies.company_id%TYPE;
  TYPE shiptositeList   IS TABLE OF    msc_company_sites.company_site_name%TYPE;
  TYPE shiptosidList    IS TABLE OF    msc_company_sites.company_site_id%TYPE;
  TYPE shiptopaddrList  IS TABLE OF    msc_sup_dem_entries.ship_to_address%TYPE;
  TYPE shiptoaddrList   IS TABLE OF    msc_supdem_lines_interface.ship_to_address%TYPE;
  TYPE endordpubList    IS TABLE OF    msc_companies.company_name%TYPE;
  TYPE endordpubidList  IS TABLE OF    msc_companies.company_id%TYPE;
  TYPE endordpubsiteList IS TABLE OF    msc_company_sites.company_site_name%TYPE;
  TYPE endordpubsidList IS TABLE OF    msc_company_sites.company_site_id%TYPE;
  TYPE ordertypeList    IS TABLE OF    fnd_lookup_values.lookup_code%TYPE;
  TYPE otdescList       IS TABLE OF    fnd_lookup_values.meaning%TYPE;
  TYPE endordertypeList IS TABLE OF    fnd_lookup_values.lookup_code%TYPE;
  TYPE endotdescList    IS TABLE OF    fnd_lookup_values.meaning%TYPE;
  TYPE bktypedescList   IS TABLE OF    fnd_lookup_values.meaning%TYPE;
  TYPE bktypeList       IS TABLE OF    fnd_lookup_values.lookup_code%TYPE;
  TYPE itemList         IS TABLE OF    msc_system_items.item_name%TYPE;
  TYPE itemidList       IS TABLE OF    msc_system_items.inventory_item_id%TYPE;
  TYPE itemdescList     IS TABLE OF    msc_system_items.description%TYPE;
  TYPE categoryList     IS TABLE OF    msc_system_items.category_name%TYPE;
  TYPE ordernumList     IS TABLE OF    msc_supdem_lines_interface.order_identifier%TYPE;
  TYPE linenumList      IS TABLE OF    msc_supdem_lines_interface.line_number%TYPE;
  TYPE relnumList       IS TABLE OF    msc_supdem_lines_interface.release_number%TYPE;
  TYPE endordList       IS TABLE OF    msc_supdem_lines_interface.pegging_order_identifier%TYPE;
  TYPE endlineList      IS TABLE OF    msc_supdem_lines_interface.ref_line_number%TYPE;
  TYPE endrelList       IS TABLE OF    msc_supdem_lines_interface.ref_release_number%TYPE;
  TYPE keydateList      IS TABLE OF    msc_sup_dem_entries.key_date%TYPE;
  TYPE newschedList     IS TABLE OF    msc_sup_dem_entries.new_schedule_date%TYPE;
  TYPE shipdateList     IS TABLE OF    msc_sup_dem_entries.ship_date%TYPE;
  TYPE receiptdateList  IS TABLE OF    msc_sup_dem_entries.receipt_date%TYPE;
  TYPE newordplaceList  IS TABLE OF    msc_sup_dem_entries.new_order_placement_date%TYPE;
  TYPE origpromList     IS TABLE OF    msc_sup_dem_entries.original_promised_date%TYPE;
  TYPE reqdateList      IS TABLE OF    msc_sup_dem_entries.request_date%TYPE;
  TYPE wipstdatelist    IS TABLE OF    msc_sup_dem_entries.wip_start_date%TYPE;
  TYPE wipenddatelist   IS TABLE OF    msc_sup_dem_entries.wip_end_date%TYPE;
  TYPE qtyList          IS TABLE OF    msc_supdem_lines_interface.quantity%TYPE;
  TYPE uomList          IS TABLE OF    msc_sup_dem_entries.uom_code%TYPE;
  TYPE commentList      IS TABLE OF    msc_supdem_lines_interface.comments%TYPE;
  TYPE carrierList      IS TABLE OF    msc_supdem_lines_interface.carrier_code%TYPE;
  TYPE billofladList    IS TABLE OF    msc_supdem_lines_interface.bill_of_lading_number%TYPE;
  TYPE trackingList     IS TABLE OF    msc_supdem_lines_interface.tracking_number%TYPE;
  TYPE vehicleList      IS TABLE OF    msc_supdem_lines_interface.vehicle_number%TYPE;
  TYPE containerList    IS TABLE OF    msc_supdem_lines_interface.container_type%TYPE;
  TYPE contqtyList      IS TABLE OF    msc_supdem_lines_interface.container_qty%TYPE;
  TYPE serialnumList    IS TABLE OF    msc_supdem_lines_interface.serial_number%TYPE;
  TYPE attachurlList    IS TABLE OF    msc_supdem_lines_interface.attachment_url%TYPE;
  TYPE errmsgList       IS TABLE OF    msc_supdem_lines_interface.err_msg%TYPE;
  TYPE versionList      IS TABLE OF    msc_supdem_lines_interface.version%TYPE;
  TYPE designatorList   IS TABLE OF    msc_supdem_lines_interface.designator%TYPE;
  TYPE contextList      IS TABLE OF    msc_supdem_lines_interface.context%TYPE;
  TYPE attributeList    IS TABLE OF    msc_supdem_lines_interface.attribute1%TYPE;
  TYPE postingpartyList IS TABLE OF    msc_supdem_lines_interface.posting_party_name%TYPE;
  TYPE lastupdatedateList IS TABLE OF  msc_supdem_lines_interface.last_update_date%TYPE; -- Bug # 5599903
  TYPE lastupdatedbyList IS TABLE OF   msc_supdem_lines_interface.last_updated_by%TYPE;
  TYPE syncList	        IS TABLE OF    msc_supdem_lines_interface.sync_indicator%TYPE; --Fix for bug 6147298
  TYPE delqtyList	IS TABLE OF    msc_supdem_lines_interface.quantity%TYPE; --Fix for bug 6147298
  TYPE numList          IS TABLE OF    NUMBER;
  TYPE usernameList     IS TABLE OF    fnd_user.user_name%TYPE;
  TYPE eventkeyList     IS TABLE OF    VARCHAR2(30);
  TYPE serialTxnId      IS TABLE OF    msc_st_serial_numbers.serial_txn_id%TYPE;
  TYPE serialNumber     IS TABLE OF    msc_st_serial_numbers.serial_number%TYPE;
  TYPE attachmentUrl    IS TABLE OF    msc_st_serial_numbers.attachment_url%TYPE;
  TYPE userDefined      IS TABLE OF    msc_st_serial_numbers.user_defined1%TYPE;
  TYPE creationDate     IS TABLE OF    msc_st_serial_numbers.creation_date%TYPE;
  TYPE createdBy        IS TABLE OF    msc_st_serial_numbers.created_by%TYPE;
  TYPE lastUpdateDate   IS TABLE OF    msc_st_serial_numbers.last_update_date%TYPE;
  TYPE lastUpdatedBy    IS TABLE OF    msc_st_serial_numbers.last_updated_by%TYPE;
  TYPE lastUpdateLogin  IS TABLE OF    msc_st_serial_numbers.last_update_login%TYPE;
  TYPE context          IS TABLE OF    msc_st_serial_numbers.context%TYPE;
  TYPE attribute        IS TABLE OF    msc_st_serial_numbers.attribute1%TYPE;
  TYPE syncIndicator    IS TABLE OF    msc_st_serial_numbers.sync_indicator%TYPE;
  TYPE rowStatus        IS TABLE OF    msc_st_serial_numbers.row_status%TYPE;
  TYPE errMsg           IS TABLE OF    msc_st_serial_numbers.err_msg%TYPE;
  TYPE planId           IS TABLE OF    msc_serial_numbers.plan_id%TYPE;
  TYPE disableDate      IS TABLE OF    msc_serial_numbers.disable_date%TYPE;
  TYPE rowidList        IS TABLE OF    ROWID INDEX BY BINARY_INTEGER;
  TYPE serialLineId     IS TABLE OF    msc_st_serial_numbers.line_id%TYPE;
  TYPE serialErrMsg  IS TABLE OF    msc_st_serial_numbers.err_msg%TYPE;
  TYPE serialOrderType  IS TABLE OF    msc_st_serial_numbers.order_type%TYPE;
  TYPE transactionIdList IS TABLE OF   msc_sup_dem_entries.transaction_id%TYPE;
  TYPE shipCtrlList IS TABLE OF   msc_sup_dem_entries.shipping_control%TYPE;
  TYPE plannerCode IS TABLE OF   msc_sup_dem_entries.planner_code%TYPE;--Bug 4424426


  PROCEDURE get_user_id(
    p_int_control_number IN NUMBER,
    p_user_id OUT NOCOPY NUMBER
  );

  PROCEDURE update_errors (
    p_header_id  IN  NUMBER,
    p_language   IN  VARCHAR2,
    p_build_err  IN  NUMBER,
    p_date_format IN VARCHAR2
    , p_consumption_advice_exists OUT NOCOPY BOOLEAN -- bug 3551850
    );

  PROCEDURE send_ntf (
    p_header_id  IN  NUMBER,
    p_file_name  IN  VARCHAR2,
    p_status     IN  NUMBER,
    p_user_name  IN  VARCHAR2,
    p_event_key  IN  VARCHAR2
  );

  FUNCTION get_message (
    p_app  IN VARCHAR2,
    p_name IN VARCHAR2,
    p_lang IN VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION build_error_string (
    p_header_id  IN  NUMBER,
    p_lang       IN  VARCHAR2
  ) RETURN VARCHAR2;



  --=====================================================================
  -- This procedure is called by the Flat file UI, XML Map and
  -- Manual Order Entry UI. The input and output parameters are
  -- explained below:
  --
  -- p_header_id => MSC_SUPDEM_HDRS_INTERFACE.HEADER_ID
  -- p_build_err => 1 when the API is called by the FF-UI and XML
  --                2 when the API is called by the manual order entry UI
  --
  -- The OUT parameters are populated only when the API is called by
  -- the manual order entry UI
  --
  -- p_status    => 0 if the manual order entry was successful
  --                1 if the manual order entry fails
  -- p_err_msg   => Contains the the error message string
  --
  --======================================================================

  PROCEDURE validate (

    p_err_msg   OUT NOCOPY VARCHAR2,
    p_status    OUT NOCOPY NUMBER,
    p_header_id IN NUMBER,
    p_build_err IN NUMBER
  );

  FUNCTION checkdates (
    p_header_id IN NUMBER,
    p_line_id IN NUMBER,
    p_date_format IN VARCHAR2
  ) RETURN NUMBER;

  PROCEDURE get_optional_info (
    p_header_id           IN     Number,
    p_language_code       IN     Varchar2,
    t_line_id             IN     lineidList,
    t_end_order_pub       IN     endordpubList,
    t_end_ord_pub_site    IN     endordpubsiteList,
    t_shipfrom            IN     shipfromList,
    t_shipfrom_site       IN     shipfromsiteList,
    t_shipto              IN     shiptoList,
    t_shipto_site         IN     shiptositeList,
    t_end_ot_desc         IN     endotdescList,
    t_posting_party_name  IN     postingpartyList,
    t_cust_id             IN OUT NOCOPY custidList,
    t_cust_site_id        IN OUT NOCOPY custsiteidList,
    t_supp_id             IN     suppidList,
    t_supp_site_id        IN     suppsiteidList,
    t_item_id             IN     itemidList,
    t_order_type          IN     ordertypeList,
    t_ship_date           IN OUT NOCOPY shipdateList,
    t_receipt_date        IN OUT NOCOPY receiptdateList,
    t_end_order_type      IN OUT NOCOPY endordertypeList,
    t_end_ord_pub_id      IN OUT NOCOPY endordpubidList,
    t_end_ord_pub_site_id IN OUT NOCOPY endordpubsidList,
    t_shipfrom_id         IN OUT NOCOPY shipfromidList,
    t_shipfrom_site_id    IN OUT NOCOPY shipfromsidList,
    t_shipto_id           IN OUT NOCOPY shiptoidList,
    t_shipto_site_id      IN OUT NOCOPY shiptosidList,
    t_posting_party_id    IN OUT NOCOPY numList,
    t_cust                IN OUT NOCOPY customerList,
    t_cust_site           IN OUT NOCOPY custsiteList,
    t_key_date		  IN OUT NOCOPY keydateList
  );

  PROCEDURE replace_supdem_entries (
    p_header_id            IN Number,
    t_line_id              IN lineidList,
    t_pub                  IN publisherList,
    t_pub_id               IN publishidList,
    t_pub_site             IN pubsiteList,
    t_pub_site_id          IN pubsiteidList,
    t_pub_addr             IN pubaddrList,
    t_cust                 IN customerList,
    t_cust_id              IN custidList,
    t_cust_site            IN custsiteList,
    t_cust_site_id         IN custsiteidList,
    t_cust_addr            IN custaddrList,
    t_supp                 IN supplierList,
    t_supp_id              IN suppidList,
    t_supp_site            IN suppsiteList,
    t_supp_site_id         IN suppsiteidList,
    t_supp_addr            IN suppaddrList,
    t_shipfrom             IN shipfromList,
    t_shipfrom_id          IN shipfromidList,
    t_shipfrom_site        IN shipfromsiteList,
    t_shipfrom_site_id     IN shipfromsidList,
    t_shipfrom_addr        IN shipfromaddrList,
    t_shipto               IN shiptoList,
    t_shipto_id            IN shiptoidList,
    t_shipto_site          IN shiptositeList,
    t_shipto_site_id       IN shiptosidList,
    t_shipto_party_addr    IN shiptopaddrList,
    t_shipto_addr          IN shiptoaddrList,
    t_end_order_pub        IN endordpubList,
    t_end_ord_pub_id       IN endordpubidList,
    t_end_ord_pub_site     IN endordpubsiteList,
    t_end_ord_pub_site_id  IN endordpubsidList,
    t_order_type           IN ordertypeList,
    t_ot_desc              IN otdescList,
    t_end_order_type       IN endordertypeList,
    t_end_ot_desc          IN endotdescList,
    t_bkt_type_desc        IN bktypedescList,
    t_bkt_type             IN bktypeList,
    t_item_id              IN itemidList,
    t_ord_num              IN ordernumList,
    t_line_num             IN linenumList,
    t_rel_num              IN relnumList,
    t_end_ord              IN endordList,
    t_end_line             IN endlineList,
    t_end_rel              IN endrelList,
    t_key_date             IN keydateList,
    t_new_sched_date       IN newschedList,
    t_ship_date            IN shipdateList,
    t_receipt_date         IN receiptdateList,
    t_new_ord_plac_date    IN newordplaceList,
    t_orig_prom_date       IN origpromList,
    t_req_date             IN reqdateList,
    /* Added for work order support */
    t_wip_st_date          IN wipstdatelist,
    t_wip_end_date         IN wipenddatelist,
    t_uom                  IN uomList,
    t_quantity             IN qtyList,
    t_comments             IN commentList,
    t_carrier_code         IN carrierList,
    t_bill_of_lading       IN billofladList,
    t_tracking_number      IN trackingList,
    t_vehicle_number       IN vehicleList,
    t_container_type       IN containerList,
    t_container_qty        IN contqtyList,
    t_serial_number        IN serialnumList,
    t_attach_url           IN attachurlList,
    t_version              IN versionList,
    t_designator           IN designatorList,
    t_context		   IN contextList,
    t_attribute1           IN attributeList,
    t_attribute2           IN attributeList,
    t_attribute3           IN attributeList,
    t_attribute4           IN attributeList,
    t_attribute5           IN attributeList,
    t_attribute6           IN attributeList,
    t_attribute7           IN attributeList,
    t_attribute8           IN attributeList,
    t_attribute9           IN attributeList,
    t_attribute10          IN attributeList,
    t_attribute11          IN attributeList,
    t_attribute12          IN attributeList,
    t_attribute13          IN attributeList,
    t_attribute14          IN attributeList,
    t_attribute15          IN attributeList,
    --p_posting_party_name    IN VARCHAR2,
    --p_posting_party_id     IN NUMBER,
    t_posting_party_name   IN postingpartyList,
    t_posting_party_id     IN numList,
    p_user_id              IN NUMBER,
    p_language_code        IN VARCHAR2
  );

  --===========================================================================
  --This proc is called in the XML Gateway Maps. The XML gateway action type
  --converts the OAG date format into 'YYYYMMDD HH24MISS' format. The proc
  --takes in a string containing a date in the 'YYYYMMDD HH24MISS' format and
  --converts it to 'DD-MON-YYYY HH24:MI:SS' format.
  --===========================================================================
  PROCEDURE change_date_format (
    p_string IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE LOG_MESSAGE(
    p_string IN  VARCHAR2
  );

  PROCEDURE POST_PROCESS(
    p_header_id IN NUMBER
  );

  PROCEDURE UPDATE_QTY_FROM_UI(
    p_item_id IN number,
    p_qty     IN number,
    p_uom     IN varchar2,
    p_pri_uom IN varchar2,
    p_tp_uom  IN varchar2,
    p_pri_qty OUT NOCOPY number,
    p_tp_qty  OUT NOCOPY number
  );

  FUNCTION GET_QUANTITY(
   p_qty IN NUMBER,
   p_uom IN VARCHAR2,
   p_uom1 IN VARCHAR2,
   p_item_id IN NUMBER
  ) RETURN NUMBER;

  --=======================================================================
  -- These procedure are used to verify and load serial Number information
  -- To improve the perfomance it creates indexes on MSC_ST_SERIAL_NUMBERS
  -- abd drops it at the before exiting from the code
  --====================================================================

  PROCEDURE serial_validation(
        p_header_id  IN  NUMBER,
   p_language  IN VARCHAR2
  );

  PROCEDURE drop_index(
       v_applsys_schema IN  VARCHAR2
  );

  PROCEDURE create_index (
       v_applsys_schema IN  VARCHAR2
  );

-- API to validate receipt/ship date for TP as a customer
PROCEDURE validate_rs_dates_supplier(
           t_line_id IN lineidList
         , p_header_id IN NUMBER
         , p_language IN VARCHAR2
         );

-- API to validate receipt/ship date for TP as a customer
PROCEDURE validate_rs_dates_customer(
           t_line_id IN lineidList
         , p_header_id IN NUMBER
         , p_language IN VARCHAR2
         );

END msc_sce_loads_pkg;

/
