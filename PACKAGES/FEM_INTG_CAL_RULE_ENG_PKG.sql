--------------------------------------------------------
--  DDL for Package FEM_INTG_CAL_RULE_ENG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_INTG_CAL_RULE_ENG_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_intg_cal_eng.pls 120.1 2005/06/08 21:01:20 appldev  $ */

  PROCEDURE Main(
    x_errbuf               OUT NOCOPY  VARCHAR2,
    x_retcode              OUT NOCOPY VARCHAR2,
    p_cal_rule_obj_def_id  IN NUMBER,
    p_period_set_name      IN VARCHAR2,
    p_period_type          IN VARCHAR2,
    p_period_year          IN NUMBER
  );

END FEM_INTG_CAL_RULE_ENG_PKG;

 

/
