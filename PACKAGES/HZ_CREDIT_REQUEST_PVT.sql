--------------------------------------------------------
--  DDL for Package HZ_CREDIT_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CREDIT_REQUEST_PVT" AUTHID CURRENT_USER AS
-- $Header: OEXCRRQS.pls 120.0.12010000.1 2008/07/25 07:46:52 appldev ship $

----------------------------------------------------------------
--This is rule function, that is subscribed to the Oracle Workflow
-- Business Event CreditRequest.Recommendation.implement
--to implement recomendations of the AR CRedit Management Review
----------------------------------------------------------------
FUNCTION Rule_Credit_Recco_Impl
( p_subscription_guid IN            RAW
, p_event             IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;



END HZ_CREDIT_REQUEST_PVT;

/
