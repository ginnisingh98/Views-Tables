--------------------------------------------------------
--  DDL for Package CCT_MIDDLEWARE_PARAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_MIDDLEWARE_PARAM_PKG" AUTHID CURRENT_USER AS
/* $Header: cctmwses.pls 115.0 2003/05/20 17:48:49 rajayara noship $ */
PROCEDURE init;


PROCEDURE seed_param(
         P_MIDDLEWARE_TYPE_ID IN VARCHAR2,
         P_NAME IN VARCHAR2,
         P_TYPE IN VARCHAR2,
         P_LENGTH IN VARCHAR2,
         P_DOMAIN_LOOKUP_TYPE IN VARCHAR2
         );

PROCEDURE seed_param(
         P_MIDDLEWARE_PARAM_ID IN VARCHAR2,
         P_MIDDLEWARE_TYPE_ID IN VARCHAR2,
         P_NAME IN VARCHAR2,
         P_TYPE IN VARCHAR2,
         P_LENGTH IN VARCHAR2,
         P_ORDERING_SEQUENCE IN VARCHAR2,
         P_DOMAIN_LOOKUP_TYPE IN VARCHAR2
         );

Ordering_index number :=10;

END CCT_MIDDLEWARE_PARAM_PKG;

 

/
