--------------------------------------------------------
--  DDL for Package CSTACDLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTACDLS" AUTHID CURRENT_USER AS
/* $Header: CSTACDLS.pls 115.3 2002/11/08 01:05:47 awwang ship $ */

PROCEDURE DELETE_SUMMARY_DETAILS(
 i_org_id               IN      NUMBER,
 i_del_period_id        IN      NUMBER,
 err_num                OUT NOCOPY    NUMBER,
 err_code               OUT NOCOPY    VARCHAR2,
 err_msg                OUT NOCOPY    VARCHAR2);

END CSTACDLS;

 

/
