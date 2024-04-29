--------------------------------------------------------
--  DDL for Package JL_BR_AP_VALIDATE_COLLECT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AP_VALIDATE_COLLECT_PUB" AUTHID CURRENT_USER as
/* $Header: jlbrcvps.pls 120.0.12010000.1 2009/11/19 11:20:52 mbarrett noship $ */

PROCEDURE validate_barcode(p_barcode    IN	        VARCHAR2
                          ,p_error_code IN OUT NOCOPY	VARCHAR2);
END JL_BR_AP_VALIDATE_COLLECT_PUB;

/
