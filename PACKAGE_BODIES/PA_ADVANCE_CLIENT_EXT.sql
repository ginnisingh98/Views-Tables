--------------------------------------------------------
--  DDL for Package Body PA_ADVANCE_CLIENT_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ADVANCE_CLIENT_EXT" AS
/*  $Header: PAAGADCB.pls 120.1 2006/11/21 05:35:04 rkchoudh noship $  */



-------------------------------------------------------------------------------
--  Client extension

PROCEDURE advance_required(
        p_customer_id                   IN      NUMBER,
        x_advance_flag                  OUT     NOCOPY boolean,
        x_error_message                 OUT     NOCOPY Varchar2,
        x_status                        OUT     NOCOPY NUMBER
        )
IS
BEGIN
   x_status := 0;
   x_error_message := NULL;
   x_advance_flag := FALSE;

END advance_required;

END PA_ADVANCE_CLIENT_EXT;

/
