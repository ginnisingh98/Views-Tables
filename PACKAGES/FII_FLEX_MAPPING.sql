--------------------------------------------------------
--  DDL for Package FII_FLEX_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_FLEX_MAPPING" AUTHID CURRENT_USER AS
/* $Header: FIICAFXS.pls 120.0 2002/08/24 04:49:55 appldev noship $ */

  /***********************************************************/
  /* function to retrieve segment value using cache          */
  /***********************************************************/
  function get_value     (p_ccid            in number,
                          p_set_of_books_id in varchar2,
                          p_structure_id    in number)
  return varchar2;


  /***********************************************************/
  /* get particular segment at a time                        */
  /***********************************************************/
  function get_fk	 (p_ccid            in number,
                          p_set_of_books_id in varchar2,
                          p_structure_id    in number,
			  p_seg_number	    in number)
  return varchar2;

  /***********************************************************/
  /* initialization procedure. must be run before            */
  /* get_value_mem function is used.
  /***********************************************************/

  procedure init_cache(p_fact_short_name VARCHAR2);


  /***********************************************************/
  /* function to drop the cache when it is no longer needed  */
  /***********************************************************/

  procedure free_mem_all;


  /***********************************************************/
  /* precompiler directives                                  */
  /***********************************************************/

  pragma restrict_references (get_value, WNDS);
  pragma restrict_references (get_fk, WNDS);

END FII_FLEX_MAPPING;

 

/
