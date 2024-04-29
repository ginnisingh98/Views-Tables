--------------------------------------------------------
--  DDL for Package AS_SALES_LEAD_AGING_WF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEAD_AGING_WF_PUB" AUTHID CURRENT_USER AS
/* $Header: asxslags.pls 115.2 2002/11/06 00:49:54 appldev ship $ */

TYPE sales_lead_rec_type IS RECORD
(
  SALES_LEAD_ID NUMBER,
  CREATION_DATE DATE,
  ASSIGN_DATE   DATE,
  ACCEPT_FLAG   VARCHAR2(1),
  STATUS_CODE   VARCHAR2(30)
);



PROCEDURE StartSalesLeadAgingProcess(
    p_request_id            IN NUMBER,
    p_sales_lead_id         IN NUMBER,
    p_assigned_resource_id  IN NUMBER,
    p_aging_days_noact      IN NUMBER,
    p_aging_days_abandon    IN NUMBER,
    p_aging_abandon_actions IN VARCHAR2,
    p_aging_noact_actions   IN VARCHAR2,
    x_item_type             OUT VARCHAR2,
    x_item_key              OUT VARCHAR2,
    x_return_status	        OUT VARCHAR2);


PROCEDURE DetermineStartFromProcess(
    itemtype      in VARCHAR2,
    itemkey       in VARCHAR2,
    actid         in NUMBER,
    funcmode      in VARCHAR2,
    result        out VARCHAR2 );

END AS_SALES_LEAD_AGING_WF_PUB;


 

/
