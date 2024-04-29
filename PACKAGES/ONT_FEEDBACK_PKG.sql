--------------------------------------------------------
--  DDL for Package ONT_FEEDBACK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_FEEDBACK_PKG" AUTHID CURRENT_USER AS
/* $Header: ONTWFCS.pls 120.1 2006/04/26 18:04:23 chhung noship $*/
   PROCEDURE init_wf(p_recipient IN VARCHAR2,
                     p_name     IN VARCHAR2,
                     p_email    IN VARCHAR2,
                     p_comments IN VARCHAR2,
                     p_feedback IN VARCHAR2,
                     p_phone    IN VARCHAR2
                     );

   PROCEDURE init_wf2(p_recipient IN VARCHAR2,
                     p_name     IN VARCHAR2,
                     p_email    IN VARCHAR2,
                     p_comments IN VARCHAR2,
                     p_phone    IN VARCHAR2,
                     p_ordernum IN VARCHAR2,
                     p_shipnum  IN VARCHAR2,
                     p_lot      IN VARCHAR2,
                     p_products IN VARCHAR2,
                     p_shipdate IN VARCHAR2
                     );

   PROCEDURE init_wf3(p_notifier IN VARCHAR2,
                     p_name     IN VARCHAR2,
                     p_email    IN VARCHAR2,
                     p_comments IN VARCHAR2,
                     p_ordernum IN VARCHAR2,
                     p_linenum  IN VARCHAR2,
                     p_quantity IN VARCHAR2,
                     p_products IN VARCHAR2,
                     p_phone    IN VARCHAR2) ;

END ONT_FEEDBACK_PKG;

 

/
