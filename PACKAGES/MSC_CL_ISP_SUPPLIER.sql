--------------------------------------------------------
--  DDL for Package MSC_CL_ISP_SUPPLIER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_ISP_SUPPLIER" AUTHID CURRENT_USER AS
/* $Header: MSCXISPS.pls 115.0 2002/05/21 22:41:56 pkm ship        $ */

    FUNCTION GET_PO_VENDOR_ID (p_user_name IN VARCHAR2) return NUMBER;

END;

 

/
