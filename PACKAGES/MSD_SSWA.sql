--------------------------------------------------------
--  DDL for Package MSD_SSWA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_SSWA" AUTHID CURRENT_USER AS
/* $Header: msddspls.pls 115.9 2004/06/22 20:53:59 ziahmed ship $ */

  PROCEDURE display_plans;
  procedure render_header;
  function get_branding_html(p_show_buttons varchar2 default 'N') return varchar2;
  procedure show_batch_log(p_path varchar2,p_id number);
  function get_batch_log(p_id number) return clob;

END MSD_SSWA;

 

/
