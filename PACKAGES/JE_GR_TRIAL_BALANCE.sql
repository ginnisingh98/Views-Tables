--------------------------------------------------------
--  DDL for Package JE_GR_TRIAL_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_GR_TRIAL_BALANCE" AUTHID CURRENT_USER as
/* $Header: jegrftbs.pls 115.2 2002/11/12 12:03:36 arimai ship $ */

/*------------------------------------------------------------------+
 | Public Procedures/Functions                                      |
 +------------------------------------------------------------------*/

FUNCTION init_account_hierarchy (p_request_id        IN     NUMBER,
                                 p_delimiter         IN     VARCHAR2,
                                 p_retcode           IN OUT NOCOPY NUMBER,
                                 p_errmsg            IN OUT NOCOPY VARCHAR2)
RETURN NUMBER;


FUNCTION get_level_value  (p_level   IN     NUMBER,
                           p_account IN     VARCHAR2)
RETURN VARCHAR2;

pragma restrict_references (get_level_value, WNDS, WNPS);

/*------------------------------------------------------------------+
 | Global Variables                                                 |
 +------------------------------------------------------------------*/

/* The following record type will store each account's parents in L1 through L9.
   If for whatever reason an account doesn't have a parent, element "levels"
   will be 0 .*/

TYPE g_account_rec_type is RECORD (
	account		VARCHAR2(150),
	delimit_account	VARCHAR2(150),
	levels		NUMBER,
	L1			VARCHAR2(150),
	L2			VARCHAR2(150),
	L3			VARCHAR2(150),
	L4			VARCHAR2(150),
	L5			VARCHAR2(150),
	L6			VARCHAR2(150),
	L7			VARCHAR2(150),
	L8			VARCHAR2(150),
	L9			VARCHAR2(150));
TYPE g_account_tab_type is TABLE of g_account_rec_type
     index by BINARY_INTEGER;

g_account_tab 		g_account_tab_type;
g_idx  			NUMBER := 0;
g_request_id		NUMBER := 0;

END JE_GR_TRIAL_BALANCE;

 

/
