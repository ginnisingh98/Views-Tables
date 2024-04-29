--------------------------------------------------------
--  DDL for Package XXAH_SUPPLIER_TMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_SUPPLIER_TMP" AS
/**************************************************************************
 * VERSION      : $Id: XXAH_SUPPLIER.pks  2015-05-21 09:28:10 vema.reddy@atos.net $
 * DESCRIPTION  : Contains functionality for the Supplier xml payload send to OFMW
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 21-May-2015 Vema Reddy       Initial
 *************************************************************************/

   /**************************************************************************
   *
   * PROCEDURE
   *   order_booked
   *
   * DESCRIPTION
   *   Send XML Suplier Payload to OFMW with 500 milliseconds delay
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
--FUNCTION PUBLISH_PAYLOAD
--  ( P_SUBSCRIPTION_GUID IN RAW,
--   P_EVENT             IN OUT NOCOPY WF_EVENT_T
--  ) RETURN varchar2;
  PROCEDURE SUPP_XML_INTERFACE_TMP (errbuf          OUT VARCHAR2
  , retcode         OUT NUMBER);
  END XXAH_SUPPLIER_TMP; 

/
