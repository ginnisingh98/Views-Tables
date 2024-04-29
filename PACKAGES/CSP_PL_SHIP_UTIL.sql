--------------------------------------------------------
--  DDL for Package CSP_PL_SHIP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PL_SHIP_UTIL" AUTHID CURRENT_USER AS
/* $Header: cspgtpss.pls 115.6 2002/11/26 06:50:13 hhaugeru ship $ */
-- Start of comments
--
-- API name : CSP_PL_SHIP_UTIL
-- Type     : PUBLIC
-- Purpose  : Wrapper to handle material transactions when a packlist is shipped.
--
-- Modification History
-- Date        Userid    Comments
-- ---------   ------    ------------------------------------------
-- 01/04/99    klou      created
--
-- Note :
-- End of comments

  PROCEDURE Confirm_Ship (
         P_Api_Version_Number           IN   NUMBER,
          P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE,
          P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE,
          p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
          p_packlist_header_id           IN   NUMBER,
          p_organization_id              IN   NUMBER,
          x_return_status                OUT NOCOPY  VARCHAR2,
          x_msg_count                    OUT NOCOPY  NUMBER,
          x_msg_data                     OUT NOCOPY  VARCHAR2
    );

 Procedure Update_Packlist_Sts_Qty (
    P_Api_Version_Number IN   NUMBER,
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit             IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level   IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_organization_id    IN   NUMBER,
    p_packlist_line_id   IN   NUMBER,
    p_line_status        IN   VARCHAR2,
    p_quantity_packed    IN   NUMBER,
    p_quantity_shipped   IN   NUMBER,
    p_quantity_received  IN   NUMBER,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2
   );


   FUNCTION validate_pl_line_status (
        p_packlist_header_id IN  NUMBER,
        p_status_to_be_validated IN VARCHAR2,
        p_check_receipt_short    BOOLEAN := FALSE)
        RETURN VARCHAR2;


Procedure update_packlist_header_sts (
          P_Api_Version_Number           IN   NUMBER,
          P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE,
          P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE,
          p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
          p_packlist_header_id           IN NUMBER,
          p_organization_id              IN NUMBER,
          p_packlist_status              IN   VARCHAR2     := FND_API.G_MISS_CHAR,
          x_return_status                OUT NOCOPY  VARCHAR2,
          x_msg_count                    OUT NOCOPY  NUMBER,
          x_msg_data                     OUT NOCOPY  VARCHAR2

    );

END; -- Package spec

 

/
