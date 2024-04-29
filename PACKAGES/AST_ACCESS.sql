--------------------------------------------------------
--  DDL for Package AST_ACCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_ACCESS" AUTHID CURRENT_USER AS
/* $Header: astuaccs.pls 115.2 2002/12/04 22:40:42 gkeshava noship $ */

  -- declare and initialize the access record type
  G_Access_Rec_Type AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE := AS_API_RECORDS_PKG.GET_P_ACCESS_PROFILE_REC;

  PROCEDURE Initialize;

  PROCEDURE Has_Create_LeadOppAccess
  ( p_admin_flag         VARCHAR2,
    p_opplead_ident      VARCHAR2,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2
  );

  PROCEDURE Has_UpdateLeadAccess
  ( p_sales_lead_id      NUMBER,
    p_admin_flag         VARCHAR2,
    p_admin_group_id     NUMBER,
    p_person_id          NUMBER,
    p_resource_id        NUMBER,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2
  );

  PROCEDURE Has_LeadOwnerAccess
  ( p_sales_lead_id      NUMBER,
    p_admin_flag         VARCHAR2,
    p_admin_group_id     NUMBER,
    p_person_id          NUMBER,
    p_resource_id        NUMBER,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2
  );

  PROCEDURE Has_UpdateOpportunityAccess
  ( p_lead_id      		 NUMBER,
    p_admin_flag         VARCHAR2,
    p_admin_group_id     NUMBER,
    p_person_id          NUMBER,
    p_resource_id        NUMBER,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2
  );

END AST_ACCESS; -- End package specification AST_ACCESS

 

/
