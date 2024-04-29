--------------------------------------------------------
--  DDL for Package Body GMS_CLIENT_EXTN_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_CLIENT_EXTN_PO" AS
/* $Header: gmspoceb.pls 120.0 2005/09/12 10:19:42 aaggarwa noship $ */

  function allow_internal_req return varchar2  is
   l_allow_internal_req varchar2(1) ;
  begin

    l_allow_internal_req := 'N' ;

    -- Customer can uncomment the following code to support
    -- internal requisitions.
    -- l_allow_internal_req := 'Y' ;

    return l_allow_internal_req ;

  end allow_internal_req ;

END gms_client_extn_po;

/
