--------------------------------------------------------
--  DDL for Package Body AP_EXPENSE_FEED_DISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_EXPENSE_FEED_DISTS_PKG" AS
/* $Header: apiwdstb.pls 120.1 2005/06/24 21:12:58 hchacko ship $ */

--------------------------------------------------------------------------
-- Procedure RETURN_SEGMENTS
--
-- Gets segment values qualified as cost center (FA_COST_CTR) and
-- account (GL_ACCOUNT) identified by P_CODE_COMBINATION_ID.
--
-- Values returned as OUT parameters P_COST_CENTER and
-- P_ACCOUNT_SEGMENT_VALUE, respectively.
--
-- Author: Tim Ball
--------------------------------------------------------------------------
PROCEDURE RETURN_SEGMENTS(
              P_CODE_COMBINATION_ID     NUMBER,
              P_COST_CENTER             IN OUT NOCOPY VARCHAR2,
              P_ACCOUNT_SEGMENT_VALUE   IN OUT NOCOPY VARCHAR2,
              P_ERROR_MESSAGE           IN OUT NOCOPY VARCHAR2,
              P_CALLING_SEQUENCE        VARCHAR2) IS
  l_segments     FND_FLEX_EXT.SEGMENTARRAY;
  l_code_combination_id            NUMBER;
  l_num_segments             NUMBER;
  l_flex_segment_number      NUMBER;
  l_cc_flex_segment_number   NUMBER;
  l_chart_of_accounts_id     GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;
  l_debug_info               VARCHAR2(100);
  l_current_calling_sequence varchar2(2000);
BEGIN

  l_current_calling_sequence := 'AP_TIM_TEST_PKG.RETURN_SEGMENTS';

  --
  -- Proceed with building new CODE_COMBINATION_ID
  --

  --
  -- Initialize FND_GLOBAL.UserId to 5
  --


  /*bug 2872130, I am commenting the call to fnd_global below.
    According to the comments in the fnd_global package this call
    should not be made in a session from a form or report.  This
    package, AP_EXPENSE_FEED_DISTS_PKG, appears to only be called
    from a form.*/

  -- FND_GLOBAL.Apps_Initialize(5,0,200);

  ----------------------------------------
  l_debug_info := 'Get Chart of Accounts ID';
  ----------------------------------------
  select  GS.chart_of_accounts_id
  into    l_chart_of_accounts_id
  from    ap_system_parameters S,
          gl_sets_of_books GS
  where   GS.set_of_books_id = S.set_of_books_id;

  -----------------------------------------------
  l_debug_info := 'Get Cost Center Qualifier Segment Number';
  -----------------------------------------------
  IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                101,
                                'GL#',
                                l_chart_of_accounts_id,
                                'FA_COST_CTR',
                                l_cc_flex_segment_number)) THEN
    p_error_message := FND_MESSAGE.GET;
    return;
  END IF;

  -----------------------------------------------
  l_debug_info := 'Get Account Qualifier Segment Number';
  -----------------------------------------------
  IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                101,
                                'GL#',
                                l_chart_of_accounts_id,
                                'GL_ACCOUNT',
                                l_flex_segment_number)) THEN
    p_error_message := FND_MESSAGE.GET;
    return;
  END IF;

  -----------------------------------------------------------------
  l_debug_info := 'Get ccid account segments';
  -----------------------------------------------------------------
  if (nvl(P_CODE_COMBINATION_ID,-1) <> -1) then
    IF (NOT FND_FLEX_EXT.GET_SEGMENTS(
                                'SQLGL',
                                'GL#',
                                l_chart_of_accounts_id,
                                P_CODE_COMBINATION_ID,
                                l_num_segments,
                                l_segments)) THEN

      p_error_message := FND_MESSAGE.GET;
      return;
    END IF;
  end if;

  P_COST_CENTER := l_segments(l_cc_flex_segment_number);

  P_ACCOUNT_SEGMENT_VALUE := l_segments(l_flex_segment_number);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (SQLCODE = -54) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
      ELSE
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                  l_current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                'P_CODE_COMBINATION_ID = '||P_CODE_COMBINATION_ID
            ||', P_COST_CENTER = '||P_COST_CENTER
            ||', P_ACCOUNT_SEGMENT_VALUE = '||P_ACCOUNT_SEGMENT_VALUE
            ||', P_ERROR_MESSAGE = '||P_ERROR_MESSAGE
                                 );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END;

END AP_EXPENSE_FEED_DISTS_PKG;

/
