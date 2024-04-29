--------------------------------------------------------
--  DDL for Package AMS_LIST_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_PURGE_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvimcs.pls 120.2 2006/03/31 05:11:09 bmuthukr noship $ */

/*****************************************************************************/
--PL\SQL table to hold ids for bulk update
/*****************************************************************************/

TYPE t_rec_table is TABLE OF NUMBER
INDEX BY BINARY_INTEGER;
l_id_tbl t_rec_table;

/*****************************************************************************/
-- Procedure
--   Purge_Expired_List_Headers
--
-- Purpose
--   Purge imported list headers which is expired or has usage as 0 or less
--
-- Note
--
-- History
--   05/18/2001    yxliu      created
-------------------------------------------------------------------------------
type id_tbl is record
(l_list_header_id  number);

type list_header_id_tbl is table of id_tbl index by binary_integer;

l_list_header_id_tbl list_header_id_tbl;

PROCEDURE Purge_Expired_List_Headers
(
    force_purge_flag  IN VARCHAR2 := FND_API.g_false,
    x_return_status OUT NOCOPY   VARCHAR2,
    x_msg_count     OUT NOCOPY   NUMBER,
    x_msg_data      OUT NOCOPY   VARCHAR2
);


/*****************************************************************************/
-- Procedure
--   Purge_List_Import
--
-- Purpose
--   This procedure is created to as a concurrent program which
--   will call the Purge_Expired_List_Headers and will return errors if any
--
-- Notes
--
--
-- History
--   05/18/2001      yxliu    created
------------------------------------------------------------------------------

PROCEDURE Purge_List_Import
(
    errbuf        OUT NOCOPY    VARCHAR2,
    retcode       OUT NOCOPY    NUMBER,
    force_purge_flag in VARCHAR2 := FND_API.G_FALSE
);

/*****************************************************************************/
-- Procedure
--   Purge_Purged_Target_Group
--
-- Purpose
--   Purge target group list headers which has purged_flag = Y and
--   send_out_date has passed
--
-- Note
--
-- History
--   05/21/2001    yxliu      created
-------------------------------------------------------------------------------
PROCEDURE Purge_Purged_Target
(
    x_return_status OUT NOCOPY   VARCHAR2,
    x_msg_count     OUT NOCOPY   NUMBER,
    x_msg_data      OUT NOCOPY   VARCHAR2
);

/*****************************************************************************/
-- Procedure
--   Purge_Target_Group
--
-- Purpose
--   This procedure is created to as a concurrent program which
--   will call the Purge_Purged_Target_Group and will return errors if any
--
-- Notes
--
--
-- History
--   05/21/2001      yxliu    created
------------------------------------------------------------------------------

PROCEDURE Purge_Target_Group
(   errbuf        OUT NOCOPY    VARCHAR2,
    retcode       OUT NOCOPY    NUMBER
);

/*****************************************************************************/
-- Procedure
--   Increase_Usage
--
-- Purpose
--   increase usage of related source lines by 1
--
-- Note
--
-- History
--   12/13/2001    yxliu      created
-------------------------------------------------------------------------------
PROCEDURE Increase_Usage
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
    p_commit            IN  VARCHAR2  := FND_API.g_false,
    p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

    x_return_status     OUT NOCOPY   VARCHAR2,
    x_msg_count         OUT NOCOPY   NUMBER,
    x_msg_data          OUT NOCOPY   VARCHAR2,
    p_list_header_id    IN    NUMBER

);

PROCEDURE delete_list_manager (x_errbuf         OUT NOCOPY VARCHAR2
                             , x_retcode        OUT NOCOPY VARCHAR2
                             , p_list_header_id IN         NUMBER
                             , p_batch_size     IN         NUMBER DEFAULT 1000
                             , p_num_workers    IN         NUMBER DEFAULT 3) ;


PROCEDURE delete_list_worker ( x_errbuf       OUT NOCOPY VARCHAR2
                            , x_retcode      OUT NOCOPY VARCHAR2
                            , x_batch_size   IN         NUMBER
                            , x_worker_id    IN         NUMBER
                            , x_num_workers  IN         NUMBER
                            , x_argument4    IN         VARCHAR2);


PROCEDURE delete_entries_soft(p_list_header_id_tbl      IN  AMS_LIST_PURGE_PVT.l_list_header_id_tbl%type,
               		      x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2);

PROCEDURE delete_entries_online(p_list_header_id_tbl      IN  AMS_LIST_PURGE_PVT.l_list_header_id_tbl%type,
                		x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2);


PROCEDURE purge_entries_manager (x_errbuf         OUT NOCOPY VARCHAR2
                               , x_retcode        OUT NOCOPY VARCHAR2
                               , p_list_type      IN         VARCHAR2
                               , p_cr_date_from   IN         VARCHAR2
                               , p_cr_date_to     IN         VARCHAR2
                               , p_batch_size     IN         NUMBER DEFAULT 1000
                               , p_num_workers    IN         NUMBER DEFAULT 3) ;



PROCEDURE purge_entries_worker ( x_errbuf       OUT NOCOPY VARCHAR2
                               , x_retcode      OUT NOCOPY VARCHAR2
                               , x_batch_size   IN         NUMBER
                               , x_worker_id    IN         NUMBER
                               , x_num_workers  IN         NUMBER
                               , x_argument4    IN         VARCHAR2);
END AMS_List_Purge_PVT;

 

/
