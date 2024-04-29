--------------------------------------------------------
--  DDL for Package MSC_CL_POST_PUBLISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_POST_PUBLISH" AUTHID CURRENT_USER AS
/* $Header: MSCXPODS.pls 115.4 2003/10/23 01:29:26 yptang ship $ */

G_EXCEP_TYPES CONSTANT varchar2(2000) := ' IN (1,2,3,4,7,8,9,10,11,29,30,31,13,14,15,23,24,27,28,33,34,43,44,45,46,47,48,12,32,16,23, 49,50, 51)';
G_EXCEP_GROUPS CONSTANT varchar2(2000) := ' IN (1,2,4,6,7,8)';
G_DUPLICATE_EXCEP_TYPES CONSTANT varchar2(2000) := ' IN (1,2,3,4,7,8,11,12,13,14,15,16,23,24,27,28,31,32,33,34,49,50, 51)';
TYPE number_arr IS TABLE of NUMBER;
G_SUCCESS                    CONSTANT NUMBER := 0;
G_WARNING                    CONSTANT NUMBER := 1;
G_ERROR                      CONSTANT NUMBER := 2;


PROCEDURE POST_CLEANUP(p_org_str IN VARCHAR2,
					   p_lrtype  IN VARCHAR2,
                       p_status	OUT NOCOPY NUMBER);

PROCEDURE UPDATE_EXCEPTION_SUMMARY(p_summary_status OUT NOCOPY NUMBER);

END;

 

/
