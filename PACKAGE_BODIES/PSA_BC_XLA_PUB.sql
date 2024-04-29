--------------------------------------------------------
--  DDL for Package Body PSA_BC_XLA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_BC_XLA_PUB" AS
--$Header: psapbcxb.pls 120.6 2006/06/26 13:05:12 bnarang noship $

G_PKG_NAME  CONSTANT  VARCHAR2(30)  :=  'PSA_BC_XLA_PUB';


---------------------------------------------------------------------------

--==========================================================================
--Logging Declarations
--==========================================================================
g_state_level NUMBER          :=    FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER          :=    FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER          :=    FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER          :=    FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER          :=    FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER          :=    FND_LOG.LEVEL_UNEXPECTED;
g_log_level   CONSTANT NUMBER         := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_path_name   CONSTANT VARCHAR2(200)  := 'psa.plsql.psapbcxb.psa_bc_xla_pub';
g_log_enabled BOOLEAN := FALSE;

--==========================================================================
-- declaring private constants
--==========================================================================

C_YES                       CONSTANT VARCHAR2(1)  := 'Y'; -- yes flag
C_NO                        CONSTANT VARCHAR2(1)  := 'N'; -- no flag
C_FUNDS_CHECK               CONSTANT VARCHAR2(1)   := 'C';
C_FUNDS_RESERVE             CONSTANT VARCHAR2(1)   := 'R';



 -- /*============================================================================
 -- API name     : Budgetary_Control
 -- Type         : public
 -- Pre-reqs     : Create events in psa_bc_xla_events_gt
 -- Description  :
 --                  This procedure calls private function which invokes the SLA online accounting engine.
 --                    All the events in the PSA_BC_XLA_EVENTS_GT would be
 --                    processed by accounitng engine.
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
 --                  x_packet_id      OUT  NUMBER
 -- Version      : Current Version 1.0
 --                  Initial Version 1.0
 --
 --
 --
 --  Logic
 --        - Validate the wf parameters
 --        - Get the events to be processed
 --        -  Call the SLA online accounting engine with required parameters
 --         -  Return the Fund status/error
 --
 --  Notes:
 --         Currently calling accounting eginge in document mode
 --          After SLA API for bcpsa is available need to make neccessary changes
 --
 --  Modification History
 --  Date         Author             Description of Change
 --
 -- *===========================================================================*/

PROCEDURE Budgetary_Control
   ( p_api_version               IN  NUMBER
    ,p_init_msg_list             IN  VARCHAR2
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
    ,p_application_id	         IN  INTEGER
    ,p_bc_mode                   IN  VARCHAR2
    ,p_override_flag             IN  VARCHAR2
    ,P_user_id                   IN  NUMBER
    ,P_user_resp_id              IN  NUMBER
    ,x_status_code                OUT NOCOPY VARCHAR2
    ,x_Packet_ID                 OUT NOCOPY NUMBER
   )


IS
l_api_name        VARCHAR2(240);
l_api_version     CONSTANT  NUMBER        :=  1.0;


BEGIN

 l_api_name :=  g_path_name || '.Budgetary_Control';
 psa_utils.debug_other_string(g_state_level,l_api_name,'Begin of Procedure Budgetary_Control');
 psa_utils.debug_other_string(g_state_level,l_api_name,'In parameters.. ');
 psa_utils.debug_other_string(g_state_level,l_api_name,'API Version =  ' || p_api_version);
 psa_utils.debug_other_string(g_state_level,l_api_name,'Application Id = '|| p_application_id);
 psa_utils.debug_other_string(g_state_level,l_api_name,'Budgetary Control Mode = '|| p_bc_mode);
 psa_utils.debug_other_string(g_state_level,l_api_name,'Override flag = '|| p_override_flag);
 psa_utils.debug_other_string(g_state_level,l_api_name,'User Id = '|| P_user_id);
 psa_utils.debug_other_string(g_state_level,l_api_name,'User Responsibility Id = '|| P_user_resp_id);

  IF (FND_API.to_boolean(NVl(p_init_msg_list,FND_API.G_FALSE))) THEN
    FND_MSG_PUB.initialize;
  END IF;

  psa_utils.debug_other_string(g_state_level,l_api_name,'Checking for API compatibility..');
  --
  --Standard call to check for call compatibility.
  --
  IF (NOT FND_API.compatible_api_call
                 (p_current_version_number => l_api_version
                 ,p_caller_version_number  => p_api_version
                 ,p_api_name               => l_api_name
                 ,p_pkg_name               => G_PKG_NAME))
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  --
  --  Initialize global variables
  --
  x_return_status        := FND_API.G_RET_STS_SUCCESS;

  --
  -- call the private function
  --
  psa_utils.debug_other_string(g_state_level,l_api_name,'Calling the Private API psa_bc_xla_pvt.Budgetary_control..');

  PSA_BC_XLA_PVT.Budgetary_control(p_init_msg_list  => NVl(p_init_msg_list,FND_API.G_FALSE)
                                  ,x_return_status  => x_return_status
                                  ,x_msg_count      => x_msg_count
                                  ,x_msg_data       => x_msg_data
                                  ,p_application_id	=> p_application_id
                                  ,p_bc_mode        => NVL(p_bc_mode,'C')
                                  ,p_override_flag  => NVL(p_override_flag,'N')
                                  ,P_user_id        => p_user_id
                                  ,P_user_resp_id   => P_user_resp_id
                                  ,x_status_code    => x_status_code
                                  ,x_Packet_ID      => x_Packet_ID );


   psa_utils.debug_other_string(g_state_level,l_api_name,'Call to Private API PSA_BC_XLA_PVT.Budgetary_control successful')   ;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
  psa_utils.debug_other_string(g_error_level,l_api_name,'EXCEPTION: '|| SQLERRM(sqlcode));
  psa_utils.debug_other_string(g_error_level,l_api_name,'Error in Budgetary_control Procedure' );
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.count_and_get(p_encoded => FND_API.G_FALSE
                             ,p_count => x_msg_count
                             ,p_data  => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  psa_utils.debug_other_string(g_unexp_level,l_api_name,'ERROR: Unexpected Error in budgetary_control Procedure' );
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.count_and_get(p_encoded => FND_API.G_FALSE
                             ,p_count => x_msg_count
                           ,p_data  => x_msg_data);

WHEN OTHERS THEN

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
    FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
  END IF;
   psa_utils.debug_other_string(g_unexp_level,l_api_name,'EXCEPTION: '|| SQLERRM(sqlcode));
   psa_utils.debug_other_string(g_unexp_level,l_api_name,'Error in budgetary_control Procedure' );
   FND_MSG_PUB.count_and_get(p_encoded => FND_API.G_FALSE
                             ,p_count => x_msg_count
                             ,p_data  => x_msg_data);


END Budgetary_control;


 /*============================================================================
 -- API name     : get_sla_notupgraded_flag
 -- Type         : public
 -- Pre-reqs     : None
 -- Description  : Returns Y/N depending on whether the distribution passed is notupgraded
 --
 --  Parameters  :
 --  IN          :
 --                  p_application_id 	IN NUMBER        Applied to Application ID
 --                  p_entity_code	IN VARCHAR2      Applied to Entity code
 --                  p_source_id_int_1	IN NUMBER        Applied to Header ID
 --                  p_dist_link_type 	IN VARCHAR2      Applied to Dist Link Type
 --                  p_distribution_id  IN NUMBER        Applied to Distribution ID
 --
 --  Returns     :   VARCHAR2 i.e., Y/N
 --
 --  Logic
 --        - If the transaction was created in transaction tables after R12 upgrade,
 --             return N
 --        - Else
 --             If the distribution was accounted in xla
 --                 return N;
 --             Else
 --                 return Y;
 --
 --  Notes:
 --         This is called from transaction objects and the return value is
 --         populated into a column that will be mapped to Upgrade option acct attrib
 --         in SLA.
 --
 --  Modification History
 --  Date               Author             Description of Change
 --  27-Oct-2005    Venkatesh N             Created
 -- ===========================================================================*/

 -- /*============================================================================
FUNCTION get_sla_notupgraded_flag (p_application_id 	IN NUMBER,
    				   p_entity_code	IN VARCHAR2,
				   p_source_id_int_1	IN NUMBER,
                                   p_dist_link_type 	IN VARCHAR2,
                                   p_distribution_id    IN NUMBER) RETURN VARCHAR2
IS
   l_return_val           VARCHAR2(1);
   l_path_name            VARCHAR2(500);

BEGIN

   l_path_name := g_path_name || '.get_sla_notupgraded_flag';
   psa_utils.debug_other_string(g_state_level,l_path_name,'BEGIN of ' || l_path_name);

   l_return_val := PSA_BC_XLA_PVT.get_sla_notupgraded_flag (p_application_id ,
    						                                p_entity_code,
   						                                    p_source_id_int_1,
                        	        	                    p_dist_link_type,
                                		                    p_distribution_id);

   psa_utils.debug_other_string(g_state_level,l_path_name,'END of ' || l_path_name);

  RETURN l_return_val;
EXCEPTION
	WHEN others THEN
        psa_utils.debug_other_string(g_error_level,l_path_name,'EXCEPTION: '|| SQLERRM(sqlcode));
        psa_utils.debug_other_string(g_error_level,l_path_name,'Error in get_sla_notupgraded_flag function' );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_sla_notupgraded_flag;

BEGIN
         g_log_enabled    := fnd_log.test
                            (log_level  => FND_LOG.G_CURRENT_RUNTIME_LEVEL
                            ,MODULE     => g_path_name);
END psa_bc_xla_pub;

/
