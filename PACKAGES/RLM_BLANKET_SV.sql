--------------------------------------------------------
--  DDL for Package RLM_BLANKET_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_BLANKET_SV" AUTHID CURRENT_USER as
/*$Header: RLMDPBOS.pls 120.1.12010000.1 2008/07/21 09:44:07 appldev ship $*/
--<TPA_PUBLIC_NAME=RLM_TPA_SV>
--<TPA_PUBLIC_FILE_NAME=RLMTPDP>

/*===========================================================================
  PACKAGE NAME: 	RLM_BLANKET_SV

  DESCRIPTION:		Contains the server side code for blanket order API
                        of RLM Demand Processor.

  CLIENT/SERVER:	Server

  DESIGN REFERENCES:    rlabldld.rtf

  LIBRARY NAME:		None

  OWNER:		rlanka

  PROCEDURE/FUNCTIONS:

  GLOBALS:

=========================================================================== */

  g_SundayDOW	  CONSTANT VARCHAR2(1) := to_char(to_date('05/01/1997','dd/mm/yyyy'),'D');
  g_MondayDOW     CONSTANT VARCHAR2(1) := to_char(to_date('06/01/1997','dd/mm/yyyy'),'D');
  g_TuesdayDOW    CONSTANT VARCHAR2(1) := to_char(to_date('07/01/1997','dd/mm/yyyy'),'D');
  g_WednesdayDOW  CONSTANT VARCHAR2(1) := to_char(to_date('08/01/1997','dd/mm/yyyy'),'D');
  g_ThursdayDOW   CONSTANT VARCHAR2(1) := to_char(to_date('09/01/1997','dd/mm/yyyy'),'D');
  g_FridayDOW     CONSTANT VARCHAR2(1) := to_char(to_date('10/01/1997','dd/mm/yyyy'),'D');
  g_SaturdayDOW   CONSTANT VARCHAR2(1) := to_char(to_date('11/01/1997','dd/mm/yyyy'),'D');
  g_CalcIntransit BOOLEAN := TRUE;
  --
  k_DNULL         CONSTANT DATE := to_date('01/01/1930','dd/mm/yyyy');
  k_NNULL         CONSTANT NUMBER := -19999999999;
  --
  k_PAST_DUE_FIRM       CONSTANT VARCHAR2(1) := '0';
  k_FIRM                CONSTANT VARCHAR2(1) := '1';
  k_FORECAST            CONSTANT VARCHAR2(1) := '2';
  k_MRP_FORECAST        CONSTANT VARCHAR2(1) := '6';
  k_RECT                CONSTANT VARCHAR2(1) := '4';
  k_AUTH                CONSTANT VARCHAR2(1) := '3';
  --
  C_TDEBUG                      NUMBER :=rlm_core_sv.C_LEVEL4;
  C_SDEBUG                      NUMBER :=rlm_core_sv.C_LEVEL5;
  C_DEBUG                       NUMBER :=rlm_core_sv.C_LEVEL6;
  --
  TYPE g_NUM_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_LineIDTab	g_NUM_TBL_TYPE;
  g_RSOIDTab	g_NUM_TBL_TYPE;
  --
  e_RSOCreationError	EXCEPTION;
  --
  --anjana
  k_PLANNING            CONSTANT VARCHAR2(30) := 'PLANNING_RELEASE';
  k_SHIPPING            CONSTANT VARCHAR2(30) := 'SHIPPING';
  k_SEQUENCED           CONSTANT VARCHAR2(30) := 'SEQUENCED';


/*===========================================================================
  PROCEDURE NAME:        DeriveRSO

  DESCRIPTION:           This procedure is called from ManageDemand to derive
			 order_header_ids for all the lines within that group.
			 This in turn calls the following procedures/functions
			  (a) QueryRSO
			  (b) CalcEffectiveDates
			  (c) CalcPriorEffectDates
			  (d) CreateRSOHeader
			  (e) InsertRSO
			  (f) UpdateLinesWithRSO

  PARAMETERS:            x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
			 x_Group_rec IN t_group_rec
		         x_header_id IN RLM_INTERFACE_HEADERS.HEADER_ID%TYPE

  DESIGN REFERENCES:     rlabldld.rtf

  CHANGE HISTORY:        created rlanka 10/10/02
===========================================================================*/
PROCEDURE DeriveRSO(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
		    x_Group_rec IN RLM_DP_SV.t_Group_rec,
		    x_return_status OUT NOCOPY NUMBER);
--<TPA_PUBLIC_NAME>


/*==================================================================================
  PROCEDURE NAME:        QueryRSO

  DESCRIPTION:           This procedure queries the RLM_BLANKET_RSO table
			 to find a RSO whose effective start and end dates
			 encompass the request date on the line.
			 x_start_date => Effective start date of the RSO, x_rso_hdr_id
			 x_end_date   => Effective end date of the RSO, x_rso_hdr_id
			 x_maxend_date => Max. end date with the current context
			 x_minstart_date => Min. start date with the current context

  PARAMETERS:            p_customer_id    IN NUMBER,
		   	 p_request_date   IN DATE,
		   	 p_cust_item_id   IN NUMBER,
		     	 x_Group_rec	  IN RLM_DP_SV.t_Group_rec,
		   	 x_rso_hdr_id	  OUT NOCOPY NUMBER,
		   	 x_start_date	  OUT NOCOPY DATE,
		   	 x_end_date	  OUT NOCOPY DATE,
		   	 x_maxend_date    OUT NOCOPY DATE,
		   	 x_minstart_date  OUT NOCOPY DATE

  DESIGN REFERENCES:     rlabldld.rtf

  CHANGE HISTORY:        created rlanka 10/10/02
====================================================================================*/
PROCEDURE QueryRSO(p_customer_id    IN NUMBER,
		   p_request_date   IN DATE,
		   p_cust_item_id   IN NUMBER,
		   x_Group_rec	    IN RLM_DP_SV.t_Group_rec,
		   x_rso_hdr_id	    OUT NOCOPY NUMBER,
		   x_start_date	    OUT NOCOPY DATE,
		   x_end_date	    OUT NOCOPY DATE,
		   x_maxend_date    OUT NOCOPY DATE,
		   x_minstart_date  OUT NOCOPY DATE);


/*===================================================================================
  PROCEDURE NAME:        CalcEffectiveDates

  DESCRIPTION:           This procedure is used to calculate the effective
			 start and end dates for a new RSO, based on the highest
			 end date in the RLM_BLANKET_RSO.

  PARAMETERS:            x_cust_po_num IN RLM_INTERFACE_LINES.cust_po_number%TYPE
			 x_Group_rec IN t_group_rec
		         x_header_id IN RLM_INTERFACE_HEADERS.HEADER_ID%TYPE

  DESIGN REFERENCES:     rlabldld.rtf

  CHANGE HISTORY:        created rlanka 10/10/02
====================================================================================*/
PROCEDURE CalcEffectiveDates(x_Group_rec	IN RLM_DP_SV.t_Group_rec,
			     p_request_date	IN DATE,
			     x_start_date 	OUT NOCOPY DATE,
			     x_end_date   	OUT NOCOPY DATE,
			     x_maxend_date	IN OUT NOCOPY DATE);


/*==================================================================================
  PROCEDURE NAME:        CalcPriorEffectDates

  DESCRIPTION:           This procedure is used to calculate the prior effective
			 start and end dates for a new RSO, based on the lowest
			 start date in the RLM_BLANKET_RSO table.

  PARAMETERS:            x_Group_rec      IN  t_group_rec
			 p_request_date	  IN  DATE
			 x_start_date 	  OUT NOCOPY DATE
			 x_end_date   	  OUT NOCOPY DATE
			 x_minstart_date  IN OUT NOCOPY DATE

  DESIGN REFERENCES:     rlabldld.rtf

  CHANGE HISTORY:        created rlanka 10/10/02
====================================================================================*/
PROCEDURE CalcPriorEffectDates(x_Group_rec	  IN RLM_DP_SV.t_Group_rec,
			       p_request_date	  IN DATE,
			       x_start_date 	  OUT NOCOPY DATE,
			       x_end_date   	  OUT NOCOPY DATE,
			       x_minstart_date	  IN OUT NOCOPY DATE);

/*===========================================================================
  PROCEDURE NAME:        InsertRSO

  DESCRIPTION:           This procedure is used to insert a new row in the
			 RLM_BLANKET_RSO table.  Every entry in this table is
			 unique.

  PARAMETERS:            x_Sched_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE
			 x_Group_rec  IN t_group_rec
		         p_rso_hdr_id IN NUMBER
		 	 p_start_date IN DATE
			 p_end_date   IN DATE

  DESIGN REFERENCES:     rlabldld.rtf

  CHANGE HISTORY:        created rlanka 10/10/02
===========================================================================*/
PROCEDURE InsertRSO(x_Sched_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
		    x_Group_rec  IN RLM_DP_SV.t_Group_rec,
		    p_rso_hdr_id IN NUMBER,
		    p_start_date IN DATE,
		    p_end_date   IN DATE);
--<TPA_PUBLIC_NAME>


/*===========================================================================
  PROCEDURE NAME:        CreateRSOHeader

  DESCRIPTION:           This procedure calls the Process Order API to create
			 a release sales order and book it.  Mandatory
			 parameters are blanket_number and customer_id, every
			 other value is obtained from defaulting rules

  PARAMETERS:            x_Sched_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE
			 x_Group_rec  IN t_group_rec
		         x_rso_hdr_id OUT NOCOPY NUMBER

  DESIGN REFERENCES:     rlabldld.rtf

  CHANGE HISTORY:        created rlanka 10/10/02
===========================================================================*/
PROCEDURE CreateRSOHeader(x_Sched_rec	   IN RLM_INTERFACE_HEADERS%ROWTYPE,
			  x_Group_rec	   IN RLM_DP_SV.t_Group_rec,
			  x_rso_hdr_id	   OUT NOCOPY NUMBER);
--<TPA_PUBLIC_NAME>

/*===========================================================================
  PROCEDURE NAME:        UpdateLinesWithRSO

  DESCRIPTION:           Once all order_header_ids have been derived for each
			 line, this procedure uses bulk updates to update the
			 interface and schedule lines.

  PARAMETERS:            x_header_id IN NUMBER

  DESIGN REFERENCES:     rlabldld.rtf

  CHANGE HISTORY:        created rlanka 10/10/02
===========================================================================*/
PROCEDURE UpdateLinesWithRSO(x_header_id IN NUMBER);

/*===============================================================================
  PROCEDURE NAME:        InsertOMMessages

  DESCRIPTION:           This procedure records all the errors/warnings
			 from Process Order API, when attempting to create/book
		 	 a release sales order.

  PARAMETERS:            x_Sched_rec	IN	RLM_INTERFACE_HEADERS%ROWTYPE
			 x_Group_rec    IN      t_group_rec
			 x_msg_count    IN	NUMBER
			 x_msg_level	IN	VARCHAR2
			 x_token	IN	VARCHAR2
			 x_msg_name	IN	VARCHAR2

  CHANGE HISTORY:        created rlanka 10/10/02
================================================================================*/
PROCEDURE InsertOMMessages(x_Sched_rec	IN	RLM_INTERFACE_HEADERS%ROWTYPE,
			   x_Group_rec	IN	RLM_DP_SV.t_Group_rec,
			   x_msg_count  IN	NUMBER,
			   x_msg_level	IN	VARCHAR2,
			   x_token	IN	VARCHAR2,
			   x_msg_name	IN	VARCHAR2);
--<TPA_PUBLIC_NAME>


/*===========================================================================
  PROCEDURE NAME:     GetTPContext

  DESCRIPTION:        This procedure returns the tp group context.
                      and null x_ship_to_ece_locn_code,
                      and null x_inter_ship_to_ece_locn_code

  PARAMETERS:         x_sched_rec       IN  RLM_INTERFACE_HEADERS%ROWTYPE
                      x_group_rec       IN  t_Group_rec
                      x_customer_number OUT VARCHAR2
                      x_ship_to_ece_locn_code OUT VARCHAR2
                      x_bill_to_ece_locn_code OUT VARCHAR2
                      x_inter_ship_to_ece_locn_code OUT VARCHAR2
                      x_tp_group_code OUT VARCHAR2

  CHANGE HISTORY:     created	rlanka	02/12/2003

===========================================================================*/
PROCEDURE GetTPContext( x_sched_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
                       x_group_rec   IN rlm_dp_sv.t_Group_rec,
                       x_customer_number OUT NOCOPY VARCHAR2,
                       x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_tp_group_code OUT NOCOPY VARCHAR2);
--<TPA_TPS>

--4302492 : Added the following procedure
/*===========================================================================
  PROCEDURE NAME:     CalFenceDays

  DESCRIPTION:        This procedure returns number of fence days

  PARAMETERS:         x_sched_rec       IN  RLM_INTERFACE_HEADERS%ROWTYPE
                      x_group_rec       IN  t_Group_rec
                      x_fence_days	OUT NUMBER

  CHANGE HISTORY:     created	anviswan 30/06/2005

===========================================================================*/
Procedure CalFenceDays(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                       x_Group_rec IN rlm_dp_sv.t_Group_rec,
                       x_fence_days OUT NOCOPY NUMBER);

END RLM_BLANKET_SV;

/
