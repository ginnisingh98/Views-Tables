--------------------------------------------------------
--  DDL for Package AMS_EVENT_OBJECTS_COPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_EVENT_OBJECTS_COPY_PVT" AUTHID CURRENT_USER as
/* $Header: amsveocs.pls 115.12 2004/03/05 07:05:14 vmodur ship $ */

    G_ATTRIBUTE_DETL  CONSTANT VARCHAR2(30) := 'DETL';-- already
    G_ATTRIBUTE_PROD    CONSTANT VARCHAR2(30) := 'PROD';-- already there
    G_ATTRIBUTE_CATG     CONSTANT VARCHAR2(30) := 'CATG';-- already
    G_ATTRIBUTE_ATCH      CONSTANT VARCHAR2(30) := 'ATCH';-- already
    G_ATTRIBUTE_MESG     CONSTANT VARCHAR2(30) := 'MESG';-- already
    G_ATTRIBUTE_RESC   CONSTANT VARCHAR2(30) := 'RESC';-- already
    G_ATTRIBUTE_AGEN   CONSTANT VARCHAR2(30) := 'AGEN';
    G_ATTRIBUTE_EVEO    CONSTANT VARCHAR2(30) := 'EVEO';
    G_ATTRIBUTE_PTNR    CONSTANT VARCHAR2(30) := 'PTNR';-- already
    G_ATTRIBUTE_CPNT    CONSTANT VARCHAR2(30) := 'CPNT';
    G_ATTRIBUTE_DELV    CONSTANT VARCHAR2(30) := 'DELV';
PROCEDURE copy_event_header (
   p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_source_object_id   IN NUMBER,
   p_attributes_table   IN AMS_CpyUtility_PVT.copy_attributes_table_type,
   p_copy_columns_table IN AMS_CpyUtility_PVT.copy_columns_table_type,
   x_new_object_id      OUT NOCOPY NUMBER,
   x_custom_setup_id    OUT NOCOPY NUMBER
);

PROCEDURE copy_event_header_agenda (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );
PROCEDURE copy_act_offers (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,

--      p_new_start_date IN       DATE,
--      p_new_end_date   IN	DATE,

      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );
PROCEDURE copy_act_delivery_method (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   );
FUNCTION get_agenda_name(p_agenda_id IN NUMBER)
      RETURN VARCHAR2;
FUNCTION get_offer_name(p_offer_id IN NUMBER)
      RETURN VARCHAR2;
END AMS_Event_Objects_Copy_PVT;

 

/
