--------------------------------------------------------
--  DDL for Package DOM_ASSOCIATIONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DOM_ASSOCIATIONS_UTIL" AUTHID CURRENT_USER as
/*$Header: DOMPASUS.pls 120.1 2006/09/05 15:15:40 dedatta noship $ */

Procedure Implement_Pending_Association(
        p_association_id        IN NUMBER  ,
        p_action                IN VARCHAR2,
        p_from_entity_name      IN VARCHAR2,
        p_from_pk1_value        IN VARCHAR2,
        p_from_pk2_value        IN VARCHAR2,
        p_from_pk3_value        IN VARCHAR2,
        p_from_pk4_value        IN VARCHAR2,
        p_from_pk5_value        IN VARCHAR2,
        p_to_entity_name        IN VARCHAR2,
        p_to_pk1_value          IN VARCHAR2,
        p_to_pk2_value          IN VARCHAR2,
        p_to_pk3_value          IN VARCHAR2,
        p_to_pk4_value          IN VARCHAR2,
        p_to_pk5_value          IN VARCHAR2,
        p_relationship_code     IN VARCHAR2,
	p_current_value         IN VARCHAR2,
        p_created_by            IN NUMBER,
        p_last_update_login     IN NUMBER,
        x_return_status       OUT  NOCOPY  VARCHAR2,
        x_msg_count           OUT  NOCOPY  NUMBER,
        x_msg_data            OUT  NOCOPY  VARCHAR2 )
;



END DOM_ASSOCIATIONS_UTIL;

 

/
