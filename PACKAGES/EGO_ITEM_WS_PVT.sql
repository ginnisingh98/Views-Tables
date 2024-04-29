--------------------------------------------------------
--  DDL for Package EGO_ITEM_WS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_WS_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVIWSS.pls 120.0.12010000.6 2009/08/14 12:32:02 nendrapu noship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : EGOVIWSS.pls                                               |
| DESCRIPTION  : This file contains the procedures required for             |
|    Item Web service.                                                      |
|                                                                           |
|                                                                           |
+==========================================================================*/

---------------------------------------------------------------
-- Global Variables and Constants --
---------------------------------------------------------------
G_CURRENT_USER_ID          NUMBER := FND_GLOBAL.User_Id;
G_CURRENT_LOGIN_ID         NUMBER := FND_GLOBAL.Login_Id;


PROCEDURE POPULATE_AGS(sessionId IN NUMBER,
                      odisessionId IN NUMBER,
                      dataLevelId IN NUMBER
                      );

PROCEDURE POPULATE_GTIN_DETAILS(sessionId IN NUMBER,
                              odisessionId IN NUMBER
                              );

PROCEDURE POPULATE_Transaction_Attrs(sessionId IN NUMBER,
                              odisessionId IN NUMBER
                              );

PROCEDURE Invocation_Mode ( p_session_id    IN  NUMBER,
                            p_odi_session_id IN NUMBER,
                            p_search_str    IN  VARCHAR2,
                            x_mode          OUT NOCOPY VARCHAR2,
                            x_batch_id      OUT NOCOPY NUMBER  );

PROCEDURE  process_bom_explosions(p_session_id    IN  NUMBER,
                              p_odi_session_id IN NUMBER,
															p_index			IN NUMBER,
                              pk1_value   IN VARCHAR2 ,
                              pk2_value   IN varchar2,
                              pk3_value   IN varchar2,
                              rev_date    IN Date,
                              alternate_desg  IN VARCHAR2  DEFAULT NULL,
                              levels_explode  IN NUMBER DEFAULT 60,
                              explode_option  IN NUMBER,
                              explode_std_bom IN VARCHAR2, -- Bug 8752314 : CMR Change
                              group_id        OUT NOCOPY NUMBER,
                              x_error_code    OUT NOCOPY VARCHAR2 ,
                              x_error_message OUT NOCOPY VARCHAR2
                              );

PROCEDURE Preprocess_Item_Input(p_session_id   IN NUMBER,
                                p_odi_session_id  IN NUMBER );

PROCEDURE process_configurations(p_session_id       IN  NUMBER,
                                p_odi_session_id    IN  NUMBER);

PROCEDURE process_non_batch_flow(p_session_id    IN  NUMBER,
    p_odi_session_id IN NUMBER,
    p_exists_inv_id IN NUMBER,
    p_exists_inv_name IN NUMBER,
    p_exists_org_id IN NUMBER,
    p_exists_org_code IN  NUMBER,
    p_exists_rev_id IN NUMBER,
    p_exists_revision IN NUMBER,
    p_exists_rev_date IN NUMBER ,
    p_mode OUT NOCOPY VARCHAR2
    );

FUNCTION  Validate_Item(p_session_id    IN  NUMBER,
      p_odi_session_id IN NUMBER,
      p_inv_id in number,
      p_org_id in NUMBER ,
      p_segment1 in varchar2,
      p_segment2 in varchar2,
      p_segment3 in varchar2,
      p_segment4 in varchar2,
      p_segment5 in varchar2,
      p_segment6 in varchar2,
      p_segment7 in varchar2,
      p_segment8 in varchar2,
      p_segment9 in varchar2,
      p_segment10 in varchar2,
      p_segment11 in varchar2,
      p_segment12 in varchar2,
      p_segment13 in varchar2,
      p_segment14 in varchar2,
      p_segment15 in varchar2,
      p_segment16 in varchar2,
      p_segment17 in varchar2,
      p_segment18 in varchar2,
      p_segment19 in varchar2,
      p_segment20 in varchar2,
      p_index in number,
      p_inv_item_id OUT NOCOPY number
      ) RETURN BOOLEAN;

 function Validate_organization(p_session_id    IN  NUMBER,
              p_odi_session_id IN NUMBER,
              p_org_id in NUMBER ,
              p_org_code IN VARCHAR2,
              p_index in number,
              p_organization_id OUT NOCOPY number
              )  RETURN BOOLEAN;

function validate_revision_details(p_session_id    IN  NUMBER,
              p_odi_session_id IN NUMBER,
              p_inv_id IN NUMBER,
              p_org_id IN NUMBER,
              p_rev_id in NUMBER ,
              p_revision IN varchar2,
              p_rev_date IN DATE,
              p_index in number,
              p_revision_id OUT NOCOPY NUMBER ,
              p_revision_date OUT NOCOPY DATE
              )  RETURN BOOLEAN;


function validate_structure_name(p_session_id    IN  NUMBER,
              p_odi_session_id IN NUMBER,
              p_org_id IN NUMBER,
              p_structure_name IN varchar2,
							p_input_id		IN	NUMBER
              )  RETURN BOOLEAN ;


PROCEDURE check_security(p_session_id IN  NUMBER,
                          p_odi_session_id IN NUMBER,
                          p_priv_check IN  VARCHAR2,
                          p_for_exploded_items IN VARCHAR2,
                          x_return_status OUT NOCOPY  VARCHAR2
                         );

/* Bug 8659248 : Added the Below procedure for getting the security details of the
  user who is publishing the Items */
PROCEDURE Init_Security_details(p_session_id IN NUMBER,
            p_odi_session_id IN NUMBER,
						p_return_status	OUT NOCOPY VARCHAR2);


PROCEDURE POPULATE_SEGMENTS(p_session_id    IN  NUMBER,
                        p_odi_session_id IN NUMBER,
                        p_segment1 in varchar2,
                        p_segment2 in varchar2,
                        p_segment3 in varchar2,
                        p_segment4 in varchar2,
                        p_segment5 in varchar2,
                        p_segment6 in varchar2,
                        p_segment7 in varchar2,
                        p_segment8 in varchar2,
                        p_segment9 in varchar2,
                        p_segment10 in varchar2,
                        p_segment11 in varchar2,
                        p_segment12 in varchar2,
                        p_segment13 in varchar2,
                        p_segment14 in varchar2,
                        p_segment15 in varchar2,
                        p_segment16 in varchar2,
                        p_segment17 in varchar2,
                        p_segment18 in varchar2,
                        p_segment19 in varchar2,
                        p_segment20 in varchar2,
                        p_index in number );

PROCEDURE POPULATE_REVISION_DETAILS(p_session_id    IN  NUMBER,
                        p_odi_session_id IN NUMBER,
                        p_rev_id NUMBER,
                        p_revision VARCHAR,
                        p_rev_date DATE,
                        p_index NUMBER);

END EGO_ITEM_WS_PVT;

/
