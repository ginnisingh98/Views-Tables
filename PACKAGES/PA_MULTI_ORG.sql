--------------------------------------------------------
--  DDL for Package PA_MULTI_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MULTI_ORG" AUTHID CURRENT_USER AS
/* $Header: PAMORGS.pls 115.0 99/07/16 15:08:15 porting ship $ */

  PROCEDURE copy_seed_data ( x_rec_count  OUT NUMBER
                           , x_err_text   OUT VARCHAR2 );

END pa_multi_org;

 

/
