--------------------------------------------------------
--  DDL for Package PA_REP_UTILS_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REP_UTILS_SUMM_PKG" AUTHID CURRENT_USER as
/* $Header: PARRSUMS.pls 115.3 2002/03/04 04:51:25 pkm ship     $ */

PROCEDURE populate_summ_entity(P_Balance_Type_Code IN VARCHAR2,
                               p_process_method    IN VARCHAR2);

END PA_REP_UTILS_SUMM_PKG;

 

/
