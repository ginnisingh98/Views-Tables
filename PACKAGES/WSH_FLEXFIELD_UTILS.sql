--------------------------------------------------------
--  DDL for Package WSH_FLEXFIELD_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FLEXFIELD_UTILS" AUTHID CURRENT_USER as
/* $Header: WSHFFUTS.pls 120.0 2005/05/26 17:12:26 appldev noship $ */

/* Type FlexfieldAttributeTabType is a table of
   Varchar2(150).
*/

TYPE FlexfieldAttributeTabType IS TABLE OF VARCHAR2(150) index by binary_integer;
/* unique identifier of a dflexfield: */
/*TYPE dflex_r IS RECORD (application_id      fnd_application.application_id%TYPE,
                        flexfield_name      fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE);
*/
/* public */
/*This has been copied from fnd_dflex.dflex_dr, added the context_required field*/
TYPE dflex_dr IS RECORD (title              fnd_descriptive_flexs_vl.title%TYPE,
                         table_name         fnd_descriptive_flexs_vl.application_table_name%TYPE,
                         table_app          fnd_application.application_short_name%TYPE,
                         description        fnd_descriptive_flexs_vl.description%TYPE,
                         segment_delimeter  fnd_descriptive_flexs_vl.concatenated_segment_delimiter%TYPE,
                         default_context_field    fnd_descriptive_flexs_vl.default_context_field_name%TYPE,
                         default_context_value    fnd_descriptive_flexs_vl.default_context_value%TYPE,
                         protected_flag           fnd_descriptive_flexs_vl.protected_flag%TYPE,
                         form_context_prompt      fnd_descriptive_flexs_vl.form_context_prompt%TYPE,
                         context_column_name      fnd_descriptive_flexs_vl.context_column_name%TYPE,
                         context_required         fnd_descriptive_flexs_vl.context_required_flag%TYPE);

/*Function Cache_DFF_Segments
Function Cache_DFF_Segments  retrieves
and caches the given flexfield segments.
Currently accepts as input only wsh_new_deliveries.
Will be extended to add wsh_trips and wsh_trip_stops.
*/

FUNCTION Cache_DFF_Segments(p_table_name IN VARCHAR2,
                             x_return_status OUT NOCOPY  VARCHAR2) RETURN BINARY_INTEGER;



/* Procedure Get_DFF_Defaults retrieves
   the default context and segment values for
   the given flexfield.
   Currently accepts as input only wsh_new_deliveries.
   Will be extended to add wsh_trips and wsh_trip_stops.
*/

Procedure Get_DFF_Defaults
          (p_flexfield_name IN VARCHAR2,
           p_default_values OUT NOCOPY  FlexfieldAttributeTabType,
           p_default_context OUT NOCOPY  VARCHAR2,
           p_update_flag OUT NOCOPY  VARCHAR2,
           x_return_status OUT NOCOPY  VARCHAR2);

/*
 Procedure Write_DFF_Attributes
   populates the relevant table with the default context
   and attributes values for the flex field.
   Currently accepts as input only wsh_new_deliveries.
   Will be extended to add wsh_trips and wsh_trip_stops.
*/

PROCEDURE Write_DFF_Attributes(p_table_name IN VARCHAR2,
                               p_primary_id IN NUMBER,
                               x_return_status OUT NOCOPY  VARCHAR2);


/*
 Procedure Read_Table_Attributes
   Gets the attribute values from the relevant table.
   Currently accepts as input only wsh_new_deliveries.
   Will be extended to add wsh_trips and wsh_trip_stops.
*/
PROCEDURE Read_Table_Attributes(p_table_name IN VARCHAR2,
                               p_primary_id IN NUMBER,
                               p_attributes OUT NOCOPY  FlexfieldAttributeTabType,
                               p_context OUT NOCOPY  VARCHAR2,
                               x_return_status OUT NOCOPY  VARCHAR2);

/*
 Procedure Validate_DFF
   Checks whether the requied segments for the
   DFF is populated in the relevant table.
   Currently accepts as input only wsh_new_deliveries.
   Will be extended to add wsh_trips and wsh_trip_stops.
*/
PROCEDURE Validate_DFF(
                       p_table_name IN VARCHAR2,
                       p_primary_id IN NUMBER,
         	       x_return_status OUT NOCOPY  VARCHAR2);

/* returns information about the flexfield */
/***Comment out for now
PROCEDURE get_flexfield(appl_short_name  IN  fnd_application.application_short_name%TYPE,
                        flexfield_name   IN  fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
                        flexfield        OUT fnd_dflex.dflex_r,
                        flexinfo         OUT wsh_flexfield_utils.dflex_dr);
*/
END WSH_FLEXFIELD_UTILS;

 

/
