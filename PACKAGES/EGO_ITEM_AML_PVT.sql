--------------------------------------------------------
--  DDL for Package EGO_ITEM_AML_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_AML_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVAMLS.pls 120.1 2005/10/06 03:10:07 srajapar noship $ */

  --
  --  Constants used for validation mode
  --
  MODE_HISTORICAL              VARCHAR2(30)  := 'HISTORICAL';
  MODE_NORMAL                  VARCHAR2(30)  := 'NORMAL';

-- ----------------------------------------------------------------------
--  API Name:	       Delete_AML_Interface_Lines
--
--  Type:            Public
--
--  Description:     To delete the interface records from AML Interface
--                   Table EGO_AML_INTF
--
-- Parameters:
--     IN    :
--        p_data_set_id        IN      NUMBER     The job number
--
--        p_delete_line_type   IN      NUMBER --  mandatory parameter
--              How the lines are to be processed in the interface table:
--              refer to the constants above for the parametere being passed
--
--  Atleast one of the above two parameters should be given else
--  the program will fail with insufficient parameters
--
--     OUT    :
--             x_return_status          OUT NOCOPY VARCHAR2
--             x_msg_count              OUT NOCOPY VARCHAR2
--             x_msg_data               OUT NOCOPY VARCHAR2
--
--  Version:		Current version 1.0
-- ----------------------------------------------------------------------

Procedure Delete_AML_Interface_Lines (
    p_api_version            IN  NUMBER
   ,p_commit                 IN  VARCHAR2
   ,p_data_set_id            IN  NUMBER
   ,p_delete_line_type       IN  NUMBER
   ,x_return_status         OUT  NOCOPY VARCHAR2
   ,x_msg_count             OUT  NOCOPY NUMBER
   ,x_msg_data              OUT  NOCOPY VARCHAR2
   );

-- ----------------------------------------------------------------------
--  API Name:	          Load_Interface_Lines
--
--  Type:               Public
--
--  Description:        To bulkload the API records into the Production
--                      and Pending changes table.
--
-- Parameters:
--     IN    :
--        p_data_set_id        IN      NUMBER     The job number
--
--        p_delete_line_type   IN      NUMBER --  mandatory parameter
--              How the lines are to be processed in the interface table:
--              refer to the constants above for the parametere being passed
--
--        p_mode               IN      VARCHAR2
--             Determines the mode of the program.  Allowable value sare
--                MODE_HISTORICAL
--                MODE_NORMAL
--             as defined in the specification
--
--        p_perform_security_check IN  VARCHAR2
--             Determines whether to perform security check
--              FND_API.G_TRUE allows you to perform security check
--              on all other values, security check is not performed.
--
--     OUT    :
--             ERRBUF                   OUT NOCOPY VARCHAR2
--             RETCODE                  OUT NOCOPY VARCHAR2
--
--  Version:		Current version 1.0
-- ----------------------------------------------------------------------
Procedure Load_Interface_Lines (
    ERRBUF                   OUT  NOCOPY VARCHAR2
   ,RETCODE                  OUT  NOCOPY VARCHAR2
   ,p_data_set_id             IN  NUMBER
   ,p_delete_line_type        IN  NUMBER
   ,p_mode                    IN  VARCHAR2
   ,p_perform_security_check  IN  VARCHAR2
   );

END EGO_ITEM_AML_PVT;


 

/
