--------------------------------------------------------
--  DDL for Package ENG_CHANGE_COMMON_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_COMMON_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGUCMNS.pls 120.1 2006/09/08 12:13:49 ksathupa noship $ */

  FUNCTION Get_User_Party_Id
  ( p_user_name      IN VARCHAR2
  , x_err_text       OUT NOCOPY VARCHAR2
  )
  RETURN NUMBER;

FUNCTION Get_New_Ref_Designators(p_component_seq_id IN NUMBER)
RETURN VARCHAR2;

-- Added for 11.5.10E changes
FUNCTION GET_COMP_REVISION_FN(
  p_organization_id       IN NUMBER
, p_component_item_id     IN NUMBER
, p_item_revision_id      IN NUMBER)
RETURN VARCHAR2;

PROCEDURE process_attribute_defaulting(p_change_attr_def_tab   IN OUT NOCOPY ENG_CHANGE_ATTR_DEFAULT_TABLE
                                       ,p_commit              IN         VARCHAR2
                                       ,p_pk_val_name         IN        VARCHAR2
                                       ,p_pk_class_val_name   IN        VARCHAR2
                                       ,x_return_status       OUT NOCOPY VARCHAR2
                                       ,x_msg_data            OUT NOCOPY VARCHAR2
                                       ,x_msg_count           OUT NOCOPY  NUMBER);

END ENG_CHANGE_COMMON_UTIL;


 

/
