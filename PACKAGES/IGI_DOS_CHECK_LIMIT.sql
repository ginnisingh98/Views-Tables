--------------------------------------------------------
--  DDL for Package IGI_DOS_CHECK_LIMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_DOS_CHECK_LIMIT" AUTHID CURRENT_USER AS
-- $Header: igidosas.pls 120.3.12000000.1 2007/06/08 08:17:45 vkilambi ship $

PROCEDURE Set_hold (p_invoice_id 	IN 	VARCHAR2,
                    p_user_id           IN      NUMBER);

PROCEDURE inv_limit (p_invoice_id 	IN 	VARCHAR2,
                     p_sob_id   	IN 	NUMBER,
                     p_user_id          IN      NUMBER);

END IGI_DOS_CHECK_LIMIT;

 

/
