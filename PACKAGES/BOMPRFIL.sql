--------------------------------------------------------
--  DDL for Package BOMPRFIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPRFIL" AUTHID CURRENT_USER as
/* $Header: BOMRFILS.pls 115.1 99/07/16 05:16:05 porting ship $ */

procedure bom_pr_get_profile(
                appl_short_name         IN      VARCHAR2,
                profile_name            IN      VARCHAR2,
                user_id                 IN      NUMBER,
                resp_appl_id            IN      NUMBER,
                resp_id                 IN      NUMBER,
                profile_value           OUT     VARCHAR2,
                return_code             OUT     NUMBER,
                return_message          OUT     VARCHAR2
);
END BOMPRFIL;

 

/
