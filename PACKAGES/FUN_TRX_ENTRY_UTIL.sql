--------------------------------------------------------
--  DDL for Package FUN_TRX_ENTRY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_TRX_ENTRY_UTIL" AUTHID CURRENT_USER AS
--  $Header: funtrxentryutils.pls 120.7 2004/11/10 06:01:23 panaraya noship $

/****************************************************************
* FUNCTION  : get_concatenated_accounted			*
*								*
*	This function returns the concatenated segments  for a 	*
*	transaction type name given ccid			*
****************************************************************/

	FUNCTION get_concatenated_account
	(
	  p_ccid in NUMBER
	) RETURN VARCHAR2;

/****************************************************************
* FUNCTION  : get_ledger_id             			*
*								*
*	This function returns the ledger_id for a       	*
*	intercompany organization       			*
****************************************************************/

	FUNCTION get_ledger_id
	(
	  p_party_id IN NUMBER,
          p_party_type IN Varchar2
	) RETURN NUMBER;

/****************************************************************
* FUNCTION  : get_default_ccid          		    *
*						                *
*	This function returns the default intercompany account (ccid)*
* for an initiator/recipient combination       		    *
****************************************************************/

	FUNCTION get_default_ccid
	(
	  p_from_le_id IN NUMBER,
          p_to_le_id   IN NUMBER,
          p_type       IN VARCHAR2
	) RETURN NUMBER;

/****************************************************************
* FUNCTION  : log_debug          		    *
*						                *
*	This procedure calls fnd_log to log debug messages      *
****************************************************************/

	PROCEDURE log_debug
	(
      p_log_level IN VARCHAR2 default null,
	  p_module    IN VARCHAR2,
      p_message   IN VARCHAR2

	);

END FUN_TRX_ENTRY_UTIL;

 

/
