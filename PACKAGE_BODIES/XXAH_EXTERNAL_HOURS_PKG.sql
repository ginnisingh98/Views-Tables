--------------------------------------------------------
--  DDL for Package Body XXAH_EXTERNAL_HOURS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_EXTERNAL_HOURS_PKG" AS
/* ************************************************************************
 * Copyright (c)  2009    Oracle Netherlands             De Meern
 * All rights reserved
 **************************************************************************
 *
 * FILENAME           : XXAH_EXTERNAL_HOURS_PKG.pkb
 * AITHOR             : Kevin Bouwmeester, Oracle NL Appstech
 * DESCRIPTION        : Package body with common functions for use
 *                      within the external employees hours export.
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

/* ************************************************************************
 * FUNCTION    :	submit_burst
 * DESCRIPTION :	submit the bursting request
 * PARAMETERS	 :	-
 *************************************************************************/
 FUNCTION submit_burst RETURN BOOLEAN
 IS
  l_result BOOLEAN;
  l_this_request_id NUMBER;
  l_req_id NUMBER;
 BEGIN
    Fnd_File.PUT_LINE(Fnd_File.LOG, TO_CHAR(SYSDATE,'HH24:MM:SS.MI') || ' - afterReport  submitting bursting request');

    -- call bursting JCP
    l_result := fnd_request.add_layout
    (    template_appl_name  => 'XDO'
    ,    template_code       => 'BURST_STATUS_REPORT'
    ,    template_language   => 'en'
    ,    template_territory  => 'US'
    ,    output_format       => 'PDF'
    );

    Fnd_File.PUT_LINE(Fnd_File.LOG, TO_CHAR(SYSDATE,'HH24:MM:SS.MI') || ' - afterReport  result of add layout');

    l_this_request_id := fnd_global.conc_request_id();

    Fnd_File.PUT_LINE(Fnd_File.LOG, TO_CHAR(SYSDATE,'HH24:MM:SS.MI') || ' - afterReport  this request id: ' || l_this_request_id);

    l_req_id := fnd_request.submit_request
    (    application    => 'XDO'
    ,    program        => 'XDOBURSTREP'
    ,    description    => 'Send external hours export'
    ,    argument1      => 'N'
    ,    argument2      => l_this_request_id
    ,    argument3      => 'Y'
    );

    Fnd_File.PUT_LINE(Fnd_File.LOG,TO_CHAR(SYSDATE,'HH24:MM:SS.MI') || ' - afterReport  request submitted: ' || l_req_id);

    RETURN TRUE;
 EXCEPTION
 WHEN OTHERS THEN
   RETURN FALSE;

 END submit_burst;

END XXAH_EXTERNAL_HOURS_PKG;

/
