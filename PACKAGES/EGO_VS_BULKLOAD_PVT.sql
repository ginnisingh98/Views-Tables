--------------------------------------------------------
--  DDL for Package EGO_VS_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_VS_BULKLOAD_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVVSBS.pls 120.0.12010000.10 2010/06/11 13:40:01 yjain noship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : EGOVVSBS.pls                                               |
| DESCRIPTION  : This file is a packaged procedure for importing value set  |
|                and corresponding values using interface or concurrent     |
|                program route.                                             |
+==========================================================================*/



--  =================================================================================
--  Name        : Convert_Name_To_Id
--  Description : This procedure will be used to get a Id for a name for a given sub entity.
--
--
--  Parameters:
--        IN    :
--                Name                    IN          VARCHAR2
--                Sub entity name, for which Id has to be resolved.
--
--                Entity_Id               IN          Number
--
--
--                Parent_Id               IN          Number
--
--        OUT    :
--                Id                      OUT NOCOPY  VARCHAR2
--
--
--
--  ===============================================================================
Procedure Convert_Name_To_Id (
          Name                IN              VARCHAR2,
          Entity_Id           IN              NUMBER,
          Parent_Id           IN              NUMBER  DEFAULT NULL, -- Here Parent Id will be Id of parent entity for a sub entity.
          Id                  OUT NOCOPY      NUMBER);




Procedure Convert_Id_To_Name (
          Id                  IN OUT NOCOPY   NUMBER,
          Entity_Id           IN              NUMBER,
          Parent_Id           IN              NUMBER  DEFAULT NULL, -- Here Parent Id will be Id of parent entity for a sub entity.
          Name                OUT NOCOPY      VARCHAR2 );




PROCEDURE Get_Effective_Version_Date (  p_value_set_id          IN         NUMBER,
                                        p_version_seq_id        IN         NUMBER,
                                        x_start_active_date     OUT NOCOPY DATE,
                                        x_end_active_date       OUT NOCOPY DATE
                                      );



--  =================================================================================
--  Name        : Resolve_Transaction_Type
--  Description : This procedure will be used to resolve transaction type 'SYNC' to either 'CREATE'
--                or 'UPDATE'.
--
--  Parameters:
--        IN    :
--
--                p_set_process_id        IN      Number
--                Batch Id to be processed
--
--
--  =================================================================================

PROCEDURE Resolve_Transaction_Type
              ( p_set_process_id    IN          NUMBER,
                x_return_status     OUT NOCOPY  VARCHAR2,
                x_return_msg        OUT NOCOPY  VARCHAR2
              );



--  ================================================================================
--  Name        : Validate_Transaction_Type
--  Description : This procedure will be used to validate valid transaction type for a given record
--
--  Parameters:
--        IN    :
--
--                p_set_process_id        IN      Number
--                Batch Id to be processed
--
--
--  =================================================================================

PROCEDURE Validate_Transaction_Type
              ( p_set_process_id    IN          NUMBER,
                x_return_status     OUT NOCOPY  VARCHAR2,
                x_return_msg        OUT NOCOPY  VARCHAR2
              );



PROCEDURE Release_Value_Set_Version(
                  p_value_set_id       IN         NUMBER,
                  p_description        IN         VARCHAR2,
                  p_start_date         IN         TIMESTAMP,
                  p_version_seq_id     IN         NUMBER,
                  p_transaction_id     IN         NUMBER,
                  x_out_vers_seq_id    OUT NOCOPY NUMBER,
                  x_return_status      OUT NOCOPY VARCHAR2,
                  x_return_msg         OUT NOCOPY VARCHAR2 );


PROCEDURE Get_Key_VS_Columns
          ( p_value_set_id        IN                NUMBER,
            p_transaction_id      IN                NUMBER,
            x_maximum_size        IN OUT  NOCOPY    VARCHAR2,
            x_maximum_value       IN OUT  NOCOPY    VARCHAR2,
            x_minimum_value       IN OUT  NOCOPY    VARCHAR2,
            x_description         IN OUT  NOCOPY    VARCHAR2,
            x_longlist_flag       IN OUT  NOCOPY    VARCHAR2,
            x_format_code         IN OUT  NOCOPY    VARCHAR2,
            x_validation_code     IN OUT  NOCOPY    VARCHAR2,
            x_return_status       OUT     NOCOPY    VARCHAR2,
            x_return_msg          OUT     NOCOPY    VARCHAR2
          );



--Bug 9702828
PROCEDURE Get_Key_Value_Columns
          ( p_value_set_id        IN                NUMBER,
            p_value_id            IN                NUMBER,
            x_display_name        IN OUT  NOCOPY    VARCHAR2,
            x_disp_sequence       IN OUT  NOCOPY    NUMBER,
            x_start_date_active   IN OUT  NOCOPY    VARCHAR2,
            x_end_date_active     IN OUT  NOCOPY    VARCHAR2,
            x_description         IN OUT  NOCOPY    VARCHAR2,
            x_enabled_flag        IN OUT  NOCOPY    VARCHAR2,
            x_return_status       OUT     NOCOPY    VARCHAR2,
            x_return_msg          OUT     NOCOPY    VARCHAR2
          );



--  =================================================================================
--  Name        : Populate_VS_Interface
--  Description : This procedure will be used to update pl/sql record back to interface table for a given value set
--
--
--  Parameters:
--        IN    :
--                p_value_set_tbl      IN      Value_Set_Tbl
--                Table instance having record of the type of ego_flex_value_set_intf
--
--        OUT    :
--                x_return_status         OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--
--  =================================================================================

PROCEDURE Populate_VS_Interface ( p_valueset_tbl    IN          Ego_Metadata_Pub.Value_Set_Tbl,
                                  x_return_status   OUT NOCOPY  VARCHAR2,
                                  x_return_msg      OUT NOCOPY  VARCHAR2);




--  =================================================================================
--  Name        : Populate_VS_Val_Interface
--  Description : This procedure will be used to update pl/sql record back to interface table
--                for a value of a value set.
--
--
--  Parameters:
--        IN    :
--                p_valueset_val_tbl      IN      Value_Set_Value_Tbl
--                Table instance having record of the type of ego_flex_value_intf
--
--        OUT    :
--                x_return_status         OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--
--  =================================================================================

PROCEDURE Populate_VS_Val_Interface ( p_valueset_val_tbl    IN          Ego_Metadata_Pub.Value_Set_Value_Tbl,
                                      x_return_status       OUT NOCOPY  VARCHAR2,
                                      x_return_msg          OUT NOCOPY  VARCHAR2);




--  =================================================================================
--  Name        : Populate_VS_Val_Tl_Interface
--  Description : This procedure will be used to update pl/sql record back to interface table
--                for a translatable value of a value set.
--
--
--  Parameters:
--        IN    :
--                p_valueset_val_tl_tbl   IN      Value_Set_Value_Tl_Tbl
--                Table instance having record of the type of ego_flex_value_Tl_intf
--
--        OUT    :
--                x_return_status         OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--
--  =================================================================================

PROCEDURE Populate_VS_Val_Tl_Interface (p_valueset_val_tl_tbl     IN          Ego_Metadata_Pub.Value_Set_Value_Tl_Tbl,
                                        x_return_status           OUT NOCOPY  VARCHAR2,
                                        x_return_msg              OUT NOCOPY  VARCHAR2);




--  =================================================================================
--  Name        : Import_Value_Set_Intf
--  Description : This procedure will be used to import value set using a concurrent program.
--
--
--  Parameters:
--        IN    :
--                p_api_version           IN      NUMBER
--                Active API version number
--
--                p_set_process_id        IN      Number
--                Batch Id to be processed
--
--
--  =================================================================================

PROCEDURE Import_Value_Set_Intf (p_set_process_id   IN          NUMBER,
                                 x_return_status    OUT NOCOPY  VARCHAR2,
                                 x_return_msg       OUT NOCOPY  VARCHAR2);



PROCEDURE Delete_Processed_Value_Sets(  p_set_process_id   IN          NUMBER,
                                        x_return_status    OUT NOCOPY  VARCHAR2,
                                        x_return_msg       OUT NOCOPY  VARCHAR2);



-- Bug 9802900
--  =================================================================================
--  Name        : Validate_Telco_profile
--  Description : This procedure will be used to validate if Telco profile option is
--                enabled to process version related records.
--
--  Parameters:
--        IN    :
--
--                p_set_process_id        IN      Number
--                Batch Id to be processed
--
--
--        OUT    :
--                x_return_status         OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--
--                x_return_msg              OUT NOCOPY VARCHAR2
--  =================================================================================
PROCEDURE Validate_Telco_profile(p_set_process_id   IN         NUMBER,
                                 x_return_status    OUT NOCOPY VARCHAR2,
                                 x_return_msg       OUT NOCOPY VARCHAR2);



-- Bug 9804379
--  =================================================================================
--  Name        : Sync_VS_With_Draft
--  Description : This procedure will be used to sync up draft version of a value set
--                with passed in version number.
--
--  Parameters:
--        IN    :
--
--                p_value_set_id          IN      Number
--                Value Set Id for which draft version need to be in sync with
--                passed in version number
--
--                p_version_number        IN      Number
--                Version sequence id with which draft version need to be in sync.
--
--        OUT    :
--                x_return_status         OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--
--                x_return_msg              OUT NOCOPY VARCHAR2
--  =================================================================================
PROCEDURE Sync_VS_With_Draft ( p_value_set_id      IN NUMBER
                              ,p_version_number    IN NUMBER
                              ,x_return_status     OUT NOCOPY VARCHAR2
                              ,x_return_msg        OUT NOCOPY VARCHAR2);

--  =================================================================================
--  Name        : Initialize_VS_Interface
--  Description : This procedure will be used to do bulk validation while called through
--                concurent program.
--
--  Parameters:
--        IN    :
--                p_api_version           IN      NUMBER
--                Active API version number
--
--                p_set_process_id        IN      Number
--                Batch Id to be processed
--
--
--
--        OUT    :
--                x_return_status         OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_msg_count             OUT NOCOPY NUMBER
--
--                x_return_msg              OUT NOCOPY VARCHAR2
--
--  =================================================================================

PROCEDURE Initialize_VS_Interface (
           p_api_version      IN         NUMBER,
           p_set_process_id   IN         NUMBER,
           x_return_status    OUT NOCOPY VARCHAR2,
           x_msg_count        OUT NOCOPY NUMBER,
           x_return_msg       OUT NOCOPY VARCHAR2);



-- Bug 9702845
PROCEDURE Validate_value_Set (
                p_value_set_name      IN          VARCHAR2,
                p_validation_code     IN          VARCHAR2,
                p_longlist_flag       IN          VARCHAR2,
                p_format_code         IN          VARCHAR2,
                p_maximum_size        IN          NUMBER,
                p_maximum_value       IN          VARCHAR2,
                p_minimum_value       IN          VARCHAR2,
                p_version_seq_id      IN          NUMBER,
                p_transaction_id      IN          NUMBER,
                p_transaction_type    IN          VARCHAR2,
                x_return_status       OUT NOCOPY  VARCHAR2,
                x_return_msg          OUT NOCOPY  VARCHAR2);



-- Pocedure to convert value to DB Date
-- Bug 9701510
PROCEDURE Convert_Value_To_DbDate ( p_value    IN  OUT NOCOPY        VARCHAR2);


-- Procedure to validate if input date is in user preferred date format.
-- Bug 9701510
PROCEDURE Validate_User_Preferred_Date (p_value             IN OUT NOCOPY     VARCHAR2,
                                        p_format_code       IN                VARCHAR2,
                                        p_transaction_id    IN                VARCHAR2,
                                        x_return_status     OUT NOCOPY        VARCHAR2,
                                        x_return_msg        OUT NOCOPY        VARCHAR2);




PROCEDURE Validate_Child_Value_Set (
                                    p_value_set_name      IN          VARCHAR2,
                                    p_value_set_id        IN          NUMBER,
                                    p_validation_code     IN          VARCHAR2,
                                    p_longlist_flag       IN          VARCHAR2,
                                    p_format_code         IN          VARCHAR2,
                                    p_version_seq_id      IN          NUMBER,
                                    p_transaction_id      IN          NUMBER,
                                    x_return_status       OUT NOCOPY  VARCHAR2,
                                    x_return_msg          OUT NOCOPY  VARCHAR2);



PROCEDURE Validate_Table_Value_Set (
                                    p_value_set_name            IN          VARCHAR2,
                                    p_value_set_id              IN          NUMBER,
                                    p_format_code               IN          VARCHAR2,
                                    p_application_table_name    IN          VARCHAR2,
                                    p_additional_where_clause   IN          VARCHAR2 DEFAULT NULL,
                                    p_value_column_name         IN          VARCHAR2,
                                    p_value_column_type         IN          VARCHAR2,
                                    p_value_column_size         IN          NUMBER,

                                    p_id_column_name            IN          VARCHAR2  DEFAULT NULL ,
                                    p_id_column_type            IN          VARCHAR2  DEFAULT NULL ,
                                    p_id_column_size            IN          NUMBER    DEFAULT NULL ,

                                    p_meaning_column_name       IN          VARCHAR2  DEFAULT NULL ,
                                    p_meaning_column_type       IN          VARCHAR2  DEFAULT NULL ,
                                    p_meaning_column_size       IN          NUMBER    DEFAULT NULL ,


                                    p_transaction_id            IN          NUMBER,
                                    x_return_status             OUT NOCOPY  VARCHAR2,
                                    x_return_msg                OUT NOCOPY  VARCHAR2);


--  =================================================================================
--  Name        : Process_Value_Sets
--  Description : This procedure will be used to create value set. It will process
--                record Row by Row.
--
--  Parameters:
--        IN    :
--                p_api_version        IN      NUMBER
--                Active API version number
--
--                p_value_set_tbl      IN      Value_Set_Tbl
--                Table instance having record of the type of ego_flex_value_set_intf
--
--                p_set_process_id     IN      Number
--                Batch Id to be processed
--
--
--
--        OUT    :
--                x_return_status      OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_msg_count          OUT NOCOPY NUMBER
--
--                x_return_msg           OUT NOCOPY VARCHAR2
--
--  =================================================================================

PROCEDURE Process_Value_Set (
           p_api_version      IN              NUMBER,
           p_value_set_tbl    IN  OUT NOCOPY  Ego_Metadata_Pub.Value_Set_Tbl,
           p_set_process_id   IN              NUMBER,
           p_commit           IN              BOOLEAN DEFAULT FALSE,
           x_return_status    OUT NOCOPY      VARCHAR2,
           x_msg_count        OUT NOCOPY      NUMBER,
           x_return_msg         OUT NOCOPY      VARCHAR2) ;


--  =================================================================================
--  Name        : Process_Value_Set_Value
--  Description : This procedure will be used to create values associated to a value set.
--                It will process record Row by Row.
--
--  Parameters:
--        IN    :
--                p_api_version           IN      NUMBER
--                Active API version number
--
--                p_value_set_val_tbl     IN      Value_Set_Value_Tbl
--                Table instance having record of the type of ego_flex_value_intf
--
--                p_value_set_val_tl_tbl  IN      Value_Set_Value_Tl_Tbl
--                Table instance having record of the type of ego_flex_value_tl_intf
--
--                p_set_process_id        IN      Number
--                Batch Id to be processed
--
--
--
--        OUT    :
--                x_return_status         OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_msg_count             OUT NOCOPY NUMBER
--
--                x_return_msg              OUT NOCOPY VARCHAR2
--
--  =================================================================================
PROCEDURE Process_Value_Set_Value (
           p_api_version          IN              NUMBER,
           p_value_set_val_tbl    IN  OUT NOCOPY  Ego_Metadata_Pub.Value_Set_Value_Tbl,
           p_value_set_val_tl_tbl IN  OUT NOCOPY  Ego_Metadata_Pub.Value_Set_Value_Tl_Tbl,
           p_set_process_id       IN              NUMBER,
           p_commit               IN              BOOLEAN DEFAULT FALSE,
           x_return_status        OUT NOCOPY      VARCHAR2,
           x_msg_count            OUT NOCOPY      NUMBER,
           x_return_msg           OUT NOCOPY      VARCHAR2) ;





PROCEDURE Process_Isolate_Value (
           p_api_version            IN              NUMBER,
           p_value_set_val_tbl      IN  OUT NOCOPY  Ego_Metadata_Pub.Value_Set_Value_Tbl,
           p_value_set_val_tl_tbl   IN  OUT NOCOPY  Ego_Metadata_Pub.Value_Set_Value_Tl_Tbl,
           p_set_process_id         IN              NUMBER,
           p_commit                 IN              BOOLEAN DEFAULT FALSE,
           x_return_status          OUT NOCOPY      VARCHAR2,
           x_msg_count              OUT NOCOPY      NUMBER,
           x_return_msg             OUT NOCOPY      VARCHAR2);


--  =================================================================================
--  Name        : Process_Child_Value_Set
--  Description : This procedure will be used to create child value set and corresponding
--                values. It will process record Row by Row.
--
--  Parameters:
--        IN    :
--                p_api_version           IN      NUMBER
--                Active API version number
--
--                p_value_set_tbl         IN      Value_Set_Tbl
--                Table instance having record of the type of ego_flex_value_set_intf
--
--                p_valueset_val_tab      IN      Value_Set_Value_Tbl
--                Table instance having record of the type of ego_flex_value_intf
--
--                p_set_process_id        IN      Number
--                Batch Id to be processed
--
--
--
--        OUT    :
--                x_return_status         OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_msg_count             OUT NOCOPY NUMBER
--
--                x_return_msg              OUT NOCOPY VARCHAR2
--
--  =================================================================================

PROCEDURE Process_Child_Value_Set (
           p_api_version        IN              NUMBER,
           p_value_set_tbl      IN  OUT NOCOPY  Ego_Metadata_Pub.Value_Set_Tbl,
           p_valueset_val_tab   IN  OUT NOCOPY  Ego_Metadata_Pub.Value_Set_Value_Tbl,
           p_set_process_id     IN              NUMBER,
           p_commit             IN              BOOLEAN DEFAULT FALSE,
           x_return_status      OUT NOCOPY      VARCHAR2,
           x_msg_count          OUT NOCOPY      NUMBER,
           x_return_msg         OUT NOCOPY      VARCHAR2) ;

END ego_vs_bulkload_pvt ;

/
