--------------------------------------------------------
--  DDL for Package HXC_ABS_INTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ABS_INTG_PKG" AUTHID CURRENT_USER as
/* $Header: hxcabsint.pkh 120.1.12010000.6 2009/10/13 15:18:17 sabvenug noship $ */

g_one_day                      NUMBER  := (  1
                                             - 1 / 24 / 3600
                                          );


PROCEDURE otl_timecard_chk(p_person_id		IN 	NUMBER,
			   p_start_time		IN	DATE,
			   p_stop_time		IN	DATE,
			   p_error_code		OUT NOCOPY    VARCHAR2,
			   p_error_level	OUT NOCOPY	NUMBER,
			   p_abs_att_id		IN	NUMBER	DEFAULT -1);


end;

/
