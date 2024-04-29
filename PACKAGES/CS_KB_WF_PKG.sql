--------------------------------------------------------
--  DDL for Package CS_KB_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: cskbwfs.pls 120.1 2005/08/12 16:24:05 mkettle noship $ */


FUNCTION getActionName(
    g_action            IN  VARCHAR2
    )
    RETURN VARCHAR2;

FUNCTION getFlowId(
    g_flow_details_id    IN  NUMBER
    )
    RETURN NUMBER;

FUNCTION getStatus(
   g_setId              IN  NUMBER
   )
   RETURN VARCHAR2;

FUNCTION getStepGroup(
  g_flow_details_id     IN NUMBER
  )
  RETURN NUMBER;

FUNCTION hasPermission(
  h_flow_details_id  IN  NUMBER,
  h_user_id  IN  NUMBER
  )
  RETURN NUMBER;

FUNCTION inCategory(
  c_user_id           IN  NUMBER,
  c_set_id            IN  NUMBER
  )
  RETURN NUMBER;

FUNCTION inProduct(
  c_user_id           IN  NUMBER,
  c_set_id            IN  NUMBER
  )
  RETURN NUMBER;

FUNCTION isMember(
  m_user_id           IN NUMBER,
  m_group_id          IN NUMBER
  )
  RETURN NUMBER;

PROCEDURE End_Wf(
  p_itemtype  IN VARCHAR2,
  p_itemkey   IN VARCHAR2,
  p_actid     IN NUMBER,
  p_funcmode  IN VARCHAR2,
  p_result    OUT NOCOPY VARCHAR2
  );

PROCEDURE Expire_Detail(
  p_flow_details_id IN NUMBER,
  p_result OUT NOCOPY NUMBER
  );

PROCEDURE Expire_Flow(
  p_flow_id IN NUMBER,
  p_result OUT NOCOPY NUMBER
  );

PROCEDURE Enable_Flow(
  p_flow_id IN NUMBER,
  p_result OUT NOCOPY NUMBER
  );

PROCEDURE Get_Actions(
  p_action_code OUT NOCOPY JTF_VARCHAR2_TABLE_100,
  p_action_name OUT NOCOPY JTF_VARCHAR2_TABLE_100
  );

PROCEDURE Get_All_Groups(
  p_group_id          OUT NOCOPY JTF_NUMBER_TABLE,
  p_group_name        OUT NOCOPY JTF_VARCHAR2_TABLE_100
  );

PROCEDURE Get_All_Steps(
  p_step          OUT NOCOPY JTF_VARCHAR2_TABLE_100,
  p_step_names    OUT NOCOPY JTF_VARCHAR2_TABLE_100
  );

PROCEDURE Get_Flow_Details(
  p_flow_id         IN NUMBER,
  p_flow_details_id OUT NOCOPY JTF_NUMBER_TABLE,
  p_order_num       OUT NOCOPY JTF_NUMBER_TABLE,
  p_step            OUT NOCOPY JTF_VARCHAR2_TABLE_100,
  p_group_id        OUT NOCOPY JTF_NUMBER_TABLE,
  p_action          OUT NOCOPY JTF_VARCHAR2_TABLE_100
  );

PROCEDURE Get_Flows(
  p_flow_id         OUT NOCOPY JTF_NUMBER_TABLE,
  p_flow_name       OUT NOCOPY JTF_VARCHAR2_TABLE_100
  );

PROCEDURE Get_Permissions(
  p_set_id          IN  NUMBER,
  p_user_id         IN  NUMBER,
  p_results         OUT NOCOPY NUMBER
  );

PROCEDURE Get_Permissions_for_PUB_soln(
  p_set_number      IN  VARCHAR2,
  p_user_id         IN  NUMBER,
  p_results         OUT NOCOPY NUMBER
  );

PROCEDURE Get_Step_List(
  p_restriction   IN  NUMBER DEFAULT 0,
  p_step          OUT NOCOPY JTF_VARCHAR2_TABLE_100,
  p_step_names    OUT NOCOPY JTF_VARCHAR2_TABLE_100
);

PROCEDURE Get_Next_Step(
  p_flow_details_id IN NUMBER,
  p_next_details_id OUT NOCOPY NUMBER
);

PROCEDURE Get_Prev_Step(
  p_flow_details_id IN NUMBER,
  p_next_details_id OUT NOCOPY NUMBER
);

PROCEDURE Insert_Flow(
  p_flow_name       IN VARCHAR2,
  p_flow_id         OUT NOCOPY NUMBER
  );

PROCEDURE Insert_Detail(
  p_flow_id         IN NUMBER,
  p_order_num       IN NUMBER,
  p_step            IN VARCHAR2,
  p_group_id        IN NUMBER,
  p_action          IN VARCHAR2,
  p_flow_details_id OUT NOCOPY NUMBER
  );

PROCEDURE Start_wf(
  p_set_number  IN VARCHAR2,
  p_set_id      IN NUMBER ,
  p_new_step    IN NUMBER ,
  p_results     OUT NOCOPY NUMBER,
  p_errormsg    OUT NOCOPY VARCHAR2
  );

PROCEDURE Start_wf_processing(
  p_itemtype        IN VARCHAR2,
  p_itemkey         IN VARCHAR2,
  p_actid           IN NUMBER,
  p_funcmode        IN VARCHAR2,
  p_result          OUT NOCOPY VARCHAR2
  );

PROCEDURE Create_Wf_Process(
  p_set_id          IN NUMBER,
  p_set_number      IN VARCHAR2,
  p_command         IN VARCHAR2,
  p_flow_details_id IN NUMBER,
  p_group_id        IN NUMBER,
  p_solution_title  IN VARCHAR2
  );

PROCEDURE Update_Detail(
  p_flow_details_id IN NUMBER,
  p_order_num       IN NUMBER,
  p_step            IN VARCHAR2,
  p_group_id        IN NUMBER,
  p_action          IN VARCHAR2,
  p_result          OUT NOCOPY NUMBER
  );


PROCEDURE Update_Flow(
  p_flow_id         IN NUMBER,
  p_flow_name       IN VARCHAR2,
  p_result          OUT NOCOPY NUMBER
  );

PROCEDURE Update_Flow_Admin(
  p_flow_id         IN NUMBER DEFAULT NULL,
  p_flow_name       IN VARCHAR2,
  p_result          OUT NOCOPY NUMBER
  );

/* This one calls Update_Detail_Admin (which deals with update/insert)
   Plus, it does Delete */
PROCEDURE Update_Detail_Admin(
    p_flow_details_id IN NUMBER DEFAULT NULL,
    p_flow_id         IN NUMBER,
    p_order_num       IN NUMBER,
    p_step            IN VARCHAR2,
    p_group_id        IN NUMBER,
    p_action          IN VARCHAR2,
    p_flag            IN VARCHAR2,
    p_result          OUT NOCOPY NUMBER
  );

PROCEDURE Add_Language;

FUNCTION IS_STEP_DISABLED ( P_FLOW_ID NUMBER,
                            P_FLOW_DETAILS_ID NUMBER,
                            P_FLOW_DETAILS_ORDER NUMBER,
                            P_CURRENT_FLOW_DETAILS_ID NUMBER) RETURN VARCHAR2;

-- Package Specification CS_KB_WF_PKG
END;

 

/
