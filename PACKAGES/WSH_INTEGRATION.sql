--------------------------------------------------------
--  DDL for Package WSH_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_INTEGRATION" AUTHID CURRENT_USER as
/* $Header: WSHINTGS.pls 120.3.12010000.6 2010/08/06 16:11:35 anvarshn ship $ */

--================ CONSTANT DECLARATION ==================
C_SDEBUG              CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL1;
C_DEBUG               CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL2;

--================ TYPE DECLARATION ==================
TYPE MsgRecType is RECORD (
      message_name   VARCHAR2(30),
      message_type   VARCHAR2(1),
      message_text   VARCHAR2(2000));

TYPE MSG_TABLE IS TABLE OF  MsgRecType index by binary_integer ;

TYPE MinMaxInRecType is RECORD (
     api_version_number       NUMBER,
     source_code              VARCHAR2(5),
     line_id                  NUMBER
);

TYPE MinMaxOutRecType is RECORD (
     quantity_uom             VARCHAR2(3),
     min_remaining_quantity   NUMBER,
     max_remaining_quantity   NUMBER,
     quantity2_uom            VARCHAR2(3),
     min_remaining_quantity2  NUMBER,
     max_remaining_quantity2  NUMBER
);

TYPE MinMaxInOutRecType is RECORD (
     dummy_quantity           NUMBER
);


TYPE ShpgUnTrxdInRecType is RECORD (
     api_version_number           NUMBER,
     source_code                  VARCHAR2(5),
     closing_fm_date              DATE,
     closing_to_date              DATE,
     organization_id              NUMBER);

TYPE ShpgUnTrxdOutRecType is RECORD (
     untrxd_rec_count             NUMBER,
     receiving_rec_count          NUMBER
);

TYPE ShpgUnTrxdInOutRecType is RECORD (
     dummy_count           NUMBER);

-- 2465199
TYPE LineIntfInRecType is RECORD (
     api_version_number           NUMBER,
     source_code                  VARCHAR2(5),
     line_id                      NUMBER);

TYPE LineIntfOutRecType is RECORD (
     nonintf_line_qty             NUMBER);

TYPE LineIntfInOutRecType is RECORD (
     dummy_count           NUMBER);

--  This record type contains information needed to identify the delivery detail which is being backordered
--  in the case of Ship Sets and SMC when Enforce Ship Set / SMC option is set
TYPE BackorderRecType IS RECORD
                ( move_order_line_id           NUMBER,
                  delivery_detail_id           NUMBER,
                  ship_set_id                  NUMBER,
                  ship_model_id                NUMBER
                 );

TYPE BackorderRec_Tbl IS TABLE OF BackorderRecType INDEX BY BINARY_INTEGER;

G_BackorderRec_Tbl        BackorderRec_Tbl;

G_MSG_TABLE             MSG_TABLE ;

-- For the issue in 2678601 porting to Pack I
-- For bug 2805603, added transaction_temp_id in both record structures
TYPE InvPCInRecType is RECORD (
     api_version_number           NUMBER,
     source_code                  VARCHAR2(5),
     transaction_id               NUMBER,
     transaction_temp_id          NUMBER
);

TYPE InvPCOutRecType is RECORD (
     transaction_id               NUMBER,
     transaction_temp_id          NUMBER
);

-- Create SUBTYPE
SUBTYPE GRP_ATTR_REC_TYPE IS WSH_DELIVERY_AUTOCREATE.GRP_ATTR_REC_TYPE;
SUBTYPE GRP_ATTR_TAB_TYPE IS WSH_DELIVERY_AUTOCREATE.GRP_ATTR_TAB_TYPE;
SUBTYPE ACTION_REC_TYPE IS WSH_DELIVERY_AUTOCREATE.ACTION_REC_TYPE;
SUBTYPE OUT_REC_TYPE IS WSH_DELIVERY_AUTOCREATE.OUT_REC_TYPE;

--================ PROCEDURE/FUNCTION DECLARATION ==================
PROCEDURE Get_Min_Max_Tolerance_Quantity
                ( p_in_attributes           IN     MinMaxInRecType,
                  p_out_attributes          OUT NOCOPY     MinMaxOutRecType,
                  p_inout_attributes        IN OUT NOCOPY  MinMaxInOutRecType,
                  x_return_status           OUT NOCOPY     VARCHAR2,
                  x_msg_count               OUT NOCOPY     NUMBER,
                  x_msg_data                OUT NOCOPY     VARCHAR2
                );
PROCEDURE Get_Untrxd_Shpg_Lines_Count
                ( p_in_attributes           IN     ShpgUnTrxdInRecType,
                  p_out_attributes          OUT NOCOPY     ShpgUnTrxdOutRecType,
                  p_inout_attributes        IN OUT NOCOPY  ShpgUnTrxdInOutRecType,
                  x_return_status           OUT NOCOPY     VARCHAR2,
                  x_msg_count               OUT NOCOPY     NUMBER,
                  x_msg_data                OUT NOCOPY     VARCHAR2
                );
PROCEDURE Get_NonIntf_Shpg_Line_Qty
                ( p_in_attributes           IN     LineIntfInRecType,
                  p_out_attributes          OUT NOCOPY     LineIntfOutRecType,
                  p_inout_attributes        IN OUT NOCOPY  LineIntfInOutRecType,
                  x_return_status           OUT NOCOPY     VARCHAR2,
                  x_msg_count               OUT NOCOPY     NUMBER,
                  x_msg_data                OUT NOCOPY     VARCHAR2
                );

PROCEDURE Ins_Backorder_SS_SMC_Rec (
                                         p_api_version_number  IN     NUMBER,
                                         p_source_code         IN     VARCHAR2,
                                         p_init_msg_list       IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
                                         p_backorder_rec       IN     BackorderRecType,
                                         x_return_status       OUT NOCOPY     VARCHAR2,
                                         x_msg_count           OUT NOCOPY     NUMBER,
                                         x_msg_data            OUT NOCOPY     VARCHAR2
                                     );

/*
**   -- The Following API has been copied from WMS file WSHPRASS.pls.
*/

/*
*******************************************************************
*  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA *
*  All rights reserved.                                           *
*                                                                 *
*  FILENAME                                                       *
*      WSHPRASS.pls                                               *
*                                                                 *
*  DESCRIPTION                                                    *
*    Spec of package WSH_PRINTER_ASSIGNMENT_PVT                   *
*    This contains the procedure to update WSH_REPORT_PRINTERS    *
*    appropriately when called from the new mobile sign on page   *
*                                                                 *
*    This API is capable of enabling/disabling specific           *
*    printers or all printers if the API is called w/o a          *
*    printer name. The default printer is the printer which       *
*    has been lately enabled.                                     *
*                                                                 *
*    The following is an explanation for the input parameters     *
*    --------------------------------------------------------     *
*    p_application_id   - Application ID.                         *
*    p_conc_program_id  - Docuemnt ID.                            *
*    p_level_type_id    - Level Type (Site, App, Resp, User       *
*    p_level_value_id   - Level Value for specific Level Type     *
*    p_organization_id  - Organization ID (Not currently used)    *
*    p_printer_name     - Printer to be enabled                   *
*    p_enabled_flag     - Enable/Disable                          *
*******************************************************************/
--  NOTES
--
--  HISTORY
--
--  05-June-2002 Created By Johnson Abraham (joabraha@us)
PROCEDURE update_printer_assignment(
                x_msg_count             OUT NOCOPY  NUMBER
        ,       x_msg_data              OUT NOCOPY  VARCHAR2
        ,       x_return_status         OUT NOCOPY  VARCHAR2
        ,       p_application_id        IN NUMBER DEFAULT NULL
        ,       p_conc_program_id       IN NUMBER DEFAULT NULL
        ,       p_level_type_id         IN NUMBER DEFAULT NULL
        ,       p_level_value_id        IN NUMBER DEFAULT NULL
        ,       p_organization_id       IN NUMBER DEFAULT NULL
        ,       p_printer_name          IN VARCHAR2 DEFAULT NULL
        ,       p_enabled_flag          IN VARCHAR2 DEFAULT NULL);


PROCEDURE Set_Inv_PC_Attributes
                ( p_in_attributes           IN         InvPCInRecType,
                  x_return_status           OUT NOCOPY VARCHAR2,
                  x_msg_count               OUT NOCOPY NUMBER,
                  x_msg_data                OUT NOCOPY VARCHAR2
                );

PROCEDURE Get_Inv_PC_Attributes
                ( p_out_attributes          OUT NOCOPY InvPCOutRecType,
                  x_return_status           OUT NOCOPY VARCHAR2,
                  x_msg_count               OUT NOCOPY NUMBER,
                  x_msg_data                OUT NOCOPY VARCHAR2
                );


-- DBI Project, Added in 11.5.10+
-- Check if DBI is Installed
Function DBI_Installed return VARCHAR2;

-- Call DBI API for updates in Delivery Detail
PROCEDURE DBI_Update_Detail_Log
  (p_delivery_detail_id_tab IN WSH_UTIL_CORE.id_tab_type,
   p_dml_type               IN VARCHAR2,
   x_return_status          OUT NOCOPY VARCHAR2);

-- Call DBI API for Create/Update/Delete of Trip Stop, Create/Delete Delivery Leg
PROCEDURE DBI_Update_Trip_Stop_Log
  (p_stop_id_tab         IN WSH_UTIL_CORE.id_tab_type,
   p_dml_type            IN VARCHAR2,
   x_return_status       OUT NOCOPY VARCHAR2);

/***********************************
-- R12, X-dock, record structures for X-dock integration
-- the data types are different from WSHDEAUS, as they do not refer to the table
TYPE    GRP_ATTR_REC_TYPE IS RECORD (
        batch_id                        number,
        group_id                        number,
        entity_id                       number,
        entity_type                     varchar2(30),
        status_code                     varchar2(30),
        planned_flag                    varchar2(1),
        ship_to_location_id             number,
        ship_from_location_id           number,
        customer_id                     number,
        intmed_ship_to_location_id      number,
        fob_code                        varchar2(30),
        freight_terms_code              varchar2(30),
        ship_method_code                varchar2(30),
        carrier_id                      number,
        source_header_id                number,
        deliver_to_location_id          number,
        organization_id                 number,
        date_scheduled                  date,
        date_requested                  date,
        delivery_id                     number,
        ignore_for_planning             varchar2(1) DEFAULT 'N',
        line_direction                  varchar2(30),
        shipping_control                varchar2(30),
        vendor_id                       number,
        party_id                        number,
        mode_of_transport               varchar2(30),
        service_level                   varchar2(30),
        lpn_id                          number,
        inventory_item_id               number,
        source_code                     varchar2(30),
        container_flag                  varchar2(1),
        l1_hash_string                  varchar2(1000),
        l1_hash_value                   number);

TYPE grp_attr_tab_type IS TABLE OF GRP_ATTR_REC_TYPE INDEX BY BINARY_INTEGER;

type action_rec_type is record (action varchar2(30),
                           caller varchar2(30),
                           group_by_header_flag varchar2(1),
                           group_by_delivery_flag varchar2(1),
                           output_format_type varchar2(30),
                           output_entity_type varchar2(30),
                           check_single_grp varchar2(1));

type out_rec_type is record (query_string varchar2(4000),
                        single_group varchar2(1),
                        bind_hash_value number,
                        bind_hash_string varchar2(1000),
                        bind_batch_id number,
                        bind_header_id number,
                        bind_carrier_id number,
                        bind_mode_of_transport varchar2(30),
                        bind_service_level varchar2(30));

*******************************/

--procedure for X-dock integration
PROCEDURE Find_Matching_Groups
          (p_attr_tab         IN OUT NOCOPY GRP_ATTR_TAB_TYPE,
           p_action_rec       IN ACTION_REC_TYPE,
           p_target_rec       IN GRP_ATTR_REC_TYPE,
           p_group_tab        IN OUT NOCOPY GRP_ATTR_TAB_TYPE,
           x_matched_entities OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
           x_out_rec          OUT NOCOPY OUT_REC_TYPE,
           x_return_status    OUT NOCOPY VARCHAR2);


-- 5870774
PROCEDURE Get_Cancel_Qty_Allowed
                ( p_source_code             IN  VARCHAR2,
                  p_source_line_id          IN  NUMBER,
                  x_cancel_qty_allowed      OUT NOCOPY NUMBER,
                  x_return_status           OUT NOCOPY VARCHAR2,
                  x_msg_count               OUT NOCOPY NUMBER,
                  x_msg_data                OUT NOCOPY VARCHAR2
                 );

--bug #8590113 : Begin
--===================================================================================================
   -- Start of comments
   --
   -- API Name          :  Get_Delivery_Detail_attributes
   -- Type              : Public
   -- Purpose           : To fetch all the delivery details attributes along with parent_delivery_Detail_id(container)
   -- Pre-reqs          : None
   -- Function          : This API can be used to get all the attributes of delivery details along with container details
   --
   --
   -- PARAMETERS        : p_header_id             header_id of the Sales Order
   --                     p_line_id               line_id of the Sales Order
   --                     x_rec_tab               Return all the delivery details attributes in following format
   --                                             x_rec_tab.detail_rec_type  - dellivery details attributes
   --                                             x_rec_tab.parent_delivery_detail_id - container delivery_detail_id
   --
   --                     x_return_status         return status
   -- VERSION          :  current version         1.0
   --                     initial version         1.0
   -- End of comments
--===================================================================================================

PROCEDURE  Get_Delivery_Detail_attributes ( p_header_id  IN NUMBER,
                            p_line_id       IN NUMBER,
                            x_rec_tab       OUT NOCOPY WSH_INTEGRATION.detail_lpn_rec_type_tab_type,
                            x_return_status OUT NOCOPY VARCHAR2);

TYPE  detail_lpn_rec_type IS RECORD (
detail_rec_type WSH_DELIVERY_DETAILS%ROWTYPE,
parent_delivery_detail_id    WSH_DELIVERY_ASSIGNMENTS.parent_delivery_detail_id%TYPE,
actual_ship_date    WSH_TRIP_STOPS.actual_departure_date%TYPE,
Ship_method         WSH_CARRIER_SERVICES.ship_method_meaning%TYPE,
carrier_name        HZ_PARTIES.party_name%TYPE
);

TYPE detail_lpn_rec_type_tab_type IS TABLE OF detail_lpn_rec_type
INDEX BY BINARY_INTEGER;

--bug #8590113 : end
--
--
-- LSP project : new API
--
--===================================================================================================
   -- Start of comments
   --
   -- API Name          : Validate_Oe_Attributes
   -- Type              : Private
   -- Purpose           : To determine whether the validation of Sales order/order line
   --                     attribute is required or not.
   -- Pre-reqs          : None
   -- Function          : This API returns 'N' when the
   --                      a) Deployment mode is Distributed
   --                      b) Deployment Mode is LSP and Order Source is equal to any of the valid client code
   --                     For all other cases this API returns 'Y'
   --
   --
   -- PARAMETERS        : p_order_source_id      Order number of the Sales Order
   --                     x_return_status         'Y' : OM should validate attributes, 'N': OM can ignore the validation.
   -- VERSION          :  current version         1.0
   --                     initial version         1.0
   -- End of comments
--===================================================================================================
FUNCTION  Validate_Oe_Attributes (p_order_source_id IN NUMBER) RETURN VARCHAR2;
--
-- LSP project : end
--

--RTV changes
--
--  Procedure:   Update_Delivery_Line
--  Parameters:  p_detail_rows   list of  Delivery Lines that need to be updated
--               x_return_status return status
--  Description: This procedure will update inv_interface_flag of
--               a delivery line to 'Y'
--
PROCEDURE Update_Delivery_Details(
    p_detail_rows    IN  wsh_util_core.id_tab_type,
  	x_return_status  OUT NOCOPY   VARCHAR2
);
--RTV changes
END WSH_INTEGRATION;

/
