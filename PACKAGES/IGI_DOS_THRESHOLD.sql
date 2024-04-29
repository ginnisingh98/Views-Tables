--------------------------------------------------------
--  DDL for Package IGI_DOS_THRESHOLD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_DOS_THRESHOLD" AUTHID CURRENT_USER AS
-- $Header: igidosfs.pls 120.3.12000000.1 2007/06/08 09:49:32 vkilambi ship $

FUNCTION PO_THRESHOLD
     ( DOCUMENT_ID IN number
      )
     RETURN  boolean;

END IGI_DOS_THRESHOLD;

 

/
