--------------------------------------------------------
--  DDL for Package CSTPWCPX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPWCPX" AUTHID CURRENT_USER AS
/* $Header: CSTPCPXS.pls 120.0 2005/05/25 06:12:27 appldev noship $ */

FUNCTION CMLCPX (
    i_group_id          IN    NUMBER,
    i_org_id            IN    NUMBER,
    i_transaction_type  IN    NUMBER,
    i_user_id           IN    NUMBER,
    i_login_id          IN    NUMBER,
    i_prg_appl_id       IN    NUMBER,
    i_prg_id            IN    NUMBER,
    i_req_id            IN    NUMBER,
    err_buf             OUT NOCOPY   VARCHAR2)
RETURN INTEGER;

END CSTPWCPX;

 

/
