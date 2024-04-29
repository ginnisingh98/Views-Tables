--------------------------------------------------------
--  DDL for Package Body PA_SELF_SERVICE_DFLEX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SELF_SERVICE_DFLEX_PUB" AS
/* $Header: PAXPDFFB.pls 120.1 2005/08/11 12:27:58 eyefimov noship $ */

C_strDFlexColNamePrefix CONSTANT VARCHAR2(20) := 'ATTRIBUTE';
C_iNumMaxAttribute      CONSTANT INTEGER := 10;
C_iNumMaxDFlexSeg       CONSTANT INTEGER := 10;

/*
Written By   :  AANDRA
Purpose      :  To append current procedure/function name to
		a string to simulate a call stack
Input        :  Module Name
Output       :
Input Output :  Call Stack - for debug purposes
Assumption   :
*/
-----------------------------------------------------------------------------
PROCEDURE UpdateCallingSequence(
		p_sCall_stack 		IN OUT NOCOPY VARCHAR2,
		p_procedure_name 	IN     VARCHAR2) IS
-----------------------------------------------------------------------------
BEGIN

  p_sCall_stack := p_sCall_stack || ' -->
 ' || p_procedure_name;

END UpdateCallingSequence;

------------------------------------------------------------------------------
PROCEDURE IsDFlexUsed(
        p_recDFlexR             IN FND_DFLEX.DFLEX_R,
	    p_recContextsDR  	    IN FND_DFLEX.CONTEXTS_DR,
        p_sErrorStack           IN VARCHAR2,
        x_bResult               OUT NOCOPY BOOLEAN,
        x_sErrorType            OUT NOCOPY VARCHAR2,
        x_sErrorStack           OUT NOCOPY VARCHAR2,
        x_sErrorStage           OUT NOCOPY VARCHAR2,
        x_sErrorMessage         OUT NOCOPY VARCHAR2)
------------------------------------------------------------------------------
IS

  l_recContextR     FND_DFLEX.CONTEXT_R;
  l_recSegmentsDR   FND_DFLEX.SEGMENTS_DR;
  l_sModuleName     VARCHAR2(200)  := 'PA_SELF_SERVICE_DFLEX_PVT.IsDFlexUsed';

  l_sErrorStack         VARCHAR2(2000);
  l_sErrorStage         VARCHAR2(2000);

BEGIN

  -- Set the calling context
  l_sErrorStage := 'Update calling sequence';
  l_sErrorStack := p_sErrorStack;
  UpdateCallingSequence(l_sErrorStack, l_sModuleName);

  -- Initialize result
  x_bResult := FALSE;

  l_sErrorStage := 'Loop through all contexts and count number of segments';
  FOR I in 1 .. p_recContextsDR.ncontexts LOOP

    -- Generate context if not the global and is enabled
    IF (p_recContextsDR.is_enabled(I)) THEN

      -- Get context information
      l_recContextR.flexfield := p_recDFlexR;
      l_recContextR.context_code :=  p_recContextsDR.context_code(I);
      FND_DFLEX.Get_Segments(l_recContextR, l_recSegmentsDR, TRUE);
      IF (l_recSegmentsDR.nsegments > 0) THEN
        x_bResult := TRUE;
        EXIT;
      END IF;
    END IF;
  END LOOP;

EXCEPTION

  WHEN OTHERS THEN
    -- Unexpected error
    x_sErrorType := 'U';
    x_sErrorStack := l_sErrorStack;
    x_sErrorStage := l_sErrorStage;
    x_sErrorMessage := SUBSTRB(SQLERRM,1,2000);
    x_bResult := FALSE;

END IsDFlexUsed;

------------------------------------------------------------------------------
PROCEDURE GetDFlexReferenceField(
        p_recDFlexDR            IN FND_DFLEX.DFLEX_DR,
        p_sErrorStack           IN VARCHAR2,
	    x_strReferenceField  	OUT NOCOPY VARCHAR2,
        x_sErrorType            OUT NOCOPY VARCHAR2,
        x_sErrorStack           OUT NOCOPY VARCHAR2,
        x_sErrorStage           OUT NOCOPY VARCHAR2,
        x_sErrorMessage         OUT NOCOPY VARCHAR2)
------------------------------------------------------------------------------
IS
  l_sModuleName     VARCHAR2(200)  := 'PA_SELF_SERVICE_DFLEX_PUB.GetDFlexReferenceField';

  l_sErrorStack         VARCHAR2(2000);
  l_sErrorStage         VARCHAR2(2000);

BEGIN

  -- Set the calling context
  l_sErrorStage := 'Update calling sequence';
  l_sErrorStack := p_sErrorStack;
  UpdateCallingSequence(l_sErrorStack,
                        l_sModuleName);

  -- Get the reference field
  x_strReferenceField := p_recDFlexDR.default_context_field;

  -- Set error type
  x_sErrorType := NULL;

EXCEPTION

  WHEN OTHERS THEN
    -- Unexpected error
    x_sErrorType := 'U';
    x_sErrorStack := l_sErrorStack;
    x_sErrorStage := l_sErrorStage;
    x_sErrorMessage := SUBSTRB(SQLERRM,1,2000);
    x_strReferenceField := Null;

END GetDFlexReferenceField;

------------------------------------------------------------------------------
PROCEDURE InitDFlex(
        p_strProductName        IN VARCHAR2,
	    p_strDFlexName	      	IN VARCHAR2,
        p_sErrorStack           IN VARCHAR2,
        x_recDFlexR             OUT NOCOPY FND_DFLEX.DFLEX_R,           /*2672653*/
        x_recDFlexDR            OUT NOCOPY FND_DFLEX.DFLEX_DR,          /*2672653*/
	    x_recContextsDR  	    OUT NOCOPY FND_DFLEX.CONTEXTS_DR,       /*2672653*/
        x_sErrorType            OUT NOCOPY VARCHAR2,
        x_sErrorStack           OUT NOCOPY VARCHAR2,
        x_sErrorStage           OUT NOCOPY VARCHAR2,
        x_sErrorMessage         OUT NOCOPY VARCHAR2)
------------------------------------------------------------------------------
IS
  l_sModuleName             VARCHAR2(200)  := 'PA_SELF_SERVICE_DFLEX_PVT.InitDflex';

  l_sErrorStack         VARCHAR2(2000);
  l_sErrorStage         VARCHAR2(2000);

BEGIN

  -- Set the calling context
  l_sErrorStage := 'Update calling sequence';
  l_sErrorStack := p_sErrorStack;
  UpdateCallingSequence(l_sErrorStack, l_sModuleName);

  l_sErrorStage := 'Get flexfield info';
  FND_DFLEX.Get_Flexfield(p_strProductName, p_strDFlexName,
                          x_recDFlexR, x_recDFlexDR);

  l_sErrorStage := 'Get context info';
  FND_DFLEX.Get_Contexts(x_recDFlexR, x_recContextsDR);

  -- No errors encountered;
  x_sErrorType := NULL;

EXCEPTION

  WHEN OTHERS THEN
    -- Unexpected error
    x_sErrorType := 'U';
    x_sErrorStack := l_sErrorStack;
    x_sErrorStage := l_sErrorStage;
    x_sErrorMessage := SUBSTRB(SQLERRM,1,2000);

END InitDFlex;

------------------------------------------------------------------------------
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
        x_sErrorMessage         OUT NOCOPY VARCHAR2)
------------------------------------------------------------------------------
IS

  l_iContextIndex       BINARY_INTEGER;
  l_sColName            VARCHAR2(20);
  l_iMaxIndex           INTEGER;
  l_sModuleName         VARCHAR2(200)  := 'PA_SELF_SERVICE_DFLEX_PVT.ValidateDflex';

  l_sErrorStack         VARCHAR2(2000);
  l_sErrorStage         VARCHAR2(2000);

BEGIN

  -- Set the calling context
  l_sErrorStage := 'Update calling sequence';
  l_sErrorStack := p_sErrorStack;
  UpdateCallingSequence(l_sErrorStack, l_sModuleName);

  l_sErrorStage := 'Get the context index';
  l_iContextIndex := NULL;
  FOR i IN 1 .. p_recContextsDR.nContexts LOOP
    IF ((p_recContextsDR.is_enabled(I)) AND
        (p_recContextsDR.context_name(i) = p_strContextName)) THEN
      l_iContextIndex := i;
    END IF;
  END LOOP;

  -- Set the context value to prepare for FND_FLEX_DESCVAL.Validate_DescCols
  -- In case where only have globals then pass null
  l_sErrorStage := 'Set the context value';
  IF (l_iContextIndex IS NULL) THEN
    FND_FLEX_DESCVAL.Set_Context_Value(null);
  ELSE
    FND_FLEX_DESCVAL.Set_Context_Value(
     p_recContextsDR.context_code(l_iContextIndex));
  END IF;

  -- Iterate only up to p_arrDFlex.Count number of times
  l_iMaxIndex := p_arrDFlex.COUNT;
  IF (l_iMaxIndex > C_iNumMaxAttribute) THEN
    l_iMaxIndex := C_iNumMaxAttribute;
  END IF;

  l_sErrorStage := 'Set the values for the columns for non null fields';
  FOR I in 1 .. p_arrDFlex.COUNT LOOP
    l_sColName := C_strDFlexColNamePrefix || I;
    FND_FLEX_DESCVAL.Set_Column_Value(l_sColName, p_arrDFlex(I));
  END LOOP;

  l_sErrorStage := 'Calling FND Validate_Desccols';
  IF (NOT FND_FLEX_DESCVAL.Validate_Desccols(
                                     appl_short_name => p_strProductName,
  				     desc_flex_name => p_strDFlexName)) THEN

    -- Descriptive flexfields are not valid
    x_sErrorType := 'E';
    x_sErrorStack := l_sErrorStack;
    x_sErrorStage := l_sErrorStage;
    x_sErrorMessage := FND_FLEX_DESCVAL.error_message;

  ELSE

    -- Successful validation
    x_sErrorType := NULL;

  END IF;

EXCEPTION

  WHEN OTHERS THEN
    -- Unexpected error
    x_sErrorType := 'U';
    x_sErrorStack := l_sErrorStack;
    x_sErrorStage := l_sErrorStage;
    x_sErrorMessage := SUBSTRB(SQLERRM,1,2000);

END ValidateDFlex;

PROCEDURE InitDFlex(p_arrDFlex OUT NOCOPY DFlex_Array)               /*2672653*/
IS
BEGIN
  FOR I IN 1 .. C_iNumMaxDFlexSeg LOOP
    p_arrDFlex(I) := NULL;
  END LOOP;
END InitDFlex;


FUNCTION IsDFlexArrayEmpty(p_arrDFlex IN DFlex_Array)
RETURN BOOLEAN
IS
BEGIN
  FOR I IN 1 .. p_arrDFlex.COUNT LOOP
    IF p_arrDFlex(I) IS NOT NULL THEN
      RETURN FALSE;
    END IF;
  END LOOP;
  RETURN TRUE;
END IsDFlexArrayEmpty;

END PA_SELF_SERVICE_DFLEX_PUB;

/
