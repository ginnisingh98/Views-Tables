--------------------------------------------------------
--  DDL for Package RLM_FORECAST_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_FORECAST_SV" AUTHID CURRENT_USER as
/*$Header: RLMDPFPS.pls 120.2 2008/02/21 09:19:23 sunilku ship $*/
--<TPA_PUBLIC_NAME=RLM_TPA_SV>
--<TPA_PUBLIC_FILE_NAME=RLMTPDP>
/*===========================================================================
  PACKAGE NAME: 	RLM_FORECAST_SV

  DESCRIPTION:		Contains the server side code for Manage MRP Forecast
                        API of RLM Demand Processor.

  CLIENT/SERVER:	Server

  LIBRARY NAME:		None

  OWNER:		abkulkar

  PROCEDURE/FUNCTIONS:

  GLOBALS:

=========================================================================== */


  TYPE t_Cursor_ref IS REF CURSOR;
  --
  k_ORIGINAL            CONSTANT VARCHAR2(30) := 'ORIGINAL';
  k_REPLACE             CONSTANT VARCHAR2(30) := 'REPLACE';
  k_REPLACE_ALL         CONSTANT VARCHAR2(30) := 'REPLACE_ALL';
  k_CHANGE              CONSTANT VARCHAR2(30) := 'CHANGE';
  k_CANCEL              CONSTANT VARCHAR2(30) := 'CANCELLATION';
  k_DELETE              CONSTANT VARCHAR2(30) := 'DELETE';
  k_INSERT              CONSTANT VARCHAR2(30) := 'INSERT';
  k_UPDATE              CONSTANT VARCHAR2(30) := 'UPDATE';
  k_UPDATE_ATTR         CONSTANT VARCHAR2(30) := 'UPDATE_ATTR';
  k_CONFIRMATION        CONSTANT VARCHAR2(30) := 'CONFIRMATION';
  k_ADD                 CONSTANT VARCHAR2(30) := 'ADD';
  k_RECEIPT             CONSTANT VARCHAR2(80) := 'RECEIPT';
  --
  k_PLANNING            CONSTANT VARCHAR2(30) := 'PLANNING_RELEASE';
  k_SHIPPING            CONSTANT VARCHAR2(30) := 'SHIPPING';
  k_SEQUENCED           CONSTANT VARCHAR2(30) := 'SEQUENCED';
  --
  k_TDEBUG              CONSTANT NUMBER := rlm_CORE_SV.C_LEVEL10;
  k_SDEBUG              CONSTANT NUMBER := rlm_CORE_SV.C_LEVEL11;
  k_DEBUG               CONSTANT NUMBER := rlm_CORE_SV.C_LEVEL12;
  --
  k_VNULL               CONSTANT VARCHAR2(25) := 'THIS_IS_A_NULL_VALUE';
  k_NNULL               CONSTANT NUMBER := -19999999999;
  k_DNULL               CONSTANT DATE := to_date('01/01/1930','dd/mm/yyyy');
  --
  k_ATS                 CONSTANT VARCHAR2(1) := 'Y';
  k_NATS                CONSTANT VARCHAR2(1) := 'N';
  --
  k_PAST_DUE_FIRM       CONSTANT VARCHAR2(1) := '0';
  k_FIRM                CONSTANT VARCHAR2(1) := '1';
  k_FORECAST            CONSTANT VARCHAR2(1) := '2';
  k_MRP_FORECAST        CONSTANT VARCHAR2(1) := '6';
  --
  k_Weekly              CONSTANT VARCHAR2(1) := '2';
  k_Quarterly           CONSTANT VARCHAR2(1) :='5';
  k_Monthly             CONSTANT VARCHAR2(1) :='3';
  k_Daily               CONSTANT VARCHAR2(1) := '1';
  k_Flexible            CONSTANT VARCHAR2(1) := '4';
  e_group_error         EXCEPTION;
  k_REPLACE_FLAG        BOOLEAN := TRUE;

  TYPE t_designator_rec IS RECORD(designator   VARCHAR2(30),
                                  organization_id NUMBER); --Bugfix 6817494

  TYPE t_designator_tab IS TABLE OF t_designator_rec INDEX BY BINARY_INTEGER;

  g_designator_tab t_designator_tab;
  --
/*===========================================================================

  PROCEDURE NAME:	ManageForecast

  DESCRIPTION:	        Cover function for Manage MRP Forecast API

  PARAMETERS:	        x_InterfaceHeaderId IN NUMBER

  DESIGN REFERENCES:	RLADPHLD.rtf
			RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created abkulkar 03/05/99
===========================================================================*/
PROCEDURE ManageForecast(x_InterfaceHeaderId IN NUMBER,
                         x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                         x_ReturnStatus OUT NOCOPY NUMBER);
--<TPA_PUBLIC_NAME>
/*===========================================================================

  PROCEDURE NAME:	ManageGroupForecast

  DESCRIPTION:	        function for Manage MRP Forecast API

  PARAMETERS:	        x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
                        x_Group_rec IN t_Group_rec
                        x_returnStatus OUT NOCOPY NUMBER

  DESIGN REFERENCES:	RLADPHLD.rtf
			RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created mnandell 03/05/99
===========================================================================*/

PROCEDURE ManageGroupForecast(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                            x_forecast  IN OUT NOCOPY
                                mrp_forecast_interface_pk.t_forecast_interface,
                            x_designator IN OUT NOCOPY
                                mrp_forecast_interface_pk.t_forecast_designator,
                            x_ReturnStatus OUT NOCOPY NUMBER);
--<TPA_PUBLIC_NAME>
/*===========================================================================
  PROCEDURE NAME:	InitializeGroup

  DESCRIPTION:	This procedure sets up the group cursor.

  PARAMETERS:	x_Sched_rec IN rlm_interface_headers%ROWTYPE
		x_Group_ref IN OUT NOCOPY t_Cursor_ref

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created abkulkar 03/08/99
===========================================================================*/
Procedure InitializeGroup(x_Sched_rec IN rlm_interface_headers%ROWTYPE,
                          x_Group_ref IN OUT NOCOPY rlm_forecast_sv.t_Cursor_ref,
                          x_Group_rec IN rlm_dp_sv.t_Group_rec);

--<TPA_PUBLIC_NAME>
/*===========================================================================
  FUNCTION NAME:	FetchGroup

  DESCRIPTION:	This function fetches next group

  PARAMETERS:	x_Group_ref IN OUT NOCOPY t_Cursor_ref
		x_Group_rec IN OUT NOCOPY t_Group_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created abkulkar 03/08/99
===========================================================================*/
Function FetchGroup(x_Group_ref IN OUT NOCOPY t_Cursor_ref,
                    x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec)
                    RETURN BOOLEAN;

/*===========================================================================

  PROCEDURE NAME:  UpdateGroupStatus

  DESCRIPTION:	   Updates the process status to x_status for the entire
                   group passed in with the x_group_rec

  PARAMETERS:      x_Group_rec         IN     t_Group_rec
                   x_header_id         IN     NUMBER,
                   x_ScheduleHeaderId  IN     NUMBER,
                   x_status            IN     NUMBER



  DESIGN REFERENCES:	RLADPHLD.rtf
			RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created mnandell 03/05/99
===========================================================================*/
PROCEDURE  UpdateGroupStatus( x_header_id         IN     NUMBER,
                              x_ScheduleHeaderId  IN     NUMBER,
                              x_Group_rec         IN     rlm_dp_sv.t_Group_rec,
                              x_status            IN     NUMBER,
                              x_UpdateLevel       IN  VARCHAR2 DEFAULT 'GROUP');
--<TPA_PUBLIC_NAME>
/*===========================================================================

  PROCEDURE NAME:  LockLines

  DESCRIPTION:	   Locks lines

  DESIGN REFERENCES:	RLADPHLD.rtf
			RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created mnandell 03/05/99
===========================================================================*/
FUNCTION LockLines (x_Group_rec         IN     rlm_dp_sv.t_Group_rec,
                    x_header_id         IN     NUMBER)
RETURN BOOLEAN;

/*===========================================================================

  PROCEDURE NAME:  LockHeaders

  DESCRIPTION:	   Locks headers

  DESIGN REFERENCES:	RLADPHLD.rtf
			RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created mnandell 03/05/99
===========================================================================*/
FUNCTION LockHeaders (x_header_id         IN     NUMBER)
RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:     UpdateHeaderStatus

  DESCRIPTION:        This procedure update the process status for the header

  PARAMETERS:         x_HeaderId           IN NUMBER
                      x_ScheduleHeaderId   IN   NUMBER
                      x_ProcessStatus      IN NUMBER

  DESIGN REFERENCES:  RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created mnandell 03/08/99
===========================================================================*/
PROCEDURE UpdateHeaderStatus(x_HeaderId           IN   NUMBER,
                             x_ScheduleHeaderId   IN   NUMBER,
                             x_Status             IN   NUMBER );

/*===========================================================================
  PROCEDURE NAME:     ProcessTable

  DESCRIPTION:  This procedure processes records returned by MRP API for errors

  PARAMETERS:   x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
                x_Group_rec IN rlm_dp_sv.t_Group_rec
                t_Forecast IN mrp_forecast_interface_pk.t_forecast_interface

  DESIGN REFERENCES:  RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created mnandell 03/08/99
===========================================================================*/

PROCEDURE ProcessTable(
                       x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                       x_Group_rec IN rlm_dp_sv.t_Group_rec,
                       t_Forecast IN
                       mrp_forecast_interface_pk.t_forecast_interface);
--<TPA_PUBLIC_NAME>
/*===========================================================================
  PROCEDURE NAME:     LoadForecast

  DESCRIPTION:        Loads Forecast records into t_forecast PLSQL Table
                      to be passed to MRP API

  PARAMETERS: x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
              x_Group_rec IN rlm_dp_sv.t_Group_rec,
              t_forecast IN OUT NOCOPY mrp_forecast_interface_pk.t_forecast_interface,
              x_forecast_designator IN
                  mrp_forecast_designators.forecast_deignator%TYPE)


  DESIGN REFERENCES:  RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created mnandell 03/08/99
===========================================================================*/

PROCEDURE LoadForecast(
         x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
         x_Group_rec IN rlm_dp_sv.t_Group_rec,
         t_forecast IN OUT NOCOPY mrp_forecast_interface_pk.t_forecast_interface,
         x_forecast_designator IN
                 mrp_forecast_designators.forecast_designator%TYPE);
--<TPA_PUBLIC_NAME>
/*===========================================================================
  PROCEDURE NAME:     initialize_table

  DESCRIPTION:  This procedure initializes records in t_forecast PLSQL table

  PARAMETERS:  t_forecast IN OUT NOCOPY mrp_forecast_interface_pk.t_forecast_interface

  DESIGN REFERENCES:  RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created mnandell 03/08/99
===========================================================================*/
PROCEDURE initialize_table(
           t_forecast IN OUT NOCOPY mrp_forecast_interface_pk.t_forecast_interface);


/*===========================================================================
  PROCEDURE NAME:     get_designator

  DESCRIPTION:  This procedure returns the designator which is to be used
                for MRP forecast interface API

  PARAMETERS:

  DESIGN REFERENCES:  RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created mnandell 03/08/99
===========================================================================*/
PROCEDURE GetDesignator( x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE DEFAULT NULL,
                         x_Group_rec IN rlm_dp_sv.t_Group_rec DEFAULT NULL,
                         x_Customer_id   IN NUMBER,
                         x_ShipFromOrgId IN NUMBER,
                         x_Ship_Site_Id IN NUMBER,
                         x_bill_site_id IN NUMBER,
                         x_bill_address_Id IN NUMBER,
                         x_ForecastDesignator IN OUT NOCOPY VARCHAR2,
                         x_ship_to_customer_id IN NUMBER DEFAULT NULL);
--<TPA_PUBLIC_NAME>
/*===========================================================================
  PROCEDURE NAME:     EmptyForecast

  DESCRIPTION:  This procedure deletes old forecast for the designator

  PARAMETERS:

  DESIGN REFERENCES:  RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created asutar 05/30/02
===========================================================================*/

PROCEDURE EmptyForecast( x_sched_rec IN  RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN  OUT NOCOPY rlm_dp_sv.t_Group_rec,
                         x_forecast  IN  OUT NOCOPY
                                mrp_forecast_interface_pk.t_forecast_interface,
                         x_designator IN OUT NOCOPY
                                mrp_forecast_interface_pk.t_forecast_designator,
                         x_t_designator IN OUT NOCOPY
                                mrp_forecast_interface_pk.t_forecast_designator);
--<TPA_PUBLIC_NAME>

PROCEDURE ProcessReplaceAll (x_sched_rec IN  RLM_INTERFACE_HEADERS%ROWTYPE,
                             x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                             x_designator IN OUT NOCOPY mrp_forecast_interface_pk.t_forecast_designator);


/*===========================================================================
  PROCEDURE NAME:     GetTPContext

  DESCRIPTION:        This procedure returns the tp group context.
                      This procedure returns a null x_ship_to_ece_locn_code,
                      and null x_inter_ship_to_ece_locn_code

  PARAMETERS:         x_sched_rec     IN  RLM_INTERFACE_HEADERS%ROWTYPE
                      x_group_rec     IN  t_Group_rec
                      x_customer_number OUT NOCOPY VARCHAR2
                      x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2
                      x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2
                      x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2
                      x_tp_group_code OUT NOCOPY VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created jckwok 12/11/03

===========================================================================*/
PROCEDURE GetTPContext( x_sched_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE DEFAULT NULL,
                       x_group_rec  IN rlm_dp_sv.t_Group_rec DEFAULT NULL,
                       x_customer_number OUT NOCOPY VARCHAR2,
                       x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_tp_group_code OUT NOCOPY VARCHAR2);
--<TPA_TPS>

/*===========================================================================
  PROCEDURE NAME:     Convert_UOM

  DESCRIPTION:        Wrapper for Inventory API for UOM Conversion.

  PARAMETERS:         from_uom   IN             VARCHAR2,
                      to_uom     IN             VARCHAR2,
                      quantity   IN OUT  NOCOPY NUMBER,
                      p_item_id  IN             NUMBER,
                      p_org_id   IN             NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:              Bug 4176961

  CLOSED ISSUES:

  CHANGE HISTORY:     created stananth 06/25/05

===========================================================================*/
PROCEDURE Convert_UOM (from_uom   IN            VARCHAR2,
                       to_uom     IN            VARCHAR2,
                       quantity   IN OUT NOCOPY NUMBER,
                       p_item_id  IN            NUMBER,
                       p_org_id   IN            NUMBER);

END RLM_FORECAST_SV;

/
