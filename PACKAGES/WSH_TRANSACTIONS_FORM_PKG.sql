--------------------------------------------------------
--  DDL for Package WSH_TRANSACTIONS_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRANSACTIONS_FORM_PKG" AUTHID CURRENT_USER as
/* $Header: WSHINFMS.pls 120.0.12010000.1 2008/07/29 06:11:14 appldev ship $ */

C_SDEBUG              CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL1;
C_DEBUG               CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL2;


PROCEDURE   Process_form( P_delivery_id    IN NUMBER,
                          P_trip_id        IN NUMBER,
                          P_transaction_id IN NUMBER,
			  X_Return_Status    OUT NOCOPY  VARCHAR2) ;
END WSH_TRANSACTIONS_FORM_PKG;

/
