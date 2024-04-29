--------------------------------------------------------
--  DDL for Package QP_OA_DELAYED_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_OA_DELAYED_REQUESTS_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVJRES.pls 120.0 2005/06/02 01:35:19 appldev noship $ */

PROCEDURE Execute(requestTbl IN system.QP_FWK_DELAYED_REQ_TAB_OBJECT,
                  x_error_request_type OUT NOCOPY VARCHAR2,
                  x_error_entity_id  OUT NOCOPY NUMBER,
                  x_error_entity_code OUT NOCOPY VARCHAR2,
                  x_error_type    OUT NOCOPY VARCHAR2,
                  x_return_status OUT NOCOPY VARCHAR2,
                  x_return_status_text OUT NOCOPY VARCHAR2);

END QP_OA_Delayed_Requests_PVT;

 

/
