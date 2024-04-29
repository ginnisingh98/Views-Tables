--------------------------------------------------------
--  DDL for Package WSH_ITM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHITPCS.pls 120.0.12010000.1 2008/07/29 06:14:07 appldev ship $ */


        PROCEDURE WSH_ITM_WSH (
                               p_request_control_id IN  NUMBER,
                               p_request_set_id IN NUMBER
                               );

END;

/
