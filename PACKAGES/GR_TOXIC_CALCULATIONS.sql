--------------------------------------------------------
--  DDL for Package GR_TOXIC_CALCULATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_TOXIC_CALCULATIONS" AUTHID CURRENT_USER AS
/* $Header: GRTXCALS.pls 115.1 2002/10/29 19:22:01 mgrosser noship $ */

/* This record type will contain the data that was used to calculate the
   product's toxicity value */
TYPE ingredient_values IS RECORD
  (  item_code            VARCHAR2(240),
     concentration_pct    NUMBER,
     weight_pct           NUMBER,
     toxic_species_code   GR_ITEM_TOXIC.toxic_species_code%TYPE,
     toxic_dose           NUMBER,
     toxic_uom            GR_ITEM_TOXIC.toxic_uom%TYPE  );



TYPE t_ingredient_values IS TABLE OF ingredient_values
             INDEX BY BINARY_INTEGER;



/* This function is used to derive the products toxic value from the
   ingredient values */
FUNCTION calculate_toxic_value (
         p_item_code IN  varchar2,        /* Item code of product */
         p_rollup_type IN  number,        /* The type of toxic calculation */
         p_label_code  IN varchar2,       /* The toxicity calculation label code */
         x_ingred_value_tbl OUT NOCOPY GR_TOXIC_CALCULATIONS.t_ingredient_values,
                                          /*  Table of values used in calculation */
         x_error_message OUT NOCOPY varchar2,    /* Error message */
         x_return_status OUT NOCOPY varchar2     /* 'S'uccess, 'E'rror, 'U'nexpected Error */
         )  RETURN number;


END gr_toxic_calculations;


 

/
