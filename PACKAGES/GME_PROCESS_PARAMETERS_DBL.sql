--------------------------------------------------------
--  DDL for Package GME_PROCESS_PARAMETERS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_PROCESS_PARAMETERS_DBL" AUTHID CURRENT_USER AS
   /* $Header: GMEVGPPS.pls 120.1 2005/06/03 13:45:53 appldev  $ */
   FUNCTION insert_row (
      p_process_parameters   IN              gme_process_parameters%ROWTYPE
     ,x_process_parameters   IN OUT NOCOPY   gme_process_parameters%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION fetch_row (
      p_process_parameters   IN              gme_process_parameters%ROWTYPE
     ,x_process_parameters   IN OUT NOCOPY   gme_process_parameters%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION delete_row (
      p_process_parameters   IN   gme_process_parameters%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION update_row (
      p_process_parameters   IN   gme_process_parameters%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION lock_row (p_process_parameters IN gme_process_parameters%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION delete_all (
      p_process_parameters   IN   gme_process_parameters%ROWTYPE)
      RETURN BOOLEAN;
END gme_process_parameters_dbl;

 

/
