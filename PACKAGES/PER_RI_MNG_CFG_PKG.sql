--------------------------------------------------------
--  DDL for Package PER_RI_MNG_CFG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_MNG_CFG_PKG" AUTHID CURRENT_USER AS
/* $Header: perrimngcfg.pkh 120.0 2005/06/01 00:52:42 appldev noship $ */



PROCEDURE delete_configuration
(
	p_config_code 	 In Varchar2	,
	p_ovn		 In  Number	,
	p_msg 		 Out nocopy Varchar2
);


PROCEDURE duplicate_configuration
(
	p_config_code 	 In Varchar2	,
	p_config_name 	 In Varchar2	,
	p_config_desc	 In  Varchar2	,
	p_esn		 In Varchar2	,
	p_msg 		 Out nocopy Varchar2

);

end per_ri_mng_cfg_pkg;

 

/
