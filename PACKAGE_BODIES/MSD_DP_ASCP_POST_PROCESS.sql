--------------------------------------------------------
--  DDL for Package Body MSD_DP_ASCP_POST_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DP_ASCP_POST_PROCESS" AS
/* $Header: msddappb.pls 120.0 2005/05/25 19:59:20 appldev noship $ */

procedure launch(p_plan_id in NUMBER,
                 p_calc_liability in NUMBER) IS

l_request_id number;

BEGIN

  IF p_calc_liability = 1 THEN

    l_request_id := 0;
    l_request_id:=  FND_REQUEST.SUBMIT_REQUEST(
                             'MSD',
                             'MSDRLF',
                             NULL,  -- description
                             NULL,  -- start date
                             FALSE, -- TRUE,
                             p_plan_id);

       COMMIT;
   END IF;

END launch;

END MSD_DP_ASCP_POST_PROCESS;

/
