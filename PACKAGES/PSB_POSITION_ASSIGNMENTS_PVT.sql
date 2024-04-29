--------------------------------------------------------
--  DDL for Package PSB_POSITION_ASSIGNMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_POSITION_ASSIGNMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVPOAS.pls 120.2 2005/07/13 11:28:54 shtripat ship $ */

--
--
--  T A B L E    H A N D L E R S
--

PROCEDURE INSERT_ROW (
  p_api_version          in number,
  p_init_msg_list        in varchar2 := fnd_api.g_false,
  p_commit               in varchar2 := fnd_api.g_false,
  p_validation_level     in number := fnd_api.g_valid_level_full,
  p_return_status        OUT  NOCOPY varchar2,
  p_msg_count            OUT  NOCOPY number,
  p_msg_data             OUT  NOCOPY varchar2,
  p_rowid                in OUT  NOCOPY varchar2,
  p_position_assignment_id  in OUT  NOCOPY number,
  p_data_extract_id      in number,
  p_worksheet_id         in number,
  p_position_id         in number,
  p_assignment_type in varchar2,
  p_attribute_id          in number,
  p_attribute_value_id    in number,
  p_attribute_value       in varchar2,
  p_pay_element_id        in number,
  p_pay_element_option_id in number,
  p_effective_start_date  in date,
  p_effective_end_date    in date,
  p_element_value_type   in varchar2,
  p_element_value         in number,
  p_currency_code         in varchar2,
  p_pay_basis             in varchar2,
  p_employee_id           in number,
  p_primary_employee_flag in varchar2 := FND_API.G_MISS_CHAR,
  p_global_default_flag   in varchar2,
  p_assignment_default_rule_id in number,
  p_modify_flag           in varchar2,
  p_mode                  in varchar2 default 'R'
  );
--
--
--

PROCEDURE UPDATE_ROW (
  p_api_version          in number,
  p_init_msg_list        in varchar2 := fnd_api.g_false,
  p_commit               in varchar2 := fnd_api.g_false,
  p_validation_level     in number := fnd_api.g_valid_level_full,
  p_return_status        OUT  NOCOPY varchar2,
  p_msg_count            OUT  NOCOPY number,
  p_msg_data             OUT  NOCOPY varchar2,
  p_position_assignment_id  in number,
  p_pay_element_id        in number := FND_API.G_MISS_NUM,
  p_pay_element_option_id in number := FND_API.G_MISS_NUM,
  p_attribute_value_id    in number := FND_API.G_MISS_NUM,
  p_attribute_value       in varchar2 := FND_API.G_MISS_CHAR,
  p_effective_start_date  in date := FND_API.G_MISS_DATE,
  p_effective_end_date    in date := FND_API.G_MISS_DATE,
  p_element_value_type   in varchar2 := FND_API.G_MISS_CHAR,
  p_element_value         in number := FND_API.G_MISS_NUM,
  p_pay_basis             in varchar2 := FND_API.G_MISS_CHAR,
  p_employee_id           in number := FND_API.G_MISS_NUM,
  p_primary_employee_flag in varchar2 := FND_API.G_MISS_CHAR,
  p_global_default_flag   in varchar2 := FND_API.G_MISS_CHAR,
  p_assignment_default_rule_id in number := FND_API.G_MISS_NUM,
  p_modify_flag           in varchar2,
  p_mode                  in varchar2 default 'R'
  );
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
  p_position_assignment_id  in number,
  p_data_extract_id      in number,
  p_worksheet_id         in number,
  p_position_id         in number,
  p_assignment_type in varchar2,
  p_attribute_id          in number,
  p_attribute_value_id    in number,
  p_attribute_value       in varchar2,
  p_pay_element_id        in number,
  p_pay_element_option_id in number,
  p_effective_start_date  in date,
  p_effective_end_date    in date,
  p_element_value_type   in varchar2,
  p_element_value         in number,
  p_currency_code         in varchar2,
  p_pay_basis             in varchar2,
  p_employee_id           in number,
  p_primary_employee_flag in varchar2,
  p_global_default_flag   in varchar2,
  p_assignment_default_rule_id in number,
  p_modify_flag           in varchar2
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
  p_position_assignment_id      in number
);
--
--
--
FUNCTION get_debug RETURN VARCHAR2;
--
END PSB_POSITION_ASSIGNMENTS_PVT ;

 

/
