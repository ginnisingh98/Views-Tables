--------------------------------------------------------
--  DDL for Package XLE_ASSOCIATIONS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_ASSOCIATIONS_INFO" AUTHID CURRENT_USER AS
/* $Header: xleasins.pls 120.2 2005/09/22 06:07:16 rbasker ship $ */

TYPE Tab_Assoc IS TABLE OF XLE_ASSOCIATIONS.SUBJECT_ID%TYPE;

PROCEDURE Get_Associations_Info(

  --   *****  Standard API parameters *****
  p_init_msg_list    IN  VARCHAR2,
  p_commit           IN  VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,


  --   *****  Legal Association information parameters *****
  p_context          IN  XLE_ASSOCIATION_TYPES.Context%TYPE,
  p_object_type      IN  XLE_ASSOC_OBJECT_TYPES.Name%TYPE,
  p_subject_type     IN  XLE_ASSOC_OBJECT_TYPES.Name%TYPE,
  p_legal_entity_id  IN  XLE_ASSOCIATIONS.SUBJECT_PARENT_ID%TYPE,
  p_object_id        IN  XLE_ASSOCIATIONS.Object_Id%TYPE,
  p_subject_id       IN  XLE_ASSOCIATIONS. Subject_Id%TYPE,
  p_assocs           OUT NOCOPY Tab_assoc);


END XLE_ASSOCIATIONS_INFO;


 

/
