--------------------------------------------------------
--  DDL for Package Body IEC_SCHEDULE_MGMT_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_SCHEDULE_MGMT_VUHK" AS
/* $Header: IECSMVHB.pls 120.1 2006/03/28 09:37:05 hhuang noship $ */

PROCEDURE CopyScheduleEntries_pre
      ( p_src_schedule_id      IN            NUMBER
      , p_dest_schedule_id    IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2)
IS
BEGIN
   NULL;
END CopyScheduleEntries_pre;

PROCEDURE CopyScheduleEntries_post
      ( p_src_schedule_id      IN            NUMBER
      , p_dest_schedule_id    IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2)
IS
BEGIN
   NULL;
END CopyScheduleEntries_post;

PROCEDURE MoveScheduleEntries_pre
      ( p_src_schedule_id      IN            NUMBER
      , p_dest_schedule_id    IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2)
IS
BEGIN
   NULL;
END MoveScheduleEntries_pre;

PROCEDURE MoveScheduleEntries_post
      ( p_src_schedule_id      IN            NUMBER
      , p_dest_schedule_id    IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2)
IS
BEGIN
   NULL;
END MoveScheduleEntries_post;

PROCEDURE PurgeScheduleEntries_pre
      ( p_schedule_id             IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2)
IS
BEGIN
   NULL;
END PurgeScheduleEntries_pre;

PROCEDURE PurgeScheduleEntries_post
      ( p_schedule_id             IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2)
IS
BEGIN
   NULL;
END PurgeScheduleEntries_post;

PROCEDURE StopScheduleExecution_pre
      ( p_schedule_id             IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2)
IS
BEGIN
   NULL;
END StopScheduleExecution_pre;

PROCEDURE StopScheduleExecution_post
      ( p_schedule_id             IN            NUMBER
      , x_data                        IN OUT NOCOPY VARCHAR2
      , x_count                      IN OUT NOCOPY NUMBER
      , x_return_code            IN OUT NOCOPY VARCHAR2)
IS
BEGIN
   NULL;
END StopScheduleExecution_post;

END IEC_SCHEDULE_MGMT_VUHK;

/
