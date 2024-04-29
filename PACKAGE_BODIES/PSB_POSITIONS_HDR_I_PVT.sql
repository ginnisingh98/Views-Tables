--------------------------------------------------------
--  DDL for Package Body PSB_POSITIONS_HDR_I_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_POSITIONS_HDR_I_PVT" AS
/* $Header: PSBWPOUB.pls 120.2 2005/07/13 11:36:45 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_POSITIONS_HDR_I_PVT';
  G_DBUG              VARCHAR2(2000) := 'start';

PROCEDURE DELETE_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_position_id         in number
)
IS

BEGIN
  PSB_POSITIONS_PVT.DELETE_ROW (
	 p_api_version          => p_api_version,
	 p_init_msg_list        => p_init_msg_list,
	 p_commit               => p_commit,
	 p_validation_level     => p_validation_level,
	 p_return_status        => p_return_status,
	 p_msg_count            => p_msg_count,
	 p_msg_data             => p_msg_data,
	 p_position_id          => p_position_id
  );
END DELETE_ROW;
--

PROCEDURE DELETE_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_distribution_id     in number
)
IS

BEGIN
  PSB_POSITION_PAY_DISTR_PVT.DELETE_ROW (
	 p_api_version          => p_api_version,
	 p_init_msg_list        => p_init_msg_list,
	 p_commit               => p_commit,
	 p_validation_level     => p_validation_level,
	 p_return_status        => p_return_status,
	 p_msg_count            => p_msg_count,
	 p_msg_data             => p_msg_data,
	 p_distribution_id      => p_distribution_id
  );
END DELETE_ROW;
--

PROCEDURE LOCK_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number   := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_row_locked          OUT  NOCOPY varchar2,
  p_distribution_id      in number,
  p_position_id          in number,
  p_data_extract_id      in number,
  p_effective_start_date   in date,
  p_effective_end_date  in date,
  p_chart_of_accounts_id     in number,
  p_code_combination_id in number,
  p_distribution_percent     in number,
  p_global_default_flag in varchar2,
  p_distribution_default_rule_id     in number
) IS

BEGIN
  PSB_POSITION_PAY_DISTR_PVT.LOCK_ROW (
  p_api_version              => p_api_version,
  p_init_msg_list            =>  p_init_msg_list,
  p_commit                   => p_commit,
  p_validation_level         => p_validation_level,
  p_return_status            => p_return_status,
  p_msg_count                => p_msg_count,
  p_msg_data                 => p_msg_data,
  p_row_locked               => p_row_locked,
  p_distribution_id          => p_distribution_id,
  p_position_id              => p_position_id,
  p_data_extract_id          => p_data_extract_id,
  p_effective_start_date     => p_effective_start_date,
  p_effective_end_date       => p_effective_end_date,
  p_chart_of_accounts_id     => p_chart_of_accounts_id,
  p_code_combination_id      => p_code_combination_id,
  p_distribution_percent     => p_distribution_percent,
  p_global_default_flag      => p_global_default_flag,
  p_distribution_default_rule_id     => p_distribution_default_rule_id
  );
END LOCK_ROW;

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
) IS

BEGIN
  PSB_POSITIONS_PVT.LOCK_ROW (
  p_api_version              => p_api_version,
  p_init_msg_list            =>  p_init_msg_list,
  p_commit                   => p_commit,
  p_validation_level         => p_validation_level,
  p_return_status            => p_return_status,
  p_msg_count                => p_msg_count,
  p_msg_data                 => p_msg_data,
  p_row_locked               => p_row_locked,
  p_position_id            => p_position_id,
  p_data_extract_id        =>p_data_extract_id,
  p_position_definition_id =>p_position_definition_id,
  p_hr_position_id         =>p_hr_position_id,
  p_business_group_id      =>p_business_group_id,
  p_effective_start_date   =>p_effective_start_date,
  p_effective_end_date     =>p_effective_end_date,
  p_set_of_books_id        =>p_set_of_books_id,
  p_vacant_position_flag   =>p_vacant_position_flag,
  p_attribute1          =>p_attribute1,
  p_attribute2          =>p_attribute2,
  p_attribute3          =>p_attribute3,
  p_attribute4          =>p_attribute4,
  p_attribute5          =>p_attribute5,
  p_attribute6          =>p_attribute6,
  p_attribute7          =>p_attribute7,
  p_attribute8          =>p_attribute8,
  p_attribute9          =>p_attribute9,
  p_attribute10         =>p_attribute10,
  p_attribute11         =>p_attribute11,
  p_attribute12         =>p_attribute12,
  p_attribute13         =>p_attribute13,
  p_attribute14         =>p_attribute14,
  p_attribute15         =>p_attribute15,
  p_attribute16         =>p_attribute16,
  p_attribute17         =>p_attribute17,
  p_attribute18         =>p_attribute18,
  p_attribute19         =>p_attribute19,
  p_attribute20         =>p_attribute20,
  p_attribute_category  =>p_attribute_category,
  p_name                =>p_name
  );
END LOCK_ROW;


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
  p_mode                in varchar2
) IS

BEGIN
  PSB_POSITIONS_PVT.UPDATE_ROW (
  p_api_version              => p_api_version,
  p_init_msg_list            =>  p_init_msg_list,
  p_commit                   => p_commit,
  p_validation_level         => p_validation_level,
  p_return_status            => p_return_status,
  p_msg_count                => p_msg_count,
  p_msg_data                 => p_msg_data,
  p_position_id            => p_position_id,
  p_data_extract_id        =>p_data_extract_id,
  p_position_definition_id =>p_position_definition_id,
  p_hr_position_id         =>p_hr_position_id,
  p_business_group_id      =>p_business_group_id,
  p_effective_start_date   =>p_effective_start_date,
  p_effective_end_date     =>p_effective_end_date,
  p_set_of_books_id        =>p_set_of_books_id,
  p_vacant_position_flag   =>p_vacant_position_flag,
  p_new_position_flag      =>p_new_position_flag,
  p_attribute1          =>p_attribute1,
  p_attribute2          =>p_attribute2,
  p_attribute3          =>p_attribute3,
  p_attribute4          =>p_attribute4,
  p_attribute5          =>p_attribute5,
  p_attribute6          =>p_attribute6,
  p_attribute7          =>p_attribute7,
  p_attribute8          =>p_attribute8,
  p_attribute9          =>p_attribute9,
  p_attribute10         =>p_attribute10,
  p_attribute11         =>p_attribute11,
  p_attribute12         =>p_attribute12,
  p_attribute13         =>p_attribute13,
  p_attribute14         =>p_attribute14,
  p_attribute15         =>p_attribute15,
  p_attribute16         =>p_attribute16,
  p_attribute17         =>p_attribute17,
  p_attribute18         =>p_attribute18,
  p_attribute19         =>p_attribute19,
  p_attribute20         =>p_attribute20,
  p_attribute_category  =>p_attribute_category,
  p_name                =>p_name ,
  p_mode                =>p_mode
  );
END UPDATE_ROW;

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
  p_mode                in varchar2
) IS

BEGIN
  PSB_POSITIONS_PVT.INSERT_ROW (
  p_api_version              => p_api_version,
  p_init_msg_list            =>  p_init_msg_list,
  p_commit                   => p_commit,
  p_validation_level         => p_validation_level,
  p_return_status            => p_return_status,
  p_msg_count                => p_msg_count,
  p_msg_data                 => p_msg_data,
  p_rowid                    => p_rowid,
  p_position_id            => p_position_id,
  p_data_extract_id        =>p_data_extract_id,
  p_position_definition_id =>p_position_definition_id,
  p_hr_position_id         =>p_hr_position_id,
  p_business_group_id      =>p_business_group_id,
  p_effective_start_date   =>p_effective_start_date,
  p_effective_end_date     =>p_effective_end_date,
  p_set_of_books_id        =>p_set_of_books_id,
  p_vacant_position_flag   =>p_vacant_position_flag,
  p_attribute1          =>p_attribute1,
  p_attribute2          =>p_attribute2,
  p_attribute3          =>p_attribute3,
  p_attribute4          =>p_attribute4,
  p_attribute5          =>p_attribute5,
  p_attribute6          =>p_attribute6,
  p_attribute7          =>p_attribute7,
  p_attribute8          =>p_attribute8,
  p_attribute9          =>p_attribute9,
  p_attribute10         =>p_attribute10,
  p_attribute11         =>p_attribute11,
  p_attribute12         =>p_attribute12,
  p_attribute13         =>p_attribute13,
  p_attribute14         =>p_attribute14,
  p_attribute15         =>p_attribute15,
  p_attribute16         =>p_attribute16,
  p_attribute17         =>p_attribute17,
  p_attribute18         =>p_attribute18,
  p_attribute19         =>p_attribute19,
  p_attribute20         =>p_attribute20,
  p_attribute_category  =>p_attribute_category,
  p_name                =>p_name ,
  p_mode                =>p_mode
  );
END INSERT_ROW;

/* ----------------------------------------------------------------------- */

END PSB_POSITIONS_HDR_I_PVT;

/
