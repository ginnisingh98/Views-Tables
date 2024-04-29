--------------------------------------------------------
--  DDL for Package RLM_DP_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_DP_SV" AUTHID CURRENT_USER as
/*$Header: RLMDPWPS.pls 120.3.12010000.1 2008/07/21 09:44:35 appldev ship $*/
/*===========================================================================
  PACKAGE NAME:	RLM_DP_SV

  DESCRIPTION:	Contains all server side code for the dsp wrapper.

  CLIENT/SERVER:	Server

  LIBRARY NAME:	None

  OWNER:

  PROCEDURE/FUNCTIONS:

  GLOBALS:

===========================================================================*/
  C_SDEBUG              CONSTANT   NUMBER := rlm_core_sv.C_LEVEL1;
  C_DEBUG               CONSTANT   NUMBER := rlm_core_sv.C_LEVEL2;
  C_TDEBUG              CONSTANT   NUMBER := rlm_core_sv.C_LEVEL3;

  k_MANUAL		CONSTANT VARCHAR2(30) := 'MANUAL';

  k_ORIGINAL            CONSTANT VARCHAR2(30) := 'ORIGINAL';
  k_REPLACE             CONSTANT VARCHAR2(30) := 'REPLACE';
  k_REPLACE_ALL         CONSTANT VARCHAR2(30) := 'REPLACE_ALL';
  k_CHANGE              CONSTANT VARCHAR2(30) := 'CHANGE';
  k_CANCEL              CONSTANT VARCHAR2(30) := 'CANCELLATION';
  k_DELETE              CONSTANT VARCHAR2(30) := 'DELETE';
  k_INSERT              CONSTANT VARCHAR2(30) := 'INSERT';
  k_CONFIRMATION        CONSTANT VARCHAR2(30) := 'CONFIRMATION';
  k_ADD                 CONSTANT VARCHAR2(30) := 'ADD';
  k_RECEIPT             CONSTANT VARCHAR2(80) := 'RECEIPT';
  k_PLANNING            CONSTANT VARCHAR2(30) := 'PLANNING_RELEASE';
  k_SHIPPING            CONSTANT VARCHAR2(30) := 'SHIPPING';
  k_SEQUENCED           CONSTANT VARCHAR2(30) := 'SEQUENCED';
  k_A           CONSTANT VARCHAR2(1) := 'A';
  k_B           CONSTANT VARCHAR2(1) := 'B';
  k_C           CONSTANT VARCHAR2(1) := 'C';
  k_D           CONSTANT VARCHAR2(1) := 'D';
  k_E           CONSTANT VARCHAR2(1) := 'E';
  k_F           CONSTANT VARCHAR2(1) := 'F';
  k_G           CONSTANT VARCHAR2(1) := 'G';
  k_VNULL               CONSTANT VARCHAR2(25) := 'THIS_IS_A_NULL_VALUE';
  k_NNULL               CONSTANT NUMBER := -19999999999;
  k_DNULL               CONSTANT DATE := to_date('01/01/1930','dd/mm/yyyy');
  k_PARALLEL_DSP	CONSTANT VARCHAR2(10) := 'PARALLEL';
  k_SEQ_DSP 		CONSTANT VARCHAR2(10) := 'SEQUENTIAL';
  e_HeaderLocked	EXCEPTION;
  edi_test_indicator    VARCHAR2(3);    /*2554058*/

  -- For sweeper program when wf is enabled
  g_warn_replace_schedule VARCHAR2(1) DEFAULT 'N';

  -- stype
  g_order_by_schedule_type VARCHAR2(1) DEFAULT 'N';

  TYPE g_request_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  -- ER 3992531: Added min_start_date_time to the following record structure.

  TYPE t_Group_rec IS RECORD(
    customer_id              rlm_interface_headers.customer_id%TYPE,
    ship_from_org_id         rlm_interface_lines.ship_from_org_id%TYPE,
    ship_to_address_id       rlm_interface_lines.ship_to_address_id%TYPE,
    ship_to_site_use_id      rlm_interface_lines.ship_to_site_use_id%TYPE,
    ship_to_org_id           rlm_interface_lines.ship_to_org_id%TYPE,
    customer_item_id         rlm_interface_lines.customer_item_id%TYPE,
    inventory_item_id        rlm_interface_lines.inventory_item_id%TYPE,
    schedule_item_num        rlm_interface_lines.schedule_item_num%TYPE,
    industry_attribute15     rlm_interface_lines.industry_attribute15%TYPE,
    order_header_id          rlm_interface_lines.order_header_id%TYPE,
    --cust_production_seq_num  rlm_interface_lines.cust_production_seq_num%TYPE,
    schedule_type_one        rlm_interface_headers.schedule_type%TYPE,
    schedule_type_two        rlm_interface_headers.schedule_type%TYPE,
    schedule_type_three      rlm_interface_headers.schedule_type%TYPE,
    deliver_to_org_id        rlm_interface_lines.deliver_to_org_id%TYPE,
--need for forecast module
    bill_to_site_use_id      rlm_interface_lines.bill_to_site_use_id%TYPE,
    bill_to_address_id       rlm_interface_lines.bill_to_address_id%TYPE,
    match_within             rlm_cust_shipto_terms.match_within_key%TYPE,
    match_within_rec         rlm_core_sv.t_Match_rec,
    match_across             rlm_cust_shipto_terms.match_across_key%TYPE,
    match_across_rec         rlm_core_sv.t_Match_rec,
    setup_terms_rec          rlm_setup_terms_sv.setup_terms_rec_typ,
    cutoff_days              NUMBER,
    disposition_code         rlm_cust_shipto_terms.unshipped_firm_disp_cd%TYPE,
    frozen_days              NUMBER,
    isSourced                BOOLEAN,
    roll_forward_frozen_flag  VARCHAR2(1),
    blanket_number	     rlm_cust_shipto_terms.blanket_number%TYPE,
    min_start_date_time	     rlm_interface_lines.start_date_time%TYPE,
    intmed_ship_to_org_id    rlm_interface_lines.intmed_ship_to_org_id%TYPE,--Bugfix 5911991
    intrmd_ship_to_id        rlm_interface_lines.intrmd_ship_to_id%TYPE,     --Bugfix 5911991
    ship_to_customer_id      rlm_interface_lines.ship_to_customer_id%TYPE
    );
  g_md_total  NUMBER:=0;
  g_mf_total  NUMBER:=0;
  g_rd_total  NUMBER:=0;

/*===========================================================================
  PROCEDURE NAME:    DemandProcessor

  DESCRIPTION:	     This procedure will be called from the inbound gateway
                     Based on the schedule_header_id passed from the
                     inbound gateway the parameters passed by EDI
                     is only schedule_header_id which is used to
                     get all the demand for that schedule. This is
                     then collected and the validate_demand is called

  PARAMETERS:        errbuf OUT NOCOPY VARCHAR2
                     retcode OUT NOCOPY VARCHAR2
                     p_schedule_purpose_code VARCHAR2  DEFAULT NULL
                     p_from_date   DATE  DEFAULT NULL
                     p_to_date   DATE  DEFAULT NULL
                     p_from_customer_ext   VARCHAR2  DEFAULT NULL
                     p_to_customer_ext   VARCHAR2  DEFAULT NULL
                     p_from_ship_to_ext   VARCHAR2  DEFAULT NULL
                     p_to_ship_to_ext   VARCHAR2  DEFAULT NULL
		     p_warn_replace_schedule VARCHAR2 DEFAULT 'N'
                     p_order_by_schedule_type VARCHAR2 DEFAULT 'N',
                     p_child_processes        NUMBER DEFAULT 0
                     p_request_id            NUMBER DEFAULT NULL

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created abkulkar 03/25/99
                        Added p_org_id    rlanka     03/30/05
===========================================================================*/
PROCEDURE DemandProcessor(  errbuf OUT NOCOPY VARCHAR2,
                            retcode OUT NOCOPY VARCHAR2,
                            p_org_id NUMBER,
                            p_schedule_purpose_code VARCHAR2  DEFAULT NULL,
                            p_from_date  VARCHAR2  DEFAULT NULL,
                            p_to_date  VARCHAR2  DEFAULT NULL,
                            p_from_customer_ext   VARCHAR2  DEFAULT NULL,
                            p_to_customer_ext   VARCHAR2  DEFAULT NULL,
                            p_from_ship_to_ext   VARCHAR2  DEFAULT NULL,
                            p_to_ship_to_ext   VARCHAR2  DEFAULT NULL,
                            p_header_id        NUMBER   DEFAULT NULL,
                            p_dummy           VARCHAR2  DEFAULT NULL,
                            p_cust_ship_from_ext  VARCHAR2    DEFAULT  NULL,
                            p_warn_replace_schedule VARCHAR2 DEFAULT 'N',
                            p_order_by_schedule_type VARCHAR2 DEFAULT 'N',
                            p_child_processes        NUMBER DEFAULT 0,
                            p_request_id            NUMBER DEFAULT NULL);


/*===========================================================================
  PROCEDURE NAME:   PurgeInterfaceLines

  DESCRIPTION:	    This procedure deletes the fully processed lines from the
                    interface tables

  PARAMETERS:      x_header_id IN NUMBER

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnandell 10/25/99
===========================================================================*/

PROCEDURE PurgeInterfaceLines(x_header_id IN NUMBER);
--
/*===========================================================================
  PROCEDURE NAME:   UpdateHeaderPS

  DESCRIPTION:	    This procedure Updates the headers process STatus
                    based on interface lines

  PARAMETERS:      x_header_id IN NUMBER

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnandell 10/25/99
===========================================================================*/
PROCEDURE UpdateHeaderPS (x_HeaderId    IN   NUMBER,
                          x_ScheduleHeaderId    IN   NUMBER);

/*===========================================================================
  PROCEDURE NAME:   UpdateGroupPS

  DESCRIPTION:	    This procedure Updates the lines process STatus
                    for the entire group

  PARAMETERS:      x_header_id IN NUMBER

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnandell 10/25/99
===========================================================================*/
PROCEDURE UpdateGroupPS(x_header_id         IN     NUMBER,
                        x_ScheduleHeaderId  IN     NUMBER,
                        x_Group_rec         IN     rlm_dp_sv.t_Group_rec,
                        x_status            IN     NUMBER,
                        x_UpdateLevel       IN  VARCHAR2 DEFAULT 'GROUP');

/*===========================================================================
  FUNCTION NAME:   LockHeader

  DESCRIPTION:	    This procedure locks the header for the entire transaction

  PARAMETERS:      x_header_id IN NUMBER

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnandell 10/25/99
===========================================================================*/
FUNCTION LockHeader (x_HeaderId IN  NUMBER,
                     v_Sched_rec OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE)
RETURN BOOLEAN;

/*=========================================================================

  PROCEDURE NAME:     RunExceptionReport

  DESCRIPTION:        This procedure  runs the exception report
                      if there are any message for the DSP run

  PARAMETERS:         x_requestId IN NUMBER
                      x_OrgId     IN NUMBER DEFAULT NULL

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created        mnandell 10/25/99
                        Add x_OrgId    rlanka   03/30/05
===========================================================================*/

PROCEDURE RunExceptionReport(x_requestId    IN   NUMBER,
                             x_OrgId        IN   NUMBER DEFAULT NULL);


/*===========================================================================
  FUNCTION NAME:   CheckForecast

  DESCRIPTION:	   This procedure checks for MRP forecast lines in a group

  PARAMETERS:      x_header_id IN NUMBER
                   x_Group_rec         IN     rlm_dp_sv.t_Group_rec

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created asutar 05/24/2001
===========================================================================*/

FUNCTION CheckForecast(x_header_id         IN     NUMBER,
                       x_Group_rec         IN     rlm_dp_sv.t_Group_rec)
RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:   ChildProcess

  DESCRIPTION:  Executable for Concurrent program RLMDSPCHILD

  PARAMETERS:   errbuf                    OUT NOCOPY VARCHAR2
                retcode                   OUT NOCOPY VARCHAR2
                p_request_id              IN         NUMBER
                p_header_id               IN         NUMBER
                p_index                   IN         NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created            asutar     07/24/03
                        Added p_org_id     rlanka     03/30/05
===========================================================================*/

PROCEDURE ChildProcess(
                errbuf                    OUT NOCOPY VARCHAR2,
                retcode                   OUT NOCOPY VARCHAR2,
                p_request_id              IN         NUMBER,
                p_header_id               IN         NUMBER,
                p_index                   IN         NUMBER,
                p_org_id                  IN         NUMBER);

/*===========================================================================
  PROCEDURE NAME:   SubmitChildRequests

  DESCRIPTION:	   This procedure submits DSP child requests and
                   populates child request table

  PARAMETERS:      x_header_id            IN NUMBER,
                   x_num_child            IN NUMBER,
                   x_child_req_id         IN OUT NOCOPY g_request_tbl


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created asutar 07/24/2003
===========================================================================*/

PROCEDURE SubmitChildRequests(
                x_header_id            IN NUMBER,
                x_num_child            IN NUMBER,
                x_child_req_id         IN OUT NOCOPY g_request_tbl);

/*===========================================================================
  PROCEDURE NAME:  ProcessGroups

  DESCRIPTION:	   This procedure loops thru groups and calls Managedemand,
                   ManageForecast and RecDemand for each group. p_index is
                   null for serial processing of groups within a schedule.

  PARAMETERS:      p_sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                   p_header_id IN NUMBER,
                   p_index     IN NUMBER DEFAULT NULL)

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created asutar 07/24/2003
===========================================================================*/

PROCEDURE ProcessGroups (p_sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         p_header_id IN NUMBER,
                         p_index     IN NUMBER DEFAULT NULL,
	                 p_dspMode   IN VARCHAR2 DEFAULT k_SEQ_DSP);

/*===========================================================================
  PROCEDURE NAME:  CreateChildGroups

  DESCRIPTION:	   This procedure marks groups with child process index
                   for parallelization.

  PARAMETERS:      x_header_id            IN NUMBER,
                   x_num_child            IN OUT NOCOPY NUMBER


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created asutar 07/24/2003
===========================================================================*/

PROCEDURE CreateChildGroups( x_header_id            IN NUMBER,
                             x_num_child            IN OUT NOCOPY NUMBER);

/*===========================================================================
  PROCEDURE NAME:  ProcessChildRequests

  DESCRIPTION:	   This procedure waits for each child request to finish
                   and updates the group status accordingly

  PARAMETERS:      x_header_id IN NUMBER
                   x_Group_rec         IN     rlm_dp_sv.t_Group_rec

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created asutar 07/24/2003
===========================================================================*/

PROCEDURE ProcessChildRequests(x_header_id            IN NUMBER,
                               x_child_req_id         IN g_request_tbl);

END RLM_DP_SV;

/
