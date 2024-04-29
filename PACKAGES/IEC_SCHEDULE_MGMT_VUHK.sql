--------------------------------------------------------
--  DDL for Package IEC_SCHEDULE_MGMT_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_SCHEDULE_MGMT_VUHK" AUTHID CURRENT_USER AS
/* $Header: IECSMVHS.pls 120.1 2006/03/28 09:38:08 hhuang noship $ */

--
--      AUTHOR                  DATE            MODIFICATION DESCRIPTION
--      ------                  ----            ------------------------
--      ANGIE ROMERO            30-JUL-2004     INITIAL IMPLEMENTATION
--

PROCEDURE CopyScheduleEntries_pre
      ( p_src_schedule_id      IN            NUMBER
      , p_dest_schedule_id    IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2);

--
--      AUTHOR                  DATE            MODIFICATION DESCRIPTION
--      ------                  ----            ------------------------
--      ANGIE ROMERO            30-JUL-2004     INITIAL IMPLEMENTATION
--

PROCEDURE CopyScheduleEntries_post
      ( p_src_schedule_id      IN            NUMBER
      , p_dest_schedule_id    IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2);

--
--      AUTHOR                  DATE            MODIFICATION DESCRIPTION
--      ------                  ----            ------------------------
--      ANGIE ROMERO            30-JUL-2004     INITIAL IMPLEMENTATION
--

PROCEDURE MoveScheduleEntries_pre
      ( p_src_schedule_id      IN            NUMBER
      , p_dest_schedule_id    IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2);

--
--      AUTHOR                  DATE            MODIFICATION DESCRIPTION
--      ------                  ----            ------------------------
--      ANGIE ROMERO            30-JUL-2004     INITIAL IMPLEMENTATION
--

PROCEDURE MoveScheduleEntries_post
      ( p_src_schedule_id      IN            NUMBER
      , p_dest_schedule_id    IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2);

--
--      AUTHOR                  DATE            MODIFICATION DESCRIPTION
--      ------                  ----            ------------------------
--      ANGIE ROMERO            30-JUL-2004     INITIAL IMPLEMENTATION
--

PROCEDURE PurgeScheduleEntries_pre
      ( p_schedule_id             IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2);

--
--      AUTHOR                  DATE            MODIFICATION DESCRIPTION
--      ------                  ----            ------------------------
--      ANGIE ROMERO            30-JUL-2004     INITIAL IMPLEMENTATION
--

PROCEDURE PurgeScheduleEntries_post
      ( p_schedule_id             IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2);

--
--      AUTHOR                  DATE            MODIFICATION DESCRIPTION
--      ------                  ----            ------------------------
--      ANGIE ROMERO            30-JUL-2004     INITIAL IMPLEMENTATION
--

PROCEDURE StopScheduleExecution_pre
      ( p_schedule_id             IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2);

--
--      AUTHOR                  DATE            MODIFICATION DESCRIPTION
--      ------                  ----            ------------------------
--      ANGIE ROMERO            30-JUL-2004     INITIAL IMPLEMENTATION
--

PROCEDURE StopScheduleExecution_post
      ( p_schedule_id             IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2);


END IEC_SCHEDULE_MGMT_VUHK;

 

/
