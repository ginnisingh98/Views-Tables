--------------------------------------------------------
--  DDL for Package CST_BIS_ALERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_BIS_ALERT" AUTHID CURRENT_USER AS
/* $Header: CSTBIALS.pls 115.2 99/08/05 13:22:23 porting  $ */

procedure Alert_Check( p_measure_short_name in varchar2 );

END CST_BIS_ALERT;

 

/
