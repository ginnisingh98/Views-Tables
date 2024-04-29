--------------------------------------------------------
--  DDL for Package PSB_POSITIONS_HDR_I_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_POSITIONS_HDR_I_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWPOUS.pls 120.2 2005/07/13 11:36:51 shtripat ship $ */

--
--
--  P O S I T I O N S T A B L E    H A N D L E R S
--

PROCEDURE INSERT_ROW (
  p_api_version            in number,
  p_init_msg_list          in varchar2 := fnd_api.g_false,
  p_commit                 in varchar2 := fnd_api.g_false,
  p_validation_level       in number   := fnd_api.g_valid_level_full,
  p_return_status          OUT  NOCOPY varchar2,
  p_msg_count              OUT  NOCOPY number,
  p_msg_data               OUT  NOCOPY varchar2,
  p_rowid                  in OUT  NOCOPY varchar2,
  p_position_id            in number,
  p_data_extract_id        in number,
  p_position_definition_id in number,
  p_hr_position_id         in number,
  p_business_group_id      in number,
  p_effective_start_date   in date,
  p_effective_end_date     in date,
  p_set_of_books_id        in number,
  p_vacant_position_flag   in varchar2,
  p_attribute1          in varchar2,
  p_attribute2          in varchar2,
  p_attribute3          in varchar2,
  p_attribute4          in varchar2,
  p_attribute5          in varchar2,
  p_attribute6          in varchar2,
  p_attribute7          in varchar2,
  p_attribute8          in varchar2,
  p_attribute9          in varchar2,
  p_attribute10         in varchar2,
  p_attribute11         in varchar2,
  p_attribute12         in varchar2,
  p_attribute13         in varchar2,
  p_attribute14         in varchar2,
  p_attribute15         in varchar2,
  p_attribute16         in varchar2,
  p_attribute17         in varchar2,
  p_attribute18         in varchar2,
  p_attribute19         in varchar2,
  p_attribute20         in varchar2,
  p_attribute_category  in varchar2,
  p_name                in varchar2,
  p_mode                in varchar2 default 'R'
  );
--
--
--

PROCEDURE UPDATE_ROW (
  p_api_version            in number,
  p_init_msg_list          in varchar2 := fnd_api.g_false,
  p_commit                 in varchar2 := fnd_api.g_false,
  p_validation_level       in number   := fnd_api.g_valid_level_full,
  p_return_status          OUT  NOCOPY varchar2,
  p_msg_count              OUT  NOCOPY number,
  p_msg_data               OUT  NOCOPY varchar2,
  p_position_id            in number,
  p_data_extract_id        in number,
  p_position_definition_id in number,
  p_hr_position_id         in number,
  p_business_group_id      in number,
  p_effective_start_date   in date,
  p_effective_end_date     in date,
  p_set_of_books_id        in number,
  p_vacant_position_flag   in varchar2,
  p_new_position_flag      in varchar2,
  p_attribute1          in varchar2,
  p_attribute2          in varchar2,
  p_attribute3          in varchar2,
  p_attribute4          in varchar2,
  p_attribute5          in varchar2,
  p_attribute6          in varchar2,
  p_attribute7          in varchar2,
  p_attribute8          in varchar2,
  p_attribute9          in varchar2,
  p_attribute10         in varchar2,
  p_attribute11         in varchar2,
  p_attribute12         in varchar2,
  p_attribute13         in varchar2,
  p_attribute14         in varchar2,
  p_attribute15         in varchar2,
  p_attribute16         in varchar2,
  p_attribute17         in varchar2,
  p_attribute18         in varchar2,
  p_attribute19         in varchar2,
  p_attribute20         in varchar2,
  p_attribute_category  in varchar2,
  p_name                in varchar2,
  p_mode                in varchar2 default 'R'
  );
--


PROCEDURE LOCK_ROW (
  p_api_version            in number,
  p_init_msg_list          in varchar2 := fnd_api.g_false,
  p_commit                 in varchar2 := fnd_api.g_false,
  p_validation_level       in number   := fnd_api.g_valid_level_full,
  p_return_status          OUT  NOCOPY varchar2,
  p_msg_count              OUT  NOCOPY number,
  p_msg_data               OUT  NOCOPY varchar2,
  p_row_locked             OUT  NOCOPY varchar2,
  p_position_id            in number,
  p_data_extract_id        in number,
  p_position_definition_id in number,
  p_hr_position_id         in number,
  p_business_group_id      in number,
  p_effective_start_date   in date,
  p_effective_end_date     in date,
  p_set_of_books_id        in number,
  p_vacant_position_flag   in varchar2,
  p_attribute1          in varchar2,
  p_attribute2          in varchar2,
  p_attribute3          in varchar2,
  p_attribute4          in varchar2,
  p_attribute5          in varchar2,
  p_attribute6          in varchar2,
  p_attribute7          in varchar2,
  p_attribute8          in varchar2,
  p_attribute9          in varchar2,
  p_attribute10         in varchar2,
  p_attribute11         in varchar2,
  p_attribute12         in varchar2,
  p_attribute13         in varchar2,
  p_attribute14         in varchar2,
  p_attribute15         in varchar2,
  p_attribute16         in varchar2,
  p_attribute17         in varchar2,
  p_attribute18         in varchar2,
  p_attribute19         in varchar2,
  p_attribute20         in varchar2,
  p_attribute_category  in varchar2,
  p_name                in varchar2
);

--
--
PROCEDURE DELETE_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_position_id         in number
);
--
---
END PSB_POSITIONS_HDR_I_PVT ;

 

/
