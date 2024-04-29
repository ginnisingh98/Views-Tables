--------------------------------------------------------
--  DDL for Package QP_LIMIT_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_LIMIT_TRANSACTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVLTDS.pls 120.0 2005/06/02 01:14:19 appldev noship $ */

--GLOBAL Constant holding the package name

G_PKG_NAME		 CONSTANT  VARCHAR2(30) := 'QP_LIMIT_TRANSACTIONS_PVT';

/*Procedure to Delete Limit Transactions conditionally */
PROCEDURE Delete(p_pricing_event_code IN  VARCHAR2,
                 x_return_status      OUT NOCOPY VARCHAR2);

END QP_LIMIT_TRANSACTIONS_PVT;

 

/
