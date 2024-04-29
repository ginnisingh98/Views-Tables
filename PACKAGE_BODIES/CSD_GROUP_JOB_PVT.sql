--------------------------------------------------------
--  DDL for Package Body CSD_GROUP_JOB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_GROUP_JOB_PVT" AS
/* $Header: csdvjobb.pls 120.0 2005/05/24 17:16:34 appldev noship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_GROUP_JOB_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvjobb.pls';
g_debug NUMBER := 0;
/*-----------------------------------------------------------------*/
/* procedure name: create_job_parameters                           */
/* description   : procedure used to create                        */
/*                 RMA/sales orders for all groups                 */
/*-----------------------------------------------------------------*/

PROCEDURE  create_job_parameters
( p_api_version             IN  NUMBER,
  p_commit                  IN  VARCHAR2,
  p_init_msg_list           IN  VARCHAR2,
  p_validation_level        IN  NUMBER,
  p_job_parameter_rec       IN  OUT NOCOPY JOB_PARAMETER_REC,
  x_group_job_id            OUT NOCOPY NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2
 ) IS

BEGIN
null;
END create_job_parameters;


/*-----------------------------------------------------------------*/
/* procedure name: update_job_parameters                           */
/* description   : procedure used to update                        */
/*                 RMA/sales orders for all groups                 */
/*-----------------------------------------------------------------*/

PROCEDURE  update_job_parameters
( p_api_version             IN  NUMBER,
  p_commit                  IN  VARCHAR2,
  p_init_msg_list           IN  VARCHAR2,
  p_validation_level        IN  NUMBER,
  p_job_parameter_rec       IN OUT NOCOPY JOB_PARAMETER_REC,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2
 ) IS

BEGIN
null;
END update_job_parameters;

/*-----------------------------------------------------------------*/
/* procedure name: lock_job_parameters                             */
/* description   : procedure used to lock                          */
/*                 RMA/sales orders for all groups                 */
/*-----------------------------------------------------------------*/

PROCEDURE  lock_job_parameters
( p_api_version             IN  NUMBER,
  p_commit                  IN  VARCHAR2,
  p_init_msg_list           IN  VARCHAR2,
  p_validation_level        IN  NUMBER,
  p_job_parameter_rec       IN  JOB_PARAMETER_REC,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2
 ) IS

BEGIN
null;
END lock_job_parameters;

-----------------------------------------------------
-- Procedure : UPDATE_RO_ORDERS
-- Purpose   : To update repair orders with status
--             and qty in wip
--
----------------------------------------------------
PROCEDURE UPDATE_RO_ORDERS(p_api_version        in  Number,
                           p_commit             in  Varchar2,
                           p_init_msg_list      in  Varchar2,
                           p_validation_level   in  number,
                           p_repair_line_id     in  number,
                           x_return_status      OUT NOCOPY varchar2,
                           x_msg_count          OUT NOCOPY number,
                           x_msg_data           OUT NOCOPY varchar2) IS


BEGIN
null;
END UPDATE_RO_ORDERS;

-------------------------------------------------------
-- Procedure : UPDATE_RO_GROUP
-- Purpose   : To update repair order groups with
--             status and quantity submitted to wip
--
------------------------------------------------------
PROCEDURE UPDATE_RO_GROUP(p_api_version        in number,
                          p_commit             in varchar2,
                          p_init_msg_list      in varchar2,
                          p_validation_level   in number,
                          p_repair_group_id    in number,
                          p_quantity_submitted in number,
                          p_wip_entity_id      in number,
                          x_return_status      OUT NOCOPY varchar2,
                          x_msg_count          OUT NOCOPY number,
                          x_msg_data           OUT NOCOPY varchar2) IS


BEGIN
null;
END UPDATE_RO_GROUP;
----------------------------------------------
-- Procedure : CREATE_JOB_ALL_GROUPS
-- Purpose   : To create Jobs for all Groups
--
----------------------------------------------

PROCEDURE CREATE_JOB_ALL_GROUPS
( p_api_version      IN   NUMBER,
  p_commit                  IN  VARCHAR2,
  p_init_msg_list           IN  VARCHAR2,
  p_validation_level        IN  NUMBER,
  p_incident_id      IN   NUMBER,
  x_return_status    OUT NOCOPY  VARCHAR2,
  x_msg_count        OUT NOCOPY  NUMBER,
  x_msg_data         OUT NOCOPY  VARCHAR2
 ) IS


BEGIN
 null;
END CREATE_JOB_ALL_GROUPS ;

----------------------------------------------
-- Procedure : CREATE_JOB_ONE_GROUP
-- Purpose   : To create Jobs for one Groups
----------------------------------------------


PROCEDURE CREATE_JOB_ONE_GROUP
( p_api_version      IN   NUMBER,
  p_commit                  IN  VARCHAR2,
  p_init_msg_list           IN  VARCHAR2,
  p_validation_level        IN  NUMBER,
  p_repair_group_id  IN   NUMBER,
  x_return_status    OUT NOCOPY  VARCHAR2,
  x_msg_count        OUT NOCOPY  NUMBER,
  x_msg_data         OUT NOCOPY  VARCHAR2
) IS

BEGIN
null;
END CREATE_JOB_ONE_GROUP;

END CSD_GROUP_JOB_PVT ;

/
