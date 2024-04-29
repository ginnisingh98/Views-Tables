--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_DEF_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_DEF_ATTR" AUTHID CURRENT_USER AS
/* $Header: INVDEFSS.pls 120.0 2005/05/25 05:07:05 appldev noship $ */
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVDEFSS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Spec. of INV_MGD_MVT_DEF_ATTR                                     |
--|                                                                       |
--|                                                                       |
--| HISTORY                                                               |
--|     04/01/2000 pseshadr     Created                                   |
--|     12/04/2002 vma          Default_Attr: added NOCOPY to x_return_sta|
--|                             tus, x_msg_count, x_msg data. Change the  |
--|                             other OUT parameters to IN OUT NOCOPY     |
--|                             parameters. This is to comply with new    |
--|                             PL/SQL standards for better performance.  |
--|    03/17/2005 yawang        Add new program for default movement amt  |
--|                             stat_ext_value, document price and vlaue  |
--+======================================================================*/

--========================================================================
-- PROCEDURE : Default_Attr
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_movement_transaction  IN Movement Statistics Record Type
--             x_transaction_nature    IN OUT Transaction Nature
--             x_delivery_terms        IN OUT Delivery Terms
--             x_area                  IN OUT Area where goods arrive/depart
--             x_Port                  IN OUT Port where goods arrive/depart
--             x_csa_code              IN OUT Csa code
--             x_oil_reference_code    IN OUT Used in oil industry
--             x_container_type_code   IN OUT Container Type
--             x_flow_indicator_code   IN OUT Used in the oil industry
--             x_affiliation_reference_code
--             x_taric_code            IN OUT Taric Code
--             x_preference_code       IN OUT Preference Code
--             x_statistical_procedure_code   IN OUT Statistical Procedure Code
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              message text
-- COMMENT   : This is the callout procedure which is called before
--             inserting records into MVt Stats table to default some of the
--             attributes if the user wanted to define their own values.
--========================================================================

PROCEDURE Default_Attr
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_movement_transaction IN
    Inv_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_transaction_nature         IN OUT NOCOPY VARCHAR2
, x_delivery_terms             IN OUT NOCOPY VARCHAR2
, x_area                       IN OUT NOCOPY VARCHAR2
, x_port                       IN OUT NOCOPY VARCHAR2
, x_csa_code                   IN OUT NOCOPY VARCHAR2
, x_oil_reference_code         IN OUT NOCOPY VARCHAR2
, x_container_type_code        IN OUT NOCOPY VARCHAR2
, x_flow_indicator_code        IN OUT NOCOPY VARCHAR2
, x_affiliation_reference_code IN OUT NOCOPY VARCHAR2
, x_taric_code                 IN OUT NOCOPY VARCHAR2
, x_preference_code            IN OUT NOCOPY VARCHAR2
, x_statistical_procedure_code IN OUT NOCOPY VARCHAR2
, x_transport_mode             IN OUT NOCOPY VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Default_Value
-- PARAMETERS: p_api_version_number       known api version
--             p_init_msg_list            FND_API.G_TRUE to reset list
--             p_movement_transaction     IN Movement Statistics Record Type
--             x_document_unit_price      IN OUT Unit price on SO/PO
--             x_document_line_ext_value  IN OUT Line value on SO/PO
--             x_movement_amount          IN OUT Movement amount
--             x_stat_ext_value           IN OUT Statistics value
--             x_return_status            return status
--             x_msg_count                number of messages in the list
--             x_msg_data                 message text
-- COMMENT   : This is the callout procedure which is called before
--             inserting records into MVt Stats table to default some of the
--             values if the user wanted to define their own.
--========================================================================

PROCEDURE Default_Value
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_movement_transaction IN
    Inv_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_document_unit_price        IN OUT NOCOPY NUMBER
, x_document_line_ext_value    IN OUT NOCOPY NUMBER
, x_movement_amount            IN OUT NOCOPY NUMBER
, x_stat_ext_value             IN OUT NOCOPY NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
);



END INV_MGD_MVT_DEF_ATTR;

 

/
