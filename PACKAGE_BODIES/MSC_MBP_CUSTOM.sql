--------------------------------------------------------
--  DDL for Package Body MSC_MBP_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_MBP_CUSTOM" AS
/* $Header: MSCMBPCB.pls 120.0 2005/05/25 19:15:55 appldev noship $  */

        PROCEDURE Custom_Post_Processing (
                p_plan_id       IN              NUMBER
        ) IS

        -- Enter the procedure variables here.
        BEGIN

                -- Enter the custom code here.
                NULL;

        EXCEPTION
                WHEN others THEN
                    NULL;

        END Custom_Post_Processing;

END MSC_MBP_CUSTOM;

/
