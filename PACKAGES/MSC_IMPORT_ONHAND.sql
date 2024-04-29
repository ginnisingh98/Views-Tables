--------------------------------------------------------
--  DDL for Package MSC_IMPORT_ONHAND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_IMPORT_ONHAND" AUTHID CURRENT_USER AS
/* $Header: MSCIOHDS.pls 120.1 2005/06/21 02:47:54 appldev ship $  */
PROCEDURE Import_Onhand(
			ERRBUF              OUT NOCOPY VARCHAR2,
			RETCODE             OUT NOCOPY NUMBER,
			v_req_id            IN  NUMBER);

FUNCTION get_onhand(
			arg_plan_id   IN NUMBER,
			arg_org_id    IN NUMBER,
			arg_instance  IN NUMBER,
			arg_item_id   IN NUMBER) return NUMBER;
END MSC_IMPORT_ONHAND;

 

/
