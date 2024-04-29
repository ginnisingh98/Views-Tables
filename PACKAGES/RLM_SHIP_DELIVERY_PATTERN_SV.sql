--------------------------------------------------------
--  DDL for Package RLM_SHIP_DELIVERY_PATTERN_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_SHIP_DELIVERY_PATTERN_SV" AUTHID CURRENT_USER as
/* $Header: RLMDPSDS.pls 120.0 2005/05/26 17:11:36 appldev noship $*/
--<TPA_PUBLIC_NAME=RLM_TPA_SV>
--<TPA_PUBLIC_FILE_NAME=RLMTPDP>

/*===========================================================================
  PACKAGE NAME:   rlm_ship_delivery_pattern_sv

  DESCRIPTION: Contains all server side code for the Calculate Scheduled Ship
               Date API.

  CLIENT/SERVER:  Server

  LIBRARY NAME:   None

  OWNER:    amitra

  PROCEDURE/FUNCTIONS:
         calc_scheduled_ship_date()
         determine_sdp_code()
         break_bucket()
         default_sdp_code()
         find_daily_percent()
         apply_percent()
         determine_lead_time()
         check_rcv_date()
         apply_lead_time()
         check_send_date()
         determine_recv_date()
         determine_send_date()

  GLOBALS:
    g_SDEBUG
    g_DEBUG


===========================================================================*/

  TYPE t_InputRec IS RECORD (
    ShipDeliveryRuleName         VARCHAR2(30),
    ItemDetailSubtype            VARCHAR2(30),
    DateTypeCode                 VARCHAR2(30),
    StartDateTime                DATE,
    ShipFromOrgId                NUMBER,
    CustomerId                   NUMBER,
    ShipToAddressId              NUMBER,
    ShipToSiteUseId              NUMBER,
    BillToAddressId              NUMBER,
    IntShipToAddressId           NUMBER,
    CustomerItemId               NUMBER,
    --global_atp
    ATPItemFlag                  BOOLEAN,
    --
    PrimaryQuantity              NUMBER,
    EndDateTime                  DATE,
    use_edi_sdp_code_flag       rlm_cust_shipto_terms.use_edi_sdp_code_flag%TYPE,
    DefaultSDP                  rlm_cust_shipto_terms.ship_delivery_rule_name%TYPE,
    ship_method                 rlm_cust_shipto_terms.ship_method%TYPE,
    intransit_time              rlm_cust_shipto_terms.intransit_time%TYPE,
    time_uom_code               rlm_cust_shipto_terms.time_uom_code%TYPE,
    customer_rcv_calendar_cd    rlm_cust_shipto_terms.customer_rcv_calendar_cd%TYPE,
    supplier_shp_calendar_cd    rlm_cust_shipto_terms.supplier_shp_calendar_cd%TYPE,
    sched_horizon_start_date    rlm_interface_headers.sched_horizon_start_date%TYPE,
    exclude_non_workdays_flag   rlm_cust_shipto_terms.exclude_non_workdays_flag%TYPE,
    ShiptoCustomerId            rlm_interface_lines.ship_to_customer_id%TYPE);

  TYPE  t_BucketRec IS RECORD (
    ShipDeliveryRuleName         VARCHAR2(30),
    ItemDetailSubtype            VARCHAR2(30),
    DateTypeCode                 VARCHAR2(30),
    StartDateTime                DATE,
    ShipToAddressId              NUMBER,
    ShipFromOrgId                NUMBER,
    CustomerItemId               NUMBER,
    PrimaryQuantity              NUMBER,
    EndDateTime                  DATE,
    WholeNumber                  BOOLEAN);

  TYPE t_OutputRec IS RECORD (
    PlannedShipmentDate           DATE,
    PlannedReceiveDate            DATE,
    PrimaryQuantity               NUMBER,
    ItemDetailSubType             rlm_interface_lines.item_detail_subtype%TYPE,
    ReturnMessage                 VARCHAR2(30));

  TYPE t_LeadTimeRec IS RECORD (
    Time                          NUMBER,
    Uom                           VARCHAR2(3));

  TYPE t_ErrorMsgRec IS RECORD (
    ErrType                   NUMBER,
    ErrMessage                VARCHAR2(4000),
    ErrMessageName            VARCHAR2(30) DEFAULT NULL);

  TYPE t_DailyPercentTable IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;
  TYPE t_BucketTable IS TABLE OF t_BucketRec
  INDEX BY BINARY_INTEGER;
  TYPE t_OutputTable IS TABLE OF t_OutputRec
  INDEX BY BINARY_INTEGER;
  TYPE t_ErrorMsgTable IS TABLE OF t_ErrorMsgRec
  INDEX BY BINARY_INTEGER;

  g_SDEBUG        NUMBER :=rlm_core_sv.C_LEVEL5;
  g_DEBUG         NUMBER :=rlm_core_sv.C_LEVEL6;
  g_PRECISION     CONSTANT NUMBER :=2;
  g_DAY           CONSTANT VARCHAR2(10) := '1';
  g_WEEK          CONSTANT VARCHAR2(10) := '2';
  g_FLEXIBLE      CONSTANT VARCHAR2(10) := '3';
  g_MONTH         CONSTANT VARCHAR2(10) := '4';
  g_QUARTER       CONSTANT VARCHAR2(10) := '5';
  g_SUCCESS       CONSTANT NUMBER := 0;
  g_WARNING       CONSTANT NUMBER := 1;
  g_ERROR         CONSTANT NUMBER := 2;
  g_SundayDOW     CONSTANT VARCHAR2(1) := to_char(to_date('05/01/1997','dd/mm/yyyy'),'D');
  g_MondayDOW   CONSTANT VARCHAR2(1) := to_char(to_date('06/01/1997','dd/mm/yyyy'),'D');
  g_TuesdayDOW  CONSTANT VARCHAR2(1) := to_char(to_date('07/01/1997','dd/mm/yyyy'),'D');
  g_WednesdayDOW  CONSTANT VARCHAR2(1) := to_char(to_date('08/01/1997','dd/mm/yyyy'),'D');
  g_ThursdayDOW  CONSTANT VARCHAR2(1) := to_char(to_date('09/01/1997','dd/mm/yyyy'),'D');
  g_FridayDOW  CONSTANT VARCHAR2(1) := to_char(to_date('10/01/1997','dd/mm/yyyy'),'D');
  g_SaturdayDOW  CONSTANT VARCHAR2(1) := to_char(to_date('11/01/1997','dd/mm/yyyy'),'D');
  g_RaiseErr      CONSTANT NUMBER := -10;


/*===========================================================================
  PROCEDURE NAME:  calc_scheduled_ship_date

  DESCRIPTION:  This procedure calculates the Scheduled Ship Date based on the
                given ship delivery pattern code, lead time and the BOM
                calendars provided.

  PARAMETERS:     x_Input             IN    rlm_ship_delivery_pattern_sv.t_InputRec
                  x_QuantityDate      OUT   rlm_ship_delivery_pattern_sv.t_OutputTable
		  x_ReturnMessage OUT rlm_ship_delivery_pattern_sv.t_ErrorMsgTable
                  x_ReturnStatus      OUT   NUMBER

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/9/98  created
                  jckwok 1/10/03 updated (TPA-enabled)
===========================================================================*/
PROCEDURE    calc_scheduled_ship_date(x_Input IN  rlm_ship_delivery_pattern_sv.t_InputRec,
                              x_QuantityDate  OUT NOCOPY rlm_ship_delivery_pattern_sv.t_OutputTable,
                              x_ReturnMessage OUT NOCOPY rlm_ship_delivery_pattern_sv.t_ErrorMsgTable,
                              x_ReturnStatus  OUT NOCOPY NUMBER);

--<TPA_PUBLIC_NAME>
/*===========================================================================
  PROCEDURE NAME:  determine_sdp_code

  DESCRIPTION:  This procedure determines the Ship Delivery Patter Code for
                given setup terms SDP code and EDI SDP code based on the
                USE EDI SDP code flag.

  PARAMETERS:   x_ShipDeliveryRuleName   IN     VARCHAR2(30)
                x_ShipFromOrgId          IN     NUMBER
               x_ShipToAddressId         IN     NUMBER
                x_CustomerItemId         IN     NUMBER
               x_SdpCode                 OUT NOCOPY    VARCHAR2(30)
               x_ReturnStatus            OUT NOCOPY    NUMBER

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/9/98  created
                  bsadri 11/2/00 added parameters
===========================================================================*/

PROCEDURE    determine_sdp_code(  ShipDeliveryRuleName IN VARCHAR2,
   use_edi_sdp_code_flag  IN  rlm_cust_shipto_terms.use_edi_sdp_code_flag%TYPE,
   DefaultSDP IN  rlm_cust_shipto_terms.ship_delivery_rule_name%TYPE,
   x_customer_id         IN      NUMBER,
   x_shipFromOrg         IN      NUMBER,
   x_shipTo              IN      NUMBER,
   x_ReturnMessage       IN OUT NOCOPY  t_ErrorMsgTable,
   x_SdpCode            OUT NOCOPY           VARCHAR2,
   x_ReturnStatus       OUT NOCOPY           NUMBER);

/*===========================================================================
  FUNCTION NAME:  find_default_sdp_code

  DESCRIPTION: Not used currently.

  PARAMETERS:  x_ShipFromOrgId      IN            NUMBER
               x_ShipToAddressId    IN            NUMBER
               x_CustomerItemId     IN            NUMBER

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/28/98  created
===========================================================================*/
FUNCTION    find_default_sdp_code( x_ShipFromOrgId      IN            NUMBER,
                                   x_ShipToAddressId    IN            NUMBER,
                                   x_CustomerItemId     IN            NUMBER)
RETURN VARCHAR2;

/*===========================================================================
  PROCEDURE NAME:  set_return_status

  DESCRIPTION: Checks to see if greater severity error occured, returns
               current severity level of return status.

  PARAMETERS:     x_ReturnStatus  IN OUT NOCOPY NUMBER
                  x_InputStatus   IN NUMBER

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/28/98  created
===========================================================================*/
PROCEDURE    set_return_status(x_ReturnStatus  IN OUT NOCOPY NUMBER,
                               x_InputStatus   IN NUMBER);


/*===========================================================================
  FUNCTION NAME:  find_daily_percent

  DESCRIPTION: This procedure applies the SDP rule to find daily percentages.

  PARAMETERS:     x_RuleName        IN    VARCHAR2

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/14/98  created
===========================================================================*/
FUNCTION  find_daily_percent(x_RuleName IN VARCHAR2)
RETURN rlm_core_sv.t_NumberTable;


/*===========================================================================
  PROCEDURE NAME:  break_bucket

  DESCRIPTION: This procedure breaks down the monthly, quarterly, and
               flexible buckets in to weekly buckets.

  PARAMETERS:     x_Input        IN    t_InputRec
                  x_WeeklyBucket   OUT NOCOPY   t_BucketTable
                  x_ReturnStatus   OUT NOCOPY   NUMBER

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/14/98  created
===========================================================================*/
PROCEDURE  break_bucket(x_Input IN rlm_ship_delivery_pattern_sv.t_InputRec,
           x_ReturnMessage IN OUT NOCOPY rlm_ship_delivery_pattern_sv.t_ErrorMsgTable,
           x_WeeklyBucket OUT NOCOPY rlm_ship_delivery_pattern_sv.t_BucketTable,
           x_ReturnStatus OUT NOCOPY NUMBER);
--<TPA_PUBLIC_NAME>
/*===========================================================================
  FUNCTION NAME:  get_weekly_quantity

  DESCRIPTION:  This procedure gets the quantity for weekly buckets.

  PARAMETERS:     x_WholeNumber      IN   BOOLEAN
                  x_Count            IN NUMBER
                  x_Input            IN t_Inputrec
                  x_DivideBy         IN NUMBER

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/23/98  created
===========================================================================*/
FUNCTION  get_weekly_quantity(
                  x_WholeNumber     IN BOOLEAN,
                  x_Count           IN NUMBER,
                  x_Input           IN rlm_ship_delivery_pattern_sv.t_InputRec,
                  x_DivideBy        IN NUMBER)
RETURN NUMBER;
--<TPA_PUBLIC_NAME>

/*===========================================================================
  FUNCTION NAME:  get_precision

  DESCRIPTION:   This function returns the global constant for precision.

  PARAMETERS:

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/28/98  created
===========================================================================*/
FUNCTION    get_precision
RETURN NUMBER;


/*===========================================================================
  PROCEDURE NAME:  apply_sdp_to_weekly_bucket

  DESCRIPTION: This procedure applies the Ship Delivery Pattern to daily
               buckets.

  PARAMETERS:     x_Input                 IN    t_InputRec
                  x_DailyPercent          IN    rlm_core_sv.t_NumberTable
                  x_ItemDetailSubtype     IN    VARCHAR2
                  x_StartDateTime         IN    DATE
                  x_PrimaryQuantity       IN    NUMBER
                  x_WholeNumber           IN    BOOLEAN
                  x_QuantityDate          IN OUT NOCOPY t_OutputTable

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/14/98  created
===========================================================================*/
PROCEDURE    apply_sdp_to_weekly_bucket(
                  x_Input                 IN    rlm_ship_delivery_pattern_sv.t_InputRec,
                  x_ItemDetailSubtype     IN    VARCHAR2,
                  x_DailyPercent          IN    rlm_core_sv.t_NumberTable,
                  x_StartDateTime         IN    DATE,
                  x_PrimaryQuantity       IN    NUMBER,
                  x_WholeNumber           IN    BOOLEAN,
                  x_QuantityDate          IN OUT NOCOPY RLM_SHIP_DELIVERY_PATTERN_SV.t_OutputTable);
--<TPA_PUBLIC_NAME>

/*===========================================================================
  PROCEDURE NAME:  apply_sdp_to_daily_bucket

  DESCRIPTION: This procedure applies the Ship Delivery Pattern to weekly
               buckets.

  PARAMETERS:     x_Input                 IN    t_InputRec
                  x_ItemDetailSubtype     IN    VARCHAR2
                  x_DailyPercent          IN    rlm_core_sv.t_NumberTable
                  x_StartDateTime         IN    DATE
                  x_PrimaryQuantity       IN    NUMBER
                  x_QuantityDate          IN OUT NOCOPY t_OutputTable

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/14/98  created
===========================================================================*/
PROCEDURE  apply_sdp_to_daily_bucket(
              x_Input        IN    rlm_ship_delivery_pattern_sv.t_InputRec,
              x_ItemDetailSubtype     IN    VARCHAR2,
              x_DailyPercent          IN    rlm_core_sv.t_NumberTable,
              x_StartDateTime         IN    DATE,
              x_PrimaryQuantity       IN    NUMBER,
              x_QuantityDate IN OUT NOCOPY rlm_ship_delivery_pattern_sv.t_OutputTable);
--<TPA_PUBLIC_NAME>

/*===========================================================================
  FUNCTION NAME:  check_start_date

  DESCRIPTION: This function checks whether the start date is valid for
               given bucket type.

  PARAMETERS:     x_Input                IN    t_Inputrec
                  x_StartDateTime         IN    DATE
                  x_BucketType            IN    VARCHAR2

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/15/98  created
===========================================================================*/
FUNCTION    check_start_date(
              x_Input IN   rlm_ship_delivery_pattern_sv.t_Inputrec,
              x_BucketType           IN    VARCHAR2)
RETURN BOOLEAN;
--<TPA_PUBLIC_NAME>
/*===========================================================================
  FUNCTION NAME:  find_monday_date

  DESCRIPTION:  This procedure finds the Monday date in the same week as given
                date.

  PARAMETERS:        x_Input      IN t_InputRec
                     x_Date         IN    DATE

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    amitra 7/15/98  created
===========================================================================*/
FUNCTION  find_monday_date(x_Input  IN  rlm_ship_delivery_pattern_sv.t_InputRec,
                             x_Date IN  DATE)
RETURN DATE;
--<TPA_PUBLIC_NAME>
/*===========================================================================
  FUNCTION NAME:  valid_sdp_date

  DESCRIPTION:  This function checks if the SDP rule indicates a percentage
                for given date.

  PARAMETERS:     x_Input      IN t_InputRec
                  x_Date            IN    DATE
                  x_DailyPercent    IN rlm_core_sv.t_NumberTable

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/15/98  created
===========================================================================*/
FUNCTION    valid_sdp_date(x_Input  IN rlm_ship_delivery_pattern_sv.t_InputRec,
                           x_DailyPercent IN rlm_core_sv.t_NumberTable)
RETURN BOOLEAN;
--<TPA_PUBLIC_NAME>
/*===========================================================================
  FUNCTION NAME:  previous_valid_sdp_date

  DESCRIPTION:  This procedure finds the previous date based on the SDP rule
                with a daily percent.

  PARAMETERS:     x_Input        IN t_InputRec
                  x_Date         IN    DATE
                  x_DailyPercent IN rlm_core_sv.t_NumberTable

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/15/98  created
===========================================================================*/
FUNCTION  previous_valid_sdp_date(
                 x_Input        IN rlm_ship_delivery_pattern_sv.t_InputRec,
                 x_Date         IN DATE,
                 x_DailyPercent IN rlm_core_sv.t_NumberTable)
RETURN DATE;
--<TPA_PUBLIC_NAME>
/*===========================================================================
  FUNCTION NAME:  get_ship_method

  DESCRIPTION:  This procedure gets the ship method. Not used currently.

                  x_Input.ShipFromOrgId         IN NUMBER
                  x_Input.ShipToAddressId       IN NUMBER
                  x_Input.CustomerItemId        IN NUMBER

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/20/98  created
===========================================================================*/
FUNCTION  get_ship_method(x_ShipFromOrgId         IN NUMBER,
                  x_ShipToAddressId       IN NUMBER,
                  x_CustomerItemId        IN NUMBER)
RETURN VARCHAR2;


/*===========================================================================
  FUNCTION NAME:  determine_lead_time

  DESCRIPTION: Not used currently.

                  x_ShipFromOrgId         IN      NUMBER
                  x_ShipToAddressId       IN      NUMBER
                  x_ShipMethod            IN    VARCHAR2

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/20/98  created
===========================================================================*/
FUNCTION  determine_lead_time(x_ShipFromOrgId         IN    NUMBER,
                  x_ShipToAddressId       IN    NUMBER,
                  x_ShipMethod            IN    VARCHAR2)
RETURN t_LeadTimeRec;


/*===========================================================================
  FUNCTION NAME:  check_receive_date

  DESCRIPTION:  This function checks to see if the receiving date is open
                on receiving calendar.

  PARAMETERS:     x_Input         IN    t_InputRec
                  x_ReceiveDate   IN    DATE

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/20/98  created
===========================================================================*/
FUNCTION  check_receive_date(
             x_Input         IN  rlm_ship_delivery_pattern_sv.t_InputRec,
             x_ReceiveDate   IN  DATE)
RETURN BOOLEAN;
--<TPA_PUBLIC_NAME>

/*===========================================================================
  PROCEDURE NAME:  determine_receive_date

  DESCRIPTION:  This calls procedure to deterine previous valid receiving date.

  PARAMETERS:     x_Input          IN    t_InputRec
                  x_DailyPercent   IN    rlm_core_sv.t_NumberTable
                  x_ReceiveDate    IN OUT DATE

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/20/98  created
===========================================================================*/
PROCEDURE  determine_receive_date(
            x_Input        IN    rlm_ship_delivery_pattern_sv.t_InputRec,
            x_DailyPercent IN    rlm_core_sv.t_NumberTable,
            x_ReceiveDate  IN OUT NOCOPY DATE);
--<TPA_PUBLIC_NAME>

/*===========================================================================
  PROCEDURE NAME:  apply_lead_time

  DESCRIPTION:  This procedure adds or subtracts lead time based on Lead type.

  PARAMETERS:     x_LeadTime           IN       t_LeadTimeRec
                  x_QuantityDateRec    IN OUT NOCOPY   t_OutputRec
                  x_LeadType           IN       VARCHAR2

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/20/98  created
===========================================================================*/
PROCEDURE   apply_lead_time (x_LeadTime           IN       t_LeadTimeRec,
                               x_QuantityDateRec    IN OUT NOCOPY   t_OutputRec,
                               x_LeadType           IN       VARCHAR2);

/*===========================================================================
  FUNCTION NAME:  check_send_date

  DESCRIPTION:  This function checks to see if the shipping date is open
                on shipping calendar.

  PARAMETERS:     x_INput         IN t_inputRec
                  x_ShipmentDate  IN DATE

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/20/98  created
===========================================================================*/
FUNCTION check_send_date(x_Input IN rlm_ship_delivery_pattern_sv.t_inputRec,
                         x_ShipmentDate IN DATE)
RETURN BOOLEAN;
--<TPA_PUBLIC_NAME>

/*===========================================================================
  PROCEDURE NAME:  determine_send_date

  DESCRIPTION: This calls the procedure to find previous valid send date.

  PARAMETERS:     x_ShipFromOrgId         IN NUMBER
                  x_ShipmentDate          IN OUT NOCOPY DATE

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: amitra 7/20/98  created
===========================================================================*/
PROCEDURE determine_send_date(x_Input IN rlm_ship_delivery_pattern_sv.t_inputRec,
                   x_DailyPercent  IN   rlm_core_sv.t_NumberTable,
                   x_ShipmentDate  IN OUT NOCOPY DATE );
--<TPA_PUBLIC_NAME>

/*=============================================================================
  PROCEDURE NAME:  get_err_message

  DESCRIPTION:  This procedure populates the Error message table with message.

  PARAMETERS:     x_ErrorMessage         IN VARCHAR2
                  x_ErrorRecord          IN NUMBER
                  x_ErrMsgTab            IN OUT NOCOPY t_ErrorMsgTable

  DESIGN REFERENCES: rladsdpc.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: mnnaraya 9/03/99  created
==============================================================================*/
PROCEDURE get_err_message (
            x_ErrorMessage     IN     VARCHAR2,
            x_ErrorMessageName IN     VARCHAR2 DEFAULT NULL,
            x_ErrorType        IN     NUMBER,
            x_ErrMsgTab        IN OUT NOCOPY t_ErrorMsgTable);

/*===========================================================================
  PROCEDURE NAME:     GetTPContext

  DESCRIPTION:        This procedure returns the tp group context.

  PARAMETERS:         x_Input     IN  t_InputRec
                      x_customer_number OUT NOCOPY VARCHAR2
                      x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2
                      x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2
                      x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2
                      x_tp_group_code OUT NOCOPY VARCHAR2

  DESIGN REFERENCES:  RLMDPSDD.rtf

  ALGORITHM:

  NOTES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created mnandell 01/18/2000

===========================================================================*/
PROCEDURE GetTPContext(x_Input  IN rlm_ship_delivery_pattern_sv.t_InputRec,
                       x_customer_number OUT NOCOPY VARCHAR2,
                       x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_tp_group_code OUT NOCOPY VARCHAR2);
--<TPA_TPS>
END rlm_ship_delivery_pattern_sv;
 

/
