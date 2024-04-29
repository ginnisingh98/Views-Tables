--------------------------------------------------------
--  DDL for Package ENG_NEW_ITEM_REQ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_NEW_ITEM_REQ_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGUNIRS.pls 120.3 2007/04/09 09:27:29 sdarbha ship $ */

  PROCEDURE Create_New_Item_Request
  (
    x_return_status     OUT NOCOPY VARCHAR2,
    change_number       IN VARCHAR2, --10
    change_name         IN VARCHAR2, --240
    change_type_code    IN VARCHAR2, --80
    item_number         IN VARCHAR2, --240
    organization_code   IN VARCHAR2, --3
    requestor_user_name IN VARCHAR2, --100
    batch_id            IN NUMBER := null
  ) ;


  -- Added in R12
  -- Item API will put returned NIR change id
  -- to Item Open Interface table
  PROCEDURE Create_New_Item_Request
  (
    x_return_status     OUT NOCOPY VARCHAR2,
    x_change_id         OUT NOCOPY NUMBER,
    change_number       IN VARCHAR2, --10
    change_name         IN VARCHAR2, --240
    change_type_code    IN VARCHAR2, --80
    item_number         IN VARCHAR2, --240
    organization_code   IN VARCHAR2, --3
    requestor_user_name IN VARCHAR2, --100
    batch_id            IN NUMBER := null
  ) ;


PROCEDURE CREATE_NEW_ITEM_REQUESTS(P_BATCH_ID           IN         NUMBER,
                                   P_NIR_OPTION         IN         VARCHAR2,
                                    x_return_status     OUT NOCOPY VARCHAR2,
                                    x_msg_data          OUT NOCOPY VARCHAR2,
                                    x_msg_count         OUT NOCOPY NUMBER);
END ENG_NEW_ITEM_REQ_UTIL;

/
