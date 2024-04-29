--------------------------------------------------------
--  DDL for Package MSC_X_EX5_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_EX5_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCXEX5S.pls 115.2 2003/07/23 23:50:48 jguo ship $ */

PROCEDURE Compute_VMI_Exceptions ( p_refresh_number IN Number
                                 , p_replenish_time_fence IN NUMBER
                                 );

PROCEDURE clean_up_process;

  PROCEDURE print_debug_info(
    p_debug_info IN VARCHAR2
  );

  PROCEDURE print_user_info(
    p_user_info IN VARCHAR2
  );

END MSC_X_EX5_PKG;


 

/
