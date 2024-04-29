--------------------------------------------------------
--  DDL for Package Body IGI_DOS_THRESHOLD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_DOS_THRESHOLD" AS
-- $Header: igidosfb.pls 120.3.12000000.1 2007/06/08 09:49:01 vkilambi ship $

 FUNCTION Po_threshold
    ( document_id IN NUMBER)
 RETURN BOOLEAN
 IS
 BEGIN
    return TRUE;
 END;

END IGI_DOS_THRESHOLD;

/
