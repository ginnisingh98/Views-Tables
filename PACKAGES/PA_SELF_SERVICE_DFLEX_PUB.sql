--------------------------------------------------------
--  DDL for Package PA_SELF_SERVICE_DFLEX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SELF_SERVICE_DFLEX_PUB" AUTHID CURRENT_USER AS
/* $Header: PAXPDFFS.pls 120.1 2005/08/11 12:27:48 eyefimov noship $ */

TYPE DFlex_Array IS TABLE OF VARCHAR2(150)
  INDEX BY BINARY_INTEGER;

PROCEDURE IsDFlexUsed(
        p_recDFlexR             IN FND_DFLEX.DFLEX_R,
	    p_recContextsDR  	    IN FND_DFLEX.CONTEXTS_DR,
        p_sErrorStack           IN VARCHAR2,
        x_bResult               OUT NOCOPY BOOLEAN,
        x_sErrorType            OUT NOCOPY VARCHAR2,
        x_sErrorStack           OUT NOCOPY VARCHAR2,
        x_sErrorStage           OUT NOCOPY VARCHAR2,
        x_sErrorMessage         OUT NOCOPY VARCHAR2);

PROCEDURE GetDFlexReferenceField(
        p_recDFlexDR            IN FND_DFLEX.DFLEX_DR,
        p_sErrorStack           IN VARCHAR2,
	    x_strReferenceField  	OUT NOCOPY VARCHAR2,
        x_sErrorType            OUT NOCOPY VARCHAR2,
        x_sErrorStack           OUT NOCOPY VARCHAR2,
        x_sErrorStage           OUT NOCOPY VARCHAR2,
        x_sErrorMessage         OUT NOCOPY VARCHAR2);

PROCEDURE InitDFlex(
        p_strProductName        IN VARCHAR2,
	    p_strDFlexName	      	IN VARCHAR2,
        p_sErrorStack           IN VARCHAR2,
        x_recDFlexR             OUT NOCOPY FND_DFLEX.DFLEX_R,      /*2672653*/
        x_recDFlexDR            OUT NOCOPY FND_DFLEX.DFLEX_DR,     /*2672653*/
	    x_recContextsDR  	    OUT NOCOPY FND_DFLEX.CONTEXTS_DR,  /*2672653*/
        x_sErrorType            OUT NOCOPY VARCHAR2,
        x_sErrorStack           OUT NOCOPY VARCHAR2,
        x_sErrorStage           OUT NOCOPY VARCHAR2,
        x_sErrorMessage         OUT NOCOPY VARCHAR2);

PROCEDURE ValidateDFlex(
        p_strProductName        IN VARCHAR2,
	    p_strDFlexName	      	IN VARCHAR2,
	    p_recContextsDR  	    IN FND_DFLEX.CONTEXTS_DR,
	    p_strContextName      	IN VARCHAR2,
	    p_arrDFlex              IN DFlex_Array,
        p_sErrorStack           IN VARCHAR2,
        x_sErrorType            OUT NOCOPY VARCHAR2,
        x_sErrorStack           OUT NOCOPY VARCHAR2,
        x_sErrorStage           OUT NOCOPY VARCHAR2,
        x_sErrorMessage         OUT NOCOPY VARCHAR2);

PROCEDURE InitDFlex(p_arrDFlex OUT NOCOPY DFlex_Array);                /*2672653*/

FUNCTION IsDFlexArrayEmpty(p_arrDFlex IN DFlex_Array)
RETURN BOOLEAN;

END PA_SELF_SERVICE_DFLEX_PUB;
 

/
