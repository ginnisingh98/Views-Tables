--------------------------------------------------------
--  DDL for Package PSB_POSITIONS_I2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_POSITIONS_I2_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWPI2S.pls 120.2 2005/07/13 11:36:34 shtripat ship $ */

PROCEDURE Validate_Salary (
  p_api_version          in number,
  p_init_msg_list        in varchar2 := fnd_api.g_false,
  p_commit               in varchar2 := fnd_api.g_false,
  p_validation_level     in number   := fnd_api.g_valid_level_full,
  p_return_status        OUT  NOCOPY varchar2,
  p_msg_count            OUT  NOCOPY number,
  p_msg_data             OUT  NOCOPY varchar2,
  p_worksheet_id         in number,
  p_position_id          in number,
  p_effective_start_date in date,
  p_effective_end_date   in date,
  p_pay_element_id       in number,
  p_data_extract_id      in number,
  p_rowid                in varchar2 );
END PSB_POSITIONS_I2_PVT ;

 

/
