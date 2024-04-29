--------------------------------------------------------
--  DDL for Package Body PSB_POSITIONS_I2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_POSITIONS_I2_PVT" AS
/* $Header: PSBWPI2B.pls 120.2.12010000.4 2009/08/20 11:57:48 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_POSITIONS_I_PVT';
  G_DBUG              VARCHAR2(2000) := 'start';

PROCEDURE Validate_Salary (
	    p_api_version        in number,
	    p_init_msg_list      in varchar2 := fnd_api.g_false,
	    p_commit             in varchar2 := fnd_api.g_false,
	    p_validation_level   in number := fnd_api.g_valid_level_full,
	    p_return_status      OUT  NOCOPY varchar2,
	    p_msg_count          OUT  NOCOPY number,
	    p_msg_data           OUT  NOCOPY varchar2,
	    p_worksheet_id       in number,
	    p_position_id  IN NUMBER ,
	    p_effective_start_date IN DATE,
	    p_effective_end_date IN DATE,
	    p_pay_element_id IN NUMBER ,
	    p_data_extract_id IN NUMBER ,
	    p_rowid IN VARCHAR2
				    ) IS
     --
BEGIN

  PSB_POSITIONS_PVT.VALIDATE_SALARY   (
     p_api_version              => p_api_version,
     p_init_msg_list            => p_init_msg_list,
     p_commit                   => p_commit,
     p_validation_level         => p_validation_level,
     p_return_status            => p_return_status,
     p_msg_count                => p_msg_count,
     p_msg_data                 => p_msg_data,
     p_worksheet_id             => p_worksheet_id,
     p_position_id              => p_position_id,
     p_pay_element_id           => p_pay_element_id,
     p_data_extract_id          => p_data_extract_id,
     p_effective_start_date     => p_effective_start_date,
     p_effective_end_date       => p_effective_end_date,
     p_rowid                    => p_rowid   --bug:7507448:modified
     ) ;
     --
END Validate_Salary ;

/* ----------------------------------------------------------------------- */

END PSB_POSITIONS_I2_PVT;

/
