--------------------------------------------------------
--  DDL for Package FND_EXEC_MIG_CMDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_EXEC_MIG_CMDS" AUTHID DEFINER AS
/* $Header: fndpemcs.pls 120.1 2005/07/02 03:34:10 appldev noship $ */

PROCEDURE process_line_child_cmds (p_lineno IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE migrate_objects
(
 p_owner               IN   VARCHAR2,
 p_aqStat              IN   VARCHAR2,
 p_exec_mode            IN   VARCHAR2,
 x_return_status       OUT   NOCOPY VARCHAR2
);

PROCEDURE disable_cons (
  p_owner                IN   VARCHAR2,
  x_return_status        OUT  NOCOPY  VARCHAR2);

PROCEDURE disable_trigger (
  p_owner                IN   VARCHAR2,
  x_return_status        OUT   NOCOPY VARCHAR2);

PROCEDURE stop_queues (
  p_owner                IN   VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2);

PROCEDURE disable_policies (
  p_owner                IN   VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2);

PROCEDURE enable_cons (
  p_owner                IN   VARCHAR2,
  x_return_status        OUT   NOCOPY VARCHAR2);

PROCEDURE enable_trigger (
  p_owner                IN   VARCHAR2,
  x_return_status        OUT   NOCOPY VARCHAR2);

PROCEDURE start_queues (
  p_owner                IN   VARCHAR2,
  x_return_status        OUT   NOCOPY VARCHAR2);

PROCEDURE enable_policies (
  p_owner                IN   VARCHAR2,
  x_return_status        OUT   NOCOPY VARCHAR2);

PROCEDURE disable (
  p_owner                IN   VARCHAR2,
  x_return_status        OUT  NOCOPY  VARCHAR2);

PROCEDURE enable (
  p_owner                IN   VARCHAR2,
  x_return_status        OUT  NOCOPY  VARCHAR2);

END FND_EXEC_MIG_CMDS;

 

/
