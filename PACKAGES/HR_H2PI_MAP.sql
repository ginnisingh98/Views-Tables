--------------------------------------------------------
--  DDL for Package HR_H2PI_MAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_H2PI_MAP" AUTHID CURRENT_USER AS
/* $Header: hrh2pimp.pkh 115.1 2002/03/07 15:35:43 pkm ship     $ */

  PROCEDURE create_id_mapping (p_table_name  VARCHAR2,
                               p_from_id           NUMBER,
                               p_to_id             NUMBER);
  FUNCTION get_to_id (p_table_name   VARCHAR2,
                      p_from_id      NUMBER,
                      p_report_error BOOLEAN DEFAULT FALSE) RETURN NUMBER;

  FUNCTION get_from_id (p_table_name   VARCHAR2,
                        p_to_id        NUMBER,
                        p_report_error BOOLEAN DEFAULT FALSE) RETURN NUMBER;
--
--
END hr_h2pi_map;

 

/
