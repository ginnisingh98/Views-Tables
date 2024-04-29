--------------------------------------------------------
--  DDL for Package RLM_WF_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_WF_SV" AUTHID CURRENT_USER as
/*$Header: RLMDPWFS.pls 120.1.12000000.1 2007/01/18 18:32:04 appldev ship $*/
/*===========================================================================
  PACKAGE NAME:	RLM_WF_SV

  DESCRIPTION:	Contains all server side code for the dsp workflow wrapper.

  CLIENT/SERVER:	Server

  LIBRARY NAME:	None

  OWNER:

  PROCEDURE/FUNCTIONS:

  GLOBALS:

===========================================================================*/
  C_SDEBUG              CONSTANT   NUMBER := rlm_core_sv.C_LEVEL19;
  C_DEBUG               CONSTANT   NUMBER := rlm_core_sv.C_LEVEL20;
  C_TDEBUG              CONSTANT   NUMBER := rlm_core_sv.C_LEVEL21;

  g_PROC_SUCCESS        CONSTANT   NUMBER := 0;
  g_PROC_WARNING        CONSTANT   NUMBER := 1;
  g_PROC_ERROR          CONSTANT   NUMBER := 2;

  g_ItemType             CONSTANT   VARCHAR2(8) := 'RLMHDR';
  g_ProcessName          CONSTANT   VARCHAR2(8) := 'DSPWF';
  g_ProcessNameLoop      CONSTANT   VARCHAR2(8) := 'DSPLOOP';

  g_Sch_rec		  rlm_interface_headers%ROWTYPE;
  g_Grp_rec               rlm_dp_sv.t_Group_rec;

  g_num_child            NUMBER;
  e_LockH		 EXCEPTION;

/*===========================================================================
  PROCEDURE NAME:   StartDSPProcess

  DESCRIPTION:	    This procedure calls the starts the DSP Workflow process

  PARAMETERS:              errbuf OUT NOCOPY VARCHAR2
                           retcode OUT NOCOPY VARCHAR2
                           p_Header_Id IN NUMBER DEFAULT NULL
                           v_Sch_rec   IN OUT NOCOPY rlm_interface_headers%ROWTYPE
                           v_num_child IN NUMBER

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnnaraya 01/12/2000
===========================================================================*/
PROCEDURE StartDSPProcess( errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY VARCHAR2,
                           p_Header_Id IN NUMBER DEFAULT NULL,
                           v_Sch_rec   IN OUT NOCOPY rlm_interface_headers%ROWTYPE,
                           v_num_child IN NUMBER);

/*===========================================================================
  PROCEDURE NAME:   ValidateDemand

  DESCRIPTION:	    This procedure calls the GroupValidateDemand procedure

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnnaraya 01/12/2000
===========================================================================*/

PROCEDURE ValidateDemand(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:   ManageDemand

  DESCRIPTION:	    This procedure calls the ManageDemand procedure

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnnaraya 01/12/2000
===========================================================================*/

PROCEDURE ManageDemand(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:   ManageForecast

  DESCRIPTION:	    This procedure calls the ManageForecast procedure

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnnaraya 01/12/2000
===========================================================================*/

PROCEDURE ManageForecast(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:   ReconcileDemand

  DESCRIPTION:	    This procedure calls the ReconcileDemand procedure

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnnaraya 01/12/2000
===========================================================================*/

PROCEDURE ReconcileDemand(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:   PurgeInterface

  DESCRIPTION:	    This procedure calls the PurgeInterface procedure

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnnaraya 01/12/2000
===========================================================================*/

PROCEDURE PurgeInterface(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:   RunReport

  DESCRIPTION:	    This procedure calls the RunReport procedure

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnnaraya 01/12/2000
===========================================================================*/

PROCEDURE RunReport(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:   CheckErrors

  DESCRIPTION:	    This procedure checks if errors exist for request_id.

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnnaraya 01/12/2000
===========================================================================*/

PROCEDURE CheckErrors(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:   GetScheduleDetails

  DESCRIPTION:	    This procedure gets the schedule reference number and
                    customer name for given header id.

  PARAMETERS:       x_Header_Id     IN  NUMBER
                    x_Schedule_Num  OUT NOCOPY VARCHAR2
                    x_Customer_Name OUT NOCOPY VARCHAR2
                    x_Schedule_Gen_Date OUT NOCOPY DATE

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnnaraya 01/12/2000
			Bug#: 3053299 - Added the argument (x_Schedule_Gen_Date) to
					get Schedule Generation Date

===========================================================================*/

PROCEDURE GetScheduleDetails( x_Header_Id     IN  NUMBER,
                              x_Schedule_Num  OUT NOCOPY VARCHAR2,
                              x_Customer_Name OUT NOCOPY VARCHAR2,
                              x_Schedule_Gen_Date OUT NOCOPY DATE);

/*===========================================================================
  PROCEDURE NAME:   StartDSPLoop

  DESCRIPTION:      This procedure is called to start process DSPLOOP

  PARAMETERS:       errbuf OUT NOCOPY VARCHAR2,
                    retcode OUT NOCOPY VARCHAR2,
                    p_Header_Id IN NUMBER DEFAULT NULL
                    p_Line_Id   IN NUMBER DEFAULT NULL
                    v_Sch_rec   IN rlm_interface_headers%ROWTYPE;
                    v_Grp_rec   IN rlm_dp_sv.t_Group_rec;


  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created bsadri 06/12/2000
===========================================================================*/

PROCEDURE StartDSPLoop( errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY VARCHAR2,
                           p_Header_Id IN NUMBER DEFAULT NULL,
                           p_Line_Id  IN NUMBER DEFAULT NULL,
                           v_Sch_rec   IN rlm_interface_headers%ROWTYPE,
                           v_Grp_rec   IN rlm_dp_sv.t_Group_rec);



/*===========================================================================
  PROCEDURE NAME:   StartDSPLoop

  DESCRIPTION:      This procedure is called to create process DSPLOOP

  PARAMETERS:       errbuf OUT NOCOPY VARCHAR2,
                    retcode OUT NOCOPY VARCHAR2,
                    p_Header_Id IN NUMBER DEFAULT NULL
                    p_Line_Id   IN NUMBER DEFAULT NULL


  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created bsadri 06/19/2000
===========================================================================*/


PROCEDURE CreateDSPLoop( errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY VARCHAR2,
                           p_Header_Id IN NUMBER DEFAULT NULL,
                           p_Line_Id  IN NUMBER DEFAULT NULL);


/*===========================================================================
  PROCEDURE NAME:   UpdateHeaderPS

  DESCRIPTION:	    This procedure calls rlm_dp_sv.updateHeaderPS.

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created bsadri   06/22/2000
===========================================================================*/

PROCEDURE UpdateHeaderPS(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:   ProcessGroupDemand

  DESCRIPTION:	    This procedure calls managedemand, mange_forecast and
                      reconciel demand

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created bsadri   06/28/2000
===========================================================================*/

PROCEDURE ProcessGroupDemand(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:   CallProcessGroup

  DESCRIPTION:	    This procedure calls     Creates and starts
                    the child processes for ProcessGroup

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created bsadri 07/06/2000
===========================================================================*/

PROCEDURE CallProcessGroup(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:   ArchiveDemand

  DESCRIPTION:	    This procedure archives the Demand

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created bsadri 07/06/2000
===========================================================================*/

PROCEDURE ArchiveDemand(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);



/*===========================================================================
  PROCEDURE NAME:   Testschedule

  DESCRIPTION:      This procedure checks if the schedule is a Test Schedule or
                    not.

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT VARCHAR2`

  DESIGN REFERENCES: Bug 2554058

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created anviswan 22/10/2002
===========================================================================*/

PROCEDURE Testschedule(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);

/*===========================================================================

  PROCEDURE NAME:   PostValidate

  DESCRIPTION:	    This procedure does post validation, which is done in
                    DSP wrapper.

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created bsadri 07/10/2000
===========================================================================*/

PROCEDURE PostValidate(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:   CheckStatus

  DESCRIPTION:	    This procedure checks if errors exist for request_id.

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

  DESIGN REFERENCES:    rladphld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created bsadri 07/19/2000
===========================================================================*/

PROCEDURE CheckStatus(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);

  -- Bug#: 3291401

/*===========================================================================
  PROCEDURE NAME:   GetScheduleStatus

  DESCRIPTION:	    This procedure checks for the schedule status.

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

  CHANGE HISTORY:       created vxsharma 12/08/2000
===========================================================================*/

PROCEDURE GetScheduleStatus(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2);


END RLM_WF_SV;
 

/
