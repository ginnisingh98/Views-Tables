--------------------------------------------------------
--  DDL for Package POS_SUPPLIER_NOTIFY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPPLIER_NOTIFY_PKG" AUTHID CURRENT_USER AS
/* $Header: POSSNTFS.pls 120.0.12010000.6 2013/01/23 20:32:45 atjen noship $ */

PROCEDURE supplier_notification
(   p_msg_subject   IN VARCHAR2,
    p_msg_body      IN VARCHAR2,
    p_msg_recipient IN VARCHAR2,
    p_msg_osn       IN VARCHAR2,
    p_notify_list   IN VARCHAR2
);

END POS_SUPPLIER_NOTIFY_PKG;

/
