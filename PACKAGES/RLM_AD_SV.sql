--------------------------------------------------------
--  DDL for Package RLM_AD_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_AD_SV" AUTHID CURRENT_USER as
/* $Header: RLMDPARS.pls 115.6 2002/12/23 06:40:42 jautomo ship $ */
/*===========================================================================
  PACKAGE NAME:		RLM_AD_SV

  DESCRIPTION:		Contains all server side procedures that access the
			requisitions  entity

  CLIENT/SERVER:	Server

  LIBRARY NAME:		None

  OWNER:		ANVERMA

  PROCEDURE/FUNCTIONS:	Archive_Demand()
                   	Archive_Headers()
                   	Archive_Lines()

===========================================================================*/

  C_SDEBUG			NUMBER := rlm_core_sv.C_LEVEL17;
  C_DEBUG			NUMBER := rlm_core_sv.C_LEVEL18;


/*===========================================================================
  FUNCTION NAME:	Archive_Demand

  DESCRIPTION:		This is a top level Function for Archiving the Demand.
			This Function makes call to rchive_headers and Archive_lines
			to archive Schedule headers and Lines.

  PARAMETERS:		x_InterfaceHeaderId  	IN NUMBER

  DESIGN REFERENCES:	rlmdlar.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	anverma		07/11	created
===========================================================================*/

FUNCTION Archive_Demand (x_InterfaceHeaderId	IN  NUMBER) RETURN BOOLEAN;

/*===========================================================================
  FUNCTION NAME:	Archive_Headers

  DESCRIPTION:		This function Archives the Header Information of the Schedule and
			updates RLM_SCHEDULE_ID in RLM_INTERFACE_HEADERS table.

  PARAMETERS:		x_InterfaceHeaderId  	IN 	NUMBER
			x_RlmScheduleId		OUT NOCOPY NUMBER

  DESIGN REFERENCES:	rlmdlar.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	anverma		07/11	created
===========================================================================*/

FUNCTION Archive_Headers (x_InterfaceHeaderId	IN  NUMBER,
			  x_RlmScheduleId OUT NOCOPY NUMBER) RETURN BOOLEAN;

/*===========================================================================
  FUNCTION NAME:	Archive_Lines

  DESCRIPTION:		This functions Archives the Schedule Lines.

  PARAMETERS:		x_InterfaceHeaderId  	IN 	NUMBER
			x_RlmScheduleId		IN	NUMBER

  DESIGN REFERENCES:	rlmdlar.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	anverma		07/11	created
===========================================================================*/

FUNCTION Archive_Lines(x_InterfaceHeaderId	IN  NUMBER,x_RlmScheduleId   IN  NUMBER) RETURN BOOLEAN;

END RLM_AD_SV;

 

/
