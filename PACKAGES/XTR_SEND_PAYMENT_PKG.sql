--------------------------------------------------------
--  DDL for Package XTR_SEND_PAYMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_SEND_PAYMENT_PKG" AUTHID CURRENT_USER as
/* $Header: xtrspays.pls 120.0.12010000.2 2008/08/06 10:44:57 srsampat ship $ */


PROCEDURE get_notification_data (p_item_type          IN VARCHAR2,
                                 p_item_key           IN VARCHAR2,
                                 p_actid              IN NUMBER,
                                 p_funmode            IN VARCHAR2,
                                 p_result             OUT NOCOPY VARCHAR2);

PROCEDURE submit_conc_program (p_item_type          IN VARCHAR2,
                               p_item_key           IN VARCHAR2,
                               p_actid              IN NUMBER,
                               p_funmode            IN VARCHAR2,
                               p_result             OUT NOCOPY VARCHAR2);

PROCEDURE wait_for_conc_program (p_item_type          IN VARCHAR2,
                               p_item_key           IN VARCHAR2,
                               p_actid              IN NUMBER,
                               p_funmode            IN VARCHAR2,
                               p_result             OUT NOCOPY VARCHAR2);

procedure raise_event(p_bank_transmission_id in NUMBER);

END XTR_SEND_PAYMENT_PKG;

/
