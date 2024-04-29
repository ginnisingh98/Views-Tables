--------------------------------------------------------
--  DDL for Package HR_BIS_ALERTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BIS_ALERTS" AUTHID CURRENT_USER AS
/* $Header: hrbistr.pkh 115.9 2002/10/17 10:32:18 cbridge ship $ */

PROCEDURE Calc_and_post_target_actuals
            ( p_target_id IN NUMBER
             ,p_DATE      IN DATE   DEFAULT SYSDATE);

PROCEDURE PROCESS_TARGET
            ( p_target_id IN NUMBER);
END;

 

/
