--------------------------------------------------------
--  DDL for Package PSA_BC_XLA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_BC_XLA_PVT" AUTHID CURRENT_USER AS
--$Header: psavbcxs.pls 120.3.12010000.2 2009/12/18 14:39:32 sasukuma ship $
---------------------------------------------------------------------------


   G_BC_MODE          VARCHAR(1);
   G_OVERRIDE_FLAG    VARCHAR2(1);
   G_USER_ID          NUMBER;
   G_USER_RESP_ID     NUMBER;
   G_APPLICATION_ID   NUMBER;
   G_PACKET_ID        NUMBER;


 -- /*============================================================================
 -- API name     : Budgetary_Control
 -- Type         : private
 -- Pre-reqs     : Create events in psa_bc_xla_events_gt
 -- Description  : Invokes the SLA accounting engine for BCPSA
 --
 --
 --
 --  Parameters  :
 --  IN          :
 --                  p_init_msg_list  IN VARCHAR2 optional Default FND_API.G_FALSE
 --                  p_commit         IN VARCHAR2 optional Default FND_API.G_FALSE
 --                  p_application_id IN NUMBER  Required
 --                  p_bc_mode        IN NUMBER optional Possible values:Check(C )
 --                                               /Reserve(R)/partial(P)/Force pass(F)
 --                  p_bc_override_flag VARCHAR2 optional Possible values: Y/N
 --                  p_user_id        IN NUMBER optional
 --                  p_user_resp_id   IN NUMBER optional
 --
 -- OUT          :   x_return_status  OUT VARCHAR2(1)
 --                  x_msg_count      OUT NUMBER
 --                  x_msg_data       OUT VARCHAR2(2000)
 --                  x_status_code    OUT
 --                  x_packet_id      OUT  NUMBER
 -- /*============================================================================

PROCEDURE Budgetary_Control
   ( p_init_msg_list             IN  VARCHAR2 DEFAULT NULL
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
    ,p_application_id	         IN INTEGER
    ,p_bc_mode                   IN VARCHAR2 DEFAULT  NULL
    ,p_override_flag             IN VARCHAR2 DEFAULT  NULL
    ,P_user_id                   IN NUMBER   DEFAULT  NULL
    ,P_user_resp_id              IN NUMBER   DEFAULT  NULL
    ,x_status_code               OUT NOCOPY  VARCHAR2
    ,x_Packet_ID                 OUT NOCOPY NUMBER
   );


-- /*============================================================================
 -- API name     : get_sla_notupgraded_flag
 -- Type         : private
 -- Pre-reqs     : None
 -- Description  : Returns Y/N depending on whether the distribution passed is notupgraded
 --
 --  Parameters  :
 --  IN          :
 --                  p_application_id 	IN NUMBER        Applied to Application ID
 --                  p_entity_code		IN VARCHAR2      Applied to Entity code
 --                  p_source_id_int_1	IN NUMBER        Applied to Header ID
 --                  p_dist_link_type 	IN VARCHAR2      Applied to Dist Link Type
 --                  p_distribution_id  IN NUMBER        Applied to Distribution ID
 --
 --  Returns     :   VARCHAR2 i.e., Y/N
 -- /*============================================================================



FUNCTION get_sla_notupgraded_flag (	p_application_id 	IN NUMBER,
    								p_entity_code		IN VARCHAR2,
    								p_source_id_int_1	IN NUMBER,
                                	p_dist_link_type 	IN VARCHAR2,
                                	p_distribution_id   IN NUMBER) RETURN VARCHAR2;
  PROCEDURE psa_xla_error
  (
    p_message_code IN VARCHAR2,
    p_event_id IN NUMBER DEFAULT NULL
  );

END PSA_BC_XLA_PVT; -- Package spec

/
