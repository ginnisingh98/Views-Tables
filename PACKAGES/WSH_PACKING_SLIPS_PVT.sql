--------------------------------------------------------
--  DDL for Package WSH_PACKING_SLIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PACKING_SLIPS_PVT" AUTHID CURRENT_USER AS
-- $Header: WSHPSTHS.pls 115.4 2002/11/12 01:48:59 nparikh ship $

PROCEDURE update_Row
  ( p_api_version               IN  NUMBER
    , p_init_msg_list             IN  VARCHAR2
    , p_commit                    IN  VARCHAR2
    , p_validation_level          IN  NUMBER
    , x_return_status             OUT NOCOPY  VARCHAR2
    , x_msg_count                 OUT NOCOPY  NUMBER
    , x_msg_data                  OUT NOCOPY  VARCHAR2
    , p_entity_name               IN  VARCHAR2
    , p_entity_id                 IN  NUMBER
    , p_document_type             IN  VARCHAR2
    , p_reason_of_transport       IN  VARCHAR2
    , p_description               IN  VARCHAR2
    , p_document_number           IN  VARCHAR2
  );



PROCEDURE insert_row
  (x_return_status             IN OUT NOCOPY  VARCHAR2,
   x_msg_count                 IN OUT NOCOPY  VARCHAR2,
   x_msg_data                  IN OUT NOCOPY  VARCHAR2,
   p_entity_name               IN     VARCHAR2,
   p_entity_id                 IN     NUMBER,
   p_application_id            IN     NUMBER,
   p_location_id               IN     NUMBER,
   p_document_type             IN     VARCHAR2,
   p_document_sub_type         IN     VARCHAR2,
   p_reason_of_transport       IN     VARCHAR2,
   p_description               IN     VARCHAR2,
   x_document_number           IN OUT NOCOPY  VARCHAR2);


PROCEDURE delete_row
  ( p_api_version                 IN  NUMBER
    , p_init_msg_list             IN  VARCHAR2
    , p_commit                    IN  VARCHAR2
    , p_validation_level          IN  NUMBER
    , x_return_status             OUT NOCOPY  VARCHAR2
    , x_msg_count                 OUT NOCOPY  NUMBER
    , x_msg_data                  OUT NOCOPY  VARCHAR2
    , p_entity_id                 IN  NUMBER
    , p_document_type             IN  VARCHAR2
    , p_document_number           IN  VARCHAR2
    );


--  Procedure:    Get_Disabled_List
--
--  Parameters:   p_delivery_id -- delivery the detail is assigned to
--                p_list_type --
--				 'FORM', will return list of form field names
--                   'TABLE', will return list of table column names
--                x_return_status  -- return status for execution of this API
-- 					x_disabled_list -- list of disabled field names
--                x_msg_count -- number of error message
--                x_msg_data  -- error message if API failed
--
PROCEDURE Get_Disabled_List(
  p_delivery_id               IN    NUMBER
, p_list_type                 IN    VARCHAR2
, x_return_status             OUT NOCOPY    VARCHAR2
, x_disabled_list             OUT NOCOPY    WSH_UTIL_CORE.column_tab_type
, x_msg_count                 OUT NOCOPY    NUMBER
, x_msg_data                  OUT NOCOPY    VARCHAR2
);


END WSH_PACKING_SLIPS_PVT;

 

/
