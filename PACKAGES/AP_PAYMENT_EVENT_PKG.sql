--------------------------------------------------------
--  DDL for Package AP_PAYMENT_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PAYMENT_EVENT_PKG" AUTHID CURRENT_USER as
/* $Header: appevnts.pls 120.2 2005/08/31 15:14:05 rlandows noship $ */

PROCEDURE raise_event (p_check_id  IN  NUMBER,
                       p_org_id    IN  NUMBER);

PROCEDURE raise_payment_batch_events (p_checkrun_name           in VARCHAR2,
                                      p_checkrun_id             in number,
                                      p_completed_pmts_group_id in number,
                                      p_org_id                  in number );

END AP_PAYMENT_EVENT_PKG;

 

/
