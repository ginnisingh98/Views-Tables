--------------------------------------------------------
--  DDL for Package ENG_PROPAGATION_LOG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_PROPAGATION_LOG_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGVPRLS.pls 120.3 2005/12/12 02:21:00 lkasturi noship $ */

---------------------------------------------------------------
--  Propagation Processing Status constants                  --
---------------------------------------------------------------
G_PRP_PRC_STS_NOACTION CONSTANT NUMBER := 0;
G_PRP_PRC_STS_SUCCESS  CONSTANT NUMBER := 1;
G_PRP_PRC_STS_ERROR    CONSTANT NUMBER := 2;
G_PRP_PRC_STS_EXCLUDE  CONSTANT NUMBER := 3;
G_PRP_PRC_STS_EXCL_TTM CONSTANT NUMBER := 4;
---------------------------------------------------------------
--  Revised line type constants                              --
---------------------------------------------------------------

G_REV_LINE_CMP_CHG  CONSTANT VARCHAR2(20) := 'COMPONENT_CHANGE';
G_REV_LINE_ATCH_CHG CONSTANT VARCHAR2(20) := 'ATTACHMENT_CHANGE';
---------------------------------------------------------------
--  Map entity name  constants                               --
---------------------------------------------------------------

G_ENTITY_CHANGE       CONSTANT VARCHAR2(20) := 'ENG_CHANGE';
G_ENTITY_REVISED_ITEM CONSTANT VARCHAR2(20) := 'ENG_REVISED_ITEM';
G_ENTITY_REVISED_LINE CONSTANT VARCHAR2(20) := 'ENG_REVISED_LINE';

---------------------------------------------------------------
--  Log Type  constants                                      --
---------------------------------------------------------------
G_LOG_TYPE_INFO              CONSTANT VARCHAR2(10) := 'INFO';
G_LOG_TYPE_WARNING           CONSTANT VARCHAR2(10) := 'WARNING';
G_LOG_TYPE_ERROR             CONSTANT VARCHAR2(10) := 'ERROR';

---------------------------------------------------------------
--  Log   constants                                          --
---------------------------------------------------------------
G_LOG_PRINT                   CONSTANT NUMBER := 6;

G_LOG_ERROR                   CONSTANT NUMBER := 5;
G_LOG_EXCEPTION               CONSTANT NUMBER := 4;
G_LOG_EVENT                   CONSTANT NUMBER := 3;
G_LOG_PROCEDURE               CONSTANT NUMBER := 2;
G_LOG_STATEMENT               CONSTANT NUMBER := 1;

---------------------------------------------------------------
--  Record and Table definition                              --
---------------------------------------------------------------
TYPE Entity_Map_Log_Rec_Type IS RECORD (
    change_propagation_map_id     NUMBER
  , change_id                     NUMBER
  , revised_item_sequence_id      NUMBER
  , revised_line_type             eng_change_propagation_maps.revised_line_type%TYPE
  , revised_line_id1              eng_change_propagation_maps.revised_line_id1%TYPE
  , revised_line_id2              eng_change_propagation_maps.revised_line_id2%TYPE
  , revised_line_id3              eng_change_propagation_maps.revised_line_id3%TYPE
  , revised_line_id4              eng_change_propagation_maps.revised_line_id4%TYPE
  , revised_line_id5              eng_change_propagation_maps.revised_line_id5%TYPE
  , local_organization_id         NUMBER
  , local_change_id               NUMBER
  , local_revised_item_seq_id     NUMBER
  , local_revised_line_id1        eng_change_propagation_maps.local_revised_line_id1%TYPE
  , local_revised_line_id2        eng_change_propagation_maps.local_revised_line_id2%TYPE
  , local_revised_line_id3        eng_change_propagation_maps.local_revised_line_id3%TYPE
  , local_revised_line_id4        eng_change_propagation_maps.local_revised_line_id4%TYPE
  , local_revised_line_id5        eng_change_propagation_maps.local_revised_line_id5%TYPE
  , entity_name                   eng_change_propagation_maps.entity_name%TYPE
  , entity_action_status          NUMBER
  , message_list                  Error_Handler.Error_Tbl_Type
 );

TYPE Entity_Map_Log_Tbl_Type IS TABLE OF Entity_Map_Log_Rec_Type
    INDEX BY BINARY_INTEGER;

---------------------------------------------------------------
--  Exposed APIS begin here                                  --
---------------------------------------------------------------

PROCEDURE Write_Propagation_Log;

PROCEDURE Check_Entity_Map_Existance (
    p_change_id                IN NUMBER
  , p_entity_name              IN eng_change_propagation_maps.entity_name%TYPE
  , p_revised_item_sequence_id IN NUMBER := NULL
  , p_revised_line_type        IN eng_change_propagation_maps.revised_line_type%TYPE := NULL
  , p_revised_line_id1         IN eng_change_propagation_maps.revised_line_id1%TYPE := NULL
  , p_revised_line_id2         IN eng_change_propagation_maps.revised_line_id2%TYPE := NULL
  , p_revised_line_id3         IN eng_change_propagation_maps.revised_line_id3%TYPE := NULL
  , p_revised_line_id4         IN eng_change_propagation_maps.revised_line_id4%TYPE := NULL
  , p_revised_line_id5         IN eng_change_propagation_maps.revised_line_id5%TYPE := NULL
  , p_local_organization_id    IN NUMBER
  , x_change_map_id    OUT NOCOPY NUMBER
);

PROCEDURE Add_Entity_Map (
    p_change_id                 IN NUMBER
  , p_revised_item_sequence_id  IN NUMBER := NULL
  , p_revised_line_type         IN eng_change_propagation_maps.revised_line_type%TYPE := NULL
  , p_revised_line_id1          IN eng_change_propagation_maps.revised_line_id1%TYPE := NULL
  , p_revised_line_id2          IN eng_change_propagation_maps.revised_line_id2%TYPE := NULL
  , p_revised_line_id3          IN eng_change_propagation_maps.revised_line_id3%TYPE := NULL
  , p_revised_line_id4          IN eng_change_propagation_maps.revised_line_id4%TYPE := NULL
  , p_revised_line_id5          IN eng_change_propagation_maps.revised_line_id5%TYPE := NULL
  , p_local_organization_id     IN NUMBER
  , p_local_change_id           IN NUMBER := NULL
  , p_local_revised_item_seq_id IN NUMBER := NULL
  , p_local_revised_line_id1    IN eng_change_propagation_maps.local_revised_line_id1%TYPE := NULL
  , p_local_revised_line_id2    IN eng_change_propagation_maps.local_revised_line_id2%TYPE := NULL
  , p_local_revised_line_id3    IN eng_change_propagation_maps.local_revised_line_id3%TYPE := NULL
  , p_local_revised_line_id4    IN eng_change_propagation_maps.local_revised_line_id4%TYPE := NULL
  , p_local_revised_line_id5    IN eng_change_propagation_maps.local_revised_line_id5%TYPE := NULL
  , p_entity_name               IN eng_change_propagation_maps.entity_name%TYPE
  , p_entity_action_status      IN NUMBER
  , p_bo_entity_identifier      IN VARCHAR2
 );

PROCEDURE Initialize;

PROCEDURE Mark_Component_Change_Transfer (
    p_api_version              IN NUMBER
  , p_init_msg_list            IN VARCHAR2 := FND_API.G_FALSE        --
  , p_commit                   IN VARCHAR2 := FND_API.G_FALSE
  , x_return_status            OUT NOCOPY VARCHAR2                    --
  , x_msg_count                OUT NOCOPY NUMBER                      --
  , x_msg_data                 OUT NOCOPY VARCHAR2                    --
  , p_change_id                IN NUMBER
  , p_revised_item_sequence_id IN NUMBER
  , p_component_sequence_id    IN NUMBER
  , p_local_organization_id    IN NUMBER
 );

FUNCTION Get_Composite_Logs_For_Map (
    p_change_propagation_map_id IN NUMBER
) RETURN VARCHAR2;

PROCEDURE Debug_Log (
    p_priority IN  NUMBER
  , p_msg      IN  VARCHAR2
 );

-- bug 4704390
/******************************************************************************
* Procedure   : Get_Propagate_Action_Flag
* Parameters  :   p_conc_request_phase_code IN VARCHAR2
*               , p_entity_action_status    IN NUMBER
*               , p_global_change_id        IN NUMBER
*               , p_local_organization_id   IN NUMBER
*
* Purpose     : This function is used to fetch the propagate action flag to
*               determine if propagation is to be allowed or not for a given
*               header and a local organization.
*******************************************************************************/

FUNCTION Get_Propagate_Action_Flag (
    p_conc_request_phase_code IN VARCHAR2
  , p_entity_action_status    IN NUMBER
  , p_global_change_id        IN NUMBER
  , p_local_organization_id   IN NUMBER
)RETURN VARCHAR2;

END ENG_PROPAGATION_LOG_UTIL;

 

/
