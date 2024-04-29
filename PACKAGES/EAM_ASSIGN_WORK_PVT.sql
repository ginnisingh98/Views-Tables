--------------------------------------------------------
--  DDL for Package EAM_ASSIGN_WORK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSIGN_WORK_PVT" AUTHID CURRENT_USER as
/* $Header: EAMASRQS.pls 115.1 2003/09/16 06:27:28 rhshriva noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below


procedure assign_work (
  p_api_version in NUMBER,
  p_init_msg_list in VARCHAR2 := FND_API.G_FALSE,
  p_commit in VARCHAR2 := FND_API.G_FALSE,
  p_validation_level in NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status out NOCOPY VARCHAR2,
  x_msg_count out NOCOPY NUMBER,
  x_msg_data out NOCOPY VARCHAR2,
  p_wip_entity_id in NUMBER,
  p_req_type in NUMBER,
  p_req_num in VARCHAR2,
  p_req_id in NUMBER

) ;
procedure delete_assignment(
  p_api_version in NUMBER,
  p_init_msg_list in VARCHAR2 := FND_API.G_FALSE,
  p_commit in VARCHAR2 := FND_API.G_FALSE,
  p_validation_level in NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status out NOCOPY VARCHAR2,
  x_msg_count out NOCOPY NUMBER,
  x_msg_data out NOCOPY VARCHAR2,
  p_wip_entity_id in NUMBER,
  p_req_type in NUMBER,
  p_req_num in VARCHAR2,
  p_req_id in NUMBER
);

 END; -- Package Specification EAM_ASSIGN_WORK_PVT


 

/
