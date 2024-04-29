--------------------------------------------------------
--  DDL for Package Body IGI_DOS_CHECK_LIMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_DOS_CHECK_LIMIT" AS
-- $Header: igidosab.pls 120.6 2007/06/08 07:02:25 vkilambi ship $

PROCEDURE Set_hold (p_invoice_id 	IN 	VARCHAR2,
                    p_user_id           IN      NUMBER)   IS
BEGIN
 NULL;
END  Set_hold;

PROCEDURE inv_limit (p_invoice_id 	IN 	VARCHAR2,
                     p_sob_id   	IN 	NUMBER,
                     p_user_id          IN      NUMBER) IS
BEGIN
 NULL;
END inv_limit;

END IGI_DOS_CHECK_LIMIT;

/
