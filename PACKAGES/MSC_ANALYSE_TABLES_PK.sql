--------------------------------------------------------
--  DDL for Package MSC_ANALYSE_TABLES_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ANALYSE_TABLES_PK" AUTHID CURRENT_USER AS
    /* $Header: MSCANTBS.pls 115.5 2002/02/26 17:30:18 pkm ship   $ */

    PROCEDURE analyse;

    PROCEDURE analyse_table( p_table_name       IN VARCHAR2,
                             p_instance_id      IN NUMBER:= NULL,
                             p_plan_id          IN NUMBER:= NULL);

END MSC_ANALYSE_TABLES_PK;

 

/
