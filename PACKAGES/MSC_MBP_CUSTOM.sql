--------------------------------------------------------
--  DDL for Package MSC_MBP_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_MBP_CUSTOM" AUTHID CURRENT_USER AS
/* $Header: MSCMBPCS.pls 120.0 2005/05/25 19:18:45 appldev noship $  */

PROCEDURE Custom_Post_Processing (
        p_plan_id       IN              NUMBER
);

END MSC_MBP_CUSTOM;

 

/
