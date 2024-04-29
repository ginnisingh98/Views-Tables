--------------------------------------------------------
--  DDL for Package XXAH_EXTERNAL_HOURS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_EXTERNAL_HOURS_PKG" AS
/* ************************************************************************
 * Copyright (c)  2009    Oracle Netherlands             De Meern
 * All rights reserved
 **************************************************************************
 *
 * FILENAME           : XXAH_EXTERNAL_HOURS_PKG.pkb
 * AITHOR             : Kevin Bouwmeester, Oracle NL Appstech
 * DESCRIPTION        : Package body with common functions for use
 *                      within the external employees hours report.
 * LAST UPDATE DATE   : 16-DEC-2009
 *
 * HISTORY
 * =======
 *
 * VER  DATE         AUTHOR(S)          DESCRIPTION
 * ---  -----------  -----------------  -----------------------------------
 * 1.0  16-DEC-2009  Kevin Bouwmeester  Genesis
 *
 *************************************************************************/

 P_PERIOD_NAME VARCHAR2(30);

/* ************************************************************************
 * PROCEDURE   :	submit_burst
 * DESCRIPTION :	submit the bursting request
 * PARAMETERS	 :	p_conc_request_id - concurrent request id
 *************************************************************************/
 FUNCTION submit_burst RETURN BOOLEAN;

END XXAH_EXTERNAL_HOURS_PKG;
 

/
