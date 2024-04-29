--------------------------------------------------------
--  DDL for Package IGC_CC_MPFS_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_MPFS_PROCESS_PKG" AUTHID CURRENT_USER as
/* $Header: IGCCMPSS.pls 120.4.12010000.2 2008/08/04 14:52:05 sasukuma ship $ */



/*==================================================================================
                             Function Get_Fiscal_Year
  =================================================================================*/

FUNCTION Get_Fiscal_Year(p_date IN DATE,
                         p_sob_id IN NUMBER)
RETURN number;

/*==================================================================================
                             Procedure MASS_PAYMENT_FORECAST_SHIFT_MAIN
  =================================================================================*/


PROCEDURE MPFS_MAIN				(errbuf			OUT NOCOPY	VARCHAR2,
 						 retcode		OUT NOCOPY	VARCHAR2,
						 p_PROCESS_PHASE	IN	VARCHAR2,
						 p_OWNER		IN	NUMBER,
						 p_START_DATE		IN	VARCHAR2,
						 p_END_DATE		IN	VARCHAR2,
						 p_TRANSFER_DATE	IN	VARCHAR2,
						 p_TARGET_DATE		IN	VARCHAR2,
						 p_THRESHOLD_VALUE	IN	NUMBER);

END IGC_CC_MPFS_PROCESS_PKG;

/
