--------------------------------------------------------
--  DDL for Package XXAH_VA_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_VA_INTERFACE_PKG" AS
/**************************************************************************
 * VERSION      : $Id: XXAH_VA_INTERFACE_PKG.pks 53 2015-01-08 08:28:10Z marc.smeenge@oracle.com $
 * DESCRIPTION  : Contains functionality for the Vendor Allowance Integration
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 5-NOV-2010 Joost Voordouw    Initial
 *************************************************************************/

   /**************************************************************************
   *
   * PROCEDURE
   *   order_booked
   *
   * DESCRIPTION
   *   Send journal entry (AES Accrual) or invoice (AES Invoice) to Accounting Plaza
   *
   * PARAMETERS
   * ==========
   * NAME              TYPE           DESCRIPTION
   * ----------------- -------------  --------------------------------------
   * errbuf            OUT            output buffer for error messages
   * retcode           OUT            return code for concurrent program
   *
   * PREREQUISITES
   *   List prerequisites to be satisfied
   *
   * CALLED BY
   *   List caller of this procedure
   *
   *************************************************************************/
  FUNCTION order_booked
  ( p_subscription_guid IN RAW
  , p_event             IN OUT NOCOPY WF_EVENT_T
  ) RETURN VARCHAR2;

  PROCEDURE order_booked_cp
  ( errbuf          OUT VARCHAR2
  , retcode         OUT NUMBER
  , p_header_id  IN oe_order_headers_all.header_id%TYPE
  );

  PROCEDURE order_xface_cp
  ( errbuf       OUT VARCHAR2
  , retcode      OUT NUMBER
  , p_type       IN VARCHAR2
  , p_request_id IN fnd_concurrent_requests.request_id%TYPE
  );

END XXAH_VA_INTERFACE_PKG;

/
