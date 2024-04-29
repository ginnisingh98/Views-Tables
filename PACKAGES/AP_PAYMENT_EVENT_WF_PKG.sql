--------------------------------------------------------
--  DDL for Package AP_PAYMENT_EVENT_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PAYMENT_EVENT_WF_PKG" AUTHID CURRENT_USER as
/* $Header: appewfps.pls 120.2 2008/05/12 06:49:42 abhsaxen ship $ */

PROCEDURE get_check_info  (p_item_type          IN VARCHAR2,
                           p_item_key           IN VARCHAR2,
                           p_actid              IN NUMBER,
                           p_funmode            IN VARCHAR2,
                           p_result             OUT NOCOPY VARCHAR2);

FUNCTION rule_function  (p_subscription in RAW,
                         p_event        in out NOCOPY WF_EVENT_T) return varchar2;

PROCEDURE get_remit_email_address (p_check_id       IN NUMBER,
                                   p_email_address OUT NOCOPY VARCHAR2) ;

END AP_PAYMENT_EVENT_WF_PKG;

/
