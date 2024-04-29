--------------------------------------------------------
--  DDL for Package AP_CUSTOM_INV_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_CUSTOM_INV_VALIDATION_PKG" AUTHID CURRENT_USER AS
/*$Header: apcsvals.pls 120.0.12010000.1 2009/02/10 10:00:29 subehera noship $*/

PROCEDURE AP_Custom_Validation_Hook(
   P_Invoice_ID                     IN   NUMBER,
   P_Calling_Sequence               IN   VARCHAR2);

END AP_CUSTOM_INV_VALIDATION_PKG;

/
