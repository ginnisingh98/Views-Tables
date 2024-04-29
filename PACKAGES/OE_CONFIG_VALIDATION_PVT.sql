--------------------------------------------------------
--  DDL for Package OE_CONFIG_VALIDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CONFIG_VALIDATION_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVBOMS.pls 120.3 2005/07/01 06:37 abalan noship $ */

/*------------------------------------------------------------------
These globals are used to indicate the caller if the configuration
is valid and complete.
------------------------------------------------------------------*/
G_VALID_CONFIG       VARCHAR2(10) := 'TRUE';
G_COMPLETE_CONFIG    VARCHAR2(10) := 'TRUE';

/*------------------------------------------------------------------
These datatypes are used by the caller to provide the API with
all options of a configuration that needs to be validated.
------------------------------------------------------------------*/
TYPE BOM_VALIDATION_REC IS RECORD
( component_code        VARCHAR2(2000) := null,
  ordered_quantity      NUMBER         := null,
  ordered_item          VARCHAR2(4000) := null,
  bom_item_type         NUMBER         := null,
  sort_order            NUMBER         := null
);

TYPE VALIDATE_OPTIONS_TBL_TYPE IS TABLE OF BOM_VALIDATION_REC
INDEX BY BINARY_INTEGER;

/*------------------------------------------------------------------
This API performs follwoing checks,

1) if the ordered quantity of any option is not outside of
   the Min - Max quantity settings in BOM.
2) if the ratio of ordered quantity of a class to model
   and option to class is integer ratio i.e. exact multiple.
3) to see that a class does not exist w/o any options selected for it.
4) if a class that has mutually exclusive options, does not have
   more than one options selected under it.
5) if at least one option is selected per mandatory class.

-------------------------------------------------------------------*/

Procedure Bom_Based_Config_Validation
( p_top_model_line_id     IN                                  NUMBER
 ,p_options_tbl           IN                                  VALIDATE_OPTIONS_TBL_TYPE
 ,x_valid_config          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 ,x_complete_config       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 ,x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 );

END OE_CONFIG_VALIDATION_PVT;

 

/
