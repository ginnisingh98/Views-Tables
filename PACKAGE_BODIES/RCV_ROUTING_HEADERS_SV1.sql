--------------------------------------------------------
--  DDL for Package Body RCV_ROUTING_HEADERS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_ROUTING_HEADERS_SV1" AS
/* $Header: POXPIRHB.pls 115.0 99/07/17 01:50:26 porting ship $ */

/*===============================================================

   FUNCTION NAME : derive_routing_header_id()

================================================================*/
FUNCTION  derive_routing_header_id(X_routing_name IN VARCHAR2)
return NUMBER IS

  X_progress            varchar2(3)     := NULL;
  X_routing_header_id_v number        := NULL;

BEGIN

 X_progress := '010';

 /* get the routing_header_id from rcv_routing_headers table based
    on routing_name which is provided from input parameter */

 SELECT routing_header_id
   INTO X_routing_header_id_v
   FROM rcv_routing_headers
  WHERE routing_name = X_routing_name;

 RETURN X_routing_header_id_v;

EXCEPTION
   WHEN no_data_found THEN
        RETURN NULL;
   WHEN others THEN
        po_message_s.sql_error('derive_routing_header_id',X_progress, sqlcode);
        raise;

END derive_routing_header_id;

END RCV_ROUTING_HEADERS_SV1;

/
