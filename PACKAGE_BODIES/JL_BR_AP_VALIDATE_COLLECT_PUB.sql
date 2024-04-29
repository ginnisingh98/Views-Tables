--------------------------------------------------------
--  DDL for Package Body JL_BR_AP_VALIDATE_COLLECT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AP_VALIDATE_COLLECT_PUB" as
/* $Header: jlbrcvpb.pls 120.0.12010000.1 2009/11/19 11:29:30 mbarrett noship $ */

PROCEDURE validate_barcode(p_barcode    IN	        VARCHAR2
                          ,p_error_code IN OUT NOCOPY	VARCHAR2) IS
BEGIN
   p_error_code := 0;
END validate_barcode;

END JL_BR_AP_VALIDATE_COLLECT_PUB;

/
