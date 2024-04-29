--------------------------------------------------------
--  DDL for Package Body AP_CREATE_PAY_DISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CREATE_PAY_DISTS_PKG" AS
/* $Header: appdistb.pls 120.4 2004/10/28 23:26:25 pjena noship $ */


    -----------------------------------------------------------------------
    -- Procedure overlay_segments performs either ACCOUNT or BALANCING
    -- segment overlay of the two input segments and returns the validated
    -- ccid of the resulting overlay segments or the reason it could not
    -- be flexbuilt.
    --
    -- Case 1: Account Segment Overlay
    --
    --     Result	B	B      [A]	B	...
    --     Primary	A	A      [A]	A	...
    --     Overlay	B	B      [B]	B	...
    --
    -- Case 2: Balancing Segment Overlay
    --
    --     Result      [B]	A       A	A	...
    --     Primary     [A]	A       A	A	...
    --     Overlay     [B]	B       B	B	...
    --
    PROCEDURE overlay_segments
	(P_primary_segments	IN	FND_FLEX_EXT.SEGMENTARRAY
	,P_overlay_segments	IN	FND_FLEX_EXT.SEGMENTARRAY
	,P_num_segments		IN	NUMBER
	,P_chart_of_accounts_id	IN	NUMBER
	,P_flex_segment_num	IN	NUMBER
	,P_flex_qualifier_name	IN	VARCHAR2
	,P_segment_delimiter	IN	VARCHAR2
	,P_ccid			OUT NOCOPY NUMBER
	,P_unbuilt_flex		OUT NOCOPY VARCHAR2
	,P_reason_unbuilt_flex	OUT NOCOPY VARCHAR2
	,P_calling_sequence	IN	VARCHAR2
	)
    IS
	l_segments			FND_FLEX_EXT.SEGMENTARRAY;
	l_result			BOOLEAN;
	l_debug_info		 	VARCHAR2(240);
	l_curr_calling_sequence 	VARCHAR2(2000);
    BEGIN
	l_curr_calling_sequence := 'AP_CREATE_PAY_DISTS_PKG.OVERLAY_SEGMENTS<-' ||
				   P_calling_sequence;

        -------------------------------------------------------------------
	-- Overlay segments
	--
	FOR i IN 1..P_num_segments LOOP

	    l_debug_info := 'Overlaying segment number ' || TO_CHAR(i);

	    IF (P_flex_qualifier_name = 'GL_ACCOUNT') THEN
	        --
	        -- Case 1: Account segment overlay
	        --
		IF (i = P_flex_segment_num) THEN
		    l_segments(i) := P_primary_segments(i);
		ELSE
		    l_segments(i) := P_overlay_segments(i);
		END IF;

	    ELSIF (P_flex_qualifier_name = 'GL_BALANCING') THEN
	        --
	        -- Case 2: Balancing segment overlay
	        --
		IF (i = P_flex_segment_num) THEN
		    l_segments(i) := P_overlay_segments(i);
		ELSE
		    l_segments(i) := P_primary_segments(i);
		END IF;

	    END IF;

	END LOOP;

        -------------------------------------------------------------------
	-- Get ccid for overlayed segments
	--
	l_result := FND_FLEX_EXT.GET_COMBINATION_ID(
				'SQLGL',
				'GL#',
				P_chart_of_accounts_id,
				SYSDATE,
				P_num_segments,
				l_segments,
				P_ccid);

	IF (NOT l_result) THEN
	    --
	    -- Store unbuild flex reason and unbuilt flex if error
	    --
	    P_ccid := -1;
	    P_reason_unbuilt_flex := FND_MESSAGE.GET;
	    P_unbuilt_flex := FND_FLEX_EXT.CONCATENATE_SEGMENTS(
					P_num_segments,
					l_segments,
					P_segment_delimiter);
	ELSE
	    P_reason_unbuilt_flex := NULL;
	    P_unbuilt_flex := NULL;
	END IF;

    EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
		  '  FLEX_QUALIFIER_NAME = '|| P_flex_qualifier_name
		||', FLEX_SEGMENT_NUM = '   || TO_CHAR(P_flex_segment_num));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

    END overlay_segments;

END AP_CREATE_PAY_DISTS_PKG;

/
