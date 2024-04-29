--------------------------------------------------------
--  DDL for Package PA_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERIODS_PKG" AUTHID CURRENT_USER AS
/* $Header: PASUCPSS.pls 120.2 2005/09/14 16:30:44 sbharath noship $ */

  PROCEDURE copy_periods ( P_Org_Id       IN NUMBER DEFAULT NULL
                         , x_rec_count   OUT NOCOPY NUMBER
                         , x_err_text    OUT NOCOPY VARCHAR2 );

  PROCEDURE copy_from_glperiods ( P_Org_Id       IN NUMBER DEFAULT NULL
                                , x_rec_count   OUT NOCOPY NUMBER
                                , x_err_text    OUT NOCOPY VARCHAR2 );

  /*Bug# 3271356 :Added function check_gl_period_used_in_pa    */
  FUNCTION check_gl_period_used_in_pa( p_period_name     IN  VARCHAR2,
                                       p_period_set_name IN VARCHAR2) RETURN VARCHAR2;

END pa_periods_pkg;

 

/
