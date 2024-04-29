--------------------------------------------------------
--  DDL for Package OE_PARAMETERS_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PARAMETERS_DEF_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUPADS.pls 120.2 2005/10/20 00:21:55 ppnair noship $ */

-- Record for parameter definition
TYPE sys_param_def_rec_type IS RECORD
  (Parameter_Code          VARCHAR2(80) --<R12.MOAC>
  ,Name                    VARCHAR2(240)
  ,Description             VARCHAR2(2000)
  ,Creation_Date           DATE
  ,Created_By              NUMBER(15)
  ,Last_Update_Date        DATE
  ,Last_Updated_By         NUMBER(15)
  ,Last_Update_Login       NUMBER(15)
  ,Category_Code           VARCHAR2(30)
  ,Value_Set_Id            NUMBER
  ,Open_Orders_Check_Flag  VARCHAR2(1)
  ,Enabled_Flag            VARCHAR2(1)
  ,Seeded_Flag             VARCHAR2(1));


PROCEDURE Insert_Row(p_sys_param_def_rec IN OE_PARAMETERS_DEF_UTIL.sys_param_def_rec_type);

PROCEDURE Delete_Row(p_parameter_code IN VARCHAR2);

PROCEDURE Update_Row(p_sys_param_def_rec IN OE_PARAMETERS_DEF_UTIL.sys_param_def_rec_type);

PROCEDURE Lock_Row(p_parameter_code IN VARCHAR2);

PROCEDURE Translate_Row(p_parameter_code IN VARCHAR2,
                        p_name IN VARCHAR2,
                        p_description IN VARCHAR2,
                        p_updated_by  IN NUMBER,
                        p_update_login  IN NUMBER,
			p_custom_mode in varchar2 default null);

PROCEDURE Load_Row(p_parameter_code  IN VARCHAR2,
                   p_name            IN VARCHAR2,
                   p_description     IN VARCHAR2,
                   p_updated_by      IN NUMBER,
                   p_update_login    IN NUMBER,
                   p_category_code   IN VARCHAR2,
                   p_value_set       IN VARCHAR2,
                   p_open_orders_check_flag  IN VARCHAR2,
                   p_enabled_flag    IN VARCHAR2,
                   p_seeded_flag     IN VARCHAR2,
		   p_custom_mode in varchar2 default null);

PROCEDURE Add_Language;

END Oe_Parameters_Def_Util;

 

/
