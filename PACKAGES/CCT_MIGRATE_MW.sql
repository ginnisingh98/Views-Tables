--------------------------------------------------------
--  DDL for Package CCT_MIGRATE_MW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_MIGRATE_MW" AUTHID CURRENT_USER as
/* $Header: cctmigms.pls 115.3 2004/06/22 02:46:24 gvasvani noship $ */

procedure migrate_middleware(p_mw1_id IN NUMBER,p_mw2_id IN NUMBER,p_name IN VARCHAR2);
procedure delete_params(p_mw1_id IN NUMBER,p_mw2_id IN NUMBER, p_mw_id IN NUMBER );
procedure update_params(p_mw1_id IN NUMBER,p_mw2_id IN NUMBER, p_mw_id IN NUMBER );
procedure update_agent_params(p_mw1_id IN NUMBER,p_mw2_id IN NUMBER, p_mw_id IN NUMBER );

END CCT_MIGRATE_MW;

 

/
