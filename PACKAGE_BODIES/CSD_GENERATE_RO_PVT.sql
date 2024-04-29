--------------------------------------------------------
--  DDL for Package Body CSD_GENERATE_RO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_GENERATE_RO_PVT" AS
/* $Header: csdvgenb.pls 120.1.12000000.2 2007/02/20 22:42:44 takwong ship $ */

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_GENERATE_RO_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvgenb.pls';
g_debug NUMBER := csd_gen_utility_pvt.g_debug_level;
/*--------------------------------------------------*/
/* procedure name: generate_ro_for_all_groups       */
/* description   : procedure used to generate       */
/*                 repair order for all groups      */
/*                                                  */
/*--------------------------------------------------*/

procedure GENERATE_RO_FOR_ALL_GROUPS
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_incident_id           IN     NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
 ) IS


 BEGIN

 NULL;

 END GENERATE_RO_FOR_ALL_GROUPS;


/*--------------------------------------------------*/
/* procedure name: generate_ro_for_one_groups       */
/* description   : procedure used to generate       */
/*                 repair order for one groups      */
/*                                                  */
/*--------------------------------------------------*/

procedure GENERATE_RO_FOR_ONE_GROUPS
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_repair_group_id       IN     NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
 ) IS


 BEGIN

NULL;

 END GENERATE_RO_FOR_ONE_GROUPS;

END CSD_GENERATE_RO_PVT;

/
