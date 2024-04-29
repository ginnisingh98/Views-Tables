--------------------------------------------------------
--  DDL for Package HXT_RETRO_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_RETRO_PROCESS" AUTHID CURRENT_USER AS
/* $Header: hxtrprc.pkh 120.2 2007/01/05 18:08:56 nissharm noship $ */
g_user_id fnd_user.user_id%TYPE := FND_GLOBAL.User_Id; -- SPR C163 by BC

--
PROCEDURE Main_Retro (
  errbuf   	 OUT NOCOPY VARCHAR2,
  retcode  	 OUT NOCOPY NUMBER,
  p_payroll_id		IN	NUMBER,
  p_date_earned         IN      VARCHAR2,
  p_retro_batch_id      IN      NUMBER DEFAULT NULL,
  p_retro_batch_id_end  IN      NUMBER DEFAULT NULL,
  p_ref_num             IN      VARCHAR2 DEFAULT NULL,
  p_process_mode        IN      VARCHAR2,
  p_bus_group_id        IN      NUMBER,
  p_merge_flag		IN	VARCHAR2 DEFAULT '0',
  p_merge_batch_name	IN	VARCHAR2 DEFAULT NULL,
  p_merge_batch_specified IN	VARCHAR2 DEFAULT NULL);
--
END hxt_retro_process;

/
