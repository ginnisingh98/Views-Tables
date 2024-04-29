--------------------------------------------------------
--  DDL for Package CSTPWPVR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPWPVR" AUTHID CURRENT_USER AS
/* $Header: CSTPWPVS.pls 115.3 2002/11/11 22:28:38 awwang ship $ */

FUNCTION REPVAR (
    i_org_id          IN    NUMBER,
    i_close_period_id IN    NUMBER,
    i_user_id         IN    NUMBER,
    i_login_id        IN    NUMBER,
    err_buf           OUT NOCOPY   VARCHAR2)
RETURN INTEGER;

END CSTPWPVR;

 

/
