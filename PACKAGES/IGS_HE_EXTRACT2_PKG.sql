--------------------------------------------------------
--  DDL for Package IGS_HE_EXTRACT2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_EXTRACT2_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSHE9BS.pls 120.0 2005/06/01 20:20:34 appldev noship $ */

PROCEDURE process_temp_table
          (p_extract_run_id IN igs_he_ext_run_dtls.extract_run_id%TYPE,
           p_module_called_from     IN VARCHAR2,
           p_new_run_flag           IN VARCHAR2);

PROCEDURE get_map_values
           (p_he_code_map_val   IN     igs_he_code_map_val%ROWTYPE,
            p_value_from        IN     VARCHAR2,
            p_return_value      OUT NOCOPY igs_he_code_map_val.map1%TYPE);

END IGS_HE_EXTRACT2_PKG;

 

/
