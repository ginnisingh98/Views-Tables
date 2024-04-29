--------------------------------------------------------
--  DDL for Package PER_RI_CONFIG_RESPON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CONFIG_RESPON_PKG" AUTHID CURRENT_USER AS
/* $Header: perriconresp.pkh 120.0 2005/06/01 01:03:10 appldev noship $ */
PROCEDURE load_configuration( p_responsibility_application  IN VARCHAR2
                             ,p_territory_code              IN VARCHAR2
                             ,p_responsibility_key          IN VARCHAR2
                             );

END per_ri_config_respon_pkg;

 

/
