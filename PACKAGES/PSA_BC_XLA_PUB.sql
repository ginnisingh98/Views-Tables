--------------------------------------------------------
--  DDL for Package PSA_BC_XLA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_BC_XLA_PUB" AUTHID CURRENT_USER as
--$Header: psapbcxs.pls 120.2 2005/10/28 14:34:58 vnoothig noship $

 -- /*============================================================================
 -- API name     : Budgetary_Control
 -- Type         : public
 -- Pre-reqs     : Create events in psa_bc_xla_events_gt
 -- Description  :
 --                  Public sector budgetary control package budgetary control
 --                  is the main procedure which product would use for funds check,
 --   	 		     the procedure validates the parameters and calls the private
 --   				 function, which invokes the SLA online accounting engine and return
 --   				 the funds status to caller.
 --
 -- Version      : Current Version 1.0
 --                  Initial Version 1.0
 --  Parameters  :
 --  IN          :   p_api_version    IN NUMBER  Required
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
 --                 x_packet_id      OUT  NUMBER
 -- /*============================================================================

PROCEDURE Budgetary_Control
   ( p_api_version               IN  NUMBER
    ,p_init_msg_list             IN  VARCHAR2  DEFAULT NULL
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

END psa_bc_xla_pub; -- Package spec

 

/
