--------------------------------------------------------
--  DDL for Package MSC_USER_DEFINED_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_USER_DEFINED_PK" AUTHID CURRENT_USER AS
/* $Header: MSCPUDPS.pls 120.0 2005/05/25 20:01:58 appldev noship $ */
PROCEDURE MSC_USER_DEFINED_SNAPSHOT_TASK(
                                arg_plan_id         IN NUMBER);
END MSC_USER_DEFINED_PK;
 

/
