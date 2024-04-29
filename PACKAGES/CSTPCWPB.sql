--------------------------------------------------------
--  DDL for Package CSTPCWPB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPCWPB" AUTHID CURRENT_USER AS
/* $Header: CSTPWPBS.pls 120.0.12000000.1 2007/01/17 12:23:58 appldev ship $ */

FUNCTION WIPCBR (
    i_org_id                      NUMBER,
    i_user_id                     NUMBER,
    i_login_id                    NUMBER,
    i_from_period_id              NUMBER,
    err_buf                OUT NOCOPY    VARCHAR2)
RETURN INTEGER;

END CSTPCWPB;

 

/
