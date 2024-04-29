--------------------------------------------------------
--  DDL for Package CSD_GENERATE_RO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_GENERATE_RO_PVT" AUTHID CURRENT_USER as
/* $Header: csdvgens.pls 115.3 2002/12/04 01:07:12 takwong noship $ */

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
  x_msg_data              OUT NOCOPY    VARCHAR2  );


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
  x_msg_data              OUT NOCOPY    VARCHAR2  );


END CSD_GENERATE_RO_PVT ;

 

/
